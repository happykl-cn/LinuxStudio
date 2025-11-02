# LinuxStudio 开发者完全指南

## 📋 目录

- [快速开始](#快速开始)
- [编译安装](#编译安装)
- [命令使用](#命令使用)
- [C++ 开发](#cpp-开发)
- [打包发布](#打包发布)
- [项目结构](#项目结构)
- [常见问题](#常见问题)

---

## 快速开始

### 系统要求

#### 运行环境（用户）
- **操作系统**：Ubuntu 18.04+, Debian 10+, CentOS 7+, Fedora 30+
- **内存**：1GB+（推荐 2GB+）

#### 编译环境（开发者）⚠️

**推荐平台：Linux**

- **编译器**：GCC 7.0+ 或 Clang 6.0+
- **构建工具**：CMake 3.15+, Make
- **依赖库**：libstdc++, pthread

**Windows 用户**：
- ✅ 推荐使用 **WSL2**（完整功能）
- ⚠️ 或使用 **Docker** 容器
- ❌ 原生 Windows 编译支持有限

> **为什么？** LinuxStudio 使用了 Linux 特定的系统调用（如 `sysinfo()`），这些在 Windows 上不存在。代码已添加平台检测，可以在 Windows 上编译但功能受限。

### 一键安装（用户）

```bash
# 方法 1：配置仓库
curl -fsSL https://packages.linuxstudio.org/setup.sh | sudo bash
sudo apt-get install linuxstudio

# 方法 2：下载包
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.0.0_ubuntu-22.04_amd64.deb
sudo dpkg -i linuxstudio_*.deb
```

---

## 编译安装

### 方法 1：快速编译（推荐）

```bash
# 1. 克隆仓库
git clone https://github.com/happykl-cn/LinuxStudio.git
cd LinuxStudio

# 2. 一键编译
chmod +x build.sh
./build.sh

# 3. 测试
./build/bin/xkl --version

# 4. 安装
cd build
sudo cmake --install .
```

### 方法 2：手动编译

```bash
# 1. 创建构建目录
mkdir build && cd build

# 2. 配置
cmake .. -DCMAKE_BUILD_TYPE=Release

# 3. 编译
cmake --build . -j$(nproc)

# 4. 测试
./bin/xkl --version

# 5. 安装
sudo cmake --install .
```

### 安装后目录结构

```
/usr/bin/
├── xkl                    # 主命令（C++ 二进制）
└── linuxstudio -> xkl     # 符号链接（向后兼容）

/opt/linuxstudio/
├── plugins/               # 插件目录
├── components/            # 组件目录
├── data/                  # 数据文件
├── logs/                  # 日志
└── scenes/                # 场景配置

/etc/linuxstudio/
└── config.yaml            # 配置文件
```

---

## 命令使用

### 基础命令

```bash
xkl --version              # 查看版本
xkl status                 # 系统状态
xkl --help                 # 帮助信息
```

### 插件管理 ⭐

```bash
# 列出插件
xkl plugin list

# 安装插件
xkl plugin install ros2          # 机器人操作系统
xkl plugin install opencv        # 计算机视觉
xkl plugin install pytorch       # 深度学习

# 管理插件
xkl plugin enable ros2
xkl plugin disable ros2
xkl plugin uninstall ros2
```

### 可用插件列表

| 插件 | 说明 | 安装命令 |
|------|------|----------|
| ros2 | Robot Operating System 2 | `xkl plugin install ros2` |
| opencv | 计算机视觉 | `xkl plugin install opencv` |
| pytorch | PyTorch 深度学习 | `xkl plugin install pytorch` |
| tensorflow | TensorFlow 机器学习 | `xkl plugin install tensorflow` |
| cuda-toolkit | NVIDIA GPU 支持 | `xkl plugin install cuda-toolkit` |

### 场景管理

```bash
# 应用场景（交互式）
xkl scene apply robotics

# 系统会显示可选组件：
═══════════════════════════════════════════════════
  Robotics & Automation - Component Selection
═══════════════════════════════════════════════════

  1) ROS2 Humble - Robot Operating System 2
  2) MoveIt2 - Motion planning framework
  3) Gazebo - 3D robot simulator
  4) OpenCV - Computer vision library
  ...

  A) Install All (Recommended)
  0) Skip this scene

Enter your choices (e.g., 1 2 3 or A for all) [A]:
```

---

## C++ 开发

### 项目结构

```
LinuxStudio/
├── CMakeLists.txt              # CMake 配置
├── build.sh                    # 编译脚本
├── include/linuxstudio/        # 头文件
│   ├── core.hpp                # 核心引擎
│   ├── managers.hpp            # 管理器
│   └── logger.hpp              # 日志系统
├── src/                        # 源代码
│   ├── core/                   # 核心模块
│   │   ├── engine.cpp          # 核心引擎
│   │   ├── system_detector.cpp
│   │   └── config.cpp
│   ├── managers/               # 管理器
│   │   ├── component_manager.cpp
│   │   └── plugin_manager.cpp
│   ├── utils/                  # 工具
│   │   ├── logger.cpp
│   │   └── file_utils.cpp
│   └── cli/                    # CLI 接口
│       ├── main.cpp
│       ├── commands.cpp
│       └── cli_handler.cpp
└── build/                      # 构建目录
    └── bin/xkl                 # 编译后的二进制
```

### 核心类说明

#### CoreEngine - 核心引擎（单例）

```cpp
// 获取实例
auto& engine = CoreEngine::getInstance();

// 初始化
engine.initialize();

// 获取系统信息
const auto& sysInfo = engine.getSystemInfo();
std::cout << "OS: " << sysInfo.osName << "\n";
std::cout << "CPU Cores: " << sysInfo.cpuCores << "\n";
```

#### Logger - 日志系统

```cpp
auto& logger = engine.getLogger();

logger.info("Info message");      // ℹ️  Info message
logger.success("Success!");        // ✅ Success!
logger.warning("Warning");         // ⚠️  Warning
logger.error("Error occurred");    // ❌ Error occurred
```

#### PluginManager - 插件管理

```cpp
auto& pluginMgr = engine.getPluginManager();

// 安装插件
pluginMgr.install("ros2");

// 列出插件
auto plugins = pluginMgr.listInstalled();

// 启用/禁用
pluginMgr.enable("ros2");
pluginMgr.disable("opencv");
```

### 平台兼容性处理

#### 问题：Linux 特定头文件

```cpp
// ❌ 问题：这些头文件只在 Linux 上存在
#include <sys/sysinfo.h>   // Linux 特定
#include <sys/utsname.h>   // POSIX 特定
```

#### 解决方案：条件编译

```cpp
// ✅ 解决：使用平台检测
#ifdef __linux__
    #include <unistd.h>
    #include <sys/utsname.h>
    #include <sys/sysinfo.h>
#elif _WIN32
    #include <windows.h>
#else
    #error "Unsupported platform"
#endif

SystemInfo CoreEngine::detectSystem() {
    SystemInfo info;
    
#ifdef __linux__
    // Linux 实现（完整功能）
    struct utsname unameData;
    uname(&unameData);
    info.osName = unameData.sysname;
    info.cpuCores = sysconf(_SC_NPROCESSORS_ONLN);
    
#elif _WIN32
    // Windows 实现（有限功能）
    SYSTEM_INFO sysInfo;
    GetSystemInfo(&sysInfo);
    info.cpuCores = sysInfo.dwNumberOfProcessors;
    
#else
    // 未知平台
    info.osName = "Unknown";
#endif
    
    return info;
}
```

### 调试

```bash
# Debug 模式编译
cmake .. -DCMAKE_BUILD_TYPE=Debug
cmake --build .

# GDB 调试
gdb ./bin/xkl
(gdb) run status
(gdb) break CoreEngine::initialize

# Valgrind 内存检查
valgrind --leak-check=full ./bin/xkl status
```

---

## 打包发布

### 企业开发流程 🏢

在实际企业中，配置文件由不同角色负责：

| 文件类型 | 负责人 | 说明 |
|---------|--------|------|
| **C++ 源代码** | 软件工程师（你） | 核心业务逻辑 |
| **CMakeLists.txt** | 软件工程师 | 构建配置 |
| **packaging/** | DevOps 工程师 | 打包配置（一次性） |
| **GitHub Actions** | CI/CD 工程师 | 自动化流程（一次性） |

**你需要做的**：
- ✅ 写 C++ 代码
- ✅ 提交代码
- ✅ 创建 tag 触发发布

**DevOps 做的（一次性配置）**：
- ✅ 配置 `packaging/debian/control`
- ✅ 配置 `.github/workflows/release.yml`

**之后完全自动化**！

### 发布流程（3 步完成）

#### Step 1: 开发和测试

```bash
# 编写代码
vim src/core/engine.cpp

# 本地编译测试
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . -j$(nproc)
./bin/xkl --version

# 本地打包测试（可选）
cpack -G DEB
sudo dpkg -i *.deb
xkl --version
sudo dpkg -r linuxstudio
```

#### Step 2: 提交代码

```bash
git add .
git commit -m "feat: add new feature"
git push origin main
```

#### Step 3: 创建发布标签（触发自动化）

```bash
# 创建版本标签
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# 🎉 完成！GitHub Actions 会自动：
# 1. 在 7+ 个 Linux 发行版上编译
# 2. 打包成 .deb 和 .rpm
# 3. 运行测试
# 4. 创建 GitHub Release
# 5. 上传所有包文件
```

### 自动化流程

```
推送 tag: v1.0.0
    ↓
GitHub Actions 触发
    ↓
┌────────────────────────────────┐
│ 并行编译（多个容器同时运行）   │
│  ├─ Ubuntu 18.04  ✅           │
│  ├─ Ubuntu 20.04  ✅           │
│  ├─ Ubuntu 22.04  ✅           │
│  ├─ Debian 11     ✅           │
│  ├─ CentOS 7      ✅           │
│  └─ Rocky Linux 8 ✅           │
└────────────────────────────────┘
    ↓
打包
  ├─ linuxstudio_1.0.0_ubuntu22.04.deb
  ├─ linuxstudio-1.0.0-centos7.rpm
  └─ ...
    ↓
自动化测试
  ├─ 安装测试  ✅
  ├─ 命令测试  ✅
  └─ 卸载测试  ✅
    ↓
创建 GitHub Release
  └─ 上传所有包文件
    ↓
用户可以下载安装
```

### 本地打包测试

#### Debian 包

```bash
cd build

# 打包
cpack -G DEB

# 查看包内容
dpkg -c *.deb

# 安装测试
sudo dpkg -i *.deb

# 验证
xkl --version
ls -la /opt/linuxstudio

# 卸载
sudo dpkg -r linuxstudio

# 完全删除（包括配置）
sudo dpkg -P linuxstudio
```

#### RPM 包

```bash
cd build

# 打包
cpack -G RPM

# 查看包内容
rpm -qpl *.rpm

# 安装测试
sudo rpm -ivh *.rpm

# 卸载
sudo rpm -e linuxstudio
```

### 查看依赖（ldd）

```bash
ldd /usr/bin/xkl

# 输出示例：
# libstdc++.so.6  → C++ 标准库
# libgcc_s.so.1   → GCC 运行时
# libc.so.6       → C 标准库
# libm.so.6       → 数学库
```

**说明**：
- `libstdc++.so.6` - C++ 标准库（必需）
- `libc.so.6` - C 标准库（系统自带）
- `linux-vdso.so.1` - 虚拟动态共享对象（内核提供）

### 打包对比

| 方式 | 大小 | 兼容性 | 易用性 | 推荐场景 |
|------|------|--------|--------|----------|
| .deb | 2MB | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Ubuntu/Debian |
| .rpm | 2MB | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | RHEL/CentOS |
| AppImage | 4MB | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | 跨发行版 |
| 静态链接 | 25MB | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 最大兼容性 |

---

## 项目结构

### 完整目录树

```
LinuxStudio/
├── 📂 src/                      # C++ 源代码
│   ├── cli/                     # CLI 接口（3 个文件）
│   ├── core/                    # 核心引擎（3 个文件）
│   ├── managers/                # 管理器（2 个文件）
│   └── utils/                   # 工具（2 个文件）
│
├── 📂 include/linuxstudio/      # 头文件（3 个）
│
├── 📂 packaging/                # 打包配置（DevOps 配置）
│   ├── debian/                  # Debian/Ubuntu 打包
│   │   ├── control             # 包信息
│   │   ├── rules               # 构建规则
│   │   ├── postinst            # 安装后脚本
│   │   ├── prerm               # 卸载前脚本
│   │   ├── postrm              # 卸载后脚本
│   │   └── changelog           # 变更日志
│   ├── rpm/                     # RPM 打包
│   │   └── linuxstudio.spec    # RPM spec 文件
│   └── setup.sh                 # 仓库配置脚本
│
├── 📂 .github/workflows/        # CI/CD（DevOps 配置）
│   └── release.yml              # 自动化发布流程
│
├── 📂 tests/                    # 测试代码
│   ├── unit/                    # 单元测试
│   └── integration/             # 集成测试
│
├── 📂 bin/                      # Bash 版本 CLI
├── 📂 web/                      # Web 界面
│
├── CMakeLists.txt               # 构建配置
├── build.sh                     # 快速编译脚本
├── heaven.sh                    # Bash 安装脚本
│
├── 📄 README.md                 # 项目首页
├── 📄 DEVELOPER_GUIDE.md        # 本文件
└── 📄 INSTALLATION_GUIDE.md     # 安装指南
```

### 关键文件说明

| 文件 | 用途 | 负责人 |
|------|------|--------|
| `src/core/engine.cpp` | 核心引擎实现 | 软件工程师 |
| `CMakeLists.txt` | CMake 构建配置 | 软件工程师 |
| `packaging/debian/control` | Debian 包元数据 | DevOps 工程师 |
| `packaging/debian/postinst` | 安装后脚本 | DevOps 工程师 |
| `.github/workflows/release.yml` | CI/CD 流程 | CI/CD 工程师 |
| `packaging/setup.sh` | 仓库配置脚本 | DevOps 工程师 |

---

## 常见问题

### Q1: xkl 和 linuxstudio 有什么区别？

**A**: 完全相同，`xkl` 是新的短命令（推荐），`linuxstudio` 是旧命令（向后兼容）。

```bash
xkl status           # 推荐 ✅
linuxstudio status   # 也可以 ✅
```

### Q2: 为什么 C++ 代码在 Windows 上编译有警告？

**A**: LinuxStudio 是为 Linux 设计的，使用了 Linux 特定的系统调用。代码已添加平台检测：

```cpp
#ifdef __linux__
    // Linux 完整实现
#elif _WIN32
    // Windows 有限实现
    #pragma message("WARNING: Windows support is limited")
#endif
```

**推荐**：在 Windows 上使用 WSL2 获得完整功能。

### Q3: 如何在 WSL2 上开发？

```bash
# 1. 安装 WSL2
wsl --install -d Ubuntu-22.04

# 2. 进入 WSL2
wsl

# 3. 正常使用
git clone https://github.com/happykl-cn/LinuxStudio.git
cd LinuxStudio
./build.sh
```

### Q4: 编译错误：找不到 C++17

**A**: 升级 GCC 到 7.0+

```bash
sudo apt-get install g++-9
export CXX=g++-9
cmake .. -DCMAKE_CXX_COMPILER=g++-9
```

### Q5: 如何卸载？

```bash
# 如果是包管理器安装
sudo apt-get remove linuxstudio      # 保留配置
sudo apt-get purge linuxstudio       # 完全删除

# 如果是编译安装
sudo rm -f /usr/bin/xkl /usr/bin/linuxstudio
sudo rm -rf /opt/linuxstudio
sudo rm -rf /etc/linuxstudio
```

### Q6: 如何添加新插件？

```cpp
// 1. 在 managers.hpp 声明
bool installMyPlugin();

// 2. 在 plugin_manager.cpp 注册
installers_["my-plugin"] = [this]() { 
    return installMyPlugin(); 
};

// 3. 实现安装函数
bool PluginManager::installMyPlugin() {
    logger.info("Installing my plugin...");
    system("apt-get install -y my-package");
    return true;
}
```

### Q7: 谁负责编写 packaging/ 配置文件？

**A**: 在企业中通常由 **DevOps 工程师** 一次性配置，之后自动化运行。作为软件工程师，你只需要：

1. 写代码
2. 提交代码
3. 创建 tag

其余全自动！

---

## 性能对比

| 指标 | Bash 版本 | C++ 版本 | 提升 |
|------|----------|----------|------|
| 启动速度 | 50ms | 5ms | **10x** ⚡ |
| 内存占用 | 15MB | 3MB | **5x** 📉 |
| 文件大小 | 40KB | 2.5MB | - |
| 执行性能 | 解释执行 | 机器码 | **100x+** 🔥 |

---

## 技术栈

| 组件 | 技术 | 版本 |
|------|------|------|
| 核心引擎 | C++ | C++17 |
| 构建系统 | CMake | 3.15+ |
| 打包 | DEB/RPM | - |
| CI/CD | GitHub Actions | - |
| 日志系统 | 自研 | - |
| 安装脚本 | Bash | 5.0+ |

---

## 参与贡献

```bash
# 1. Fork 仓库
# 2. 创建分支
git checkout -b feature/my-feature

# 3. 提交
git commit -m "feat: add my-feature"
git push origin feature/my-feature

# 4. 创建 Pull Request
```

---

## 资源链接

- **文档**：https://docs.linuxstudio.org
- **社区**：https://community.linuxstudio.org
- **问题反馈**：https://github.com/happykl-cn/LinuxStudio/issues

---

**LinuxStudio - 专业的 Linux 环境管理工具！** 🚀

**命令：`xkl` - Extra Kool Linux!** ✨
