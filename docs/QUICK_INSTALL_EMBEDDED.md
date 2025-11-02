# LinuxStudio 嵌入式设备快速安装

## 🚀 标准安装（有 sudo）

```bash
# 下载包
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.1_debian-11_armhf.deb

# 安装
sudo dpkg -i linuxstudio_*.deb

# 验证
xkl --version
```

## 🔧 手动安装（无 sudo / 最小化系统）

适用于：STM32MP1, OpenSTLinux, BusyBox, 自定义 Yocto/Buildroot

```bash
# 以 root 身份运行

# 1. 解压包
ar x linuxstudio_1.1.1_debian-11_armhf.deb
tar -xzf data.tar.gz -C /

# 2. 创建目录
mkdir -p /opt/linuxstudio/plugins
mkdir -p /opt/linuxstudio/components
mkdir -p /opt/linuxstudio/data
mkdir -p /opt/linuxstudio/logs
mkdir -p /opt/linuxstudio/scenes
mkdir -p /etc/linuxstudio

# 3. 配置
cat > /etc/linuxstudio/config.yaml <<'EOF'
version: 1.1.1
install_path: /opt/linuxstudio
log_level: info
auto_update_check: true
EOF

# 4. 设置权限
chmod +x /usr/bin/xkl
ln -sf /usr/bin/xkl /usr/bin/linuxstudio

# 5. 验证
/usr/bin/xkl --version
/usr/bin/xkl status
```

## ✅ 验证安装

```bash
# 检查版本
xkl --version

# 检查状态
xkl status

# 检查依赖（应该只有基本库）
ldd /usr/bin/xkl
```

## ❓ 常见问题

### Q: 提示 "libatomic1 not found"
**A**: 新版本不需要 libatomic1，请使用最新版本。

### Q: 没有 wget 怎么办？
**A**: 使用 `curl -O <URL>` 或在其他机器下载后传输到设备。

### Q: 没有 ar 命令
**A**: 安装 binutils：`apt-get install binutils` 或使用其他机器解压。

### Q: 权限不足
**A**: 确保以 root 身份运行：`su -` 或 `sudo -i`

## 📚 详细文档

- [完整安装指南](EMBEDDED_COMPATIBILITY.md)
- [故障排除](EMBEDDED_COMPATIBILITY.md#故障排除)
- [主文档](README.md)

## 💡 快速命令

```bash
# 查看帮助
xkl --help

# 检查系统状态
xkl status

# 列出插件
xkl plugin list

# 应用场景
xkl scene list
xkl scene apply web
```

## 🎯 支持的设备

- ✅ STM32MP1 系列 (ATK-MP157, STM32MP157, etc.)
- ✅ Raspberry Pi 全系列 (1/2/3/4, Zero/Zero 2)
- ✅ BeagleBone (Black, AI, etc.)
- ✅ 其他 ARM32/ARM64 开发板

## 📦 最小系统要求

- **CPU**: ARM32 (armv6+) 或 ARM64
- **内存**: 64MB+ RAM
- **存储**: 10MB 可用空间
- **系统**: Linux 内核 3.10+
- **依赖**: 仅需 libc6 + libstdc++6

## 🆘 需要帮助？

- 📖 文档: [EMBEDDED_COMPATIBILITY.md](EMBEDDED_COMPATIBILITY.md)
- 🐛 报告问题: https://github.com/happykl-cn/LinuxStudio/issues
- 💬 社区: https://community.linuxstudio.org

---

**版本**: 1.0.0  
**更新**: 2025-11-02

