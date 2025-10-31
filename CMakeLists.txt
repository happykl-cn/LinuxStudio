cmake_minimum_required(VERSION 3.10)

project(LinuxStudio 
    VERSION 1.0.0
    DESCRIPTION "High-Performance Linux Environment Manager"
    LANGUAGES CXX
)

# ========== 平台检测 ==========
if(UNIX AND NOT APPLE)
    message(STATUS "✅ Platform: Linux (Recommended)")
    set(PLATFORM_LINUX TRUE)
elseif(WIN32)
    message(WARNING "⚠️  Platform: Windows (Limited Support)")
    message(WARNING "   LinuxStudio is designed for Linux.")
    message(WARNING "   Some features may not work correctly on Windows.")
    message(WARNING "   Consider using WSL2 for full functionality.")
    set(PLATFORM_WINDOWS TRUE)
elseif(APPLE)
    message(WARNING "⚠️  Platform: macOS (Experimental)")
    message(WARNING "   LinuxStudio is designed for Linux.")
    set(PLATFORM_MACOS TRUE)
else()
    message(FATAL_ERROR "❌ Unsupported platform")
endif()

# ========== 架构检测 ==========
if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm64|aarch64" OR CMAKE_SYSTEM_PROCESSOR MATCHES "^aarch64" OR CMAKE_SYSTEM_PROCESSOR MATCHES "^arm64")
    message(STATUS "🏗️  Architecture: ARM64 (aarch64)")
    set(TARGET_ARCH_ARM64 TRUE)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "arm" OR CMAKE_SYSTEM_PROCESSOR MATCHES "^arm")
    message(STATUS "🏗️  Architecture: ARM (32-bit)")
    set(TARGET_ARCH_ARM32 TRUE)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|AMD64")
    message(STATUS "🏗️  Architecture: x86_64 (amd64)")
    set(TARGET_ARCH_X86_64 TRUE)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "i[3-6]86" OR CMAKE_SYSTEM_PROCESSOR MATCHES "^i386")
    message(STATUS "🏗️  Architecture: x86 (32-bit)")
    set(TARGET_ARCH_X86 TRUE)
else()
    message(STATUS "🏗️  Architecture: ${CMAKE_SYSTEM_PROCESSOR} (detected)")
endif()

# C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# 编译选项
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wpedantic")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g -O0")
elseif(MSVC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /O2")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /Od /Zi")
endif()

# 输出目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# 包含目录
include_directories(
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/src
)

# 查找依赖
find_package(Threads REQUIRED)

# 检查 C++17 filesystem 支持
include(CheckCXXSourceCompiles)
check_cxx_source_compiles("
    #include <filesystem>
    int main() { std::filesystem::path p; return 0; }
" HAVE_FILESYSTEM_WITHOUT_LIB)

if(NOT HAVE_FILESYSTEM_WITHOUT_LIB)
    set(NEED_FILESYSTEM_LIB TRUE)
endif()

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

# 平台特定的链接库
target_link_libraries(xkl 
    linuxstudio_core
    Threads::Threads
)

# 如果需要显式链接 filesystem 库
if(NEED_FILESYSTEM_LIB AND PLATFORM_LINUX)
    target_link_libraries(xkl stdc++fs)
endif()

# 安装规则
install(TARGETS xkl
    RUNTIME DESTINATION bin
)

# 创建符号链接 linuxstudio -> xkl（向后兼容）
install(CODE "
    set(SYMLINK_PATH \"\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/bin/linuxstudio\")
    set(TARGET_PATH \"xkl\")
    if(NOT EXISTS \"\${SYMLINK_PATH}\")
        execute_process(
            COMMAND \${CMAKE_COMMAND} -E create_symlink \${TARGET_PATH} \${SYMLINK_PATH}
        )
    endif()
")

install(DIRECTORY ${CMAKE_SOURCE_DIR}/include/
    DESTINATION include/linuxstudio
)

# 创建运行时目录结构
install(DIRECTORY DESTINATION /opt/linuxstudio/plugins)
install(DIRECTORY DESTINATION /opt/linuxstudio/components)
install(DIRECTORY DESTINATION /opt/linuxstudio/data)
install(DIRECTORY DESTINATION /opt/linuxstudio/logs)
install(DIRECTORY DESTINATION /opt/linuxstudio/scenes)

# 创建配置目录
install(DIRECTORY DESTINATION /etc/linuxstudio)

# 安装默认配置文件
install(CODE "
    set(CONFIG_FILE \"\$ENV{DESTDIR}/etc/linuxstudio/config.yaml\")
    if(NOT EXISTS \"\${CONFIG_FILE}\")
        file(WRITE \"\${CONFIG_FILE}\" \"# LinuxStudio Configuration
version: 1.0.0
install_path: /opt/linuxstudio
log_level: info
auto_update_check: true
\")
    endif()
")

# 测试（可选）
enable_testing()
# add_subdirectory(tests)

# ========== CPack 打包配置 ==========
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_PACKAGE_VENDOR "Dino Studio")
set(CPACK_PACKAGE_CONTACT "support@linuxstudio.org")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "High-Performance Linux Environment Manager")
set(CPACK_PACKAGE_DESCRIPTION "LinuxStudio is a framework for managing development environments, toolchains, and multi-server deployments.")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE")
set(CPACK_RESOURCE_FILE_README "${CMAKE_SOURCE_DIR}/README.md")

# DEB 包配置
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Dino Studio <support@linuxstudio.org>")
set(CPACK_DEBIAN_PACKAGE_SECTION "devel")
set(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "bash (>= 5.0)")
set(CPACK_DEBIAN_PACKAGE_HOMEPAGE "https://linuxstudio.org")

# RPM 包配置
set(CPACK_RPM_PACKAGE_GROUP "Development/Tools")
set(CPACK_RPM_PACKAGE_LICENSE "MIT")
set(CPACK_RPM_PACKAGE_URL "https://linuxstudio.org")
set(CPACK_RPM_PACKAGE_REQUIRES "bash >= 5.0")

# 包含 CPack
include(CPack)

# CPack 架构设置
if(TARGET_ARCH_ARM64)
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "arm64")
    set(CPACK_RPM_PACKAGE_ARCHITECTURE "aarch64")
elseif(TARGET_ARCH_ARM32)
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "armhf")
    set(CPACK_RPM_PACKAGE_ARCHITECTURE "armv7hl")
elseif(TARGET_ARCH_X86_64)
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "amd64")
    set(CPACK_RPM_PACKAGE_ARCHITECTURE "x86_64")
elseif(TARGET_ARCH_X86)
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "i386")
    set(CPACK_RPM_PACKAGE_ARCHITECTURE "i686")
else()
    # 自动检测
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm64|aarch64")
        set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "arm64")
        set(CPACK_RPM_PACKAGE_ARCHITECTURE "aarch64")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")
        set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "amd64")
        set(CPACK_RPM_PACKAGE_ARCHITECTURE "x86_64")
    endif()
endif()

# 打印配置信息
message(STATUS "LinuxStudio Build Configuration:")
message(STATUS "  Version: ${PROJECT_VERSION}")
message(STATUS "  C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "  Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  Compiler: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "  System Processor: ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "  DEB Architecture: ${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}")
message(STATUS "  RPM Architecture: ${CPACK_RPM_PACKAGE_ARCHITECTURE}")
message(STATUS "  Install Prefix: ${CMAKE_INSTALL_PREFIX}")

