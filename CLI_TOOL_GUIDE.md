# LinuxStudio CLI 工具使用指南

## 📋 概述

`linuxstudio` 是 LinuxStudio 框架的命令行管理工具，安装在 `/usr/local/bin/linuxstudio`，可以在系统任何位置直接使用。

---

## 🚀 快速开始

### 安装后验证

```bash
# 查看版本
linuxstudio version

# 查看帮助
linuxstudio help

# 查看系统状态
linuxstudio status
```

---

## 📦 命令参考

### 1. 框架管理

#### 查看状态
```bash
linuxstudio status
```

**输出示例**：
```
ℹ️  LinuxStudio Framework Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Version:        1.0.0
Install Path:   /opt/linuxstudio
Config Path:    /opt/linuxstudio/config
Data Path:      /opt/linuxstudio/data

Installed Components: 5
Installed Plugins:    3
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### 更新框架
```bash
sudo linuxstudio update
```

---

### 2. 组件管理

#### 列出已安装组件
```bash
linuxstudio component list
```

**输出示例**：
```
ℹ️  Available Components
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  nginx - ✅ Installed
  mysql-server - ✅ Installed
  redis-server - ✅ Installed
  docker - ✅ Installed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### 搜索组件
```bash
linuxstudio component search nginx
```

#### 安装组件
```bash
sudo linuxstudio component install nginx
sudo linuxstudio component install mysql-server
sudo linuxstudio component install redis-server
```

#### 卸载组件
```bash
sudo linuxstudio component uninstall nginx
```

---

### 3. 插件管理 ⭐

插件是 LinuxStudio 的扩展功能，提供专业领域的工具集。

#### 列出所有插件
```bash
linuxstudio plugin list
```

**输出示例**：
```
ℹ️  Installed Plugins
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✅ ros2 (enabled)
  ✅ robot-arm (enabled)
  ⚪ opencv (disabled)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

如果没有安装任何插件，会显示可用插件列表：
```
⚠️  No plugins installed yet.

ℹ️  Available plugins:
  • ros2           - Robot Operating System 2
  • robot-arm      - Robot arm control libraries
  • opencv         - Computer vision library
  • pytorch        - Deep learning framework
  • tensorflow     - Machine learning framework
  • cuda-toolkit   - NVIDIA CUDA development kit

ℹ️  Install a plugin: sudo linuxstudio plugin install <name>
```

#### 安装插件

**安装 ROS2（机器人开发）**：
```bash
sudo linuxstudio plugin install ros2
```

这会：
- 添加 ROS2 apt 仓库
- 安装 `ros-humble-desktop`
- 安装 `python3-colcon-common-extensions`
- 配置环境

**安装机器人臂控制库**：
```bash
sudo linuxstudio plugin install robot-arm
```

这会安装：
- `libmodbus-dev` - Modbus 通信
- `can-utils` - CAN 总线工具
- `liburdfdom-dev` - URDF 机器人描述
- `roboticstoolbox-python` - Python 机器人工具箱

**安装 OpenCV（计算机视觉）**：
```bash
sudo linuxstudio plugin install opencv
```

**安装 PyTorch（深度学习）**：
```bash
sudo linuxstudio plugin install pytorch
```

**安装 TensorFlow（机器学习）**：
```bash
sudo linuxstudio plugin install tensorflow
```

**安装 CUDA Toolkit（NVIDIA GPU）**：
```bash
sudo linuxstudio plugin install cuda-toolkit
```

#### 卸载插件
```bash
sudo linuxstudio plugin uninstall ros2
```

#### 启用/禁用插件

禁用插件（不删除，只是停用）：
```bash
sudo linuxstudio plugin disable opencv
```

重新启用插件：
```bash
sudo linuxstudio plugin enable opencv
```

---

### 4. 场景管理

场景是预配置的开发环境，一键安装所有相关组件。

#### 列出可用场景
```bash
linuxstudio scene list
```

**输出示例**：
```
ℹ️  Available Development Scenes
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  1. web-development       - Web Development (PHP/Java/Node.js)
  2. embedded              - Embedded Systems (ARM/RISC-V)
  3. robotics              - Robotics & Automation (ROS2)
  4. ai-ml                 - AI/ML Development
  5. game-dev              - Game Development
  6. devops                - Cloud Native / DevOps
  7. security              - Cybersecurity / Penetration Testing
  8. blockchain            - Blockchain Development
  9. iot                   - IoT Development
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ️  Apply a scene: sudo linuxstudio scene apply <name>
```

#### 应用场景

**Web 开发场景**：
```bash
sudo linuxstudio scene apply web-development
```
安装：Nginx, PHP, MySQL, Redis

**机器人开发场景**：
```bash
sudo linuxstudio scene apply robotics
```
安装：ROS2, Robot Arm SDK, OpenCV

**AI/ML 开发场景**：
```bash
sudo linuxstudio scene apply ai-ml
```
安装：Python3, pip, PyTorch, TensorFlow

**DevOps 场景**：
```bash
sudo linuxstudio scene apply devops
```
安装：Docker, Docker Compose

---

### 5. 远程服务器管理

管理多台远程服务器，批量部署环境。

#### 列出远程服务器
```bash
linuxstudio remote list
```

#### 添加远程服务器
```bash
sudo linuxstudio remote add user@192.168.1.100
sudo linuxstudio remote add root@server.example.com
```

这会：
- 测试 SSH 连接
- 验证访问权限
- 保存到配置文件

#### 部署到远程服务器
```bash
sudo linuxstudio remote deploy user@192.168.1.100 robotics
```

---

## 💡 使用场景示例

### 场景 1：机器人开发环境

```bash
# 1. 查看状态
linuxstudio status

# 2. 应用机器人场景（自动安装基础组件）
sudo linuxstudio scene apply robotics

# 3. 额外安装需要的插件
sudo linuxstudio plugin install opencv
sudo linuxstudio plugin install pytorch

# 4. 列出已安装的插件
linuxstudio plugin list

# 5. 验证安装
which ros2
python3 -c "import cv2; print(cv2.__version__)"
```

### 场景 2：Web 开发环境（Java 栈）

```bash
# 1. 安装 Web 开发场景
sudo linuxstudio scene apply web-development

# 2. 单独安装 Java 相关组件
sudo linuxstudio component install openjdk-17-jdk
sudo linuxstudio component install tomcat9
sudo linuxstudio component install maven

# 3. 验证
java -version
mvn -version
```

### 场景 3：AI/ML 研究环境

```bash
# 1. 应用 AI/ML 场景
sudo linuxstudio scene apply ai-ml

# 2. 如果有 NVIDIA GPU，安装 CUDA
sudo linuxstudio plugin install cuda-toolkit

# 3. 验证
python3 -c "import torch; print(torch.cuda.is_available())"
python3 -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
```

### 场景 4：多服务器部署

```bash
# 1. 添加多台服务器
sudo linuxstudio remote add user@server1.com
sudo linuxstudio remote add user@server2.com
sudo linuxstudio remote add user@server3.com

# 2. 查看服务器列表
linuxstudio remote list

# 3. 批量部署 DevOps 环境
sudo linuxstudio remote deploy user@server1.com devops
sudo linuxstudio remote deploy user@server2.com devops
sudo linuxstudio remote deploy user@server3.com devops
```

---

## 🔧 插件详细说明

### ROS2 插件
**安装内容**：
- ROS2 Humble Desktop（完整桌面版）
- Colcon 构建工具
- ROS2 Python 扩展

**使用方法**：
```bash
sudo linuxstudio plugin install ros2
source /opt/ros/humble/setup.bash
ros2 run demo_nodes_cpp talker
```

### Robot Arm 插件
**安装内容**：
- Modbus 通信库（工业机械臂常用）
- CAN 总线工具（机器人控制器通信）
- URDF 机器人描述工具
- Robotics Toolbox for Python

**使用场景**：机械臂控制、工业自动化

### OpenCV 插件
**安装内容**：
- OpenCV C++ 开发库
- OpenCV Python 绑定

**使用方法**：
```bash
sudo linuxstudio plugin install opencv
python3 -c "import cv2; print(cv2.__version__)"
```

### PyTorch 插件
**安装内容**：
- PyTorch 深度学习框架
- TorchVision 计算机视觉工具
- TorchAudio 音频处理工具

### TensorFlow 插件
**安装内容**：
- TensorFlow 2.x

### CUDA Toolkit 插件
**要求**：必须有 NVIDIA GPU

**说明**：
- 会检测 GPU
- 提供下载链接和安装指南

---

## 📂 文件结构

```
/opt/linuxstudio/
├── bin/
│   └── linuxstudio          # CLI 可执行文件
├── config/
│   ├── framework.conf       # 框架配置
│   ├── components.json      # 组件注册表
│   ├── plugins.json         # 插件注册表
│   └── remote_servers.conf  # 远程服务器列表
├── data/
│   └── ...
├── plugins/
│   ├── ros2/
│   │   └── metadata.json    # 插件元数据
│   ├── robot-arm/
│   ├── opencv/
│   └── ...
├── components/
│   ├── nginx/
│   ├── mysql-server/
│   └── ...
└── logs/
    └── ...

/usr/local/bin/
└── linuxstudio -> /opt/linuxstudio/bin/linuxstudio  # 符号链接
```

---

## 🛠️ 高级用法

### 插件元数据

每个插件都有一个 `metadata.json` 文件：

```json
{
  "name": "ros2",
  "version": "1.0.0",
  "status": "enabled",
  "installed_at": "2025-10-27T10:30:00+08:00",
  "enabled": true
}
```

### 手动管理插件

**查看插件元数据**：
```bash
cat /opt/linuxstudio/plugins/ros2/metadata.json
```

**手动启用/禁用插件**：
```bash
# 禁用
sudo linuxstudio plugin disable ros2

# 启用
sudo linuxstudio plugin enable ros2
```

---

## ❓ 常见问题

### Q1: 插件和组件有什么区别？

**组件**：系统级软件包（通过 apt/yum 等安装）
- 例如：nginx, mysql-server, docker

**插件**：LinuxStudio 管理的专业工具集
- 例如：ROS2, Robot Arm SDK, CUDA Toolkit
- 可能包含多个组件、配置、脚本

### Q2: 如何查看已安装的插件？

```bash
linuxstudio plugin list
```

### Q3: 插件安装失败怎么办？

1. 查看错误信息
2. 检查网络连接
3. 检查系统权限（是否使用 sudo）
4. 查看日志：`/opt/linuxstudio/logs/`

### Q4: 如何卸载 LinuxStudio？

```bash
sudo rm -rf /opt/linuxstudio
sudo rm -f /usr/local/bin/linuxstudio
```

### Q5: 插件安装后如何使用？

不同插件有不同的使用方法：

**ROS2**：
```bash
source /opt/ros/humble/setup.bash
ros2 --help
```

**PyTorch/TensorFlow**：
```bash
python3 -c "import torch; print(torch.__version__)"
```

---

## 📚 相关文档

- [安装指南](INSTALLATION_GUIDE.md)
- [架构文档](LinuxStudio_Architecture.md)
- [场景升级说明](SCENE_UPGRADE_NOTES.md)
- [主 README](README.md)

---

## 🎓 学习资源

### ROS2 学习
- [ROS2 官方文档](https://docs.ros.org/en/humble/)
- [ROS2 教程](https://docs.ros.org/en/humble/Tutorials.html)

### 机器人开发
- [Robotics Toolbox 文档](https://petercorke.github.io/robotics-toolbox-python/)
- [机械臂运动学教程](https://modernrobotics.northwestern.edu/)

### 深度学习
- [PyTorch 官方教程](https://pytorch.org/tutorials/)
- [TensorFlow 指南](https://www.tensorflow.org/guide)

---

**LinuxStudio - 让 Linux 环境管理更简单！** 🚀

