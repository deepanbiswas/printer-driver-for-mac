cmake_minimum_required(VERSION 3.20)
project(canon_g3010_driver VERSION 0.1.0 LANGUAGES C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Single predictable output dir so CTest and docs can refer to ${CMAKE_BINARY_DIR}/g3010_filter.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")

add_executable(g3010_filter filters/g3010_filter.c)
target_compile_options(g3010_filter PRIVATE -Wall -Wextra -Wpedantic)

enable_testing()

add_test(
  NAME stub_filter_exits_zero
  COMMAND "${CMAKE_SOURCE_DIR}/tests/stub_filter_integration.sh" "$<TARGET_FILE:g3010_filter>"
)

install(TARGETS g3010_filter RUNTIME DESTINATION libexec/cups/filter)
install(FILES ppd/Canon-G3010.ppd DESTINATION share/cups/model)
