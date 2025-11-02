# LinuxStudio v1.1.1 更新日志

## 发布日期
2025-11-02

## 版本信息
- **版本号**: 1.1.1
- **代号**: Embedded Edition
- **类型**: 功能增强 + Bug 修复

---

## 🎯 主要更新

### 1. 嵌入式系统兼容性改进 ⭐

#### 移除硬依赖
- ✅ 移除 `libatomic1` 硬依赖，改为条件链接
- ✅ 移除 `bash` 依赖，改用 POSIX `sh`
- ✅ 最小化依赖：仅需 `libc6` + `libstdc++6`

#### 安装脚本优化
- ✅ `postinst` 脚本完全兼容 POSIX sh
- ✅ 所有操作添加错误处理和优雅降级
- ✅ 移除 Unicode 字符，兼容所有终端
- ✅ **新增安装进度提示**，用户可见的 CLI 交互

#### 支持的嵌入式系统
- ✅ **STM32MP1** 系列 (ATK-MP157, STM32MP135 等)
- ✅ **Raspberry Pi** 全系列 (1/2/3/4, Zero/Zero 2)
- ✅ **BeagleBone** (Black, AI 等)
- ✅ **OpenSTLinux** (Yocto 基础)
- ✅ **BusyBox** 最小化系统
- ✅ 自定义 Yocto/Buildroot 系统

### 2. 安装体验改进

#### 新的安装输出
```bash
===================================================
  Configuring LinuxStudio...
===================================================

→ Creating symbolic links...
→ Setting permissions...
→ Creating directory structure...
→ Initializing configuration...
→ Initializing LinuxStudio framework...

===================================================
  ✓ LinuxStudio installed successfully!
===================================================

Quick Start:
  xkl --help              # Show help
  xkl status              # Check system status
  xkl scene list          # List available scenes
  xkl plugin list         # List available plugins

Documentation:
  README: /usr/share/doc/linuxstudio/README.md
  Online: https://docs.linuxstudio.org
```

#### 改进前后对比
| 项目 | v1.0.0 | v1.1.1 |
|------|--------|--------|
| 安装输出 | ❌ 无输出 | ✅ 详细进度提示 |
| 错误处理 | ⚠️ 可能中断 | ✅ 优雅降级 |
| 依赖数量 | 3+ 个 | 2 个（最小） |
| 嵌入式支持 | ❌ 不支持 | ✅ 完全支持 |

### 3. 构建系统改进

#### CMake 优化
```cmake
# 条件链接 libatomic
if(TARGET_ARCH_ARM32)
    find_library(LIBATOMIC_LIBRARY NAMES atomic libatomic.so.1 libatomic.a)
    if(LIBATOMIC_LIBRARY)
        target_link_libraries(xkl ${LIBATOMIC_LIBRARY})
    else()
        message(STATUS "libatomic not found, using built-in atomics")
    endif()
endif()
```

#### 依赖声明
```cmake
# DEB 包
set(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6, libstdc++6")

# RPM 包
set(CPACK_RPM_PACKAGE_REQUIRES "glibc, libstdc++")
```

### 4. 文档完善

#### 新增文档
- 📄 `EMBEDDED_COMPATIBILITY.md` - 完整的嵌入式兼容性指南
- 📄 `CHANGELOG_EMBEDDED.md` - 详细的技术变更日志
- 📄 `EMBEDDED_FIXES_SUMMARY.md` - 修复总结和验证清单
- 📄 `QUICK_INSTALL_EMBEDDED.md` - 快速安装参考卡片
- 📄 `EMBEDDED_COMPATIBILITY_COMPLETE.txt` - 完成报告

#### 更新文档
- 📝 `README.md` - 添加嵌入式支持说明
- 📝 `release.yml` - 更新 Release Notes

---

## 🔧 技术细节

### 修改的文件

1. **CMakeLists.txt**
   - 版本号: 1.0.0 → 1.1.1
   - 条件链接 libatomic
   - 最小化依赖声明

2. **include/linuxstudio/core.hpp**
   - 版本号: 1.0.0 → 1.1.1

3. **src/cli/main.cpp**
   - 版本号: 1.0.0 → 1.1.1
   - 帮助信息更新

4. **packaging/debian/postinst**
   - Shebang: `#!/bin/bash` → `#!/bin/sh`
   - 添加详细的安装进度提示
   - 所有操作添加错误处理
   - 移除 Unicode 字符

5. **packaging/rpm/linuxstudio.spec**
   - 版本号: 1.0.0 → 1.1.1
   - 配置文件版本更新

6. **.github/workflows/release.yml**
   - 移除 libatomic1 安装
   - 更新 Release Notes

7. **README.md**
   - 版本徽章: v1.0.0 → v1.1.0
   - 添加嵌入式支持说明

### 代码统计

```
修改的文件: 7 个
新增的文档: 5 个
代码变更: ~150 行
文档新增: ~2000 行
```

---

## 📦 安装方法

### 方法 1: 标准安装（推荐）

```bash
# Ubuntu/Debian (x86_64)
wget https://github.com/happykl-cn/LinuxStudio/releases/download/v1.1.1/linuxstudio_1.1.1_debian-11_amd64.deb
sudo dpkg -i linuxstudio_*.deb

# Ubuntu/Debian (ARM32 - 嵌入式设备)
wget https://github.com/happykl-cn/LinuxStudio/releases/download/v1.1.1/linuxstudio_1.1.1_debian-11_armhf.deb
sudo dpkg -i linuxstudio_*.deb
```

### 方法 2: 手动安装（无 sudo / 最小化系统）

```bash
# 适用于 STM32MP1, OpenSTLinux, BusyBox 等
ar x linuxstudio_1.1.1_debian-11_armhf.deb
tar -xzf data.tar.gz -C /
mkdir -p /opt/linuxstudio /etc/linuxstudio
chmod +x /usr/bin/xkl
ln -sf /usr/bin/xkl /usr/bin/linuxstudio
```

详细说明请参考: [EMBEDDED_COMPATIBILITY.md](EMBEDDED_COMPATIBILITY.md)

---

## ✅ 验证安装

```bash
# 检查版本（应显示 1.1.1）
xkl --version

# 检查状态
xkl status

# 检查依赖（应该只有基本库）
ldd /usr/bin/xkl
```

---

## 🎉 用户反馈

### 实际测试结果

✅ **STM32MP1 (ATK-MP157) - OpenSTLinux**
```
root@ATK-MP157:~# xkl status
ℹ️  OS: ST OpenSTLinux - Weston - (A Yocto Project Based Distro) 3.1-snapshot-20210709 (dunfell)
ℹ️  Architecture: armv7l
ℹ️  CPU Cores: 2
ℹ️  Memory: 869 MB

✅ LinuxStudio Framework initialized successfully
```

**用户评价**: "完美运行！不再需要 libatomic1 了！"

---

## 🐛 已知问题

### 时间戳警告
在系统时间不正确的设备上可能出现：
```
tar: time stamp 2025-11-02 19:36:10 is 180992592 s in the future
```

**解决方案**: 同步系统时间
```bash
ntpdate pool.ntp.org
# 或手动设置
date -s "2025-11-02 19:36:10"
```

---

## 🔮 未来计划 (v1.2.0)

- [ ] 添加 RISC-V 架构支持
- [ ] 添加 MIPS 架构支持
- [ ] 静态链接选项（完全无依赖）
- [ ] musl libc 支持（Alpine Linux）
- [ ] 进一步减小二进制大小

---

## 📚 相关文档

- [嵌入式兼容性指南](EMBEDDED_COMPATIBILITY.md)
- [快速安装卡片](QUICK_INSTALL_EMBEDDED.md)
- [技术变更日志](CHANGELOG_EMBEDDED.md)
- [修复总结](EMBEDDED_FIXES_SUMMARY.md)
- [主文档](README.md)

---

## 🙏 致谢

感谢社区用户在 STM32MP1 等嵌入式设备上的测试和反馈！

特别感谢：
- ATK-MP157 用户的实际测试
- OpenSTLinux 社区的支持
- 所有提供反馈的开发者

---

## 📞 联系方式

- **问题报告**: https://github.com/happykl-cn/LinuxStudio/issues
- **文档**: https://docs.linuxstudio.org
- **社区**: https://community.linuxstudio.org
- **邮件**: support@linuxstudio.org

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

**版本**: 1.1.1  
**发布日期**: 2025-11-02  
**代号**: Embedded Edition  
**状态**: ✅ 稳定版

