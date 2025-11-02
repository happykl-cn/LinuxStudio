# LinuxStudio 快速升级

## 🚀 一键升级

### Ubuntu/Debian (标准系统)

```bash
# 方法 1: 使用包管理器（推荐）
sudo apt update && sudo apt upgrade linuxstudio

# 方法 2: 手动下载安装
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.1_debian-11_armhf.deb
sudo dpkg -i linuxstudio_*.deb
```

### CentOS/RHEL/Rocky Linux

```bash
# 方法 1: 使用包管理器（推荐）
sudo yum update linuxstudio
# 或
sudo dnf update linuxstudio

# 方法 2: 手动下载安装
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio-1.1.1-1.rockylinux-8.x86_64.rpm
sudo rpm -Uvh linuxstudio-*.rpm
```

### 嵌入式系统 (STM32MP1/OpenSTLinux/BusyBox)

```bash
# 以 root 身份运行
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.1_debian-11_armhf.deb
ar x linuxstudio_*.deb
tar -xzf data.tar.gz -C /
xkl --version  # 验证
```

## ✅ 验证升级

```bash
# 检查版本（应显示 1.1.1）
xkl --version

# 检查状态
xkl status

# 检查依赖（应该只有基本库，不应有 libatomic）
ldd /usr/bin/xkl
```

## 🔄 回滚（如果需要）

```bash
# Ubuntu/Debian
wget https://github.com/happykl-cn/LinuxStudio/releases/download/v1.0.0/linuxstudio_1.0.0_debian-11_armhf.deb
sudo dpkg -i linuxstudio_1.0.0_debian-11_armhf.deb

# CentOS/RHEL/Rocky
wget https://github.com/happykl-cn/LinuxStudio/releases/download/v1.0.0/linuxstudio-1.0.0-1.rockylinux-8.x86_64.rpm
sudo rpm -Uvh --oldpackage linuxstudio-1.0.0-*.rpm
```

## 📚 详细文档

完整升级指南: [UPGRADE_GUIDE.md](UPGRADE_GUIDE.md)

---

**当前最新版本**: v1.1.1  
**更新日期**: 2025-11-02

