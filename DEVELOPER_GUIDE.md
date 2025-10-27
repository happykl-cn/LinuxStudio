# LinuxStudio 开发者完全指南

## 📋 目录

- [快速开始](#快速开始)
- [安装部署](#安装部署)
- [命令使用](#命令使用)
- [C++ 开发](#cpp-开发)
- [打包分发](#打包分发)
- [架构设计](#架构设计)

---

## 快速开始

### 一键安装（推荐）

```bash
# Bash 版本（原型）
curl -fsSL https://linuxstudio.org/heaven.sh | sudo bash

# 或使用 wget
wget -qO- https://linuxstudio.org/heaven.sh | sudo bash
```

### 编译 C++ 版本

```bash
# 一键编译
chmod +x build.sh
./build.sh

# 测试
./build/bin/xkl --version

# 安装
cd build
sudo cmake --install .
```

### 系统要求

- **操作系统**：Ubuntu 18.04+, Debian 10+, CentOS 7+, Fedora 30+
- **内存**：1GB+（推荐 2GB+）
- **编译**：GCC 7.0+, CMake 3.15+

---

## 安装部署

### 方法 1：使用安装脚本

```bash
# 交互式安装
sudo bash heaven.sh

# 非交互式
sudo bash heaven.sh -y -s

# 查看选项
bash heaven.sh --help
```

### 方法 2：编译安装

```bash
# 1. 克隆仓库
git clone https://github.com/happykl-cn/LinuxStudio.git
cd LinuxStudio

# 2. 编译
./build.sh

# 3. 安装
cd build
sudo cmake --install .
```

### 安装后目录结构

```
/opt/linuxstudio/
├── bin/              # 可执行文件
├── config/           # 配置文件
├── data/             # 数据文件
├── plugins/          # 插件目录
├── components/       # 组件目录
└── logs/             # 日志文件

/usr/local/bin/
├── xkl               # 主命令（推荐）
└── linuxstudio       # 别名（向后兼容）
```

---

## 命令使用

### 基础命令

```bash
# 查看状态
xkl status

# 查看版本
xkl version

# 查看帮助
xkl help
```

### 插件管理 ⭐

```bash
# 列出插件
xkl plugin list

# 安装插件
xkl plugin install ros2          # 机器人操作系统
xkl plugin install robot-arm     # 机械臂控制
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
| robot-arm | 机械臂控制库 | `xkl plugin install robot-arm` |
| opencv | 计算机视觉 | `xkl plugin install opencv` |
| pytorch | PyTorch 深度学习 | `xkl plugin install pytorch` |
| tensorflow | TensorFlow 机器学习 | `xkl plugin install tensorflow` |
| cuda-toolkit | NVIDIA GPU 支持 | `xkl plugin install cuda-toolkit` |

### 组件管理

```bash
# 列出组件
xkl component list

# 安装组件
xkl component install nginx
xkl component install docker
xkl component install mysql-server
```

### 场景管理

LinuxStudio 提供 9 大开发场景，每个场景包含多个可选组件。

#### 可用场景

| 场景 | 命令 | 包含组件 |
|------|------|----------|
| Web 开发 | `xkl scene apply web-development` | Nginx, PHP, Java, MySQL, Redis, Node.js |
| 嵌入式开发 | `xkl scene apply embedded` | ARM GCC, OpenOCD, GDB, Minicom |
| 机器人开发 | `xkl scene apply robotics` | ROS2, MoveIt2, Gazebo, OpenCV |
| AI/ML 开发 | `xkl scene apply ai-ml` | Python, Jupyter, PyTorch, TensorFlow |
| 游戏开发 | `xkl scene apply game-dev` | SDL2, OpenGL, Vulkan, Godot |
| DevOps | `xkl scene apply devops` | Docker, K8s, Terraform, Ansible |
| 网络安全 | `xkl scene apply security` | Nmap, Wireshark, Metasploit |
| 区块链 | `xkl scene apply blockchain` | Hardhat, Web3.js, Solidity |
| 物联网 | `xkl scene apply iot` | Mosquitto, Node-RED, InfluxDB |

#### 场景安装示例

```bash
# 应用场景
xkl scene apply robotics

# 系统会显示可选组件
═══════════════════════════════════════════════════════════════
  Robotics & Automation - Component Selection
═══════════════════════════════════════════════════════════════

  1) ROS2 Humble - Robot Operating System 2
  2) MoveIt2 - Motion planning framework
  3) Gazebo - 3D robot simulator
  4) OpenCV - Computer vision library
  ...

  A) Install All (Recommended)
  0) Skip this scene

Enter your choices (e.g., 1 2 3 or A for all) [A]:
```

### 远程服务器管理

```bash
# 添加远程服务器
xkl remote add user@192.168.1.100

# 列出服务器
xkl remote list

# 部署到远程
xkl remote deploy user@server.com robotics
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
│   ├── managers/               # 管理器
│   ├── utils/                  # 工具
│   └── cli/                    # CLI 接口
└── build/                      # 构建目录
    └── bin/xkl                 # 编译后的二进制
```

### 编译步骤

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

### 设计模式

| 模式 | 应用 | 优势 |
|------|------|------|
| 单例模式 | CoreEngine | 全局唯一实例 |
| 策略模式 | 插件安装器 | 易于扩展 |
| 依赖注入 | 管理器 | 降低耦合 |

### 系统调用

```cpp
// 获取系统信息
struct utsname unameData;
uname(&unameData);  // 系统名称、架构

// 获取内存信息
struct sysinfo si;
sysinfo(&si);       // 内存、负载

// 获取 CPU 核心数
int cores = sysconf(_SC_NPROCESSORS_ONLN);
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

## 打包分发

### 查看依赖

```bash
# 查看动态库依赖
ldd /usr/local/bin/xkl

# 输出示例：
# libstdc++.so.6  → C++ 标准库
# libgcc_s.so.1   → GCC 运行时
# libc.so.6       → C 标准库
```

### 方法 1：Debian 包（.deb）

```bash
# 安装工具
sudo apt-get install checkinstall

# 编译并打包
cd build
sudo checkinstall \
    --pkgname=xkl \
    --pkgversion=1.0.0 \
    cmake --install .

# 使用
sudo dpkg -i xkl_1.0.0-1_amd64.deb
```

### 方法 2：RPM 包

```bash
# 创建 spec 文件
cat > xkl.spec <<EOF
Name:     xkl
Version:  1.0.0
Release:  1
Summary:  LinuxStudio CLI
License:  MIT
...
EOF

# 构建
rpmbuild -ba xkl.spec

# 使用
sudo rpm -ivh xkl-1.0.0-1.x86_64.rpm
```

### 方法 3：AppImage（跨发行版）

```bash
# 创建 AppDir
mkdir -p xkl.AppDir/usr/bin
cp build/bin/xkl xkl.AppDir/usr/bin/

# 创建 AppRun
cat > xkl.AppDir/AppRun <<'EOF'
#!/bin/bash
exec "${HERE}/usr/bin/xkl" "$@"
EOF

# 构建
appimagetool xkl.AppDir xkl-x86_64.AppImage

# 使用（无需安装）
./xkl-x86_64.AppImage --version
```

### 方法 4：静态链接（完全独立）

```bash
# 静态链接编译
cmake .. -DCMAKE_EXE_LINKER_FLAGS="-static"
cmake --build .

# 检查（无动态依赖）
ldd bin/xkl
# not a dynamic executable
```

### 打包对比

| 方式 | 大小 | 兼容性 | 易用性 | 推荐场景 |
|------|------|--------|--------|----------|
| .deb | 2MB | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Ubuntu/Debian |
| .rpm | 2MB | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | RHEL/CentOS |
| AppImage | 4MB | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | 跨发行版 |
| 静态链接 | 25MB | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 最大兼容性 |

---

## 架构设计

### 系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                   LinuxStudio Framework                      │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   Core      │  │  Component   │  │   Plugin     │       │
│  │   Engine    │  │   Manager    │  │   Manager    │       │
│  │   (C++)     │  │   (C++)      │  │   (C++)      │       │
│  └──────┬──────┘  └──────┬───────┘  └──────┬───────┘       │
│         │                │                  │                │
│         └────────────────┴──────────────────┘                │
│                          │                                   │
│         ┌────────────────┴────────────────┐                 │
│         │                                  │                 │
│  ┌──────▼──────┐                  ┌───────▼────────┐        │
│  │   CLI       │                  │   Web GUI      │        │
│  │  Interface  │                  │  (React/Vue)   │        │
│  └─────────────┘                  └────────────────┘        │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### 技术栈

| 组件 | 技术 | 版本 |
|------|------|------|
| 核心引擎 | C++ | C++17 |
| 构建系统 | CMake | 3.15+ |
| 日志系统 | 自研 | - |
| 安装脚本 | Bash | 5.0+ |
| Web 界面 | React | 规划中 |

### 性能对比

| 指标 | Bash 版本 | C++ 版本 | 提升 |
|------|----------|----------|------|
| 启动速度 | 50ms | 5ms | **10x** ⚡ |
| 内存占用 | 15MB | 3MB | **5x** 📉 |
| 文件大小 | 40KB | 2.5MB | - |
| 执行性能 | 解释执行 | 机器码 | **100x+** 🔥 |

### 开发路线

- ✅ **Phase 1**：Bash 原型（已完成）
- 🔄 **Phase 2**：C++ 核心重构（进行中）
- 📅 **Phase 3**：Web GUI + API Server（规划中）

---

## 常见问题

### Q1: xkl 和 linuxstudio 有什么区别？

**A**: 命令完全相同，`xkl` 是新的短命令（推荐），`linuxstudio` 是旧命令（向后兼容）。

```bash
xkl status           # 推荐 ✅
linuxstudio status   # 也可以 ✅
```

### Q2: 如何查看已安装的插件？

```bash
xkl plugin list
```

### Q3: 编译错误：找不到 C++17

**A**: 升级 GCC 到 7.0+

```bash
sudo apt-get install g++-9
export CXX=g++-9
```

### Q4: 运行时错误：Permission denied

**A**: 需要 root 权限

```bash
sudo xkl plugin install ros2
```

### Q5: 如何卸载？

```bash
# 卸载二进制
sudo rm -f /usr/local/bin/xkl
sudo rm -f /usr/local/bin/linuxstudio

# 删除数据
sudo rm -rf /opt/linuxstudio

# 如果是 .deb 包
sudo dpkg -r xkl
```

---

## 参与贡献

### 添加新插件

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

### 提交代码

```bash
# 1. Fork 仓库
# 2. 创建分支
git checkout -b feature/my-plugin

# 3. 提交
git commit -m "feat: add my-plugin support"

# 4. Push
git push origin feature/my-plugin

# 5. 创建 Pull Request
```

---

## 资源链接

- **文档**：https://docs.linuxstudio.org
- **社区**：https://community.linuxstudio.org
- **问题反馈**：https://github.com/happykl-cn/LinuxStudio/issues
- **官网**：https://linuxstudio.org

---

## 许可证

MIT License - Copyright (c) 2025 Dino Studio

---

**LinuxStudio - 让 Linux 环境管理更简单！** 🚀

**命令：`xkl` - Extra Kool Linux!** ✨

