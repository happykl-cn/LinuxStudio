# LinuxStudio 架构设计文档

## 项目概述

**LinuxStudio** 是一个高性能、模块化的 Linux 环境管理框架，旨在为不同使用场景提供快速、交互式的系统配置和工具链管理解决方案。

### 核心理念

- 🚀 **一键部署**：`curl | bash` 即可启动交互式安装
- 🎯 **场景驱动**：根据使用场景（嵌入式开发、Web 开发、AI/ML 等）智能推荐组件
- 🔧 **模块化设计**：核心框架 + 组件管理器 + 插件管理器
- ⚡ **高性能**：核心框架基于 C++ 实现，追求极致性能
- 🌐 **多服务器支持**：一个脚本可在多台服务器上并行部署

---

## 系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                     LinuxStudio Framework                    │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   Core      │  │  Component   │  │   Plugin     │       │
│  │   Engine    │  │   Manager    │  │   Manager    │       │
│  │   (C++)     │  │   (C++)      │  │   (C++)      │       │
│  └──────┬──────┘  └──────┬───────┘  └──────┬───────┘       │
│         │                │                  │                │
│         └────────────────┴──────────────────┘                │
│                          │                                   │
│         ┌────────────────┴────────────────┐                 │
│         │                                  │                 │
│  ┌──────▼──────┐                  ┌───────▼────────┐        │
│  │   CLI       │                  │   GUI Panel    │        │
│  │  Interface  │                  │   (Web-based)  │        │
│  └─────────────┘                  └────────────────┘        │
│                                                               │
└─────────────────────────────────────────────────────────────┘
         │                          │                 │
         ▼                          ▼                 ▼
   ┌─────────┐              ┌─────────┐       ┌─────────┐
   │ System  │              │Component│       │ Plugin  │
   │ Utils   │              │Registry │       │Registry │
   └─────────┘              └─────────┘       └─────────┘
```

---

## 核心模块设计

### 1. Core Engine (核心引擎)

**职责**：框架的核心调度和管理中心

**技术栈**：C++17/20

**核心功能**：
- 系统环境检测（OS 版本、架构、已安装软件）
- 依赖关系解析
- 安装任务调度
- 并发任务管理（多服务器支持）
- 日志系统
- 配置管理

**关键类设计**：

```cpp
namespace LinuxStudio {

// 核心引擎
class CoreEngine {
public:
    static CoreEngine& getInstance();
    
    // 初始化框架
    bool initialize(const Config& config);
    
    // 系统检测
    SystemInfo detectSystem();
    
    // 场景推荐
    std::vector<Component> recommendComponents(SceneType scene);
    
    // 任务调度
    void scheduleTask(Task task);
    
private:
    ComponentManager componentMgr_;
    PluginManager pluginMgr_;
    TaskScheduler scheduler_;
    Logger logger_;
};

// 系统信息
struct SystemInfo {
    std::string osName;
    std::string osVersion;
    std::string architecture;
    std::map<std::string, std::string> installedPackages;
    uint64_t totalMemory;
    uint32_t cpuCores;
};

// 场景类型
enum class SceneType {
    WebDevelopment,      // Web 开发
    EmbeddedDevelopment, // 嵌入式开发
    AIMLDevelopment,     // AI/ML 开发
    GameDevelopment,     // 游戏开发
    DevOps,              // 运维
    Custom               // 自定义
};

}
```

---

### 2. Component Manager (组件管理器)

**职责**：管理框架核心组件和系统基础工具

**组件分类**：

#### 2.1 必备组件（Mandatory Components）
安装框架时自动安装：
- `build-essential` (gcc, g++, make)
- `cmake`
- `git`
- `curl`, `wget`
- `vim` / `nano`
- `tar`, `gzip`, `unzip`

#### 2.2 框架组件（Framework Components）
框架运行所需：
- `vcpkg` - C++ 包管理器
- `ninja` - 构建系统
- `ccache` - 编译缓存
- `gdb` - 调试器
- `valgrind` - 内存检查

#### 2.3 场景组件（Scene Components）
根据使用场景选装：

**Web 开发场景**：
- `nginx` / `apache2`
- `openssl`, `libssl-dev`
- `php-fpm`, `php-mysql`
- `mysql-server` / `postgresql`
- `redis-server`
- `nodejs`, `npm`

**嵌入式开发场景**：
- `arm-none-eabi-gcc` - ARM 交叉编译器
- `openocd` - 调试器
- `minicom` - 串口工具
- `i2c-tools`, `spi-tools`
- 实时内核补丁

**AI/ML 开发场景**：
- `python3`, `pip3`
- `cuda-toolkit`
- `cudnn`
- `tensorrt`
- `opencv`

**关键类设计**：

```cpp
namespace LinuxStudio {

class ComponentManager {
public:
    // 安装组件
    bool installComponent(const std::string& name, const Version& version);
    
    // 卸载组件
    bool uninstallComponent(const std::string& name);
    
    // 更新组件
    bool updateComponent(const std::string& name);
    
    // 列出已安装组件
    std::vector<Component> listInstalled();
    
    // 列出可用组件
    std::vector<Component> listAvailable(ComponentCategory category);
    
    // 搜索组件
    std::vector<Component> search(const std::string& keyword);
    
    // 检查依赖
    DependencyGraph checkDependencies(const std::string& name);
    
    // 自定义组件安装
    bool installCustomComponent(const ComponentSpec& spec);
    
private:
    ComponentRegistry registry_;
    DependencyResolver resolver_;
};

// 组件定义
struct Component {
    std::string name;
    std::string displayName;
    std::string description;
    Version version;
    ComponentCategory category;
    std::vector<std::string> dependencies;
    std::string installScript;
    std::string uninstallScript;
    std::map<std::string, std::string> metadata;
};

// 组件分类
enum class ComponentCategory {
    Mandatory,    // 必备
    Framework,    // 框架
    WebDev,       // Web 开发
    Embedded,     // 嵌入式
    AIML,         // AI/ML
    DevOps,       // 运维
    Custom        // 自定义
};

}
```

---

### 3. Plugin Manager (插件管理器)

**职责**：管理用户场景特定的工具和框架

**插件分类**：

#### 3.1 开发框架插件
- `ros2` - 机器人操作系统
- `qt5` / `qt6` - GUI 框架
- `boost` - C++ 库
- `eigen` - 线性代数库
- `opencv` - 计算机视觉

#### 3.2 Web 框架插件
- `laravel` - PHP 框架
- `django` - Python 框架
- `express` - Node.js 框架
- `spring-boot` - Java 框架

#### 3.3 工具链插件
- `docker` - 容器化
- `kubernetes` - 容器编排
- `ansible` - 自动化运维
- `jenkins` - CI/CD

**关键类设计**：

```cpp
namespace LinuxStudio {

class PluginManager {
public:
    // 安装插件
    bool installPlugin(const std::string& name, const Version& version);
    
    // 卸载插件
    bool uninstallPlugin(const std::string& name);
    
    // 启用/禁用插件
    bool enablePlugin(const std::string& name);
    bool disablePlugin(const std::string& name);
    
    // 列出插件
    std::vector<Plugin> listInstalled();
    std::vector<Plugin> listAvailable(PluginCategory category);
    
    // 搜索插件
    std::vector<Plugin> search(const std::string& keyword);
    
    // 插件配置
    bool configurePlugin(const std::string& name, const Config& config);
    
    // 自定义插件安装
    bool installCustomPlugin(const PluginSpec& spec);
    
private:
    PluginRegistry registry_;
    PluginLoader loader_;
};

// 插件定义
struct Plugin {
    std::string name;
    std::string displayName;
    std::string description;
    Version version;
    PluginCategory category;
    std::vector<std::string> dependencies; // 依赖的组件
    std::string installScript;
    std::string uninstallScript;
    std::string configFile;
    bool enabled;
};

// 插件分类
enum class PluginCategory {
    Framework,     // 开发框架
    WebFramework,  // Web 框架
    Toolchain,     // 工具链
    Database,      // 数据库
    Monitoring,    // 监控
    Custom         // 自定义
};

}
```

---

### 4. CLI Interface (命令行界面)

**职责**：提供交互式命令行操作界面

**核心命令**：

```bash
# 框架管理
linuxstudio init              # 初始化框架
linuxstudio status            # 查看框架状态
linuxstudio update            # 更新框架
linuxstudio config            # 配置框架

# 组件管理
linuxstudio component list                    # 列出组件
linuxstudio component search <keyword>        # 搜索组件
linuxstudio component install <name>          # 安装组件
linuxstudio component uninstall <name>        # 卸载组件
linuxstudio component update <name>           # 更新组件
linuxstudio component info <name>             # 组件信息

# 插件管理
linuxstudio plugin list                       # 列出插件
linuxstudio plugin search <keyword>           # 搜索插件
linuxstudio plugin install <name>             # 安装插件
linuxstudio plugin uninstall <name>           # 卸载插件
linuxstudio plugin enable <name>              # 启用插件
linuxstudio plugin disable <name>             # 禁用插件
linuxstudio plugin config <name>              # 配置插件

# 场景管理
linuxstudio scene list                        # 列出预设场景
linuxstudio scene apply <scene>               # 应用场景配置
linuxstudio scene create <name>               # 创建自定义场景

# 多服务器管理
linuxstudio remote add <host>                 # 添加远程服务器
linuxstudio remote list                       # 列出远程服务器
linuxstudio remote deploy <host> <scene>      # 部署到远程服务器
linuxstudio remote sync                       # 同步配置到所有服务器
```

**交互式安装流程**：

```
$ curl -fsSL https://linuxstudio.dev/heaven.sh | bash

╔════════════════════════════════════════════════════════════╗
║           Welcome to LinuxStudio Framework v1.0            ║
║        High-Performance Linux Environment Manager          ║
╚════════════════════════════════════════════════════════════╝

🔍 Detecting system...
   ✓ OS: Ubuntu 22.04 LTS
   ✓ Architecture: x86_64
   ✓ Memory: 16 GB
   ✓ CPU: 8 cores

📦 Installing mandatory components...
   ✓ gcc/g++ (11.3.0)
   ✓ cmake (3.22.1)
   ✓ git (2.34.1)
   ✓ vim (8.2)

🎯 Please select your usage scenario:
   1) Web Development
   2) Embedded Development (ARM/RISC-V)
   3) AI/ML Development
   4) Game Development
   5) DevOps
   6) Custom (Manual selection)

Your choice [1-6]: 2

🤖 Embedded Development scenario selected!

📋 Recommended components:
   • arm-none-eabi-gcc - ARM cross compiler
   • openocd - On-chip debugger
   • minicom - Serial communication
   • i2c-tools - I2C utilities

Install recommended components? [Y/n]: Y

🔌 Available plugins for this scenario:
   • ros2 - Robot Operating System 2
   • opencv - Computer Vision library
   • eigen - Linear algebra library

Select plugins to install (space-separated, or 'skip'): ros2 opencv

⚙️  Installing components and plugins...
   [████████████████████████████████████] 100%

✅ Installation complete!

🚀 Quick start:
   • Run 'linuxstudio status' to check installation
   • Run 'linuxstudio plugin list' to see installed plugins
   • Run 'linuxstudio --help' for more commands

📚 Documentation: https://linuxstudio.dev/docs
```

---

### 5. GUI Panel (图形化管理面板)

**职责**：提供 Web 界面进行可视化管理

**技术栈**：
- 后端：C++ (Crow/Drogon Web Framework)
- 前端：Vue.js 3 + TypeScript
- 通信：RESTful API + WebSocket

**核心功能**：

1. **Dashboard（仪表盘）**
   - 系统资源监控（CPU、内存、磁盘）
   - 已安装组件/插件概览
   - 最近操作日志

2. **Component Manager（组件管理）**
   - 可视化组件列表
   - 一键安装/卸载
   - 依赖关系图谱
   - 版本管理

3. **Plugin Manager（插件管理）**
   - 插件市场
   - 插件配置界面
   - 启用/禁用开关

4. **Scene Manager（场景管理）**
   - 预设场景模板
   - 自定义场景配置
   - 场景导入/导出

5. **Remote Manager（远程管理）**
   - 多服务器列表
   - 批量部署
   - 配置同步

6. **Settings（设置）**
   - 框架配置
   - 镜像源设置
   - 代理配置

**API 设计**：

```cpp
// REST API 端点
GET    /api/v1/system/info              // 系统信息
GET    /api/v1/components               // 组件列表
POST   /api/v1/components/:name/install // 安装组件
DELETE /api/v1/components/:name         // 卸载组件
GET    /api/v1/plugins                  // 插件列表
POST   /api/v1/plugins/:name/install    // 安装插件
PUT    /api/v1/plugins/:name/config     // 配置插件
GET    /api/v1/scenes                   // 场景列表
POST   /api/v1/scenes/:name/apply       // 应用场景
GET    /api/v1/remotes                  // 远程服务器列表
POST   /api/v1/remotes/:host/deploy     // 部署到远程

// WebSocket 端点
WS     /ws/logs                         // 实时日志流
WS     /ws/progress                     // 安装进度
```

---

## 数据存储设计

### 配置文件结构

```
/opt/linuxstudio/
├── bin/
│   └── linuxstudio              # 主程序
├── lib/
│   ├── liblinuxstudio-core.so   # 核心库
│   ├── liblinuxstudio-component.so
│   └── liblinuxstudio-plugin.so
├── config/
│   ├── framework.conf           # 框架配置
│   ├── components.json          # 组件注册表
│   ├── plugins.json             # 插件注册表
│   └── scenes.json              # 场景配置
├── data/
│   ├── installed_components.db  # 已安装组件数据库
│   ├── installed_plugins.db     # 已安装插件数据库
│   └── logs/                    # 日志目录
├── scripts/
│   ├── install/                 # 安装脚本
│   ├── uninstall/               # 卸载脚本
│   └── config/                  # 配置脚本
└── web/
    ├── index.html               # GUI 面板
    └── assets/                  # 前端资源
```

### 组件注册表格式 (components.json)

```json
{
  "version": "1.0",
  "components": [
    {
      "id": "nginx",
      "name": "Nginx",
      "description": "High-performance HTTP server",
      "category": "WebDev",
      "version": "1.24.0",
      "dependencies": ["openssl", "pcre"],
      "install_script": "scripts/install/nginx.sh",
      "uninstall_script": "scripts/uninstall/nginx.sh",
      "config_template": "config/nginx.conf.template",
      "metadata": {
        "homepage": "https://nginx.org",
        "license": "BSD-2-Clause",
        "size": "1.2 MB"
      }
    }
  ]
}
```

### 场景配置格式 (scenes.json)

```json
{
  "version": "1.0",
  "scenes": [
    {
      "id": "web-development",
      "name": "Web Development",
      "description": "Full stack web development environment",
      "components": [
        "nginx",
        "mysql-server",
        "redis-server",
        "nodejs",
        "php-fpm"
      ],
      "plugins": [
        "laravel",
        "vue-cli"
      ],
      "system_optimizations": {
        "max_open_files": 65535,
        "tcp_keepalive": true
      }
    }
  ]
}
```

---

## 性能优化策略

### 1. 编译优化
```cpp
// CMakeLists.txt
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -march=native -flto")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
```

### 2. 并发处理
- 使用 C++20 协程处理异步任务
- 线程池管理并发安装任务
- 无锁数据结构优化性能

```cpp
// 并发安装示例
class TaskScheduler {
    std::vector<std::future<bool>> installConcurrently(
        const std::vector<Component>& components) {
        
        std::vector<std::future<bool>> futures;
        for (const auto& comp : components) {
            futures.push_back(
                threadPool_.enqueue([comp]() {
                    return installComponent(comp);
                })
            );
        }
        return futures;
    }
};
```

### 3. 缓存机制
- 组件包本地缓存
- 依赖关系缓存
- 系统信息缓存

### 4. 增量更新
- 仅下载变更部分
- 差分更新支持

---

## 多服务器支持

### 架构设计

```
┌──────────────┐
│ Master Node  │  (用户操作的主机)
└──────┬───────┘
       │
       ├─────────────┐
       │             │
   ┌───▼────┐   ┌───▼────┐
   │ Node 1 │   │ Node 2 │  (远程服务器)
   └────────┘   └────────┘
```

### 实现方式

1. **SSH 连接管理**
```cpp
class RemoteManager {
public:
    bool addRemote(const std::string& host, const SSHConfig& config);
    bool deployToRemote(const std::string& host, const Scene& scene);
    bool syncConfig(const std::vector<std::string>& hosts);
    
private:
    std::map<std::string, SSHSession> sessions_;
};
```

2. **并行部署**
- 使用线程池并行连接多台服务器
- 实时显示每台服务器的部署进度

3. **配置同步**
- 主节点配置自动同步到所有远程节点
- 支持选择性同步

---

## 扩展性设计

### 1. 自定义组件安装

用户可以通过 YAML 定义自定义组件：

```yaml
# custom-component.yaml
name: my-custom-tool
version: 1.0.0
description: My custom development tool
category: Custom

dependencies:
  - cmake
  - git

install:
  - git clone https://github.com/user/my-tool.git
  - cd my-tool && mkdir build && cd build
  - cmake .. && make -j$(nproc)
  - sudo make install

uninstall:
  - sudo rm -rf /usr/local/bin/my-tool

config:
  config_file: /etc/my-tool/config.conf
  template: |
    # My Tool Configuration
    option1 = value1
    option2 = value2
```

安装：
```bash
linuxstudio component install --custom custom-component.yaml
```

### 2. 插件开发 API

提供 C++ 插件开发接口：

```cpp
// Plugin SDK
class IPlugin {
public:
    virtual ~IPlugin() = default;
    
    virtual std::string getName() const = 0;
    virtual Version getVersion() const = 0;
    virtual bool onInstall() = 0;
    virtual bool onUninstall() = 0;
    virtual bool onConfigure(const Config& config) = 0;
};

// 用户插件实现
class MyPlugin : public IPlugin {
public:
    std::string getName() const override { return "MyPlugin"; }
    Version getVersion() const override { return Version(1, 0, 0); }
    
    bool onInstall() override {
        // 安装逻辑
        return true;
    }
    
    bool onUninstall() override {
        // 卸载逻辑
        return true;
    }
    
    bool onConfigure(const Config& config) override {
        // 配置逻辑
        return true;
    }
};

// 插件注册
REGISTER_PLUGIN(MyPlugin)
```

---

## 安全性设计

### 1. 权限管理
- 组件安装需要 sudo 权限
- 敏感操作需要二次确认
- 操作日志审计

### 2. 签名验证
- 组件包数字签名验证
- 防止中间人攻击

### 3. 沙箱隔离
- 自定义脚本在沙箱环境中执行
- 限制文件系统访问范围

---

## 测试策略

### 1. 单元测试
```cpp
TEST(ComponentManager, InstallComponent) {
    ComponentManager mgr;
    EXPECT_TRUE(mgr.installComponent("nginx", Version(1, 24, 0)));
    EXPECT_TRUE(mgr.isInstalled("nginx"));
}
```

### 2. 集成测试
- Docker 容器中测试完整安装流程
- 多发行版兼容性测试（Ubuntu、Debian、CentOS、Arch）

### 3. 性能测试
- 并发安装性能基准测试
- 内存占用监控
- 启动时间优化

---

## 发布计划

### Phase 1: MVP (v0.1) - 3 个月
- ✅ 核心引擎实现
- ✅ 组件管理器基础功能
- ✅ CLI 交互式安装
- ✅ 支持 Ubuntu/Debian

### Phase 2: 功能完善 (v0.5) - 2 个月
- ✅ 插件管理器
- ✅ 场景管理
- ✅ 多发行版支持
- ✅ 基础 GUI 面板

### Phase 3: 高级特性 (v1.0) - 2 个月
- ✅ 多服务器支持
- ✅ 自定义组件/插件
- ✅ 完整 GUI 面板
- ✅ 性能优化

### Phase 4: 生态建设 (v1.5+)
- 🔄 社区组件/插件市场
- 🔄 云端配置同步
- 🔄 AI 智能推荐
- 🔄 企业版功能

---

## 技术栈总结

### 核心框架
- **语言**：C++17/20
- **构建系统**：CMake + Ninja
- **包管理**：vcpkg
- **并发**：C++20 协程 + 线程池
- **日志**：spdlog
- **JSON 解析**：nlohmann/json
- **HTTP 客户端**：libcurl
- **SSH 客户端**：libssh2

### GUI 面板
- **后端**：Crow / Drogon (C++ Web Framework)
- **前端**：Vue.js 3 + TypeScript + Vite
- **UI 组件**：Element Plus
- **状态管理**：Pinia
- **通信**：Axios + WebSocket

### 测试
- **单元测试**：Google Test
- **性能测试**：Google Benchmark
- **CI/CD**：GitHub Actions

---

## 贡献指南

### 代码规范
- 遵循 Google C++ Style Guide
- 使用 clang-format 格式化代码
- 所有公共 API 必须有文档注释

### 提交流程
1. Fork 仓库
2. 创建功能分支
3. 编写测试用例
4. 提交 Pull Request
5. 代码审查

---

## 许可证

MIT License

---

## 联系方式

- **官网**：https://linuxstudio.dev
- **GitHub**：https://github.com/happykl-cn/LinuxStudio
- **文档**：https://docs.linuxstudio.dev
- **社区**：https://community.linuxstudio.dev

---

**LinuxStudio - 让 Linux 环境管理更简单、更高效！** 🚀

