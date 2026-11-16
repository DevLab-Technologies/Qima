# The libraries Dart opens through FFI; Flutter copies them next to the app.
cmake_minimum_required(VERSION 3.14)
set(PROJECT_NAME "qima_llm")
project(${PROJECT_NAME} LANGUAGES C CXX)

add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../src" "${CMAKE_CURRENT_BINARY_DIR}/shared")

set(qima_llm_bundled_libraries
  $<TARGET_FILE:qima_llm>
  $<TARGET_FILE:qima_cpu>
  PARENT_SCOPE
)
