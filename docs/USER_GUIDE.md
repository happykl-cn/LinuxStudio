# LinuxStudio 用户指南

本指南涵盖升级、调试、嵌入式系统等所有用户需要的信息。

## 📋 目录

- [升级指南](#升级指南)
- [调试指南](#调试指南)
- [嵌入式系统](#嵌入式系统)
- [常见问题](#常见问题)

---

## 🔄 升级指南

### 快速升级

#### 标准系统

```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade linuxstudio

# CentOS/RHEL/Rocky Linux
sudo yum update linuxstudio
# 或
sudo dnf update linuxstudio
```

#### 手动下载升级

```bash
# Ubuntu/Debian
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.2_debian-11_amd64.deb
sudo dpkg -i linuxstudio_*.deb

# CentOS/RHEL/Rocky Linux
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio-1.1.2-1.rockylinux-9.x86_64.rpm
sudo rpm -Uvh linuxstudio-*.rpm
```

#### 嵌入式系统

```bash
# 以 root 身份运行
wget --no-check-certificate https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.2_debian-11_armhf.deb
ar x linuxstudio_*.deb
tar -xzf data.tar.gz -C /
xkl --version  # 验证
```

### 验证升级

```bash
# 1. 检查版本号
xkl --version
# 预期输出: LinuxStudio Framework v1.1.2 (C++ Core)

# 2. 检查系统状态
xkl status

# 3. 测试 scene 命令
xkl scene list

# 4. 测试应用场景
xkl scene apply embedded
```

### 版本升级说明

#### 从 v1.0.0 升级到 v1.1.2

**主要变化**：
1. **依赖变化**
   - ❌ 移除: `bash (>= 5.0)`
   - ❌ 移除: `libatomic1`
   - ✅ 保留: `libc6`, `libstdc++6`

2. **新增功能**
   - ✅ 场景命令完整实现
   - ✅ 中文/英文本地化
   - ✅ 嵌入式系统完全支持
   - ✅ SSL 证书自动处理
   - ✅ 日志文件自动写入

3. **配置文件**
   - 配置格式未变化
   - 现有配置会被保留

### 回滚操作

如果升级后遇到问题，可以回滚：

```bash
# Ubuntu/Debian
wget https://github.com/happykl-cn/LinuxStudio/releases/download/v1.1.1/linuxstudio_1.1.1_debian-11_armhf.deb
sudo dpkg -i linuxstudio_1.1.1_debian-11_armhf.deb

# CentOS/RHEL/Rocky Linux
wget https://github.com/happykl-cn/LinuxStudio/releases/download/v1.1.1/linuxstudio-1.1.1-1.rockylinux-9.x86_64.rpm
sudo rpm -Uvh --oldpackage linuxstudio-1.1.1-1.rockylinux-9.x86_64.rpm
```

---

## 🔧 调试指南

### 快速诊断脚本

运行以下命令进行系统诊断：

```bash
cat > /tmp/linuxstudio_diagnose.sh <<'EOF'
#!/bin/sh
echo "=================================================="
echo "LinuxStudio 诊断报告"
echo "=================================================="
echo ""

echo "【1】系统信息"
uname -a
echo ""

echo "【2】已安装的 xkl 版本"
if command -v xkl >/dev/null 2>&1; then
    /usr/bin/xkl --version 2>&1
else
    echo "❌ xkl 命令未找到"
fi
echo ""

echo "【3】二进制文件信息"
if [ -f /usr/bin/xkl ]; then
    ls -lh /usr/bin/xkl
    echo "文件大小: $(stat -c%s /usr/bin/xkl 2>/dev/null) bytes"
else
    echo "❌ /usr/bin/xkl 不存在"
fi
echo ""

echo "【4】测试 scene 命令"
if command -v xkl >/dev/null 2>&1; then
    xkl scene list 2>&1 | head -10
else
    echo "❌ xkl 命令未找到"
fi
echo ""

echo "【5】配置文件检查"
if [ -f /etc/linuxstudio/config.yaml ]; then
    echo "配置文件存在"
    cat /etc/linuxstudio/config.yaml | head -10
else
    echo "⚠️  配置文件不存在"
fi
echo ""

echo "【6】日志目录检查"
if [ -d /opt/linuxstudio/logs ]; then
    echo "日志目录存在"
    ls -lh /opt/linuxstudio/logs/
else
    echo "⚠️  日志目录不存在"
fi

echo "=================================================="
echo "诊断完成"
echo "=================================================="
EOF

chmod +x /tmp/linuxstudio_diagnose.sh
/tmp/linuxstudio_diagnose.sh
```

### 常见问题排查

#### 问题 1: scene 命令不可用

**症状**:
```bash
$ xkl scene list
Error: Unknown command: scene
```

**解决**:
```bash
# 方法 1: 完全重新安装
rm -f /usr/bin/xkl /usr/bin/linuxstudio
curl -fsSLk https://linuxstudio.org/heaven-cn.sh | bash

# 方法 2: 手动强制更新
cd /tmp
rm -f linuxstudio_*.deb
wget --no-check-certificate https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.2_debian-11_armhf.deb

# 强制安装
rm -f /usr/bin/xkl /usr/bin/linuxstudio
ar x linuxstudio_1.1.2_debian-11_armhf.deb
tar -xzf data.tar.gz
cp -f usr/bin/xkl /usr/bin/xkl
chmod +x /usr/bin/xkl
ln -sf /usr/bin/xkl /usr/bin/linuxstudio

# 验证
xkl --version
xkl scene list
```

#### 问题 2: SSL 证书错误

**症状**:
```
curl: (60) server certificate verification failed
```

**解决**:
```bash
# 使用 -k 参数跳过 SSL 验证
curl -fsSLk https://linuxstudio.org/heaven-cn.sh | bash

# 或者手动下载时使用 --no-check-certificate
wget --no-check-certificate https://github.com/...
```

#### 问题 3: 日志为空

**解决**:
```bash
# 创建日志目录
sudo mkdir -p /opt/linuxstudio/logs
sudo chmod 755 /opt/linuxstudio/logs

# 运行 xkl 命令生成日志
xkl status

# 检查日志
cat /opt/linuxstudio/logs/linuxstudio.log
```

### 版本对照表

| 版本 | 发布日期 | scene 命令 | i18n 支持 | 嵌入式优化 |
|-----|---------|-----------|----------|-----------|
| v1.0.0 | 2025-10-28 | ❌ | ❌ | ❌ |
| v1.1.1 | 2025-11-02 | ✅ | ✅ | ✅ |
| v1.1.2 | 2025-11-03 | ✅ | ✅ | ✅ |

---

## 📱 嵌入式系统

### 支持的设备

#### 完全测试
- ✅ Ubuntu 20.04/22.04 (armhf/arm64)
- ✅ Debian 11/12 (armhf/arm64)
- ✅ Raspberry Pi OS (32-bit/64-bit)
- ✅ STM32MP1 系列 (ATK-MP157, STM32MP135)
- ✅ BeagleBone (Black, AI)

#### 理论兼容
- 🟡 OpenSTLinux (STM32MP1)
- 🟡 Yocto/Buildroot 自定义系统
- 🟡 OpenWrt (需要手动安装)

### 最小系统要求

- **CPU**: ARM32 (armv6+) 或 ARM64
- **内存**: 64MB+ RAM（推荐 128MB+）
- **存储**: 10MB 可用空间
- **系统**: Linux 内核 3.10+
- **依赖**: 仅需 libc6 + libstdc++6

### 安装方法

#### 方法 1: 使用 dpkg（推荐）

```bash
# 下载 .deb 包
wget --no-check-certificate https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.2_debian-11_armhf.deb

# 以 root 身份安装
dpkg -i linuxstudio_1.1.2_debian-11_armhf.deb
```

#### 方法 2: 手动安装（无包管理器）

适用于 STM32MP1, OpenSTLinux, BusyBox 等：

```bash
# 以 root 身份运行

# 1. 下载并解压包
wget --no-check-certificate https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.2_debian-11_armhf.deb
ar x linuxstudio_1.1.2_debian-11_armhf.deb
tar -xzf data.tar.gz -C /

# 2. 创建目录结构
mkdir -p /opt/linuxstudio/{plugins,components,data,logs,scenes}
mkdir -p /etc/linuxstudio

# 3. 创建配置文件
cat > /etc/linuxstudio/config.yaml <<'EOF'
version: 1.1.2
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

#### 方法 3: 使用一键安装脚本

脚本会自动检测嵌入式系统：

```bash
# 中文版（自动处理 SSL 证书）
curl -fsSLk https://linuxstudio.org/heaven-cn.sh | bash

# 英文版
curl -fsSLk https://linuxstudio.org/heaven.sh | bash
```

### SSL 证书问题

#### 问题描述

在嵌入式系统上运行安装脚本时，可能会遇到 SSL 证书验证失败：

```bash
curl: (60) server certificate verification failed. CAfile: /etc/ssl/certs/ca-certificates.crt
```

#### 原因

- CA 证书不完整或过期
- 系统时间不正确
- 证书链缺失
- 存储空间限制

#### 解决方案

**方案 1: 使用 -k 参数（推荐）**

```bash
curl -fsSLk https://linuxstudio.org/heaven-cn.sh | bash
```

**方案 2: 检查系统时间**

```bash
# 查看当前时间
date

# 如果时间不正确，设置正确时间（需要 root）
date -s "2025-11-03 12:00:00"
```

**方案 3: 更新 CA 证书（如果可能）**

```bash
# Debian/Ubuntu 系统
apt-get update && apt-get install -y ca-certificates
update-ca-certificates
```

### 性能优化

#### ARM32 设备

**ARMv7（如 STM32MP157）：**
- 启用 NEON SIMD 指令集
- 硬浮点 ABI（`-mfloat-abi=hard`）
- 优化编译标志（`-O2`）

**ARMv6（如 Raspberry Pi 1）：**
- VFP 浮点支持
- 硬浮点 ABI
- 保守优化以确保兼容性

#### 内存占用

- **二进制大小**：~500KB（stripped）
- **运行时内存**：~2-5MB
- **适合**：64MB+ RAM 的设备

### 故障排除

#### 常见问题

**Q: 提示 "libatomic1 not found"**  
**A**: 新版本不再需要 `libatomic1`。请使用 v1.1.2+

**Q: postinst 脚本失败**  
**A**: 权限问题。尝试以 root 身份运行：
```bash
su -
dpkg -i linuxstudio_*.deb
```

**Q: 系统没有 bash**  
**A**: 没问题！LinuxStudio 使用 POSIX `sh`，兼容 BusyBox

**Q: 未知架构: armv7l**  
**A**: 脚本会自动将 `armv7l` 映射到 `armhf`

#### 验证安装

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

---

## ❓ 常见问题

### Q1: 升级会丢失我的配置吗？

**A**: 不会。升级会保留 `/etc/linuxstudio/config.yaml` 中的配置。

### Q2: 如何检查是否需要升级？

**A**: 
```bash
# 检查当前版本
xkl --version

# 检查最新版本
curl -s https://api.github.com/repos/happykl-cn/LinuxStudio/releases/latest | grep '"tag_name"'
```

### Q3: 如何卸载？

```bash
# 如果是包管理器安装
sudo apt-get remove linuxstudio      # 保留配置
sudo apt-get purge linuxstudio       # 完全删除

# 如果是编译安装
sudo rm -f /usr/bin/xkl /usr/bin/linuxstudio
sudo rm -rf /opt/linuxstudio
sudo rm -rf /etc/linuxstudio
```

### Q4: 支持哪些 Linux 发行版？

**标准系统**：
- Ubuntu 18.04+, Debian 10+
- CentOS 7+, Fedora 30+
- Arch Linux, openSUSE

**嵌入式系统**：
- OpenSTLinux, Yocto, Buildroot
- Raspberry Pi OS
- 自定义嵌入式 Linux

### Q5: 如何启用详细日志？

```bash
export LINUXSTUDIO_LOG_LEVEL=debug
xkl status
```

### Q6: 国内网络安装很慢怎么办？

脚本会自动检测并切换到阿里云镜像源，启用并行下载加速。

---

## 📞 获取帮助

如果以上方法都无法解决问题：

1. **收集诊断信息**:
   ```bash
   /tmp/linuxstudio_diagnose.sh > /tmp/diagnose_report.txt
   ```

2. **提交 Issue**:
   - 访问: https://github.com/happykl-cn/LinuxStudio/issues
   - 附上诊断报告
   - 说明你的系统信息（OS、架构）
   - 描述复现步骤

3. **社区讨论**:
   - 查看已有的 Issues 和 Discussions
   - 搜索类似问题的解决方案

---

**版本**: v1.1.2  
**最后更新**: 2025-11-03

