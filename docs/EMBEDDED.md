# LinuxStudio 嵌入式系统指南

## 📋 目录

- [概述](#概述)
- [兼容性特性](#兼容性特性)
- [安装方法](#安装方法)
- [SSL 证书问题](#ssl-证书问题)
- [性能优化](#性能优化)
- [支持的设备](#支持的设备)
- [故障排除](#故障排除)

---

## 📱 概述

LinuxStudio 已针对嵌入式 Linux 系统进行优化，可在资源受限的设备上运行，包括：
- **STM32MP1** 系列（ATK-MP157, STM32MP135 等）
- **Raspberry Pi** 全系列（1/2/3/4, Zero/Zero 2）
- **BeagleBone** (Black, AI 等)
- **OpenSTLinux** (Yocto 基础)
- **BusyBox** 最小化系统
- 其他基于 ARM32/ARM64 的嵌入式设备

---

## ✨ 兼容性特性

### 1. 最小化依赖

LinuxStudio 仅依赖最基本的系统库：
- `libc6` / `glibc` - C 标准库
- `libstdc++6` / `libstdc++` - C++ 标准库

**不再依赖：**
- ❌ `bash` - 使用 POSIX `sh` 替代
- ❌ `libatomic1` - 使用编译器内置原子操作
- ❌ `sudo` - 安装脚本可在无 sudo 环境运行

### 2. 灵活的安装脚本

`postinst` 脚本已优化为：
- 使用 `#!/bin/sh` 而非 `#!/bin/bash`
- 所有操作都有错误处理（`|| true`）
- 权限不足时优雅降级
- 兼容最小化的 BusyBox 环境

### 3. 条件链接 libatomic

CMake 构建系统会自动检测 `libatomic` 是否可用：
```cmake
find_library(LIBATOMIC_LIBRARY NAMES atomic libatomic.so.1 libatomic.a)
if(LIBATOMIC_LIBRARY)
    target_link_libraries(xkl ${LIBATOMIC_LIBRARY})
else()
    message(STATUS "libatomic not found, using built-in atomics")
endif()
```

---

## 🔧 安装方法

### 方法 1: 使用 dpkg（推荐）

适用于有包管理器的系统：

```bash
# 下载 .deb 包
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.1_debian-11_armhf.deb

# 以 root 身份安装
dpkg -i linuxstudio_1.1.1_debian-11_armhf.deb

# 如果提示依赖问题，尝试修复
apt-get install -f
```

### 方法 2: 手动安装（无包管理器）

适用于 STM32MP1, OpenSTLinux, BusyBox 等：

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
# LinuxStudio Configuration (Embedded Optimized)
version: 1.1.1
install_path: /opt/linuxstudio
log_level: info
auto_update_check: false
embedded_mode: true
memory_optimization: true
minimal_logging: true
EOF

# 4. 设置权限和符号链接
chmod +x /usr/bin/xkl
ln -sf /usr/bin/xkl /usr/bin/linuxstudio

# 5. 验证安装
/usr/bin/xkl --version
/usr/bin/xkl status
```

### 方法 3: 使用一键安装脚本

脚本会自动检测嵌入式系统：

```bash
# 中文版（支持 SSL 证书自动处理）
curl -fsSL https://linuxstudio.org/heaven-cn.sh | bash

# 如果遇到 SSL 证书问题，脚本会自动处理
# 或手动跳过证书验证
curl -fsSLk https://linuxstudio.org/heaven-cn.sh | bash
```

**脚本特性**：
- ✅ 自动检测嵌入式系统
- ✅ SSL 证书自动处理（使用 `-k` 参数）
- ✅ 架构自动识别（armv7l, armv6l → armhf）
- ✅ 支持 OpenSTLinux 和 Yocto 系统

---

## 🔒 SSL 证书问题

### 问题描述

在嵌入式系统上运行安装脚本时，可能会遇到 SSL 证书验证失败的错误：

```bash
curl: (60) server certificate verification failed. CAfile: /etc/ssl/certs/ca-certificates.crt
```

### 原因

嵌入式系统的常见问题：
1. **CA 证书不完整或过期** - 系统预装的 CA 证书可能不完整
2. **系统时间不正确** - SSL 证书验证依赖系统时间
3. **证书链缺失** - 缺少中间证书
4. **存储空间限制** - 无法安装完整的证书包

### 解决方案

#### 方案 1: 使用 -k 参数（推荐）

```bash
# 中文版
curl -fsSLk https://linuxstudio.org/heaven-cn.sh | bash

# 英文版
curl -fsSLk https://linuxstudio.org/heaven.sh | bash
```

**说明**：
- `-k` 或 `--insecure` 参数会跳过 SSL 证书验证
- 脚本内部已经实现了自动降级，会尝试使用 `-k` 参数

#### 方案 2: 手动下载脚本

如果网络有问题，可以先下载脚本再执行：

```bash
# 下载脚本（跳过证书验证）
curl -k -o /tmp/heaven-cn.sh https://linuxstudio.org/heaven-cn.sh

# 执行脚本
bash /tmp/heaven-cn.sh
```

#### 方案 3: 更新 CA 证书（如果可能）

如果系统允许，可以尝试更新 CA 证书：

```bash
# Debian/Ubuntu 系统
apt-get update && apt-get install -y ca-certificates

# 更新证书
update-ca-certificates
```

#### 方案 4: 检查系统时间

确保系统时间正确：

```bash
# 查看当前时间
date

# 如果时间不正确，设置正确时间（需要 root）
date -s "2024-01-01 12:00:00"
```

---

## ⚡ 性能优化

### ARM32 设备

LinuxStudio 针对 ARM32 架构进行了优化：

**ARMv7（如 STM32MP157）：**
- 启用 NEON SIMD 指令集
- 硬浮点 ABI（`-mfloat-abi=hard`）
- 优化编译标志（`-O2` 平衡性能和稳定性）

**ARMv6（如 Raspberry Pi 1）：**
- VFP 浮点支持
- 硬浮点 ABI
- 保守优化以确保兼容性

### 内存占用

- **二进制大小**：~500KB（stripped）
- **运行时内存**：~2-5MB
- **适合**：64MB+ RAM 的设备

---

## 🎯 支持的设备

### 完全测试

- ✅ Ubuntu 20.04/22.04 (armhf/arm64)
- ✅ Debian 11/12 (armhf/arm64)
- ✅ Raspberry Pi OS (32-bit/64-bit)
- ✅ STM32MP1 系列 (ATK-MP157, STM32MP135)
- ✅ BeagleBone (Black, AI)

### 理论兼容

- 🟡 OpenSTLinux (STM32MP1)
- 🟡 Yocto/Buildroot 自定义系统
- 🟡 OpenWrt (需要手动安装)

### 最小系统要求

- **CPU**: ARM32 (armv6+) 或 ARM64
- **内存**: 64MB+ RAM（推荐 128MB+）
- **存储**: 10MB 可用空间
- **系统**: Linux 内核 3.10+
- **依赖**: 仅需 libc6 + libstdc++6

---

## 🔍 故障排除

### 常见问题

**Q: 提示 "libatomic1 not found"**  
**A**: 新版本不再需要 `libatomic1`。请使用最新版本（v1.1.1+）。

**Q: postinst 脚本失败**  
**A**: 这通常是权限问题。尝试：
```bash
# 以 root 身份运行
su -
dpkg -i linuxstudio_*.deb
```

**Q: 系统没有 bash**  
**A**: 没问题！LinuxStudio 使用 POSIX `sh`，兼容 BusyBox 和其他最小化 shell。

**Q: 在 OpenSTLinux 上安装失败**  
**A**: OpenSTLinux 使用定制的软件源。建议使用"方法 2：手动安装"。

**Q: SSL 证书验证失败**  
**A**: 参见 [SSL 证书问题](#ssl-证书问题) 部分。

**Q: 未知架构: armv7l**  
**A**: 脚本会自动将 `armv7l` 和 `armv6l` 映射到 `armhf`。如果仍然失败，使用手动安装方法。

### 验证安装

```bash
# 检查版本
xkl --version

# 检查系统状态
xkl status

# 检查依赖（应该只有基本库）
ldd /usr/bin/xkl

# 查看帮助
xkl --help
```

### 启用详细日志

```bash
export LINUXSTUDIO_LOG_LEVEL=debug
xkl status
```

### 检查依赖

```bash
# 检查所需的动态库
ldd /usr/bin/xkl

# 应该只显示基本库：
# libc.so.6
# libstdc++.so.6
# libgcc_s.so.1
# libm.so.6
# libpthread.so.0

# 不应该出现：libatomic.so.1
```

### 报告问题

如果在嵌入式设备上遇到问题，请提供：
1. 设备型号和架构（`uname -a`）
2. 发行版信息（`cat /etc/os-release`）
3. 可用内存（`free -h`）
4. 错误日志（`/opt/linuxstudio/logs/linuxstudio.log`）

---

## 📚 相关文档

- [安装指南](INSTALLATION.md)
- [升级指南](UPGRADE.md)
- [版本更新日志](CHANGELOG.md)

---

## 💡 快速命令参考

```bash
# 查看帮助
xkl --help

# 检查系统状态
xkl status

# 列出场景
xkl scene list

# 应用嵌入式场景
xkl scene apply embedded

# 列出插件
xkl plugin list

# 列出组件
xkl component list

# 查看日志
cat /opt/linuxstudio/logs/linuxstudio.log
```

---

**版本**: v1.1.1  
**更新日期**: 2025-11-02

