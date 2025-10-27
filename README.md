# LinuxStudio Framework

<div align="center">

![LinuxStudio Logo](https://img.shields.io/badge/LinuxStudio-v1.0.0-blue?style=for-the-badge&logo=linux)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![C++](https://img.shields.io/badge/C++-17/20-orange?style=for-the-badge&logo=cplusplus)](https://isocpp.org/)
[![Bash](https://img.shields.io/badge/Bash-5.0+-yellow?style=for-the-badge&logo=gnu-bash)](https://www.gnu.org/software/bash/)

**高性能、模块化的 Linux 环境管理框架**

[快速开始](#快速开始) • [文档](https://docs.linuxstudio.org) • [社区](https://community.linuxstudio.org) • [贡献指南](#贡献)

</div>

---

## 🌟 项目简介

**LinuxStudio** 是一个为开发者和运维人员设计的 Linux 环境管理框架，旨在简化系统配置、工具链管理和多服务器部署。

### 核心特性

- 🚀 **一键部署** - `curl | bash` 即可启动交互式安装
- 🎯 **场景驱动** - 根据使用场景智能推荐组件（Web、嵌入式、AI/ML 等）
- 🔧 **模块化设计** - 核心框架 + 组件管理器 + 插件管理器
- ⚡ **高性能** - 核心框架基于 C++ 实现，追求极致性能
- 🌐 **多服务器支持** - 一个脚本可在多台服务器上并行部署
- 🎨 **友好界面** - CLI + Web GUI 双重管理界面

---

## 📦 快速开始

### 一键安装

```bash
curl -fsSL https://linuxstudio.org/heaven.sh | sudo bash
```

或使用 wget：

```bash
wget -qO- https://linuxstudio.org/heaven.sh | sudo bash
```

### 系统要求

- **操作系统**：Ubuntu 18.04+, Debian 10+, CentOS 7+, Fedora 30+, Arch Linux, openSUSE
- **内存**：至少 1GB（推荐 2GB+）
- **权限**：需要 root/sudo 权限

> **注意**：已取消磁盘空间强制检查，允许在任何容量下安装。

### 安装选项

```bash
# 非交互式安装
curl -fsSL https://linuxstudio.org/heaven.sh | sudo bash -s -- -y -s

# 查看帮助
bash heaven.sh --help
```

---

## 🎯 使用场景

LinuxStudio 提供 9 大专业开发场景，每个场景包含精选组件，支持自定义选择安装。

### 1️⃣ Web 开发

快速搭建全栈 Web 开发环境，支持 PHP、Java、Node.js

```bash
linuxstudio scene apply web-development
```

**可选组件**：Nginx, Apache, PHP, Java, Tomcat, Spring Boot, Maven, Gradle, MySQL, PostgreSQL, Redis, Node.js, Composer, Certbot, ModSecurity (WAF), Fail2Ban, ELK Stack, Prometheus, Grafana, Supervisor  
**推荐配置**：
- PHP 栈：Nginx + PHP + MySQL + Redis + Node.js
- Java 栈：Nginx + Java + Tomcat + MySQL + Redis
- 运维栈：ModSecurity + Fail2Ban + Prometheus + Grafana

---

### 2️⃣ 嵌入式系统开发

MCU/SoC 开发与交叉编译工具链

```bash
linuxstudio scene apply embedded-development
```

**可选组件**：ARM/RISC-V GCC, OpenOCD, GDB, Minicom, I2C/SPI Tools, ST-Link, Platform.io, Arduino CLI  
**推荐配置**：ARM GCC + OpenOCD + GDB + Minicom + I2C/SPI Tools

---

### 3️⃣ 机器人与自动化

机器人控制、ROS2、运动规划、机械臂开发

```bash
linuxstudio scene apply robotics
```

**可选组件**：ROS2, MoveIt2, Gazebo, RViz2, OpenCV, PCL, CAN Utils, Modbus, EtherCAT, Robot Arm SDK  
**推荐配置**：ROS2 + MoveIt2 + Gazebo + OpenCV + Robot Arm SDK  
**适用于**：机械臂控制、移动机器人、工业自动化、无人机

---

### 4️⃣ AI/ML 开发

深度学习、计算机视觉、数据科学

```bash
linuxstudio scene apply ai-ml
```

**可选组件**：Python3, Jupyter, NumPy, Pandas, Matplotlib, Scikit-learn, TensorFlow, PyTorch, OpenCV, CUDA  
**推荐配置**：Python3 + Jupyter + NumPy + Pandas + TensorFlow/PyTorch

---

### 5️⃣ 游戏开发

游戏引擎、图形库、资源工具

```bash
linuxstudio scene apply game-dev
```

**可选组件**：SDL2, OpenGL, GLFW, Vulkan, Godot, Unity, Unreal, Blender, Aseprite  
**推荐配置**：SDL2 + OpenGL + Godot/Unity + Blender

---

### 6️⃣ 云原生 / DevOps

容器编排、基础设施即代码、CI/CD、监控告警、日志聚合

```bash
linuxstudio scene apply devops
```

**可选组件**：Docker, Kubernetes, Helm, Terraform, Ansible, Jenkins, GitLab Runner, GitHub Actions, Prometheus, Grafana, Node Exporter, cAdvisor, Alertmanager, ELK Stack, Loki, Fluentd, Nginx, Traefik, HAProxy, Cron, Supervisor, Zabbix, Netdata, Portainer  
**推荐配置**：
- 容器栈：Docker + Kubernetes + Helm + Terraform
- 监控栈：Prometheus + Grafana + Node Exporter + Alertmanager
- 日志栈：ELK Stack / Loki + Promtail

---

### 7️⃣ 网络安全 / 渗透测试

安全审计、渗透测试、取证分析

```bash
linuxstudio scene apply security
```

**可选组件**：Nmap, Wireshark, Metasploit, Burp Suite, John the Ripper, Hashcat, SQLMap, OWASP ZAP  
**推荐配置**：Nmap + Wireshark + Metasploit + Burp Suite  
⚠️ **仅在授权系统上使用！**

---

### 8️⃣ 区块链开发

智能合约、DApp 开发、Web3 工具

```bash
linuxstudio scene apply blockchain
```

**可选组件**：Node.js, Hardhat, Truffle, Ganache, Web3.js, Solidity, Geth, IPFS, Solana  
**推荐配置**：Node.js + Hardhat + Web3.js + Solidity + IPFS

---

### 9️⃣ 物联网开发

IoT 平台、MQTT、边缘计算

```bash
linuxstudio scene apply iot
```

**可选组件**：Mosquitto, Node-RED, InfluxDB, Grafana, Arduino CLI, Platform.io, ESPHome  
**推荐配置**：Mosquitto + Node-RED + InfluxDB + Grafana

---

## 🔧 核心功能

### 组件管理

```bash
# 列出所有组件
linuxstudio component list

# 搜索组件
linuxstudio component search nginx

# 安装组件
linuxstudio component install nginx

# 卸载组件
linuxstudio component uninstall nginx

# 更新组件
linuxstudio component update nginx
```

### 插件管理

```bash
# 列出所有插件
linuxstudio plugin list

# 安装插件
linuxstudio plugin install ros2

# 卸载插件
linuxstudio plugin uninstall ros2

# 启用/禁用插件
linuxstudio plugin enable ros2
linuxstudio plugin disable ros2

# 配置插件
linuxstudio plugin config ros2
```

### 场景管理

```bash
# 列出预设场景
linuxstudio scene list

# 应用场景
linuxstudio scene apply web-development

# 创建自定义场景
linuxstudio scene create my-custom-scene
```

### 多服务器管理

```bash
# 添加远程服务器
linuxstudio remote add user@192.168.1.100

# 列出远程服务器
linuxstudio remote list

# 部署到远程服务器
linuxstudio remote deploy user@192.168.1.100 web-development

# 同步配置到所有服务器
linuxstudio remote sync
```

---

## 🏗️ 架构设计

```
┌─────────────────────────────────────────────────────────────┐
│                     LinuxStudio Framework                    │
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
│  │   CLI       │                  │   GUI Panel    │        │
│  │  Interface  │                  │   (Web-based)  │        │
│  └─────────────┘                  └────────────────┘        │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

详细架构设计请参考：[LinuxStudio_Architecture.md](LinuxStudio_Architecture.md)

---

## 📚 文档

- [安装指南](INSTALLATION_GUIDE.md) - 详细的安装步骤和说明
- [架构设计](LinuxStudio_Architecture.md) - 系统架构和技术设计
- [实现清单](heaven.txt) - 功能实现进度和待办事项
- [API 文档](https://docs.linuxstudio.org/api) - API 接口文档（即将推出）
- [用户手册](https://docs.linuxstudio.org/manual) - 完整用户手册（即将推出）

---

## 🛠️ 技术栈

### 核心框架
- **语言**：C++17/20
- **构建系统**：CMake + Ninja
- **包管理**：vcpkg
- **并发**：C++20 协程 + 线程池
- **日志**：spdlog
- **JSON 解析**：nlohmann/json
- **HTTP 客户端**：libcurl
- **SSH 客户端**：libssh2

### GUI 面板
- **后端**：Crow / Drogon (C++ Web Framework)
- **前端**：Vue.js 3 + TypeScript + Vite
- **UI 组件**：Element Plus
- **状态管理**：Pinia
- **通信**：Axios + WebSocket

### 测试
- **单元测试**：Google Test
- **性能测试**：Google Benchmark
- **CI/CD**：GitHub Actions

---

## 📊 项目状态

### 最新更新 v1.0.1 🎉

**性能优化版**（2025-10-26）：
- ✅ **实时进度显示** - 显示时间/大小/速度/状态
- ✅ **网络优化** - APT并行下载，智能缓存，超时控制
- ✅ **自动重试** - 失败自动重试2次，可跳过继续
- ✅ **Build Tools优化** - 显示gcc/g++/make位置
- ✅ **vcpkg优化** - 克隆进度百分比显示
- ✅ **命令行参数** - 支持-y/-s/--help/--version
- ✅ **Piped输入** - 支持curl | bash

### 已完成 ✅

- [x] 安装脚本 (heaven.sh) - 1483行
- [x] 系统检测和优化
- [x] 包管理器支持（APT/YUM/Pacman/Zypper）
- [x] 场景驱动安装
- [x] 日志系统
- [x] 交互式 CLI
- [x] 实时进度显示系统
- [x] 超时和重试机制

### 进行中 🚧

- [ ] C++ 核心引擎实现
- [ ] 组件和插件注册表
- [ ] Web GUI 面板
- [ ] 多服务器支持

### 计划中 📅

- [ ] 自定义组件/插件支持
- [ ] 版本更新机制
- [ ] 社区市场
- [ ] AI 智能推荐

详细进度请查看：[heaven.txt](heaven.txt)

---

## 🤝 贡献

我们欢迎所有形式的贡献！

### 如何贡献

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 代码规范

- 遵循 [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html)
- 使用 `clang-format` 格式化代码
- 所有公共 API 必须有文档注释
- 编写单元测试

### 贡献者

感谢所有贡献者！

<a href="https://github.com/happykl-cn/LinuxStudio/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=happykl-cn/LinuxStudio" />
</a>

---

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

---

## 🔗 相关链接

- **官网**：https://linuxstudio.org
- **文档**：https://docs.linuxstudio.org
- **社区**：https://community.linuxstudio.org
- **GitHub**：https://github.com/happykl-cn/LinuxStudio
- **问题反馈**：https://github.com/happykl-cn/LinuxStudio/issues

---

## 💬 联系我们

- **邮件**：support@linuxstudio.org
- **Discord**：[加入我们的 Discord](https://discord.gg/linuxstudio)
- **Twitter**：[@LinuxStudio](https://twitter.com/linuxstudio)
- **微信公众号**：LinuxStudio

---

## 🌟 Star History

[![Star History Chart](https://api.star-history.com/svg?repos=happykl-cn/LinuxStudio&type=Date)](https://star-history.com/#happykl-cn/LinuxStudio&Date)

---

## 📈 统计

![GitHub stars](https://img.shields.io/github/stars/happykl-cn/LinuxStudio?style=social)
![GitHub forks](https://img.shields.io/github/forks/happykl-cn/LinuxStudio?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/happykl-cn/LinuxStudio?style=social)

---

<div align="center">

**LinuxStudio - 让 Linux 环境管理更简单、更高效！** 🚀

Made with ❤️ by [Dino Studio](https://github.com/happykl-cn)

</div>


