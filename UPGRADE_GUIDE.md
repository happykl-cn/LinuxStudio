# LinuxStudio 升级指南

## 📋 目录

- [升级方法](#升级方法)
- [从 v1.0.0 升级到 v1.1.1](#从-v100-升级到-v111)
- [验证升级](#验证升级)
- [回滚操作](#回滚操作)
- [常见问题](#常见问题)

---

## 🚀 升级方法

### 方法 1: 使用包管理器升级（推荐）

#### Ubuntu/Debian 系统

```bash
# 1. 更新包列表
sudo apt-get update

# 2. 升级 LinuxStudio
sudo apt-get upgrade linuxstudio

# 或者使用 apt（更现代的方式）
sudo apt update
sudo apt upgrade linuxstudio
```

#### CentOS/RHEL/Rocky Linux 系统

```bash
# 1. 更新包列表
sudo yum check-update

# 2. 升级 LinuxStudio
sudo yum update linuxstudio

# 或者使用 dnf（Fedora/Rocky 9+）
sudo dnf update linuxstudio
```

### 方法 2: 手动下载并安装新版本

#### Ubuntu/Debian (x86_64)

```bash
# 1. 下载最新版本
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.1_debian-11_amd64.deb

# 2. 安装（会自动覆盖旧版本）
sudo dpkg -i linuxstudio_1.1.1_debian-11_amd64.deb

# 3. 如果有依赖问题，修复
sudo apt-get install -f
```

#### Ubuntu/Debian (ARM32 - 嵌入式设备)

```bash
# 1. 下载最新版本
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.1_debian-11_armhf.deb

# 2. 安装
sudo dpkg -i linuxstudio_1.1.1_debian-11_armhf.deb
```

#### CentOS/RHEL/Rocky Linux

```bash
# 1. 下载最新版本
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio-1.1.1-1.rockylinux-8.x86_64.rpm

# 2. 安装（会自动升级）
sudo rpm -Uvh linuxstudio-1.1.1-1.rockylinux-8.x86_64.rpm
```

### 方法 3: 嵌入式系统手动升级（无 sudo）

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

## 📦 从 v1.0.0 升级到 v1.1.1

### 主要变化

1. **依赖变化**
   - ❌ 移除: `bash (>= 5.0)`
   - ❌ 移除: `libatomic1`
   - ✅ 保留: `libc6`, `libstdc++6`

2. **新增功能**
   - ✅ 嵌入式系统完整支持
   - ✅ 安装时显示进度提示
   - ✅ POSIX sh 兼容性

3. **配置文件**
   - 配置文件格式**未变化**
   - 版本号自动更新: `1.0.0` → `1.1.1`
   - 现有配置会被保留

### 升级步骤

#### 标准系统（有 sudo）

```bash
# 1. 检查当前版本
xkl --version
# 输出: LinuxStudio Framework v1.0.0

# 2. 下载新版本
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.1_debian-11_armhf.deb

# 3. 升级安装
sudo dpkg -i linuxstudio_1.1.1_debian-11_armhf.deb

# 安装时会显示：
# ===================================================
#   Configuring LinuxStudio...
# ===================================================
# 
# → Creating symbolic links...
# → Setting permissions...
# → Creating directory structure...
# → Initializing configuration...
# → Initializing LinuxStudio framework...
# 
# ===================================================
#   ✓ LinuxStudio installed successfully!
# ===================================================

# 4. 验证升级
xkl --version
# 输出: LinuxStudio Framework v1.1.1

# 5. 检查状态
xkl status
```

#### 嵌入式系统（无 sudo）

```bash
# 1. 备份配置
cp /etc/linuxstudio/config.yaml /tmp/config.yaml.backup

# 2. 下载并解压
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.1_debian-11_armhf.deb
ar x linuxstudio_1.1.1_debian-11_armhf.deb
tar -xzf data.tar.gz -C /

# 3. 恢复配置（如果需要保留自定义配置）
# 注意：新版本会自动更新版本号，但保留其他设置
if [ -f /tmp/config.yaml.backup ]; then
    # 合并配置（保留自定义设置，更新版本号）
    sed 's/version: 1.0.0/version: 1.1.1/' /tmp/config.yaml.backup > /etc/linuxstudio/config.yaml
fi

# 4. 验证
xkl --version
```

---

## ✅ 验证升级

### 1. 检查版本号

```bash
xkl --version
```

**预期输出**:
```
LinuxStudio Framework v1.1.1
```

### 2. 检查系统状态

```bash
xkl status
```

**预期输出**:
```
ℹ️  LinuxStudio Framework Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Version:        1.1.1 (C++ Core)
Install Path:   /opt/linuxstudio
...
```

### 3. 检查依赖

```bash
ldd /usr/bin/xkl
```

**预期输出**（应该只有基本库）:
```
linux-vdso.so.1
libc.so.6 => /lib/arm-linux-gnueabihf/libc.so.6
libstdc++.so.6 => /usr/lib/arm-linux-gnueabihf/libstdc++.so.6
libgcc_s.so.1 => /lib/arm-linux-gnueabihf/libgcc_s.so.1
libm.so.6 => /lib/arm-linux-gnueabihf/libm.so.6
libpthread.so.0 => /lib/arm-linux-gnueabihf/libpthread.so.0
```

**不应该出现**: `libatomic.so.1`

### 4. 测试基本功能

```bash
# 列出场景
xkl scene list

# 列出插件
xkl plugin list

# 列出组件
xkl component list
```

### 5. 检查配置文件

```bash
cat /etc/linuxstudio/config.yaml
```

**预期内容**:
```yaml
# LinuxStudio Configuration
version: 1.1.1
install_path: /opt/linuxstudio
log_level: info
auto_update_check: true
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
# 1. 查看已安装版本
rpm -qa | grep linuxstudio

# 2. 下载旧版本
wget https://github.com/happykl-cn/LinuxStudio/releases/download/v1.0.0/linuxstudio-1.0.0-1.rockylinux-8.x86_64.rpm

# 3. 降级
sudo rpm -Uvh --oldpackage linuxstudio-1.0.0-1.rockylinux-8.x86_64.rpm

# 4. 验证
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

**A**: 这是正常的。v1.1.1 不再需要 `libatomic1`。如果你看到这个提示，说明你可能还在使用旧版本。请确认：
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

### Q5: 在嵌入式系统上升级后没有看到安装提示

**A**: v1.1.1 新增了安装进度提示。如果你使用 `dpkg -i` 安装，应该能看到：
```
===================================================
  Configuring LinuxStudio...
===================================================

→ Creating symbolic links...
...
```

如果没有看到，可能是：
1. 使用了手动安装方法（解压 tar.gz）
2. 输出被重定向了

这不影响功能，只是没有视觉反馈。

### Q6: 升级后系统时间警告

**A**: 如果看到：
```
tar: time stamp 2025-11-02 19:36:10 is 180992592 s in the future
```

这是因为系统时间不正确。同步时间：
```bash
# 使用 NTP 同步
ntpdate pool.ntp.org

# 或手动设置
date -s "2025-11-02 20:00:00"
```

### Q7: 如何检查是否需要升级？

**A**: 
```bash
# 检查当前版本
xkl --version

# 检查最新版本
curl -s https://api.github.com/repos/happykl-cn/LinuxStudio/releases/latest | grep '"tag_name"'

# 或访问
# https://github.com/happykl-cn/LinuxStudio/releases/latest
```

### Q8: 升级失败怎么办？

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

- [版本更新日志](VERSION_1.1.1_CHANGELOG.md)
- [嵌入式兼容性指南](EMBEDDED_COMPATIBILITY.md)
- [快速安装指南](QUICK_INSTALL_EMBEDDED.md)
- [主文档](README.md)

---

## 🆘 需要帮助？

- 📖 文档: https://docs.linuxstudio.org
- 🐛 报告问题: https://github.com/happykl-cn/LinuxStudio/issues
- 💬 社区: https://community.linuxstudio.org
- 📧 邮件: support@linuxstudio.org

---

**更新日期**: 2025-11-02  
**适用版本**: v1.0.0 → v1.1.1

