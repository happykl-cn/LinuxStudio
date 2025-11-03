# LinuxStudio 版本更新日志

## v1.1.1 - Embedded Edition (2025-11-02)

### 🎯 主要更新

#### 1. 嵌入式系统兼容性改进 ⭐

- ✅ 移除 `libatomic1` 硬依赖，改为条件链接
- ✅ 移除 `bash` 依赖，改用 POSIX `sh`
- ✅ 最小化依赖：仅需 `libc6` + `libstdc++6`
- ✅ `postinst` 脚本完全兼容 POSIX sh
- ✅ 所有操作添加错误处理和优雅降级
- ✅ 移除 Unicode 字符，兼容所有终端
- ✅ 新增安装进度提示

#### 2. 支持的嵌入式系统

- ✅ **STM32MP1** 系列 (ATK-MP157, STM32MP135 等)
- ✅ **Raspberry Pi** 全系列 (1/2/3/4, Zero/Zero 2)
- ✅ **BeagleBone** (Black, AI 等)
- ✅ **OpenSTLinux** (Yocto 基础)
- ✅ **BusyBox** 最小化系统
- ✅ 自定义 Yocto/Buildroot 系统

#### 3. 安装体验改进

新的安装输出：
```
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
```

#### 4. CLI 功能增强

- ✅ 实现 `scene` 命令（`list` 和 `apply`）
- ✅ 添加中文本地化支持
- ✅ 自动日志文件写入
- ✅ 改进错误提示

#### 5. SSL 证书处理

- ✅ 自动检测 SSL 证书验证失败
- ✅ 在嵌入式模式下自动使用 `-k` 参数
- ✅ 支持 `curl` 和 `wget` 的 SSL 降级

#### 6. 架构检测改进

- ✅ 正确映射 `armv7l` 和 `armv6l` 到 `armhf`
- ✅ 支持 OpenSTLinux 和 Yocto 系统检测
- ✅ 改进未知架构的默认处理

### 🔧 技术细节

#### 修改的文件

1. **CMakeLists.txt**
   - 条件链接 libatomic
   - 最小化依赖声明

2. **packaging/debian/postinst**
   - Shebang: `#!/bin/bash` → `#!/bin/sh`
   - 添加详细的安装进度提示
   - 所有操作添加错误处理

3. **src/cli/main.cpp**
   - 实现 `scene` 命令
   - 添加中文本地化
   - 改进错误提示

4. **src/core/engine.cpp**
   - 自动创建日志目录
   - 设置日志文件路径

5. **src/utils/logger.cpp**
   - 改进日志文件打开错误处理

6. **heaven.sh / heaven-cn.sh**
   - SSL 证书自动处理
   - 架构检测改进
   - OpenSTLinux 系统支持

### 📦 代码统计

```
修改的文件: 8 个
新增的文档: 5 个
代码变更: ~200 行
文档新增: ~2500 行
```

### ✅ 验证安装

```bash
# 检查版本（应显示 1.1.1）
xkl --version

# 检查状态
xkl status

# 检查依赖（应该只有基本库）
ldd /usr/bin/xkl
```

### 🎉 用户反馈

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

## v1.0.0 - Initial Release

### 🎯 主要功能

- ✅ C++ 核心引擎
- ✅ 场景驱动安装
- ✅ 插件管理系统
- ✅ 组件管理系统
- ✅ 多服务器部署支持
- ✅ 标准 Linux 系统支持

### 📦 支持的系统

- Ubuntu 18.04+
- Debian 10+
- CentOS 7+
- Fedora 30+
- Arch Linux
- openSUSE

### ⚠️ 已知限制

- ❌ 不支持嵌入式系统
- ❌ 依赖 `bash` 和 `libatomic1`
- ❌ 安装脚本不兼容 POSIX sh

---

## 🔮 未来计划

### v1.2.0 (计划中)

- [ ] 添加 RISC-V 架构支持
- [ ] 添加 MIPS 架构支持
- [ ] 静态链接选项（完全无依赖）
- [ ] musl libc 支持（Alpine Linux）
- [ ] 进一步减小二进制大小
- [ ] 组件自动安装功能

### v1.3.0 (计划中)

- [ ] 插件市场
- [ ] 远程服务器管理
- [ ] Web 管理界面
- [ ] 配置导入/导出

---

## 📚 相关文档

- [安装指南](INSTALLATION.md)
- [升级指南](UPGRADE.md)
- [嵌入式系统指南](EMBEDDED.md)
- [开发者指南](DEVELOPER.md)

---

**当前版本**: v1.1.1  
**最新更新**: 2025-11-02  
**状态**: ✅ 稳定版

