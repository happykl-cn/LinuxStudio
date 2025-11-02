# LinuxStudio 安装方式完整总结

## 📋 概览

LinuxStudio v1.1.1 支持 **6 种不同的安装方式**，适应不同的系统环境和用户需求。

---

## 🚀 方法 1: 一键安装脚本（推荐）

### 适用场景
- ✅ 标准 Linux 系统（Ubuntu, Debian, CentOS, Fedora）
- ✅ 有网络连接
- ✅ 有 sudo 权限
- ✅ 希望自动配置和场景选择

### 安装命令
```bash
# 使用 curl
curl -fsSL https://linuxstudio.org/heaven.sh | sudo bash

# 使用 wget
wget -qO- https://linuxstudio.org/heaven.sh | sudo bash

# 非交互式安装
curl -fsSL https://linuxstudio.org/heaven.sh | sudo bash -s -- -y -s
```

### 特点
- 🎯 **最简单**: 一条命令完成所有配置
- 🔄 **自动检测**: 自动检测系统类型和架构
- 🎨 **场景选择**: 交互式选择开发场景
- 📦 **自动配置**: 自动安装推荐的插件和组件
- 🌐 **在线安装**: 总是获取最新版本

### 安装过程
1. 检测系统类型（Ubuntu/Debian/CentOS/Fedora）
2. 检测架构（x86_64/ARM64/ARM32）
3. 下载对应的包
4. 安装包
5. 场景选择（Web开发/AI/机器人等）
6. 安装推荐组件

---

## 📦 方法 2: 包管理器安装

### 适用场景
- ✅ 已配置 LinuxStudio 官方仓库
- ✅ 希望通过系统包管理器管理
- ✅ 需要自动更新

### Ubuntu/Debian
```bash
# 配置仓库
curl -fsSL https://packages.linuxstudio.org/setup.sh | sudo bash

# 安装
sudo apt update
sudo apt install linuxstudio

# 升级
sudo apt upgrade linuxstudio
```

### CentOS/RHEL/Rocky Linux
```bash
# 配置仓库
curl -fsSL https://packages.linuxstudio.org/setup.sh | sudo bash

# 安装
sudo yum install linuxstudio
# 或
sudo dnf install linuxstudio

# 升级
sudo yum update linuxstudio
```

### 特点
- 🔄 **自动更新**: 通过系统包管理器自动更新
- 🛡️ **签名验证**: 包签名验证，安全可靠
- 📋 **依赖管理**: 自动处理依赖关系
- 🗑️ **干净卸载**: 完整的卸载支持

---

## 💾 方法 3: 手动下载 DEB/RPM 包

### 适用场景
- ✅ 离线安装
- ✅ 特定版本需求
- ✅ 不想配置仓库
- ✅ 标准 Linux 系统

### Ubuntu/Debian (DEB)
```bash
# x86_64
wget https://github.com/happykl-cn/LinuxStudio/releases/download/v1.1.1/linuxstudio_1.1.1_debian-11_amd64.deb
sudo dpkg -i linuxstudio_*.deb

# ARM64
wget https://github.com/happykl-cn/LinuxStudio/releases/download/v1.1.1/linuxstudio_1.1.1_ubuntu-22.04_arm64.deb
sudo dpkg -i linuxstudio_*.deb

# ARM32 (嵌入式设备)
wget https://github.com/happykl-cn/LinuxStudio/releases/download/v1.1.1/linuxstudio_1.1.1_debian-11_armhf.deb
sudo dpkg -i linuxstudio_*.deb
```

### CentOS/RHEL/Rocky Linux (RPM)
```bash
# x86_64
wget https://github.com/happykl-cn/LinuxStudio/releases/download/v1.1.1/linuxstudio-1.1.1-1.rockylinux-8.x86_64.rpm
sudo rpm -ivh linuxstudio-*.rpm

# ARM64
wget https://github.com/happykl-cn/LinuxStudio/releases/download/v1.1.1/linuxstudio-1.1.1-1.rockylinux-9.aarch64.rpm
sudo rpm -ivh linuxstudio-*.rpm
```

### 特点
- 📱 **离线安装**: 不需要网络连接
- 🎯 **版本控制**: 可以安装特定版本
- 📦 **标准包**: 标准的 DEB/RPM 包格式
- 🔧 **依赖检查**: 安装时检查依赖

---

## 🔧 方法 4: 嵌入式设备手动安装（无 sudo）

### 适用场景
- ✅ 嵌入式 Linux 系统
- ❌ 没有 sudo 命令
- ❌ 没有完整的包管理器
- ✅ 有 root 权限
- 🎯 **专门针对**: STM32MP1, OpenSTLinux, BusyBox

### 安装步骤
```bash
# 以 root 身份运行

# 1. 下载并解压包
wget https://github.com/happykl-cn/LinuxStudio/releases/download/v1.1.1/linuxstudio_1.1.1_debian-11_armhf.deb
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
auto_update_check: true
EOF

# 4. 设置权限和符号链接
chmod +x /usr/bin/xkl
ln -sf /usr/bin/xkl /usr/bin/linuxstudio

# 5. 验证安装
xkl --version
```

### 特点
- 🏗️ **完全手动**: 完全控制安装过程
- 📱 **嵌入式优化**: 专门为嵌入式系统设计
- 🚫 **无依赖**: 不依赖包管理器
- ⚡ **最小化**: 仅安装必要文件

---

## 🛠️ 方法 5: 从源码编译安装

### 适用场景
- ✅ 开发者
- ✅ 自定义编译选项
- ✅ 不支持的架构
- ✅ 最新开发版本

### 编译安装
```bash
# 1. 克隆仓库
git clone https://github.com/happykl-cn/LinuxStudio.git
cd LinuxStudio

# 2. 切换到稳定版本
git checkout v1.1.1

# 3. 安装依赖
# Ubuntu/Debian
sudo apt install build-essential cmake g++ git

# CentOS/RHEL
sudo yum install gcc-c++ cmake git make

# 4. 编译
./build.sh

# 5. 安装
cd build
sudo cmake --install .

# 6. 验证
xkl --version
```

### 特点
- 🔧 **完全控制**: 自定义编译选项
- 🚀 **最新代码**: 可以使用开发版本
- 🎯 **架构支持**: 支持任何架构
- 📚 **学习价值**: 了解项目结构

---

## 🐳 方法 6: Docker 容器安装

### 适用场景
- ✅ 容器化环境
- ✅ 隔离安装
- ✅ 开发和测试
- ✅ CI/CD 流水线

### Docker 安装
```bash
# 1. 拉取镜像
docker pull linuxstudio/linuxstudio:1.1.1

# 2. 运行容器
docker run -it --name linuxstudio linuxstudio/linuxstudio:1.1.1

# 3. 在容器中使用
docker exec -it linuxstudio xkl status

# 4. 持久化数据
docker run -it -v /host/data:/opt/linuxstudio linuxstudio/linuxstudio:1.1.1
```

### 特点
- 🐳 **容器化**: 完全隔离的环境
- 🔄 **可重现**: 一致的运行环境
- 📦 **预配置**: 预装所有依赖
- 🚀 **快速部署**: 秒级启动

---

## 📊 安装方式对比

| 方式 | 难度 | 速度 | 适用场景 | 网络需求 | 权限需求 | 自动更新 |
|------|------|------|----------|----------|----------|----------|
| 一键脚本 | ⭐ | ⭐⭐⭐ | 标准系统 | 需要 | sudo | ✅ |
| 包管理器 | ⭐⭐ | ⭐⭐⭐ | 标准系统 | 需要 | sudo | ✅ |
| 手动包安装 | ⭐⭐ | ⭐⭐ | 离线安装 | 可选 | sudo | ❌ |
| 嵌入式手动 | ⭐⭐⭐ | ⭐⭐ | 嵌入式系统 | 可选 | root | ❌ |
| 源码编译 | ⭐⭐⭐⭐ | ⭐ | 开发者 | 需要 | sudo | ❌ |
| Docker | ⭐⭐ | ⭐⭐⭐ | 容器环境 | 需要 | docker | ❌ |

## 🎯 推荐选择

### 新用户（标准系统）
**推荐**: 方法 1 - 一键安装脚本
```bash
curl -fsSL https://linuxstudio.org/heaven.sh | sudo bash
```

### 嵌入式设备用户
**推荐**: 方法 4 - 嵌入式手动安装
```bash
# 下载 armhf 包并手动解压安装
```

### 企业用户
**推荐**: 方法 2 - 包管理器安装
```bash
# 配置仓库后使用 apt/yum 管理
```

### 开发者
**推荐**: 方法 5 - 源码编译
```bash
# 从 GitHub 克隆并编译
```

### 离线环境
**推荐**: 方法 3 - 手动包安装
```bash
# 预先下载 DEB/RPM 包
```

### 容器环境
**推荐**: 方法 6 - Docker 安装
```bash
# 使用官方 Docker 镜像
```

---

## 🔧 安装后验证

无论使用哪种安装方式，都可以通过以下命令验证：

```bash
# 检查版本
xkl --version
# 应显示: LinuxStudio CLI v1.1.1 (C++ Core)

# 检查状态
xkl status
# 应显示系统信息和框架状态

# 检查功能
xkl plugin list
xkl component list
xkl scene list
```

---

## 🆘 安装问题排查

### 常见问题
1. **权限不足**: 确保有 sudo 或 root 权限
2. **网络问题**: 检查网络连接和防火墙
3. **架构不匹配**: 确认下载了正确架构的包
4. **依赖缺失**: 在嵌入式系统上可能缺少某些库

### 获取帮助
- 📖 详细文档: [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)
- 🔧 故障排除: [EMBEDDED_COMPATIBILITY.md](EMBEDDED_COMPATIBILITY.md)
- 🐛 问题报告: https://github.com/happykl-cn/LinuxStudio/issues

---

**更新日期**: 2025-11-02  
**适用版本**: v1.1.1  
**支持架构**: x86_64, ARM64, ARM32
