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

LinuxStudio 提供多种专业开发场景，每个场景包含精选的开发工具和组件。选择场景后，您可以自定义安装所需的组件。

#### 🎯 可用场景

##### 1️⃣ Web Development（Web 开发）
完整的全栈 Web 开发环境，支持 PHP、Java、Node.js 技术栈

**可选组件**：

**Web 服务器**：
- Nginx - 高性能 Web 服务器
- Apache - 流行的 Web 服务器（Nginx 替代方案）

**编程语言与框架**：
- PHP 8.x + PHP-FPM - 服务端脚本语言
- Java (OpenJDK 17) - Java 运行环境
- Tomcat - Java 应用服务器
- Spring Boot CLI - Spring 框架工具
- Maven - Java 项目管理工具
- Gradle - 构建自动化工具
- Node.js + npm - JavaScript 运行时
- Composer - PHP 依赖管理器

**数据库与缓存**：
- MySQL 8.x - 关系型数据库
- PostgreSQL - 高级关系型数据库
- Redis - 内存数据存储与缓存
- Memcached - 分布式内存缓存

**安全与证书**：
- Certbot - Let's Encrypt SSL 证书
- ModSecurity (WAF) - Web 应用防火墙
- Fail2Ban - 入侵防御系统

**监控与日志**：
- Logrotate - 日志轮转工具
- ELK Stack - Elasticsearch, Logstash, Kibana（集中式日志）
- Prometheus - 监控与告警系统
- Grafana - 指标可视化面板

**进程管理**：
- Supervisor - 进程控制系统

**推荐配置**：
- PHP 栈：Nginx + PHP + MySQL + Redis + Node.js
- Java 栈：Nginx + Java + Tomcat + MySQL + Redis
- 系统运维：ModSecurity + Fail2Ban + Prometheus + Grafana

---

##### 2️⃣ Embedded Systems（嵌入式系统开发）
MCU/SoC 开发与交叉编译工具链

**可选组件**：
- ARM GCC Toolchain - ARM Cortex-M/A 交叉编译器
- RISC-V GCC Toolchain - RISC-V 交叉编译器
- OpenOCD - 片上调试器（JTAG/SWD）
- GDB Multiarch - 多架构调试器
- Minicom - 串口终端模拟器
- PuTTY/Screen - 替代串口工具
- I2C Tools - I2C 总线工具
- SPI Tools - SPI 总线工具
- ST-Link Tools - STMicroelectronics 编程器
- J-Link Tools - SEGGER J-Link 工具
- Platform.io - 嵌入式开发平台
- Arduino CLI - Arduino 命令行工具

**推荐配置**：ARM GCC + OpenOCD + GDB + Minicom + I2C/SPI Tools

---

##### 3️⃣ Robotics & Automation（机器人与自动化）
机器人控制、ROS2、运动规划、感知系统

**可选组件**：
- ROS2 Humble - 机器人操作系统 2
- MoveIt2 - 运动规划框架
- Gazebo - 3D 机器人仿真器
- RViz2 - 3D 可视化工具
- Python3 + NumPy - 脚本与数学计算
- OpenCV - 计算机视觉库
- PCL - 点云处理库
- URDF Tools - 机器人描述工具
- CAN Utils - CAN 总线工具（机器人控制器）
- Modbus Tools - 工业通信协议
- EtherCAT - 实时以太网协议
- Robot Arm SDK - 机械臂控制库

**推荐配置**：ROS2 + MoveIt2 + Gazebo + OpenCV + Robot Arm SDK

**适用于**：机械臂控制、移动机器人、工业自动化、无人机开发

---

##### 4️⃣ AI/ML Development（人工智能/机器学习）
深度学习、计算机视觉、数据科学

**可选组件**：
- Python3 + pip - Python 开发环境
- Jupyter Notebook - 交互式笔记本
- NumPy + SciPy - 科学计算
- Pandas - 数据分析
- Matplotlib + Seaborn - 数据可视化
- Scikit-learn - 机器学习库
- TensorFlow - 深度学习框架
- PyTorch - 深度学习框架
- OpenCV - 计算机视觉
- CUDA Toolkit - NVIDIA GPU 支持
- cuDNN - 深度学习 GPU 加速
- Anaconda - 数据科学平台

**推荐配置**：Python3 + Jupyter + NumPy + Pandas + TensorFlow/PyTorch

---

##### 5️⃣ Game Development（游戏开发）
游戏引擎、图形库、资源工具

**可选组件**：
- SDL2 - Simple DirectMedia Layer
- OpenGL - 图形 API
- GLFW - OpenGL 框架
- GLEW - OpenGL 扩展加载器
- Vulkan SDK - 下一代图形 API
- Godot Engine - 开源游戏引擎
- Unity Editor - 流行游戏引擎
- Unreal Engine - AAA 游戏引擎
- Blender - 3D 建模与动画
- Aseprite - 像素艺术编辑器
- FMOD - 音频中间件

**推荐配置**：SDL2 + OpenGL + Godot/Unity + Blender

---

##### 6️⃣ Cloud Native / DevOps（云原生 / 运维）
容器编排、基础设施即代码、CI/CD 流水线、完整的监控与日志系统

**可选组件**：

**容器与编排**：
- Docker - 容器运行时
- Docker Compose - 多容器编排
- Kubernetes (kubectl) - 容器编排平台
- Helm - Kubernetes 包管理器
- Portainer - Docker 管理 UI

**基础设施即代码**：
- Terraform - 基础设施即代码
- Ansible - 配置管理

**CI/CD 工具**：
- Jenkins - CI/CD 自动化服务器
- GitLab Runner - GitLab CI/CD
- GitHub Actions Runner - GitHub CI/CD

**监控与告警**：
- Prometheus - 监控与告警系统
- Grafana - 指标可视化面板
- Node Exporter - 硬件与操作系统指标收集器
- cAdvisor - 容器指标收集器
- Alertmanager - 告警处理与路由
- Zabbix - 企业级监控解决方案
- Netdata - 实时性能监控面板

**日志聚合**：
- ELK Stack - Elasticsearch, Logstash, Kibana（集中式日志）
- Loki + Promtail - 日志聚合系统
- Fluentd - 统一日志层

**负载均衡与代理**：
- Nginx - 反向代理与负载均衡
- Traefik - 云原生边缘路由器
- HAProxy - 高可用负载均衡器

**任务调度与进程管理**：
- Cron - 任务调度守护进程
- Supervisor - 进程控制系统
- systemd-cron - Systemd 定时器单元

**推荐配置**：
- 容器栈：Docker + Kubernetes + Helm + Terraform
- 监控栈：Prometheus + Grafana + Node Exporter + Alertmanager
- 日志栈：ELK Stack / Loki + Promtail

---

##### 7️⃣ Cybersecurity / Penetration Testing（网络安全 / 渗透测试）
安全审计、渗透测试、取证分析

**可选组件**：
- Nmap - 网络扫描器
- Wireshark - 网络协议分析器
- Metasploit - 渗透测试框架
- Burp Suite - Web 安全测试
- John the Ripper - 密码破解工具
- Hashcat - 高级密码恢复
- Aircrack-ng - 无线安全工具
- SQLMap - SQL 注入工具
- Nikto - Web 服务器扫描器
- Hydra - 网络登录破解器
- OWASP ZAP - Web 应用安全扫描器
- Volatility - 内存取证工具

**推荐配置**：Nmap + Wireshark + Metasploit + Burp Suite + SQLMap

⚠️ **重要提示**：仅在授权系统上使用这些工具！未经授权的渗透测试是违法行为。

---

##### 8️⃣ Blockchain Development（区块链开发）
智能合约、DApp 开发、Web3 工具

**可选组件**：
- Node.js + npm - JavaScript 运行时
- Hardhat - Ethereum 开发环境
- Truffle - 智能合约框架
- Ganache - 个人区块链
- Web3.js - Ethereum JavaScript API
- Ethers.js - Ethereum 库
- Solidity Compiler - 智能合约语言
- Go-Ethereum (Geth) - Ethereum 客户端
- IPFS - 分布式文件系统
- Rust + Solana CLI - Solana 开发
- Anchor - Solana 框架

**推荐配置**：Node.js + Hardhat + Web3.js + Solidity + IPFS

---

##### 9️⃣ IoT Development（物联网开发）
IoT 平台、MQTT、边缘计算

**可选组件**：
- MQTT Broker (Mosquitto) - 消息代理
- MQTT Clients - 发布/订阅工具
- Node-RED - 流程编程平台
- InfluxDB - 时序数据库
- Grafana - IoT 数据可视化
- Python3 + Paho MQTT - MQTT 库
- Arduino CLI - Arduino 开发
- Platform.io - IoT 开发平台
- Home Assistant - 家庭自动化
- Zigbee2MQTT - Zigbee 转 MQTT 桥接
- ESPHome - ESP32/ESP8266 固件

**推荐配置**：Mosquitto + Node-RED + InfluxDB + Grafana + Python MQTT

---

##### 0️⃣ 跳过
稍后使用 `linuxstudio scene apply <scene-name>` 安装

---

#### 📝 使用说明

1. **场景选择**：安装过程中会显示场景菜单，输入数字（0-9）选择场景

2. **组件选择**：选择场景后，会显示该场景的所有可用组件
   - 输入 `A` 或 `a`：安装所有组件（推荐）
   - 输入数字（如 `1 2 3`）：安装特定组件
   - 输入 `0`：跳过此场景

3. **示例**：
   ```
   Your choice [0-9]: 3
   
   ═══════════════════════════════════════════════════════════════
     Robotics & Automation - Component Selection
   ═══════════════════════════════════════════════════════════════
   
     1) ROS2 Humble - Robot Operating System 2
     2) MoveIt2 - Motion planning framework
     3) Gazebo - 3D robot simulator
     4) OpenCV - Computer vision library
     5) Robot Arm SDK - Manipulator control libraries
     ...
   
     A) Install All (Recommended)
     0) Skip this scene
   
   Enter your choices (e.g., 1 2 3 or A for all) [A]: 1 2 4 5
   ```

4. **确认安装**：选择组件后会显示确认提示，输入 `Y` 继续安装

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


