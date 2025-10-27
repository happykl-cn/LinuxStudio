cmake_minimum_required(VERSION 3.15)

project(LinuxStudio 
    VERSION 1.0.0
    DESCRIPTION "High-Performance Linux Environment Manager"
    LANGUAGES CXX
)

# C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# 编译选项
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wpedantic")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g -O0")

# 输出目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# 包含目录
include_directories(
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/src
)

# 查找依赖（可选）
find_package(Threads REQUIRED)

# 源文件
set(CORE_SOURCES
    src/core/engine.cpp
    src/core/system_detector.cpp
    src/core/config.cpp
    src/utils/logger.cpp
    src/utils/file_utils.cpp
    src/managers/component_manager.cpp
    src/managers/plugin_manager.cpp
)

# CLI 源文件
set(CLI_SOURCES
    src/cli/main.cpp
    src/cli/commands.cpp
    src/cli/cli_handler.cpp
)

# 创建核心库
add_library(linuxstudio_core STATIC ${CORE_SOURCES})
target_link_libraries(linuxstudio_core 
    Threads::Threads
)

# 创建可执行文件
add_executable(xkl ${CLI_SOURCES})
target_link_libraries(xkl 
    linuxstudio_core
    Threads::Threads
    stdc++fs  # C++17 filesystem support
)

# 安装规则
install(TARGETS xkl
    RUNTIME DESTINATION /usr/local/bin
)

# 创建符号链接 linuxstudio -> xkl（向后兼容）
install(CODE "execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink xkl linuxstudio WORKING_DIRECTORY \${CMAKE_INSTALL_PREFIX}/bin)")


install(DIRECTORY ${CMAKE_SOURCE_DIR}/include/
    DESTINATION /usr/local/include/linuxstudio
)

# 测试（可选）
enable_testing()
# add_subdirectory(tests)

# 打印配置信息
message(STATUS "LinuxStudio Build Configuration:")
message(STATUS "  Version: ${PROJECT_VERSION}")
message(STATUS "  C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "  Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  Compiler: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")

