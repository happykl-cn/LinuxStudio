# xkl 命令快速参考

## 🚀 常用命令

```bash
# 框架管理
xkl status              # 查看状态
xkl version             # 查看版本
xkl help                # 帮助信息

# 插件管理（最常用）⭐
xkl plugin list                  # 列出插件
xkl plugin install ros2          # 安装 ROS2
xkl plugin install robot-arm     # 安装机械臂库
xkl plugin install opencv        # 安装 OpenCV
xkl plugin install pytorch       # 安装 PyTorch
xkl plugin enable ros2           # 启用插件
xkl plugin disable ros2          # 禁用插件

# 组件管理
xkl component list               # 列出组件
xkl component install nginx      # 安装 Nginx
xkl component install docker     # 安装 Docker

# 场景管理
xkl scene list                   # 列出场景
xkl scene apply robotics         # 应用机器人场景
xkl scene apply web-development  # 应用 Web 场景
xkl scene apply ai-ml            # 应用 AI/ML 场景
```

## 📦 可用插件

| 插件 | 命令 | 说明 |
|------|------|------|
| ROS2 | `xkl plugin install ros2` | 机器人操作系统 2 |
| Robot Arm | `xkl plugin install robot-arm` | 机械臂控制库 |
| OpenCV | `xkl plugin install opencv` | 计算机视觉 |
| PyTorch | `xkl plugin install pytorch` | 深度学习框架 |
| TensorFlow | `xkl plugin install tensorflow` | 机器学习框架 |
| CUDA | `xkl plugin install cuda-toolkit` | NVIDIA GPU 支持 |

## 🎯 开发场景

| 场景 | 命令 |
|------|------|
| Web 开发 | `xkl scene apply web-development` |
| 嵌入式开发 | `xkl scene apply embedded` |
| 机器人开发 | `xkl scene apply robotics` |
| AI/ML 开发 | `xkl scene apply ai-ml` |
| 游戏开发 | `xkl scene apply game-dev` |
| DevOps | `xkl scene apply devops` |
| 网络安全 | `xkl scene apply security` |
| 区块链 | `xkl scene apply blockchain` |
| 物联网 | `xkl scene apply iot` |

## 💡 提示

- 命令 `xkl` 替代了 `linuxstudio`（更短更快）
- 旧命令 `linuxstudio` 仍然可用（向后兼容）
- 大多数命令需要 `sudo` 权限

**快速上手**: `xkl --help`

