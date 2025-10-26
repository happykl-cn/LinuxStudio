# LinuxStudio 安装指南

## 快速安装

### 一键安装（推荐）

```bash
curl -fsSL https://linuxstudio.org/heaven.sh | sudo bash
```

或者使用 wget：

```bash
wget -qO- https://linuxstudio.org/heaven.sh | sudo bash
```

### 手动安装

```bash
# 下载安装脚本
wget https://linuxstudio.org/heaven.sh

# 赋予执行权限
chmod +x heaven.sh

# 运行安装
sudo ./heaven.sh
```

### 安装选项

```bash
# 非交互式安装（跳过所有确认）
sudo bash heaven.sh -y

# 跳过场景选择
sudo bash heaven.sh -s

# 组合使用（完全自动化）
sudo bash heaven.sh -y -s

# 查看帮助
bash heaven.sh --help

# 查看版本
bash heaven.sh --version
```

---

## 安装流程说明

### 1. 欢迎界面

脚本会显示 LinuxStudio 的 ASCII 艺术 Logo 和版本信息。

### 2. 系统检测

自动检测以下信息：
- 操作系统类型和版本
- CPU 架构（x86_64, ARM, etc.）
- CPU 核心数
- 内存大小
- 可用磁盘空间
- 网络位置（国内/国外）

### 3. 系统要求检查

- **最小内存**：1GB（推荐 2GB+）
- **支持的系统**：
  - Ubuntu / Debian / Linux Mint / Kali
  - Fedora / RHEL / CentOS / Rocky / AlmaLinux
  - Arch / Manjaro
  - openSUSE

> **注意**：已取消磁盘空间检查，允许在任何容量下安装。

### 4. 确认安装

脚本会显示将要进行的系统修改：
- 包管理器镜像源配置（国内网络）
- 系统限制和内核参数优化
- Swap 配置
- 时区设置

### 5. 系统优化

- **镜像源配置**：国内网络自动切换到阿里云镜像
- **Swap 配置**：如果没有 swap，自动创建 2GB swap 文件
- **SELinux**：自动禁用（CentOS/RHEL）
- **时区**：国内网络自动设置为 Asia/Shanghai
- **系统限制**：
  - 文件描述符：65535
  - 进程数：65535
  - TCP 优化参数

### 6. 安装必备组件

自动安装以下工具（显示实时进度和速度）：
- `curl` - 下载工具
- `wget` - 下载工具
- `git` - 版本控制
- `vim` - 文本编辑器
- `tar` / `unzip` - 压缩工具
- `gcc` / `g++` / `make` - 编译工具（Build Tools）
- `cmake` - 构建系统

**安装进度显示**：
```
[7/8] Checking Build Tools (gcc/g++/make)...
🔹 Installing Build Tools (gcc/g++/make)...
   [/] Build Tools | 45s | 156MB | 3MB/s | Downloading...
✅ Build Tools (gcc/g++/make) installed successfully (234MB in 95s)
ℹ️  GCC: /usr/bin/gcc
ℹ️  G++: /usr/bin/g++
ℹ️  Make: /usr/bin/make
```

特性：
- ⏱️ 实时显示已用时间
- 📦 显示已下载大小（KB/MB）
- 🚀 显示下载速度（KB/s 或 MB/s）
- 📊 显示当前状态（Downloading/Installing/Processing）
- 🔄 自动重试机制（最多2次）
- ⏰ 超时保护（10分钟）

### 7. 安装框架组件

- **vcpkg**：C++ 包管理器
  - 支持进度显示和超时控制（5分钟）
  - 自动重试机制
  - 显示克隆进度百分比
- **ninja**：高性能构建系统
- **ccache**：编译缓存加速

**vcpkg 安装进度示例**：
```
[1/3] Installing vcpkg (C++ Package Manager)...
ℹ️  Cloning vcpkg repository (this may take a few minutes)...
   [/] Cloning vcpkg... 35s | 45%
✅ vcpkg installed successfully
ℹ️  Location: /opt/linuxstudio/vcpkg
ℹ️  Binary: /usr/local/bin/vcpkg
```

### 8. 安装 LinuxStudio 核心

创建以下目录结构：
```
/opt/linuxstudio/
├── bin/           # 可执行文件
├── lib/           # 库文件
├── config/        # 配置文件
├── data/          # 数据文件
├── scripts/       # 脚本文件
├── web/           # Web 界面
└── logs/          # 日志文件
```

### 9. 场景选择（交互式）

选择你的开发场景：

#### 1️⃣ Web 开发
安装：Nginx, PHP, MySQL, Redis, Node.js

#### 2️⃣ 嵌入式开发（ARM/RISC-V）
安装：ARM 交叉编译器, OpenOCD, Minicom, 串口工具

#### 3️⃣ AI/ML 开发
安装：Python3, pip, CUDA toolkit, TensorFlow, PyTorch

#### 4️⃣ 游戏开发
安装：SDL2, OpenGL, Vulkan（即将推出）

#### 5️⃣ DevOps
安装：Docker, Kubernetes, Ansible, Jenkins

#### 6️⃣ 跳过
稍后使用 `linuxstudio scene apply` 安装

### 10. 完成安装

显示安装摘要和快速开始指南。

---

## 安装后使用

### 检查安装状态

```bash
linuxstudio status
```

### 组件管理

```bash
# 列出所有组件
linuxstudio component list

# 搜索组件
linuxstudio component search nginx

# 安装组件
linuxstudio component install nginx

# 卸载组件
linuxstudio component uninstall nginx

# 更新组件
linuxstudio component update nginx
```

### 插件管理

```bash
# 列出所有插件
linuxstudio plugin list

# 安装插件
linuxstudio plugin install ros2

# 卸载插件
linuxstudio plugin uninstall ros2

# 启用/禁用插件
linuxstudio plugin enable ros2
linuxstudio plugin disable ros2
```

### 场景管理

```bash
# 列出预设场景
linuxstudio scene list

# 应用场景
linuxstudio scene apply web-development

# 创建自定义场景
linuxstudio scene create my-scene
```

### 多服务器管理

```bash
# 添加远程服务器
linuxstudio remote add user@192.168.1.100

# 列出远程服务器
linuxstudio remote list

# 部署到远程服务器
linuxstudio remote deploy user@192.168.1.100 web-development

# 同步配置到所有服务器
linuxstudio remote sync
```

---

## 日志文件

安装日志保存在：
```
/tmp/linuxstudio_install_YYYYMMDD_HHMMSS.log
```

如果安装失败，请查看日志文件以获取详细错误信息。

---

## 卸载

```bash
# 卸载 LinuxStudio（即将推出）
sudo linuxstudio uninstall

# 手动卸载
sudo rm -rf /opt/linuxstudio
sudo rm -f /usr/local/bin/linuxstudio
sudo rm -f /etc/systemd/system/linuxstudio.service
```

---

## 常见问题

### Q: 安装失败怎么办？

A: 
1. 检查日志文件：`/tmp/linuxstudio_install_*.log`
2. 确保有 root 权限
3. 确保网络连接正常
4. 如果某个包安装失败，脚本会自动重试2次
5. 重试后仍失败会询问是否继续，可选择跳过
6. 到社区寻求帮助：https://community.linuxstudio.org

### Q: 支持哪些 Linux 发行版？

A: 
- Ubuntu 18.04+
- Debian 10+
- CentOS 7+
- Fedora 30+
- Arch Linux
- openSUSE

### Q: 国内网络安装很慢怎么办？

A: 
1. 脚本会自动检测国内网络并切换到阿里云镜像源
2. 启用了 APT 并行下载（5个并发连接）
3. 显示实时下载速度，可以监控进度
4. 如果超时，会自动重试
5. 可以手动优化镜像源：
   ```bash
   sudo sed -i 's|http://archive.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list
   sudo apt-get update
   ```

### Q: 可以在生产服务器上安装吗？

A: 建议先在测试环境验证。脚本会修改一些系统配置，请谨慎使用。

### Q: 如何更新 LinuxStudio？

A: 
```bash
linuxstudio update
```

### Q: 如何自定义安装组件？

A: 使用 YAML 配置文件：
```bash
linuxstudio component install --custom my-component.yaml
```

---

## 技术支持

- 📚 文档：https://docs.linuxstudio.org
- 💬 社区：https://community.linuxstudio.org
- 🐛 问题反馈：https://github.com/happykl-cn/LinuxStudio/issues
- 📧 邮件：support@linuxstudio.org

---

## 贡献

欢迎贡献代码、文档或反馈！

1. Fork 仓库
2. 创建功能分支
3. 提交 Pull Request

详见：[CONTRIBUTING.md](CONTRIBUTING.md)

---

**LinuxStudio - 让 Linux 环境管理更简单！** 🚀


