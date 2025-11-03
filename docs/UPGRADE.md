# LinuxStudio 升级指南

## 📋 目录

- [快速升级](#快速升级)
- [升级方法](#升级方法)
- [版本升级说明](#版本升级说明)
- [验证升级](#验证升级)
- [回滚操作](#回滚操作)
- [常见问题](#常见问题)

---

## 🚀 快速升级

### 标准系统

```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade linuxstudio

# CentOS/RHEL/Rocky Linux
sudo yum update linuxstudio
# 或
sudo dnf update linuxstudio
```

### 手动下载升级

```bash
# Ubuntu/Debian
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.1_debian-11_amd64.deb
sudo dpkg -i linuxstudio_*.deb

# CentOS/RHEL/Rocky Linux
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio-1.1.1-1.rockylinux-8.x86_64.rpm
sudo rpm -Uvh linuxstudio-*.rpm
```

### 嵌入式系统

```bash
# 以 root 身份运行
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.1_debian-11_armhf.deb
ar x linuxstudio_*.deb
tar -xzf data.tar.gz -C /
xkl --version  # 验证
```

---

## 📦 升级方法

### 方法 1: 使用包管理器升级（推荐）

**Ubuntu/Debian 系统**：
```bash
# 更新包列表
sudo apt-get update

# 升级 LinuxStudio
sudo apt-get upgrade linuxstudio

# 或使用 apt
sudo apt update
sudo apt upgrade linuxstudio
```

**CentOS/RHEL/Rocky Linux 系统**：
```bash
# 更新包列表
sudo yum check-update

# 升级 LinuxStudio
sudo yum update linuxstudio

# 或使用 dnf（Fedora/Rocky 9+）
sudo dnf update linuxstudio
```

### 方法 2: 手动下载并安装新版本

**Ubuntu/Debian**：
```bash
# 下载最新版本
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.1_debian-11_amd64.deb

# 安装（会自动覆盖旧版本）
sudo dpkg -i linuxstudio_1.1.1_debian-11_amd64.deb

# 如果有依赖问题，修复
sudo apt-get install -f
```

**CentOS/RHEL/Rocky Linux**：
```bash
# 下载最新版本
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio-1.1.1-1.rockylinux-8.x86_64.rpm

# 安装（会自动升级）
sudo rpm -Uvh linuxstudio-1.1.1-1.rockylinux-8.x86_64.rpm
```

### 方法 3: 嵌入式系统手动升级

适用于 STM32MP1, OpenSTLinux, BusyBox 等：

```bash
# 以 root 身份运行

# 1. 备份当前配置（可选）
cp /etc/linuxstudio/config.yaml /etc/linuxstudio/config.yaml.backup

# 2. 下载新版本
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.1_debian-11_armhf.deb

# 3. 解压并安装
ar x linuxstudio_1.1.1_debian-11_armhf.deb
tar -xzf data.tar.gz -C /

# 4. 恢复配置（如果需要）
cp /etc/linuxstudio/config.yaml.backup /etc/linuxstudio/config.yaml

# 5. 验证
xkl --version
```

### 方法 4: 从源码编译升级

```bash
# 1. 进入项目目录
cd LinuxStudio

# 2. 拉取最新代码
git fetch origin
git checkout v1.1.1

# 3. 清理旧构建
rm -rf build

# 4. 重新构建
./build.sh

# 5. 安装
cd build
sudo cmake --install .
```

---

## 🔄 版本升级说明

### 从 v1.0.0 升级到 v1.1.1

#### 主要变化

1. **依赖变化**
   - ❌ 移除: `bash (>= 5.0)`
   - ❌ 移除: `libatomic1`
   - ✅ 保留: `libc6`, `libstdc++6`

2. **新增功能**
   - ✅ 嵌入式系统完整支持
   - ✅ 安装时显示进度提示
   - ✅ POSIX sh 兼容性
   - ✅ SSL 证书自动处理
   - ✅ 场景命令完整实现
   - ✅ 日志文件自动写入

3. **配置文件**
   - 配置文件格式**未变化**
   - 版本号自动更新: `1.0.0` → `1.1.1`
   - 现有配置会被保留

#### 升级步骤

**标准系统（有 sudo）**：
```bash
# 1. 检查当前版本
xkl --version

# 2. 下载新版本
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.1_debian-11_amd64.deb

# 3. 升级安装
sudo dpkg -i linuxstudio_1.1.1_debian-11_amd64.deb

# 4. 验证升级
xkl --version
xkl status
```

**嵌入式系统（无 sudo）**：
```bash
# 1. 备份配置
cp /etc/linuxstudio/config.yaml /tmp/config.yaml.backup

# 2. 下载并解压
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.1_debian-11_armhf.deb
ar x linuxstudio_1.1.1_debian-11_armhf.deb
tar -xzf data.tar.gz -C /

# 3. 验证
xkl --version
```

---

## ✅ 验证升级

### 1. 检查版本号

```bash
xkl --version
```

**预期输出**: `LinuxStudio CLI v1.1.1 (C++ Core)`

### 2. 检查系统状态

```bash
xkl status
```

应该显示框架状态和系统信息。

### 3. 检查依赖

```bash
ldd /usr/bin/xkl
```

**预期输出**（应该只有基本库）:
```
linux-vdso.so.1
libc.so.6
libstdc++.so.6
libgcc_s.so.1
libm.so.6
libpthread.so.0
```

**不应该出现**: `libatomic.so.1`

### 4. 测试基本功能

```bash
# 列出场景
xkl scene list

# 应用场景
xkl scene apply embedded

# 列出插件
xkl plugin list

# 列出组件
xkl component list
```

### 5. 检查日志文件

```bash
# 检查日志目录是否存在
ls -la /opt/linuxstudio/logs/

# 查看日志内容
cat /opt/linuxstudio/logs/linuxstudio.log
```

---

## 🔄 回滚操作

如果升级后遇到问题，可以回滚到旧版本：

### Ubuntu/Debian 系统

```bash
# 1. 下载旧版本
wget https://github.com/happykl-cn/LinuxStudio/releases/download/v1.0.0/linuxstudio_1.0.0_debian-11_armhf.deb

# 2. 降级安装
sudo dpkg -i linuxstudio_1.0.0_debian-11_armhf.deb

# 3. 验证
xkl --version
```

### CentOS/RHEL/Rocky Linux 系统

```bash
# 1. 下载旧版本
wget https://github.com/happykl-cn/LinuxStudio/releases/download/v1.0.0/linuxstudio-1.0.0-1.rockylinux-8.x86_64.rpm

# 2. 降级
sudo rpm -Uvh --oldpackage linuxstudio-1.0.0-1.rockylinux-8.x86_64.rpm

# 3. 验证
xkl --version
```

### 嵌入式系统

```bash
# 1. 备份当前配置
cp /etc/linuxstudio/config.yaml /tmp/config.yaml.backup

# 2. 下载并安装旧版本
wget https://github.com/happykl-cn/LinuxStudio/releases/download/v1.0.0/linuxstudio_1.0.0_debian-11_armhf.deb
ar x linuxstudio_1.0.0_debian-11_armhf.deb
tar -xzf data.tar.gz -C /

# 3. 恢复配置
cp /tmp/config.yaml.backup /etc/linuxstudio/config.yaml

# 4. 验证
xkl --version
```

---

## ❓ 常见问题

### Q1: 升级会丢失我的配置吗？

**A**: 不会。升级过程会保留 `/etc/linuxstudio/config.yaml` 中的配置。只有版本号会自动更新。

### Q2: 升级会影响已安装的插件和组件吗？

**A**: 不会。所有插件和组件数据都保存在 `/opt/linuxstudio/` 目录下，升级不会影响它们。

### Q3: 升级后提示 "libatomic1 not found"

**A**: 这是正常的。v1.1.1 不再需要 `libatomic1`。如果看到依赖错误，请确认已升级到最新版本：
```bash
xkl --version  # 应该显示 1.1.1
```

### Q4: 升级后 `xkl` 命令不工作

**A**: 尝试以下步骤：
```bash
# 1. 检查文件是否存在
ls -l /usr/bin/xkl

# 2. 检查权限
sudo chmod +x /usr/bin/xkl

# 3. 检查符号链接
ls -l /usr/bin/linuxstudio

# 4. 重新创建符号链接
sudo ln -sf /usr/bin/xkl /usr/bin/linuxstudio

# 5. 验证
xkl --version
```

### Q5: 如何检查是否需要升级？

**A**: 
```bash
# 检查当前版本
xkl --version

# 检查最新版本
curl -s https://api.github.com/repos/happykl-cn/LinuxStudio/releases/latest | grep '"tag_name"'

# 或访问
# https://github.com/happykl-cn/LinuxStudio/releases/latest
```

### Q6: 升级失败怎么办？

**A**: 
1. 查看错误日志
```bash
# Debian/Ubuntu
sudo dpkg -i linuxstudio_*.deb 2>&1 | tee upgrade.log

# 查看系统日志
journalctl -xe | grep linuxstudio
```

2. 尝试强制重新安装
```bash
sudo dpkg -i --force-overwrite linuxstudio_*.deb
```

3. 如果仍然失败，尝试完全卸载后重新安装
```bash
sudo dpkg -r linuxstudio
sudo dpkg -i linuxstudio_*.deb
```

---

## 📚 相关文档

- [安装指南](INSTALLATION.md)
- [嵌入式系统指南](EMBEDDED.md)
- [版本更新日志](CHANGELOG.md)

---

**版本**: v1.1.1  
**更新日期**: 2025-11-02

