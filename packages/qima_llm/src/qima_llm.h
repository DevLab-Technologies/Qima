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
// One model per handle; a handle is used from one thread at a time.

// Loads the model at [path] (UTF-8). Returns null when it can't be loaded.
QIMA_LLM_API void* qima_llm_open(const char* path, int threads);

// The model's answer to [user] after [system], in the model's own chat
// format, constrained by the GBNF [grammar] when it isn't empty, and at most
// [max_tokens] long. Returns null on failure. Free it with qima_llm_free_text.
QIMA_LLM_API char* qima_llm_ask(void* handle, const char* system, const char* user, const char* grammar, int max_tokens);

QIMA_LLM_API void qima_llm_free_text(char* text);

QIMA_LLM_API void qima_llm_close(void* handle);

#ifdef __cplusplus
}
#endif

#endif
