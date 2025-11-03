# LinuxStudio 安装指南

## 📋 目录

- [快速安装](#快速安装)
- [安装方式](#安装方式)
- [安装流程](#安装流程)
- [安装后使用](#安装后使用)
- [故障排除](#故障排除)

---

## 🚀 快速安装

### 一键安装（推荐）

```bash
# 英文版
curl -fsSL https://linuxstudio.org/heaven.sh | sudo bash

# 中文版
curl -fsSL https://linuxstudio.org/heaven-cn.sh | sudo bash

# 使用 wget
wget -qO- https://linuxstudio.org/heaven.sh | sudo bash
```

### 安装选项

```bash
# 非交互式安装（跳过所有确认）
curl -fsSL https://linuxstudio.org/heaven.sh | sudo bash -s -- -y

# 跳过场景选择
curl -fsSL https://linuxstudio.org/heaven.sh | sudo bash -s -- -s

# 组合使用（完全自动化）
curl -fsSL https://linuxstudio.org/heaven.sh | sudo bash -s -- -y -s

# 查看帮助
bash heaven.sh --help
```

---

## 📦 安装方式

### 方式 1: 一键安装脚本（推荐）

**适用场景**：
- ✅ 标准 Linux 系统（Ubuntu, Debian, CentOS, Fedora）
- ✅ 有网络连接
- ✅ 有 sudo 权限
- ✅ 希望自动配置和场景选择

**安装命令**：
```bash
# 使用 curl
curl -fsSL https://linuxstudio.org/heaven.sh | sudo bash

# 使用 wget
wget -qO- https://linuxstudio.org/heaven.sh | sudo bash

# 非交互式安装
curl -fsSL https://linuxstudio.org/heaven.sh | sudo bash -s -- -y -s
```

**特点**：
- 🎯 **最简单**: 一条命令完成所有配置
- 🔄 **自动检测**: 自动检测系统类型和架构
- 🎨 **场景选择**: 交互式选择开发场景
- 📦 **自动配置**: 自动安装推荐的插件和组件

### 方式 2: 包管理器安装

**适用场景**：
- ✅ 已配置 LinuxStudio 官方仓库
- ✅ 希望通过系统包管理器管理
- ✅ 需要自动更新

**Ubuntu/Debian**：
```bash
# 配置仓库（使用 GitHub）
curl -fsSL https://raw.githubusercontent.com/happykl-cn/LinuxStudio/main/packaging/setup.sh | sudo bash

# 安装
sudo apt update
sudo apt install linuxstudio

# 升级
sudo apt upgrade linuxstudio
```

**CentOS/RHEL/Rocky Linux**：
```bash
# 配置仓库
curl -fsSL https://raw.githubusercontent.com/happykl-cn/LinuxStudio/main/packaging/setup.sh | sudo bash

# 安装
sudo yum install linuxstudio
# 或
sudo dnf install linuxstudio

# 升级
sudo yum update linuxstudio
```

### 方式 3: 手动下载 DEB/RPM 包

**适用场景**：
- ✅ 离线安装
- ✅ 特定版本需求
- ✅ 不想配置仓库

**Ubuntu/Debian (DEB)**：
```bash
# x86_64
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.1_debian-11_amd64.deb
sudo dpkg -i linuxstudio_*.deb

# ARM64
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.1_ubuntu-22.04_arm64.deb
sudo dpkg -i linuxstudio_*.deb

# ARM32 (嵌入式设备)
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.1_debian-11_armhf.deb
sudo dpkg -i linuxstudio_*.deb
```

**CentOS/RHEL/Rocky Linux (RPM)**：
```bash
# x86_64
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio-1.1.1-1.rockylinux-8.x86_64.rpm
sudo rpm -ivh linuxstudio-*.rpm

# ARM64
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio-1.1.1-1.rockylinux-9.aarch64.rpm
sudo rpm -ivh linuxstudio-*.rpm
```

### 方式 4: 嵌入式设备手动安装

**适用场景**：
- ✅ 嵌入式 Linux 系统（STM32MP1, OpenSTLinux, BusyBox）
- ❌ 没有 sudo 命令
- ❌ 没有完整的包管理器
- ✅ 有 root 权限

**安装步骤**：
```bash
# 以 root 身份运行

# 1. 下载并解压包
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.1_debian-11_armhf.deb
ar x linuxstudio_1.1.1_debian-11_armhf.deb
tar -xzf data.tar.gz -C /

# 2. 创建目录结构
mkdir -p /opt/linuxstudio/plugins
mkdir -p /opt/linuxstudio/components
mkdir -p /opt/linuxstudio/data
mkdir -p /opt/linuxstudio/logs
mkdir -p /opt/linuxstudio/scenes
mkdir -p /etc/linuxstudio

# 3. 创建配置文件
cat > /etc/linuxstudio/config.yaml <<'EOF'
version: 1.1.1
install_path: /opt/linuxstudio
log_level: info
auto_update_check: false
embedded_mode: true
EOF

# 4. 设置权限和符号链接
chmod +x /usr/bin/xkl
ln -sf /usr/bin/xkl /usr/bin/linuxstudio

# 5. 验证安装
/usr/bin/xkl --version
/usr/bin/xkl status
```

**详细说明**：参见 [EMBEDDED.md](EMBEDDED.md)

### 方式 5: 从源码编译安装

**适用场景**：
- ✅ 开发者
- ✅ 自定义编译选项
- ✅ 不支持的架构

**编译安装**：
```bash
# 1. 克隆仓库
git clone https://github.com/happykl-cn/LinuxStudio.git
cd LinuxStudio

# 2. 安装依赖
# Ubuntu/Debian
sudo apt install build-essential cmake g++ git

# CentOS/RHEL
sudo yum install gcc-c++ cmake git make

# 3. 编译
./build.sh

# 4. 安装
cd build
sudo cmake --install .

# 5. 验证
xkl --version
```

---

## 🔄 安装流程

### 1. 系统检测

脚本自动检测：
- 操作系统类型和版本
- CPU 架构（x86_64, ARM64, ARM32）
- CPU 核心数
- 内存大小
- 网络位置（国内/国外）

### 2. 系统要求检查

- **最小内存**：1GB（推荐 2GB+）
- **支持的系统**：
  - Ubuntu / Debian / Linux Mint / Kali
  - Fedora / RHEL / CentOS / Rocky / AlmaLinux
  - Arch / Manjaro
  - openSUSE
  - OpenSTLinux / Yocto（嵌入式）

### 3. 系统优化

- **镜像源配置**：国内网络自动切换到阿里云镜像
- **Swap 配置**：如果没有 swap，自动创建 2GB swap 文件
- **SELinux**：自动禁用（CentOS/RHEL）
- **时区**：国内网络自动设置为 Asia/Shanghai
- **系统限制优化**

### 4. 安装必备组件

自动安装工具：
- `curl`, `wget` - 下载工具
- `git` - 版本控制
- `vim` - 文本编辑器
- `gcc` / `g++` / `make` - 编译工具
- `cmake` - 构建系统

### 5. 安装 LinuxStudio 核心

创建目录结构：
```
/opt/linuxstudio/
├── plugins/       # 插件目录
├── components/     # 组件目录
├── data/          # 数据目录
├── logs/          # 日志文件
└── scenes/        # 场景配置
```

### 6. 场景选择（交互式）

LinuxStudio 提供 9 大开发场景：

1. **web-development** - Web 开发（Nginx, PHP, Java, MySQL, Redis）
2. **embedded** - 嵌入式开发（ARM GCC, OpenOCD, GDB）
3. **robotics** - 机器人开发（ROS2, MoveIt2, Gazebo）
4. **ai-ml** - AI/ML 开发（Python, Jupyter, TensorFlow, PyTorch）
5. **game-dev** - 游戏开发（SDL2, OpenGL, Vulkan, Godot）
6. **devops** - DevOps（Docker, Kubernetes, Jenkins）
7. **security** - 网络安全（Nmap, Wireshark, Metasploit）
8. **blockchain** - 区块链开发（Hardhat, Solidity, Web3.js）
9. **iot** - 物联网开发（Mosquitto, Node-RED, InfluxDB）

**使用说明**：
- 输入数字（0-9）选择场景
- 选择 `A` 安装所有组件
- 输入数字列表（如 `1 2 3`）安装特定组件
- 输入 `0` 跳过场景选择

---

## 📚 安装后使用

### 检查安装状态

```bash
# 检查版本
xkl --version

# 检查状态
xkl status

# 查看帮助
xkl --help
```

### 组件管理

```bash
# 列出所有组件
xkl component list

# 安装组件
xkl component install nginx

# 卸载组件
xkl component uninstall nginx
```

### 插件管理

```bash
# 列出所有插件
xkl plugin list

# 安装插件
xkl plugin install ros2

# 启用/禁用插件
xkl plugin enable ros2
xkl plugin disable ros2
```

### 场景管理

```bash
# 列出预设场景
xkl scene list

# 应用场景
xkl scene apply embedded

# 查看场景包含的组件
xkl scene apply web-development
```

### 日志查看

```bash
# 查看日志文件
cat /opt/linuxstudio/logs/linuxstudio.log

# 实时查看日志
tail -f /opt/linuxstudio/logs/linuxstudio.log
```

---

## 🔧 故障排除

### 常见问题

**Q: 安装失败怎么办？**
- 检查日志文件：`/tmp/linuxstudio_install_*.log`
- 确保有 root/sudo 权限
- 确保网络连接正常
- 检查系统架构是否匹配

**Q: 支持哪些 Linux 发行版？**
- Ubuntu 18.04+, Debian 10+, CentOS 7+, Fedora 30+
- Arch Linux, openSUSE
- OpenSTLinux, Yocto（嵌入式）

**Q: 国内网络安装很慢怎么办？**
- 脚本会自动检测并切换到阿里云镜像源
- 启用并行下载加速
- 显示实时下载进度

**Q: SSL 证书验证失败（嵌入式系统）？**
- 脚本会自动处理 SSL 证书问题
- 使用 `-k` 参数跳过证书验证（自动）
- 参见 [EMBEDDED.md](EMBEDDED.md) 详细说明

**Q: 嵌入式系统安装失败？**
- 确保有 root 权限
- 检查依赖库（仅需 libc6 + libstdc++6）
- 参见 [EMBEDDED.md](EMBEDDED.md) 手动安装步骤

**Q: 如何卸载？**
```bash
# 卸载包
sudo apt remove linuxstudio  # Ubuntu/Debian
sudo yum remove linuxstudio  # CentOS/RHEL

# 手动清理
sudo rm -rf /opt/linuxstudio
sudo rm -f /usr/bin/xkl /usr/bin/linuxstudio
sudo rm -rf /etc/linuxstudio
```

### 获取帮助

- 📖 详细文档：https://github.com/happykl-cn/LinuxStudio
- 🔧 嵌入式问题：参见 [EMBEDDED.md](EMBEDDED.md)
- 🐛 问题报告：https://github.com/happykl-cn/LinuxStudio/issues
- 💬 社区支持：https://community.linuxstudio.org

---

**版本**: v1.1.1  
**更新日期**: 2025-11-02

