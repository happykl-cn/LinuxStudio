# LinuxStudio 安装过程详解

## 📦 安装命令

```bash
dpkg -i linuxstudio_1.1.1_debian-11_armhf.deb
```

## 🔄 完整的安装流程

### 阶段 1: dpkg 解包 (Unpacking)

```
(Reading database ... 40865 files and directories currently installed.)
Preparing to unpack linuxstudio_1.1.1_debian-11_armhf.deb ...
Unpacking linuxstudio (1.1.1) over (1.0.0) ...
```

**发生的事情**：

1. **读取数据库**
   - dpkg 读取 `/var/lib/dpkg/status` 检查已安装的包
   - 检查是否有冲突或依赖问题

2. **准备解包**
   - 如果是升级，运行旧版本的 `prerm` 脚本（如果存在）
   - 备份旧文件（如果需要）

3. **解包文件**
   - 从 `linuxstudio_1.1.1_debian-11_armhf.deb` 中提取文件
   - 将文件复制到系统目录：
     ```
     /usr/bin/xkl                              ← 主程序
     /usr/bin/linuxstudio                      ← 符号链接（可能）
     /opt/linuxstudio/                         ← 框架目录
     /etc/linuxstudio/                         ← 配置目录
     /usr/share/doc/linuxstudio/              ← 文档
     /var/lib/dpkg/info/linuxstudio.*         ← 包信息文件
     ```

4. **提取控制文件**
   - 提取 `postinst` 脚本到 `/var/lib/dpkg/info/linuxstudio.postinst`
   - 提取 `md5sums` 到 `/var/lib/dpkg/info/linuxstudio.md5sums`
   - 提取 `control` 到 `/var/lib/dpkg/info/linuxstudio.list`

### 阶段 2: 配置 (Setting up)

```
Setting up linuxstudio (1.1.1) ...
```

**发生的事情**：

dpkg 执行 `postinst` 脚本：

```bash
/var/lib/dpkg/info/linuxstudio.postinst configure
```

#### postinst 脚本详细步骤

**步骤 1: 显示配置开始**

```
===================================================
  Configuring LinuxStudio...
===================================================
```

**步骤 2: 创建符号链接**

```bash
→ Creating symbolic links...

# 执行：
if [ ! -L /usr/bin/linuxstudio ]; then
    ln -sf /usr/bin/xkl /usr/bin/linuxstudio 2>/dev/null || true
fi
```

**结果**：
- `/usr/bin/linuxstudio` → `/usr/bin/xkl` (符号链接)
- 向后兼容，允许使用 `linuxstudio` 命令

**步骤 3: 设置权限**

```bash
→ Setting permissions...

# 执行：
chmod +x /usr/bin/xkl 2>/dev/null || true
```

**结果**：
- `/usr/bin/xkl` 设置为可执行 (`755`)

**步骤 4: 创建目录结构**

```bash
→ Creating directory structure...

# 执行：
mkdir -p /opt/linuxstudio/plugins 2>/dev/null || true
mkdir -p /opt/linuxstudio/components 2>/dev/null || true
mkdir -p /opt/linuxstudio/data 2>/dev/null || true
mkdir -p /opt/linuxstudio/logs 2>/dev/null || true
mkdir -p /opt/linuxstudio/scenes 2>/dev/null || true
```

**结果**：
```
/opt/linuxstudio/
├── plugins/           ← 插件目录
├── components/        ← 组件目录
├── data/             ← 数据目录
├── logs/             ← 日志目录
└── scenes/           ← 场景配置目录
```

**步骤 5: 初始化配置文件**

```bash
→ Initializing configuration...

# 执行：
if [ ! -f /etc/linuxstudio/config.yaml ]; then
    mkdir -p /etc/linuxstudio 2>/dev/null || true
    if [ -w /etc/linuxstudio ] || [ -w /etc ]; then
        cat > /etc/linuxstudio/config.yaml <<'EOF'
# LinuxStudio Configuration
version: 1.1.1
install_path: /opt/linuxstudio
log_level: info
auto_update_check: true
EOF
    fi
fi
```

**结果**：
- `/etc/linuxstudio/config.yaml` 创建（如果不存在）
- 包含默认配置

**步骤 6: 初始化框架**

```bash
→ Initializing LinuxStudio framework...

# 执行：
if [ -x /usr/bin/xkl ]; then
    /usr/bin/xkl init --quiet 2>/dev/null || echo "  (Framework initialization skipped - will run on first use)"
fi
```

**结果**：
- 运行 `xkl init --quiet` 初始化框架
- 创建必要的内部数据结构
- 加载默认场景和插件配置

**步骤 7: 显示完成信息**

```
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

### 阶段 3: 更新 dpkg 数据库

**发生的事情**：

1. **更新状态文件**
   - 更新 `/var/lib/dpkg/status`
   - 标记 linuxstudio 为 "installed"
   - 记录版本号 1.1.1

2. **创建包信息文件**
   ```
   /var/lib/dpkg/info/linuxstudio.list         ← 已安装文件列表
   /var/lib/dpkg/info/linuxstudio.md5sums      ← 文件校验和
   /var/lib/dpkg/info/linuxstudio.postinst     ← 安装后脚本
   /var/lib/dpkg/info/linuxstudio.prerm        ← 卸载前脚本（如果有）
   ```

## 📂 最终的文件系统状态

### 系统文件

```
/usr/
├── bin/
│   ├── xkl                              ← 主程序（可执行文件）
│   └── linuxstudio -> /usr/bin/xkl     ← 符号链接
└── share/
    └── doc/
        └── linuxstudio/
            ├── README.md
            ├── LICENSE
            └── ...                      ← 其他文档

/opt/
└── linuxstudio/                         ← 框架根目录
    ├── plugins/                         ← 插件目录（空）
    ├── components/                      ← 组件目录（空）
    ├── data/                           ← 数据目录（空）
    ├── logs/                           ← 日志目录（空）
    └── scenes/                         ← 场景目录（空）

/etc/
└── linuxstudio/
    └── config.yaml                     ← 配置文件

/var/lib/dpkg/
├── status                              ← 包状态数据库（已更新）
└── info/
    └── linuxstudio.*                   ← 包信息文件
```

### 配置文件内容

```yaml
# /etc/linuxstudio/config.yaml
version: 1.1.1
install_path: /opt/linuxstudio
log_level: info
auto_update_check: true
```

## 🎯 安装后立即可用的命令

### 基本命令

```bash
# 查看帮助
xkl --help
xkl help

# 查看版本
xkl --version
xkl version

# 查看状态
xkl status
```

### 框架命令

```bash
# 初始化（如果需要）
xkl init

# 更新框架
xkl update
```

### 管理命令

```bash
# 列出插件
xkl plugin list

# 列出组件
xkl component list

# 列出场景
xkl scene list
```

## 🔧 内部发生的事情

### xkl init 做了什么

当运行 `xkl init` 时（在 postinst 中自动运行）：

1. **检查系统环境**
   - 检测操作系统类型和版本
   - 检测架构（x86_64, ARM64, ARM32）
   - 检测 CPU 核心数和内存

2. **创建内部数据结构**
   - 初始化组件注册表：`/opt/linuxstudio/data/components.json`
   - 初始化插件注册表：`/opt/linuxstudio/data/plugins.json`
   - 初始化场景配置：`/opt/linuxstudio/data/scenes.json`

3. **加载默认配置**
   - 读取 `/etc/linuxstudio/config.yaml`
   - 设置日志级别
   - 配置自动更新检查

4. **创建日志文件**
   - `/opt/linuxstudio/logs/linuxstudio.log`

## 📊 资源占用

### 磁盘空间

```
/usr/bin/xkl                    ≈ 500 KB   (主程序)
/opt/linuxstudio/               ≈ 10 KB    (空目录)
/etc/linuxstudio/               ≈ 1 KB     (配置文件)
/usr/share/doc/linuxstudio/     ≈ 100 KB   (文档)
/var/lib/dpkg/info/linuxstudio* ≈ 10 KB    (包信息)
────────────────────────────────────────────
总计                            ≈ 621 KB
```

### 内存占用

- **安装过程**: ~5-10 MB (临时)
- **xkl init**: ~2-5 MB (临时)
- **运行时**: ~2-5 MB (常驻，取决于功能)

### 进程

安装完成后：
- ✅ 没有常驻进程（按需启动）
- ✅ 没有系统服务
- ✅ 不占用后台资源

## ⚙️ 环境变量

安装后**不会**自动设置环境变量，因为：
- `xkl` 已安装到 `/usr/bin/`（已在 PATH 中）
- 可以直接运行 `xkl` 命令

如果需要自定义配置：

```bash
# 可选：设置配置文件路径
export LINUXSTUDIO_CONFIG=/etc/linuxstudio/config.yaml

# 可选：设置日志级别
export LINUXSTUDIO_LOG_LEVEL=debug

# 可选：设置数据目录
export LINUXSTUDIO_DATA_DIR=/opt/linuxstudio/data
```

## 🔐 权限要求

### 安装时

- **需要**: root 权限（`sudo` 或 `root` 用户）
- **原因**: 需要写入 `/usr/bin/`, `/opt/`, `/etc/` 等系统目录

### 运行时

- **一般操作**: 普通用户即可
  ```bash
  xkl status
  xkl plugin list
  xkl scene list
  ```

- **系统级操作**: 需要 root 权限
  ```bash
  sudo xkl component install <name>
  sudo xkl plugin install <name>
  sudo xkl scene apply <name>
  ```

## 🚫 安装时不会做的事情

### 不会修改

- ❌ 不会修改 shell 配置文件（`.bashrc`, `.zshrc` 等）
- ❌ 不会修改系统环境变量
- ❌ 不会创建系统服务
- ❌ 不会修改系统启动项
- ❌ 不会安装额外的依赖包
- ❌ 不会连接网络（离线安装）

### 不会创建

- ❌ 不会创建系统用户或组
- ❌ 不会创建 cron 任务
- ❌ 不会创建 systemd 服务

### 不会启动

- ❌ 不会启动后台服务
- ❌ 不会启动守护进程

## 🔄 升级时的特殊处理

如果是升级安装（从 1.0.0 → 1.1.1）：

1. **保留配置**
   - `/etc/linuxstudio/config.yaml` 保持不变
   - 只更新程序文件

2. **保留数据**
   - `/opt/linuxstudio/data/` 下的所有数据保留
   - 插件和组件不受影响

3. **覆盖文件**
   - `/usr/bin/xkl` 被新版本替换
   - 文档被更新

## 🗑️ 卸载时会发生什么

```bash
dpkg -r linuxstudio
# 或
apt-get remove linuxstudio
```

**会删除**：
- ✅ `/usr/bin/xkl`
- ✅ `/usr/bin/linuxstudio`（符号链接）
- ✅ `/usr/share/doc/linuxstudio/`

**会保留**（purge 才会删除）：
- ⚠️ `/etc/linuxstudio/` （配置文件）
- ⚠️ `/opt/linuxstudio/` （数据目录）

**完全删除**：
```bash
dpkg -P linuxstudio
# 或
apt-get purge linuxstudio
```

## 📝 日志和调试

### 查看安装日志

```bash
# dpkg 日志
cat /var/log/dpkg.log | grep linuxstudio

# apt 日志
cat /var/log/apt/history.log | grep linuxstudio

# LinuxStudio 日志
cat /opt/linuxstudio/logs/linuxstudio.log
```

### 调试安装问题

```bash
# 重新运行 postinst
/var/lib/dpkg/info/linuxstudio.postinst configure

# 检查文件完整性
dpkg -V linuxstudio

# 查看包信息
dpkg -s linuxstudio

# 列出所有文件
dpkg -L linuxstudio
```

## ✅ 验证安装成功

### 快速验证

```bash
# 1. 检查版本
xkl --version
# 应显示: LinuxStudio CLI v1.1.1 (C++ Core)

# 2. 检查状态
xkl status
# 应显示系统信息

# 3. 检查文件
ls -l /usr/bin/xkl
ls -la /opt/linuxstudio/
cat /etc/linuxstudio/config.yaml
```

### 完整验证

```bash
# 检查所有组件
xkl --version                 # 版本号
xkl status                    # 系统状态
xkl plugin list               # 插件列表
xkl component list            # 组件列表
xkl scene list                # 场景列表
ls -l /var/lib/dpkg/info/linuxstudio.postinst  # postinst 存在
ldd /usr/bin/xkl              # 依赖检查
```

---

**总结：安装过程非常简洁和安全，只创建必要的目录和文件，不会修改系统配置，随时可以完全卸载！** 🎉

