# qima_llm: llama.cpp built for the CPU and linked into one shared library
# that Dart opens through FFI.
cmake_minimum_required(VERSION 3.28)
project(qima_llm_library VERSION 1.0.0 LANGUAGES C CXX)

include(FetchContent)

# llama.cpp's own sources, pinned. Set FETCHCONTENT_SOURCE_DIR_LLAMA to a
# checkout of the same tag to build without a download.
FetchContent_Declare(llama
  URL https://github.com/ggml-org/llama.cpp/archive/refs/tags/b12200.tar.gz
  URL_HASH SHA256=3ae917adc5894129427e67bfc6263b1b1b7f64dfb93c6fa4e425744544d7bc09
  DOWNLOAD_EXTRACT_TIMESTAMP TRUE
  # Built only as qima_llm needs it, and its install rules (its headers and
  # static libraries) kept out of the app; only qima_llm is shipped.
  EXCLUDE_FROM_ALL
)

# Only the library: no tools, tests, server, network or OpenMP, and code
# that runs on any x86-64 CPU with AVX2 rather than only on the build machine.
# Plain variables, so they reach llama.cpp's options without leaking into the
# rest of the app's build.
set(BUILD_SHARED_LIBS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(LLAMA_BUILD_COMMON OFF)
set(LLAMA_BUILD_TESTS OFF)
set(LLAMA_BUILD_TOOLS OFF)
set(LLAMA_BUILD_EXAMPLES OFF)
set(LLAMA_BUILD_SERVER OFF)
set(LLAMA_BUILD_APP OFF)
set(LLAMA_OPENSSL OFF)
set(LLAMA_ALL_WARNINGS OFF)
set(GGML_NATIVE OFF)
set(GGML_OPENMP OFF)
set(GGML_METAL OFF)
set(GGML_BLAS OFF)

# The Windows runner defines UNICODE for itself; llama.cpp calls the
# narrow Win32 functions.
remove_definitions(-DUNICODE -D_UNICODE)

FetchContent_MakeAvailable(llama)

add_library(qima_llm SHARED qima_llm.cpp)
target_compile_features(qima_llm PRIVATE cxx_std_17)
target_link_libraries(qima_llm PRIVATE llama)
set_target_properties(qima_llm PROPERTIES
  CXX_VISIBILITY_PRESET hidden
  OUTPUT_NAME "qima_llm"
)

# The CPU check, built without llama.cpp's instruction set so it is safe to
# load and call on a CPU that can't run qima_llm.
add_library(qima_cpu SHARED qima_cpu.c)
set_target_properties(qima_cpu PROPERTIES
  C_VISIBILITY_PRESET hidden
  OUTPUT_NAME "qima_cpu"
)
