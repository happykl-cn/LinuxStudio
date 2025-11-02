# LinuxStudio Framework

<div align="center">

![LinuxStudio Logo](https://img.shields.io/badge/LinuxStudio-v1.1.0-blue?style=for-the-badge&logo=linux)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![C++](https://img.shields.io/badge/C++-17/20-orange?style=for-the-badge&logo=cplusplus)](https://isocpp.org/)

**高性能、模块化的 Linux 环境管理框架**

[快速开始](#快速开始) • [开发者指南](DEVELOPER_GUIDE.md) • [安装详解](INSTALLATION_GUIDE.md)

</div>

---

## 🌟 项目简介

**LinuxStudio** 是一个为开发者和运维人员设计的 Linux 环境管理框架，旨在简化系统配置、工具链管理和多服务器部署。

### 核心特性

- 🚀 **一键部署** - 像安装 Docker 一样简单
- 🎯 **场景驱动** - 9 大开发场景（Web、机器人、AI/ML 等）
- 🔧 **插件系统** - 丰富的插件生态（ROS2、OpenCV、PyTorch...）
- ⚡ **高性能** - C++ 核心引擎，启动速度提升 10x
- 📦 **系统集成** - 通过 apt/yum 安装，自动更新

---

## 📦 快速开始

### 方法 1：系统包管理器安装（推荐）

```bash
# 配置仓库
curl -fsSL https://packages.linuxstudio.org/setup.sh | sudo bash

# 安装
sudo apt-get install linuxstudio
```

### 方法 2：下载包直接安装

```bash
# Ubuntu/Debian
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.0.0_ubuntu-22.04_amd64.deb
sudo dpkg -i linuxstudio_*.deb

# CentOS/RHEL
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio-1.0.0-1.el7.x86_64.rpm
sudo rpm -ivh linuxstudio-*.rpm
```

### 方法 3：从源码编译

```bash
git clone https://github.com/happykl-cn/LinuxStudio.git
cd LinuxStudio
./build.sh
cd build
sudo cmake --install .
```

---

## 🎯 使用场景

### 1️⃣ Web 开发
```bash
xkl scene apply web-development
```
**组件**：Nginx, PHP, Java, Tomcat, MySQL, Redis, Node.js, ModSecurity(WAF), Prometheus

### 2️⃣ 嵌入式开发
```bash
xkl scene apply embedded
```
**组件**：ARM/RISC-V GCC, OpenOCD, GDB, Minicom, I2C/SPI Tools

### 3️⃣ 机器人与自动化
```bash
xkl scene apply robotics
```
**组件**：ROS2, MoveIt2, Gazebo, OpenCV, PCL, CAN Utils, 机械臂 SDK

### 4️⃣ AI/ML 开发
```bash
xkl scene apply ai-ml
```
**组件**：Python, Jupyter, TensorFlow, PyTorch, CUDA, OpenCV

### 5️⃣ 游戏开发
```bash
xkl scene apply game-dev
```
**组件**：SDL2, OpenGL, Vulkan, Godot, Unity, Blender

### 6️⃣ 云原生 / DevOps
```bash
xkl scene apply devops
```
**组件**：Docker, Kubernetes, Terraform, Jenkins, Prometheus, Grafana, ELK Stack

### 7️⃣ 网络安全
```bash
xkl scene apply security
```
**组件**：Nmap, Wireshark, Metasploit, Burp Suite, SQLMap

### 8️⃣ 区块链开发
```bash
xkl scene apply blockchain
```
**组件**：Hardhat, Web3.js, Solidity, IPFS, Geth

### 9️⃣ 物联网开发
```bash
xkl scene apply iot
```
**组件**：Mosquitto, Node-RED, InfluxDB, Grafana, Arduino CLI

---

## 🔧 核心命令

### 基础命令
```bash
xkl --version          # 查看版本
xkl status             # 系统状态
xkl --help             # 帮助信息
```

### 插件管理
```bash
xkl plugin list                # 列出所有插件
xkl plugin install ros2        # 安装 ROS2
xkl plugin install opencv      # 安装 OpenCV
xkl plugin uninstall ros2      # 卸载插件
```

### 组件管理
```bash
xkl component list             # 列出组件
xkl component install nginx    # 安装组件
xkl component update nginx     # 更新组件
```

### 场景管理
```bash
xkl scene list                 # 列出场景
xkl scene apply web            # 应用场景（交互式选择组件）
```

---

## 🏗️ 架构设计

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

---

## 🛠️ 技术栈

- **核心引擎**：C++17, CMake 3.15+
- **CLI 工具**：Bash 5.0+ / C++ (xkl)
- **打包**：DEB, RPM, AppImage
- **CI/CD**：GitHub Actions
- **支持平台**：Ubuntu, Debian, CentOS, Fedora, Arch Linux

---

## 📚 文档

- 📘 **[开发者指南](DEVELOPER_GUIDE.md)** - 完整开发、编译、打包、发布指南
- 📗 **[安装指南](INSTALLATION_GUIDE.md)** - 详细安装步骤和场景选择

---

## 🤝 贡献

### 开发流程

```bash
# 1. Fork 并克隆
git clone https://github.com/YOUR_USERNAME/LinuxStudio.git

# 2. 创建分支
git checkout -b feature/my-feature

# 3. 开发和测试
./build.sh
./build/bin/xkl --version

# 4. 提交
git commit -m "feat: add new feature"
git push origin feature/my-feature

# 5. 创建 Pull Request
```

### 代码规范

- 遵循 [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html)
- 使用 `clang-format` 格式化代码
- 编写单元测试

---

## 📊 项目状态

### 最新版本：v1.0.0

- ✅ C++ 核心引擎
- ✅ 9 大开发场景
- ✅ 插件管理系统
- ✅ DEB/RPM 打包
- ✅ GitHub Actions CI/CD
- 🚧 Web GUI（开发中）
- 📅 社区市场（计划中）

---

## ⚙️ 系统要求

### 运行环境
- **操作系统**：Ubuntu 18.04+, Debian 10+, CentOS 7+, Fedora 30+
- **内存**：1GB+（推荐 2GB+）
- **权限**：需要 root/sudo

### 编译环境（开发者）
- **平台**：Linux（推荐）或 WSL2
- **编译器**：GCC 7.0+ 或 Clang 6.0+
- **构建工具**：CMake 3.15+, Make/Ninja

> **Windows 用户**：推荐使用 WSL2（完整功能）或 Docker

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

## 🔗 相关链接

- **官网**：https://linuxstudio.org
- **文档**：https://docs.linuxstudio.org
- **GitHub**：https://github.com/happykl-cn/LinuxStudio
- **问题反馈**：https://github.com/happykl-cn/LinuxStudio/issues
- **社区**：https://community.linuxstudio.org

---

## 💬 联系我们

- **邮件**：support@linuxstudio.org
- **Discord**：[加入我们](https://discord.gg/linuxstudio)
- **微信公众号**：LinuxStudio

---

<div align="center">

**LinuxStudio - 让 Linux 环境管理更简单！** 🚀

Made with ❤️ by [Dino Studio](https://github.com/happykl-cn)

</div>
