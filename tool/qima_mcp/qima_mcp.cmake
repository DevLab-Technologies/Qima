# Builds qima-mcp, Qima's read-only MCP helper for AI apps, and installs it
# beside the app (qima-mcp.exe next to qima.exe; qima-mcp in the Linux
# bundle). Included from windows/CMakeLists.txt and linux/CMakeLists.txt
# after CMAKE_INSTALL_PREFIX is set. `AiApps.helperPath` looks for it there.

# FLUTTER_ROOT is set inside the flutter/ subdirectory, which the parent
# scope can't see, so read the generated config again here.
include("${FLUTTER_MANAGED_DIR}/ephemeral/generated_config.cmake")

set(QIMA_REPO "${CMAKE_CURRENT_SOURCE_DIR}/..")
set(QIMA_MCP_PKG "${QIMA_REPO}/tool/qima_mcp")
if(WIN32)
  set(QIMA_MCP_NAME "qima-mcp.exe")
  set(QIMA_DART "${FLUTTER_ROOT}/bin/dart.bat")
else()
  set(QIMA_MCP_NAME "qima-mcp")
  set(QIMA_DART "${FLUTTER_ROOT}/bin/dart")
endif()
set(QIMA_MCP_OUT "${CMAKE_BINARY_DIR}/qima_mcp/${QIMA_MCP_NAME}")

file(STRINGS "${QIMA_REPO}/pubspec.yaml" QIMA_VERSION_LINE REGEX "^version:")
string(REGEX REPLACE "^version: *" "" QIMA_VERSION "${QIMA_VERSION_LINE}")
file(GLOB_RECURSE QIMA_MCP_SOURCES
  "${QIMA_REPO}/lib/mcp/*.dart"
  "${QIMA_REPO}/lib/models/*.dart"
  "${QIMA_MCP_PKG}/bin/*.dart")

add_custom_command(
  OUTPUT "${QIMA_MCP_OUT}"
  COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/qima_mcp"
  COMMAND "${QIMA_DART}" pub get
  COMMAND "${QIMA_DART}" compile exe bin/qima_mcp.dart "-DQIMA_VERSION=${QIMA_VERSION}"
          -o "${QIMA_MCP_OUT}" --verbosity=error
  WORKING_DIRECTORY "${QIMA_MCP_PKG}"
  DEPENDS ${QIMA_MCP_SOURCES} "${QIMA_MCP_PKG}/pubspec.yaml"
  COMMENT "Building qima-mcp"
  VERBATIM)
add_custom_target(qima_mcp ALL DEPENDS "${QIMA_MCP_OUT}")
add_dependencies(${BINARY_NAME} qima_mcp)
install(PROGRAMS "${QIMA_MCP_OUT}" DESTINATION "${CMAKE_INSTALL_PREFIX}" COMPONENT Runtime)
