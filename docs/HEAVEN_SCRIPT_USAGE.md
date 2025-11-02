# Heaven.sh 一键安装脚本使用指南

## 📋 概述

`heaven.sh` 是 LinuxStudio 的智能一键安装脚本，支持自动检测嵌入式系统并进行优化安装。

**版本**: v2.1.0  
**新增功能**: 嵌入式系统检测和优化

---

## 🚀 基本使用

### 标准安装（推荐）

```bash
# 交互式安装
curl -fsSL https://linuxstudio.org/heaven.sh | sudo bash

# 或下载后运行
wget https://linuxstudio.org/heaven.sh
chmod +x heaven.sh
sudo ./heaven.sh
```

### 非交互式安装

```bash
# 自动选择最佳安装方式
curl -fsSL https://linuxstudio.org/heaven.sh | sudo bash -s -- -y

# 或
sudo ./heaven.sh --yes
```

---

## 🎯 嵌入式系统支持

### 自动检测

脚本会自动检测以下嵌入式系统：

- **STM32MP1** 系列 (ATK-MP157, STM32MP135 等)
- **Raspberry Pi** 全系列 (Pi 1/2/3/4, Zero/Zero 2)
- **BeagleBone** (Black, AI 等)
- **通用 ARM32** 设备 (内存 < 2GB)
- **BusyBox** 环境

### 检测示例

```bash
🔍 Detecting system environment...

🎯 Detected embedded system: STM32MP1
📱 Memory: 869M
🏗️  Architecture: armv7l

This appears to be an embedded system. Would you like to:
  1) Use embedded-optimized installation (recommended)
  2) Use standard installation  
  3) Auto-detect (let script decide)

Please choose [1-3] (default: 1):
```

---

## ⚙️ 命令行选项

### 完整语法

```bash
./heaven.sh [OPTIONS]
```

### 可用选项

| 选项 | 说明 |
|------|------|
| `--embedded` | 强制使用嵌入式优化安装 |
| `--standard` | 强制使用标准安装 |
| `-y, --yes, --non-interactive` | 非交互模式（使用默认选项） |
| `--skip-detection` | 跳过嵌入式系统检测 |
| `-h, --help` | 显示帮助信息 |

### 使用示例

```bash
# 强制嵌入式安装（交互式）
sudo ./heaven.sh --embedded

# 强制嵌入式安装（非交互式）
sudo ./heaven.sh --embedded -y

# 强制标准安装
sudo ./heaven.sh --standard

# 跳过检测，直接标准安装
sudo ./heaven.sh --skip-detection

# 查看帮助
./heaven.sh --help
```

---

## 🔄 安装流程

### 标准系统流程

```
1. 系统检测 → 2. 包管理器安装 → 3. GitHub下载 → 4. 源码编译
```

### 嵌入式系统流程

```
1. 嵌入式检测 → 2. 包管理器安装 → 3. GitHub下载 → 4. 嵌入式手动安装 → 5. 源码编译
```

### 嵌入式优化安装详情

当选择嵌入式安装时，脚本会：

1. **下载 ARM32 包**
   ```bash
   📱 Method 3: Embedded system manual installation...
   Downloading linuxstudio_1.1.1_debian-11_armhf.deb...
   ```

2. **手动解压安装**
   ```bash
   🔧 Performing embedded-optimized manual installation...
   → Extracting package...
   → Installing files...
   → Creating directory structure...
   → Creating configuration...
   → Setting permissions...
   → Creating symbolic links...
   ```

3. **应用嵌入式优化**
   ```bash
   → Applying embedded system optimizations...
   → Applying low-memory optimizations (869MB detected)...
   → Initializing framework...
   ```

4. **优化配置**
   ```yaml
   # 自动生成的嵌入式配置
   version: 1.1.1
   install_path: /opt/linuxstudio
   log_level: warning          # 减少日志
   auto_update_check: false    # 禁用自动更新
   embedded_mode: true         # 嵌入式模式
   memory_optimization: true   # 内存优化
   minimal_logging: true       # 最小日志
   max_memory_usage: 64MB      # 内存限制（低内存时）
   cache_size: 8MB            # 缓存大小
   worker_threads: 1          # 单线程模式
   ```

---

## 📊 系统要求

### 标准安装

- **内存**: 512MB+
- **存储**: 100MB+
- **网络**: 需要（下载包）
- **权限**: root 或 sudo

### 嵌入式安装

- **内存**: 64MB+
- **存储**: 50MB+
- **网络**: 需要（下载包）
- **权限**: root
- **架构**: ARM32/ARM64

---

## 🎯 使用场景

### 场景 1: STM32MP1 开发板

```bash
# 在 STM32MP1 上安装
root@ATK-MP157:~# curl -fsSL https://linuxstudio.org/heaven.sh | bash

# 输出示例：
🎯 Detected embedded system: STM32MP1
📱 Memory: 869M
🏗️  Architecture: armv7l

# 选择嵌入式安装后：
🎉 LinuxStudio embedded installation completed!

📱 Embedded optimizations applied:
   • Reduced memory usage
   • Minimal logging  
   • Disabled auto-updates
   • Single-threaded mode (if low memory)
```

### 场景 2: Raspberry Pi

```bash
# 在树莓派上自动安装
pi@raspberrypi:~$ curl -fsSL https://linuxstudio.org/heaven.sh | sudo bash -s -- --embedded -y

# 自动检测为嵌入式系统并优化安装
```

### 场景 3: 标准服务器

```bash
# 在标准服务器上安装
user@server:~$ curl -fsSL https://linuxstudio.org/heaven.sh | sudo bash -s -- --standard -y

# 使用标准安装流程
```

### 场景 4: 开发环境

```bash
# 开发者手动控制安装方式
developer@workstation:~$ wget https://linuxstudio.org/heaven.sh
developer@workstation:~$ chmod +x heaven.sh
developer@workstation:~$ sudo ./heaven.sh --help
developer@workstation:~$ sudo ./heaven.sh --embedded  # 测试嵌入式模式
```

---

## 🔍 故障排除

### 常见问题

#### 1. 网络连接失败

```bash
[WARNING] Package installation failed, trying alternative method...
[WARNING] Direct download failed
```

**解决方案**：
- 检查网络连接
- 使用代理：`export https_proxy=http://proxy:port`
- 手动下载包后安装

#### 2. 权限不足

```bash
Please run as root (use sudo)
```

**解决方案**：
```bash
sudo ./heaven.sh
# 或
su -
./heaven.sh
```

#### 3. 嵌入式检测错误

```bash
# 强制使用嵌入式模式
sudo ./heaven.sh --embedded

# 或跳过检测
sudo ./heaven.sh --skip-detection --standard
```

#### 4. 包下载失败

```bash
[WARNING] Failed to download embedded package
```

**解决方案**：
- 检查 GitHub 连接
- 手动下载包：
  ```bash
  wget https://github.com/happykl-cn/LinuxStudio/releases/download/v1.1.1/linuxstudio_1.1.1_debian-11_armhf.deb
  sudo dpkg -i linuxstudio_*.deb
  ```

### 调试模式

```bash
# 启用详细输出
bash -x heaven.sh --embedded -y
```

---

## 📝 日志和验证

### 安装日志

脚本会显示详细的安装过程：

```bash
[INFO] Starting LinuxStudio installation...
[INFO] 🔍 Detecting system environment...
[INFO] 🎯 Detected embedded system: STM32MP1
[INFO] ✅ Using embedded-optimized installation
[INFO] Detected OS: ST OpenSTLinux
[INFO] 📦 Method 1: Installing from package repository...
[WARNING] Package installation failed, trying alternative method...
[INFO] 📦 Method 2: Downloading package from GitHub Releases...
[WARNING] Direct download failed
[INFO] 📱 Method 3: Embedded system manual installation...
[INFO] ✅ Package downloaded successfully
[INFO] 🔧 Performing embedded-optimized manual installation...
[INFO] → Extracting package...
[INFO] → Installing files...
[INFO] → Creating directory structure...
[INFO] → Creating configuration...
[INFO] → Setting permissions...
[INFO] → Creating symbolic links...
[INFO] → Applying embedded system optimizations...
[INFO] → Applying low-memory optimizations (869MB detected)...
[INFO] → Initializing framework...
[SUCCESS] 🎉 LinuxStudio embedded installation completed!
```

### 安装验证

```bash
# 检查版本
xkl --version
# 输出: LinuxStudio CLI v1.1.1 (C++ Core)

# 检查状态
xkl status
# 显示系统信息和嵌入式优化状态

# 检查配置
cat /etc/linuxstudio/config.yaml
# 查看嵌入式优化配置
```

---

## 🔗 相关文档

- [安装方式对比](INSTALLATION_METHODS_SUMMARY.md)
- [嵌入式兼容性指南](EMBEDDED_COMPATIBILITY.md)
- [安装流程对比](INSTALLATION_FLOW_COMPARISON.md)
- [升级指南](UPGRADE_GUIDE.md)

---

## 🆘 获取帮助

- **脚本帮助**: `./heaven.sh --help`
- **问题报告**: https://github.com/happykl-cn/LinuxStudio/issues
- **文档**: https://docs.linuxstudio.org
- **社区**: https://community.linuxstudio.org

---

**更新日期**: 2025-11-02  
**脚本版本**: v2.1.0  
**支持系统**: Ubuntu, Debian, CentOS, Rocky Linux, Fedora  
**支持架构**: x86_64, ARM64, ARM32  
**嵌入式支持**: STM32MP1, Raspberry Pi, BeagleBone, 通用 ARM32
