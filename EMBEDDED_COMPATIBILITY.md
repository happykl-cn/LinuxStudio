# 嵌入式系统兼容性指南

## 概述

LinuxStudio 已针对嵌入式 Linux 系统进行优化，可在资源受限的设备上运行，包括：
- STM32MP1 系列（如 ATK-MP157）
- Raspberry Pi（所有型号）
- BeagleBone
- 其他基于 ARM32/ARM64 的嵌入式设备

## 兼容性特性

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
    # 如果找到则链接
    target_link_libraries(xkl ${LIBATOMIC_LIBRARY})
else()
    # 如果未找到则跳过（使用编译器内置支持）
    message(STATUS "libatomic not found, using built-in atomics")
endif()
```

## 在嵌入式系统上安装

### 方法 1：使用 dpkg（推荐）
```bash
# 下载 .deb 包
wget https://github.com/your-repo/linuxstudio/releases/download/v1.0.0/linuxstudio_1.0.0_debian-11_armhf.deb

# 以 root 身份安装
dpkg -i linuxstudio_1.0.0_debian-11_armhf.deb

# 如果提示依赖问题，尝试修复
apt-get install -f
```

### 方法 2：手动安装（无包管理器）
如果系统没有 `apt` 或 `dpkg`：

```bash
# 1. 解压 .deb 包
ar x linuxstudio_1.0.0_debian-11_armhf.deb
tar -xzf data.tar.gz -C /

# 2. 手动创建目录
mkdir -p /opt/linuxstudio/{plugins,components,data,logs,scenes}
mkdir -p /etc/linuxstudio

# 3. 创建配置文件
cat > /etc/linuxstudio/config.yaml <<'EOF'
version: 1.0.0
install_path: /opt/linuxstudio
log_level: info
auto_update_check: true
EOF

# 4. 设置权限
chmod +x /usr/bin/xkl
ln -sf /usr/bin/xkl /usr/bin/linuxstudio

# 5. 初始化
/usr/bin/xkl init
```

### 方法 3：从源码编译
对于特殊架构或定制需求：

```bash
# 1. 克隆仓库
git clone https://github.com/your-repo/linuxstudio.git
cd linuxstudio

# 2. 构建
./build.sh

# 3. 安装
cd build
make install
```

## 常见问题

### Q: 提示 "libatomic1 not found"
**A:** 新版本不再需要 `libatomic1`。如果使用旧版本，请升级到最新版本。

### Q: postinst 脚本失败
**A:** 这通常是权限问题。尝试：
```bash
# 以 root 身份运行
su -
dpkg -i linuxstudio_*.deb
```

### Q: 系统没有 bash
**A:** 没问题！LinuxStudio 使用 POSIX `sh`，兼容 BusyBox 和其他最小化 shell。

### Q: 在 OpenSTLinux 上安装失败
**A:** OpenSTLinux 使用定制的软件源。建议使用"方法 2：手动安装"。

### Q: 如何验证安装
```bash
# 检查版本
xkl --version

# 检查系统状态
xkl status

# 查看帮助
xkl --help
```

## 性能优化

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
- 二进制大小：~500KB（stripped）
- 运行时内存：~2-5MB
- 适合 64MB+ RAM 的设备

## 支持的发行版

### 完全测试
- ✅ Ubuntu 20.04/22.04 (armhf/arm64)
- ✅ Debian 11/12 (armhf/arm64)
- ✅ Raspberry Pi OS (32-bit/64-bit)

### 理论兼容
- 🟡 OpenSTLinux (STM32MP1)
- 🟡 Yocto/Buildroot 自定义系统
- 🟡 OpenWrt (需要手动安装)

## 故障排除

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
```

### 报告问题
如果在嵌入式设备上遇到问题，请提供：
1. 设备型号和架构（`uname -a`）
2. 发行版信息（`cat /etc/os-release`）
3. 可用内存（`free -h`）
4. 错误日志

## 贡献

欢迎提交针对嵌入式系统的改进！特别是：
- 新架构支持（MIPS、RISC-V 等）
- 更小的二进制大小
- 更低的内存占用
- 特定设备的优化

## 许可证

MIT License - 详见 LICENSE 文件

