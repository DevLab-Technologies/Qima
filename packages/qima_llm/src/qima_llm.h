#ifndef QIMA_LLM_H
#define QIMA_LLM_H

#ifdef _WIN32
#define QIMA_LLM_API __declspec(dllexport)
#else
#define QIMA_LLM_API __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

// A small language model in a GGUF file, run on the CPU by llama.cpp.
// One model per handle; a handle is asked from one thread at a time, and
// may be cancelled from any thread until it is closed.

// 1 when this CPU runs what qima_llm is built for, else 0. In its own
// library (qima_cpu), so it is safe to call on any CPU.
QIMA_LLM_API int qima_cpu_ok(void);

// Loads the model at [path] (UTF-8). Returns null when it can't be loaded.
QIMA_LLM_API void* qima_llm_open(const char* path, int threads);

// The model's answer to [user] after [system], in the model's own chat
// format, constrained by the GBNF [grammar] when it isn't empty, and at most
// [max_tokens] long. Returns null on failure or when question [id] was
// cancelled. Ids rise with each question. Free it with qima_llm_free_text.
QIMA_LLM_API char* qima_llm_ask(void* handle, int id, const char* system, const char* user, const char* grammar,
                                int max_tokens);

// Stops question [id] and every earlier one, running or not yet started.
QIMA_LLM_API void qima_llm_cancel(void* handle, int id);

QIMA_LLM_API void qima_llm_free_text(char* text);

QIMA_LLM_API void qima_llm_close(void* handle);

#ifdef __cplusplus
}
#endif

#endif
