#include "qima_llm.h"

#include <atomic>
#include <cstdlib>
#include <cstring>
#include <mutex>
#include <string>
#include <vector>

#include "llama.h"

namespace {

struct Model {
    llama_model* model = nullptr;
    llama_context* ctx = nullptr;
    const llama_vocab* vocab = nullptr;
    std::string chat_template;
    // The question being answered, and the last one cancelled.
    std::atomic<int> current{0};
    std::atomic<int> cancelled{-1};

    bool stopped() const { return current.load() <= cancelled.load(); }
};

// llama.cpp asks this between steps of a decode, so a cancel also stops
// reading a long prompt.
bool abort_asked(void* data) { return static_cast<const Model*>(data)->stopped(); }

constexpr int kContext = 2048;

void quiet(ggml_log_level, const char*, void*) {}

std::once_flag backend;

// [system] and [user] in the model's chat format, ready for its answer.
bool format(const Model& m, const char* system, const char* user, std::string& out) {
    llama_chat_message messages[] = {{"system", system}, {"user", user}};
    const char* tmpl = m.chat_template.empty() ? nullptr : m.chat_template.c_str();
    std::vector<char> buf(4096);
    int n = llama_chat_apply_template(tmpl, messages, 2, true, buf.data(), (int32_t)buf.size());
    if (n < 0) return false;
    if (n > (int)buf.size()) {
        buf.resize(n);
        n = llama_chat_apply_template(tmpl, messages, 2, true, buf.data(), (int32_t)buf.size());
        if (n < 0) return false;
    }
    out.assign(buf.data(), n);
    return true;
}

}  // namespace

extern "C" {

void* qima_llm_open(const char* path, int threads) {
    if (path == nullptr) return nullptr;
    std::call_once(backend, [] {
        llama_log_set(quiet, nullptr);
        llama_backend_init();
    });

    llama_model_params mp = llama_model_default_params();
    mp.n_gpu_layers = 0;
    llama_model* model = llama_model_load_from_file(path, mp);
    if (model == nullptr) return nullptr;

    auto* m = new Model();
    llama_context_params cp = llama_context_default_params();
    cp.n_ctx = kContext;
    cp.n_batch = kContext;
    if (threads > 0) {
        cp.n_threads = threads;
        cp.n_threads_batch = threads;
    }
    cp.abort_callback = abort_asked;
    cp.abort_callback_data = m;
    llama_context* ctx = llama_init_from_model(model, cp);
    if (ctx == nullptr) {
        llama_model_free(model);
        delete m;
        return nullptr;
    }

    m->model = model;
    m->ctx = ctx;
    m->vocab = llama_model_get_vocab(model);
    if (const char* t = llama_model_chat_template(model, nullptr)) m->chat_template = t;
    return m;
}

char* qima_llm_ask(void* handle, int id, const char* system, const char* user, const char* grammar, int max_tokens) {
    auto* m = static_cast<Model*>(handle);
    if (m == nullptr || system == nullptr || user == nullptr || max_tokens <= 0) return nullptr;
    m->current.store(id);
    if (m->stopped()) return nullptr;

    std::string prompt;
    if (!format(*m, system, user, prompt)) return nullptr;

    const int needed = -llama_tokenize(m->vocab, prompt.c_str(), (int32_t)prompt.size(), nullptr, 0, true, true);
    if (needed <= 0 || needed + max_tokens > kContext) return nullptr;
    std::vector<llama_token> tokens(needed);
    if (llama_tokenize(m->vocab, prompt.c_str(), (int32_t)prompt.size(), tokens.data(), needed, true, true) < 0) {
        return nullptr;
    }

    llama_memory_clear(llama_get_memory(m->ctx), true);

    llama_sampler* sampler = llama_sampler_chain_init(llama_sampler_chain_default_params());
    if (grammar != nullptr && grammar[0] != '\0') {
        llama_sampler* g = llama_sampler_init_grammar(m->vocab, grammar, "root");
        if (g == nullptr) {
            llama_sampler_free(sampler);
            return nullptr;
        }
        llama_sampler_chain_add(sampler, g);
    }
    llama_sampler_chain_add(sampler, llama_sampler_init_greedy());

    std::string answer;
    bool ok = llama_decode(m->ctx, llama_batch_get_one(tokens.data(), (int32_t)tokens.size())) == 0;
    for (int i = 0; ok && i < max_tokens; i++) {
        if (m->stopped()) {
            ok = false;
            break;
        }
        llama_token token = llama_sampler_sample(sampler, m->ctx, -1);
        if (llama_vocab_is_eog(m->vocab, token)) break;
        char piece[256];
        const int n = llama_token_to_piece(m->vocab, token, piece, sizeof(piece), 0, false);
        if (n < 0) {
            ok = false;
            break;
        }
        answer.append(piece, n);
        ok = llama_decode(m->ctx, llama_batch_get_one(&token, 1)) == 0;
    }
    llama_sampler_free(sampler);
    if (!ok) return nullptr;

    char* out = static_cast<char*>(std::malloc(answer.size() + 1));
    if (out == nullptr) return nullptr;
    std::memcpy(out, answer.data(), answer.size());
    out[answer.size()] = '\0';
    return out;
}

void qima_llm_cancel(void* handle, int id) {
    auto* m = static_cast<Model*>(handle);
    if (m == nullptr) return;
    int was = m->cancelled.load();
    while (was < id && !m->cancelled.compare_exchange_weak(was, id)) {
    }
}

void qima_llm_free_text(char* text) { std::free(text); }

void qima_llm_close(void* handle) {
    auto* m = static_cast<Model*>(handle);
    if (m == nullptr) return;
    llama_free(m->ctx);
    llama_model_free(m->model);
    delete m;
}

}  // extern "C"
