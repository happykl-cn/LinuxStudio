# LinuxStudio C++ 版本构建指南

## 🎯 快速开始

### 一键编译

```bash
# 1. 赋予执行权限
chmod +x build.sh

# 2. 编译
./build.sh

# 3. 测试
./build/bin/linuxstudio --version

# 4. 安装
cd build
sudo cmake --install .

# 5. 使用
linuxstudio status
```

---

## 📋 系统要求

### 必需依赖

| 软件 | 最低版本 | 安装命令 |
|------|---------|----------|
| GCC/G++ | 7.0+ | `sudo apt-get install build-essential` |
| CMake | 3.15+ | `sudo apt-get install cmake` |
| Make/Ninja | - | `sudo apt-get install ninja-build` |

### 可选依赖

| 软件 | 用途 |
|------|------|
| GDB | 调试 |
| Valgrind | 内存检查 |
| Doxygen | 文档生成 |

### 检查环境

```bash
# 检查 C++ 编译器
g++ --version

# 检查 CMake
cmake --version

# 检查 C++ 标准支持
g++ -std=c++17 --version
```

---

## 🏗️ 编译步骤

### 方法 1：使用脚本（推荐）

```bash
./build.sh
```

**输出示例**：
```
╔════════════════════════════════════════════════════╗
║     LinuxStudio C++ Build Script                  ║
╚════════════════════════════════════════════════════╝

Checking dependencies...
✓ Dependencies OK

Creating build directory...
Configuring project...
-- The CXX compiler identification is GNU 11.4.0
-- Configuring done
-- Generating done

Building project...
[ 10%] Building CXX object CMakeFiles/linuxstudio_core.dir/src/core/engine.cpp.o
[ 20%] Building CXX object CMakeFiles/linuxstudio_core.dir/src/utils/logger.cpp.o
...
[100%] Linking CXX executable bin/linuxstudio

╔════════════════════════════════════════════════════╗
║     Build Completed Successfully!                 ║
╚════════════════════════════════════════════════════╝

Binary location: /path/to/build/bin/linuxstudio
```

### 方法 2：手动编译

#### 步骤 1：创建构建目录

```bash
mkdir build
cd build
```

#### 步骤 2：配置项目

```bash
# Release 模式（优化性能）
cmake .. -DCMAKE_BUILD_TYPE=Release

# 或 Debug 模式（包含调试符号）
cmake .. -DCMAKE_BUILD_TYPE=Debug
```

**CMake 输出**：
```
-- LinuxStudio Build Configuration:
--   Version: 1.0.0
--   C++ Standard: 17
--   Build Type: Release
--   Compiler: GNU 11.4.0
```

#### 步骤 3：编译

```bash
# 使用所有 CPU 核心编译
cmake --build . -j$(nproc)

# 或指定核心数
cmake --build . -j4
```

#### 步骤 4：测试

```bash
# 查看版本
./bin/linuxstudio --version

# 查看帮助
./bin/linuxstudio --help

# 测试功能
./bin/linuxstudio status
```

#### 步骤 5：安装

```bash
# 安装到 /usr/local/bin
sudo cmake --install .

# 或指定安装路径
sudo cmake --install . --prefix /opt/linuxstudio
```

---

## 🔍 验证安装

### 检查二进制文件

```bash
# 查看文件类型
file /usr/local/bin/linuxstudio

# 输出（示例）：
# linuxstudio: ELF 64-bit LSB executable, x86-64, version 1 (GNU/Linux), 
# dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, 
# BuildID[sha1]=abc123..., stripped
```

### 查看依赖

```bash
ldd /usr/local/bin/linuxstudio

# 输出（示例）：
# linux-vdso.so.1 (0x00007fff...)
# libstdc++.so.6 => /usr/lib/x86_64-linux-gnu/libstdc++.so.6
# libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1
# libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6
# libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6
```

### 查看文件大小

```bash
ls -lh /usr/local/bin/linuxstudio

# 输出（示例）：
# -rwxr-xr-x 1 root root 2.3M Oct 27 10:30 /usr/local/bin/linuxstudio
```

### 测试功能

```bash
# 查看版本
linuxstudio version
# LinuxStudio Framework v1.0.0 (C++ Core)

# 查看状态
linuxstudio status

# 列出插件
linuxstudio plugin list
```

---

## 🚀 性能对比

### 启动速度

```bash
# Bash 版本
time bash bin/linuxstudio --version
# real    0m0.052s

# C++ 版本
time ./build/bin/linuxstudio --version
# real    0m0.005s

# 提升：10x 🚀
```

### 内存占用

```bash
# Bash 版本
/usr/bin/time -v bash bin/linuxstudio status
# Maximum resident set size (kbytes): 8192

# C++ 版本
/usr/bin/time -v ./build/bin/linuxstudio status
# Maximum resident set size (kbytes): 2048

# 减少：4x 🎉
```

---

## 🛠️ 编译选项

### 构建类型

```bash
# Release（默认，优化性能）
cmake .. -DCMAKE_BUILD_TYPE=Release

# Debug（包含调试符号）
cmake .. -DCMAKE_BUILD_TYPE=Debug

# RelWithDebInfo（发布+调试信息）
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo

# MinSizeRel（最小文件大小）
cmake .. -DCMAKE_BUILD_TYPE=MinSizeRel
```

### 自定义安装路径

```bash
cmake .. -DCMAKE_INSTALL_PREFIX=/opt/linuxstudio
```

### 启用详细输出

```bash
cmake .. -DCMAKE_VERBOSE_MAKEFILE=ON
```

### 使用 Ninja 构建系统

```bash
# 安装 Ninja
sudo apt-get install ninja-build

# 使用 Ninja
cmake .. -G Ninja
ninja
```

---

## 🧪 调试与测试

### GDB 调试

```bash
# Debug 模式编译
cmake .. -DCMAKE_BUILD_TYPE=Debug
cmake --build .

# 启动 GDB
gdb ./bin/linuxstudio

# GDB 命令
(gdb) run status                 # 运行程序
(gdb) break main                 # 在 main 设置断点
(gdb) break CoreEngine::initialize  # 在方法设置断点
(gdb) next                       # 单步执行
(gdb) print variable             # 打印变量
(gdb) backtrace                  # 查看调用栈
(gdb) quit                       # 退出
```

### Valgrind 内存检查

```bash
# 安装 Valgrind
sudo apt-get install valgrind

# 运行内存检查
valgrind --leak-check=full --show-leak-kinds=all ./bin/linuxstudio status

# 输出示例
==12345== HEAP SUMMARY:
==12345==     in use at exit: 0 bytes in 0 blocks
==12345==   total heap usage: 156 allocs, 156 frees, 89,234 bytes allocated
==12345== 
==12345== All heap blocks were freed -- no leaks are possible
```

### 性能分析

```bash
# 使用 perf
perf record ./bin/linuxstudio status
perf report

# 使用 gprof
cmake .. -DCMAKE_CXX_FLAGS="-pg"
cmake --build .
./bin/linuxstudio status
gprof ./bin/linuxstudio gmon.out > analysis.txt
```

---

## 📦 打包与分发

### 创建 Debian 包

```bash
# 安装工具
sudo apt-get install checkinstall

# 创建包
cd build
sudo checkinstall --pkgname=linuxstudio \
                  --pkgversion=1.0.0 \
                  --provides=linuxstudio \
                  cmake --install .

# 安装包
sudo dpkg -i linuxstudio_1.0.0-1_amd64.deb
```

### 创建 RPM 包

```bash
# 安装工具
sudo apt-get install rpm

# 创建包
# TODO: 添加 .spec 文件配置
```

### 静态链接（独立二进制）

```bash
# 静态链接 C++ 标准库
cmake .. -DCMAKE_CXX_FLAGS="-static-libstdc++ -static-libgcc"
cmake --build .

# 检查依赖（应该更少）
ldd ./bin/linuxstudio
```

---

## 🔧 常见问题

### Q1: 编译错误：C++17 特性不支持

**错误信息**：
```
error: 'filesystem' is not a member of 'std'
```

**解决方案**：
```bash
# 检查 GCC 版本
g++ --version

# GCC 7.0+ 支持 C++17
# 如果版本太低，升级 GCC
sudo apt-get install g++-9
export CXX=g++-9
```

### Q2: 链接错误：找不到 -lstdc++fs

**解决方案**：
```cmake
# 在 CMakeLists.txt 中添加
target_link_libraries(linuxstudio 
    stdc++fs  # C++17 filesystem 支持
)
```

### Q3: 运行时错误：Permission denied

**解决方案**：
```bash
# 需要 root 权限安装组件
sudo linuxstudio plugin install ros2
```

### Q4: CMake 版本太低

**错误信息**：
```
CMake Error: CMake 3.15 or higher is required.
```

**解决方案**：
```bash
# Ubuntu 18.04 默认 CMake 较旧，手动安装新版本
wget https://github.com/Kitware/CMake/releases/download/v3.25.0/cmake-3.25.0-linux-x86_64.sh
chmod +x cmake-3.25.0-linux-x86_64.sh
sudo ./cmake-3.25.0-linux-x86_64.sh --prefix=/usr/local --skip-license
```

---

## 📈 优化技巧

### 编译优化

```bash
# 最高优化级别 -O3
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-O3"

# 启用 LTO（链接时优化）
cmake .. -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON

# 特定 CPU 架构优化
cmake .. -DCMAKE_CXX_FLAGS="-march=native"
```

### 减小二进制大小

```bash
# 编译时优化大小
cmake .. -DCMAKE_BUILD_TYPE=MinSizeRel

# Strip 调试符号
strip --strip-all ./bin/linuxstudio

# 使用 UPX 压缩
sudo apt-get install upx
upx --best --lzma ./bin/linuxstudio
```

### 并行编译

```bash
# 使用所有 CPU 核心
cmake --build . -j$(nproc)

# 使用 Ninja（更快）
cmake .. -G Ninja
ninja -j$(nproc)
```

---

## 📚 相关文档

- [C++ 代码详解](CPP_CODE_DOCUMENTATION.md) - 详细的代码说明
- [开发路线图](DEVELOPMENT_ROADMAP.md) - Bash vs C++ 对比
- [CLI 使用指南](CLI_TOOL_GUIDE.md) - 命令行使用

---

## ✅ 检查清单

安装前检查：

- [ ] GCC/G++ 7.0+
- [ ] CMake 3.15+
- [ ] 足够的磁盘空间（100MB+）
- [ ] Root/sudo 权限

编译后检查：

- [ ] 二进制文件生成：`build/bin/linuxstudio`
- [ ] 文件类型正确：`file` 命令显示 ELF
- [ ] 版本显示正确：`--version` 输出版本号
- [ ] 功能正常：`status` 命令显示系统信息

安装后检查：

- [ ] 命令可用：`which linuxstudio`
- [ ] 全局可执行：`linuxstudio --version`
- [ ] 插件功能：`linuxstudio plugin list`

---

**恭喜！你已经成功编译了 C++ 版本的 LinuxStudio！** 🎉

**这是一个真正的 C++ 编译二进制文件，不是 Bash 脚本！** ⚡

