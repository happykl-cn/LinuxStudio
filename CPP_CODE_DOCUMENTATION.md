# LinuxStudio C++ 代码文档

## 📋 目录

1. [项目结构](#项目结构)
2. [核心架构](#核心架构)
3. [关键类详解](#关键类详解)
4. [代码示例](#代码示例)
5. [编译与安装](#编译与安装)
6. [扩展开发](#扩展开发)

---

## 项目结构

```
LinuxStudio/
├── CMakeLists.txt              # CMake 构建配置
├── build.sh                    # 编译脚本
├── include/                    # 头文件目录
│   └── linuxstudio/
│       ├── core.hpp            # 核心引擎头文件
│       ├── managers.hpp        # 管理器头文件
│       └── logger.hpp          # 日志系统头文件
├── src/                        # 源文件目录
│   ├── core/                   # 核心模块
│   │   ├── engine.cpp          # 核心引擎实现
│   │   ├── system_detector.cpp # 系统检测
│   │   └── config.cpp          # 配置管理
│   ├── managers/               # 管理器模块
│   │   ├── component_manager.cpp  # 组件管理器
│   │   └── plugin_manager.cpp     # 插件管理器
│   ├── utils/                  # 工具模块
│   │   ├── logger.cpp          # 日志实现
│   │   └── file_utils.cpp      # 文件工具
│   └── cli/                    # CLI 模块
│       ├── main.cpp            # 主程序入口
│       ├── commands.cpp        # 命令处理
│       └── cli_handler.cpp     # CLI 处理器
└── build/                      # 构建目录（生成）
    └── bin/
        └── linuxstudio         # 编译后的二进制文件
```

---

## 核心架构

### 设计模式

#### 1. **单例模式**（Singleton Pattern）

**应用场景**：CoreEngine 类

**原因**：
- 整个应用只需要一个核心引擎实例
- 全局访问点，避免多个实例造成状态不一致

**实现**：
```cpp
class CoreEngine {
public:
    static CoreEngine& getInstance() {
        static CoreEngine instance;  // 线程安全（C++11）
        return instance;
    }
    
    // 禁用拷贝和赋值
    CoreEngine(const CoreEngine&) = delete;
    CoreEngine& operator=(const CoreEngine&) = delete;
    
private:
    CoreEngine();  // 私有构造函数
    ~CoreEngine();
};
```

**使用方式**：
```cpp
// 获取单例
auto& engine = CoreEngine::getInstance();
engine.initialize();
```

#### 2. **策略模式**（Strategy Pattern）

**应用场景**：PluginManager 中的插件安装器

**实现**：
```cpp
// 插件安装函数类型
using PluginInstaller = std::function<bool()>;

// 注册不同的安装策略
std::map<std::string, PluginInstaller> installers_;

installers_["ros2"] = [this]() { return installROS2(); };
installers_["opencv"] = [this]() { return installOpenCV(); };
```

#### 3. **依赖注入**（Dependency Injection）

**实现**：
```cpp
class CoreEngine {
private:
    std::unique_ptr<ComponentManager> componentMgr_;
    std::unique_ptr<PluginManager> pluginMgr_;
    std::unique_ptr<Logger> logger_;
};
```

---

## 关键类详解

### 1. CoreEngine - 核心引擎

**文件**：`include/linuxstudio/core.hpp`, `src/core/engine.cpp`

**职责**：
- 框架初始化
- 系统信息检测
- 管理器协调
- 全局状态维护

#### 关键方法

##### `initialize()` - 初始化框架

```cpp
bool CoreEngine::initialize() {
    if (initialized_) {
        return true;
    }
    
    logger_->info("Initializing LinuxStudio Framework...");
    
    // 检测系统信息
    systemInfo_ = detectSystem();
    
    logger_->success("LinuxStudio Framework initialized successfully");
    
    initialized_ = true;
    return true;
}
```

**作用**：
1. 防止重复初始化（通过 `initialized_` 标志）
2. 检测系统信息
3. 记录日志

##### `detectSystem()` - 系统检测

```cpp
SystemInfo CoreEngine::detectSystem() {
    SystemInfo info;
    
    // 1. 使用 uname 获取基本信息
    struct utsname unameData;
    if (uname(&unameData) == 0) {
        info.osName = unameData.sysname;
        info.architecture = unameData.machine;
    }
    
    // 2. 读取 /etc/os-release 获取发行版信息
    std::ifstream osRelease("/etc/os-release");
    // 解析文件...
    
    // 3. 获取 CPU 核心数
    info.cpuCores = sysconf(_SC_NPROCESSORS_ONLN);
    
    // 4. 获取内存信息
    struct sysinfo si;
    if (sysinfo(&si) == 0) {
        info.totalMemory = si.totalram / (1024 * 1024);  // MB
        info.availableMemory = si.freeram / (1024 * 1024);
    }
    
    return info;
}
```

**系统调用说明**：

| 函数 | 头文件 | 作用 |
|------|--------|------|
| `uname()` | `<sys/utsname.h>` | 获取系统名称、版本、架构 |
| `sysconf()` | `<unistd.h>` | 获取系统配置（如 CPU 核心数）|
| `sysinfo()` | `<sys/sysinfo.h>` | 获取系统信息（内存、负载等）|

---

### 2. Logger - 日志系统

**文件**：`include/linuxstudio/logger.hpp`, `src/utils/logger.cpp`

**特点**：
- 彩色终端输出
- 文件日志记录
- 多级别日志（DEBUG, INFO, WARNING, ERROR, SUCCESS）
- Emoji 图标支持

#### 日志级别枚举

```cpp
enum class LogLevel {
    DEBUG,    // 调试信息 🔍
    INFO,     // 一般信息 ℹ️
    WARNING,  // 警告 ⚠️
    ERROR,    // 错误 ❌
    SUCCESS   // 成功 ✅
};
```

#### 彩色输出实现

```cpp
std::string Logger::getColorCode(LogLevel level) {
    if (!useColors_) {
        return "";
    }
    
    switch (level) {
        case LogLevel::DEBUG:   return "\033[0;36m";  // Cyan
        case LogLevel::INFO:    return "\033[0;36m";  // Cyan
        case LogLevel::WARNING: return "\033[1;33m";  // Yellow
        case LogLevel::ERROR:   return "\033[0;31m";  // Red
        case LogLevel::SUCCESS: return "\033[0;32m";  // Green
        default:                return "";
    }
}
```

**ANSI 颜色代码**：
- `\033[0;31m` - 红色
- `\033[0;32m` - 绿色
- `\033[1;33m` - 黄色（加粗）
- `\033[0;36m` - 青色
- `\033[0m` - 重置

#### 使用示例

```cpp
auto& logger = engine.getLogger();

logger.info("This is an info message");      // ℹ️  This is an info message
logger.success("Installation complete");     // ✅ Installation complete
logger.warning("Disk space low");            // ⚠️  Disk space low
logger.error("Failed to connect");           // ❌ Failed to connect
```

---

### 3. PluginManager - 插件管理器

**文件**：`include/linuxstudio/managers.hpp`, `src/managers/plugin_manager.cpp`

**职责**：
- 插件安装/卸载
- 插件启用/禁用
- 插件元数据管理
- 内置插件安装函数

#### 插件结构

```cpp
struct Plugin {
    std::string name;             // 插件名称
    std::string version;          // 版本
    std::string description;      // 描述
    bool enabled;                 // 是否启用
    std::string installedAt;      // 安装时间（ISO 8601 格式）
    
    Plugin() : enabled(false) {}
};
```

#### 插件安装流程

```cpp
bool PluginManager::install(const std::string& name) {
    auto& logger = CoreEngine::getInstance().getLogger();
    
    // 1. 检查是否已安装
    if (isInstalled(name)) {
        logger.warning("Plugin '" + name + "' is already installed");
        return false;
    }
    
    // 2. 执行安装（通过内置安装器或创建目录）
    bool success = false;
    if (installers_.find(name) != installers_.end()) {
        success = installers_[name]();  // 调用对应的安装函数
    } else {
        // 创建自定义插件目录
        std::string pluginDir = pluginsPath_ + "/" + name;
        mkdir(pluginDir.c_str(), 0755);
        success = true;
    }
    
    // 3. 保存元数据
    if (success) {
        Plugin plugin(name, "");
        plugin.enabled = true;
        plugin.installedAt = getCurrentTime();
        
        plugins_[name] = plugin;
        savePluginMetadata(name, plugin);
        
        logger.success("Plugin '" + name + "' installed successfully");
        return true;
    }
    
    return false;
}
```

#### 内置插件安装函数

##### ROS2 安装

```cpp
bool PluginManager::installROS2() {
    auto& logger = CoreEngine::getInstance().getLogger();
    logger.info("Installing ROS2 Humble...");
    
    // 执行 Shell 命令序列
    std::string cmd = R"(
        apt-get update -qq && \
        apt-get install -y software-properties-common curl && \
        curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
            -o /usr/share/keyrings/ros-archive-keyring.gpg && \
        echo "deb [arch=$(dpkg --print-architecture) \
            signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
            http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" \
            | tee /etc/apt/sources.list.d/ros2.list > /dev/null && \
        apt-get update -qq && \
        apt-get install -y ros-humble-desktop python3-colcon-common-extensions
    )";
    
    int ret = system(cmd.c_str());
    return ret == 0;
}
```

**说明**：
- 使用 R 字符串字面量（C++11）避免转义
- 使用 `system()` 调用 Shell 命令
- 返回值：0 表示成功

---

### 4. ComponentManager - 组件管理器

**文件**：`include/linuxstudio/managers.hpp`, `src/managers/component_manager.cpp`

**职责**：
- 系统包管理（apt, yum, dnf, pacman）
- 组件安装/卸载
- 依赖解析

#### 自动检测包管理器

```cpp
bool ComponentManager::install(const std::string& name) {
    auto& logger = CoreEngine::getInstance().getLogger();
    
    std::string cmd;
    
    // 检测并使用相应的包管理器
    if (system("which apt-get > /dev/null 2>&1") == 0) {
        cmd = "apt-get update -qq && apt-get install -y " + name;
    } else if (system("which yum > /dev/null 2>&1") == 0) {
        cmd = "yum install -y " + name;
    } else if (system("which dnf > /dev/null 2>&1") == 0) {
        cmd = "dnf install -y " + name;
    } else if (system("which pacman > /dev/null 2>&1") == 0) {
        cmd = "pacman -S --noconfirm " + name;
    } else {
        logger.error("Unsupported package manager");
        return false;
    }
    
    int ret = system(cmd.c_str());
    return ret == 0;
}
```

---

### 5. CLI Main - 命令行主程序

**文件**：`src/cli/main.cpp`

**架构**：命令路由器模式

```cpp
int main(int argc, char* argv[]) {
    // 1. 参数检查
    if (argc < 2) {
        showHelp();
        return 1;
    }
    
    // 2. 初始化框架
    auto& engine = CoreEngine::getInstance();
    engine.initialize();
    
    // 3. 命令路由
    std::string command = argv[1];
    
    if (command == "status") {
        cmdStatus();
    }
    else if (command == "plugin") {
        std::string subcommand = argv[2];
        if (subcommand == "install") {
            cmdPluginInstall(argv[3]);
        }
        // ... 其他子命令
    }
    // ... 其他命令
    
    return 0;
}
```

---

## 代码示例

### 示例 1：完整的插件安装流程

```cpp
#include "linuxstudio/core.hpp"
#include "linuxstudio/managers.hpp"

int main() {
    // 1. 获取核心引擎实例
    auto& engine = CoreEngine::getInstance();
    
    // 2. 初始化
    if (!engine.initialize()) {
        std::cerr << "Failed to initialize\n";
        return 1;
    }
    
    // 3. 获取插件管理器
    auto& pluginMgr = engine.getPluginManager();
    auto& logger = engine.getLogger();
    
    // 4. 安装插件
    logger.info("Installing ROS2 plugin...");
    if (pluginMgr.install("ros2")) {
        logger.success("ROS2 installed!");
        
        // 5. 检查状态
        if (pluginMgr.isEnabled("ros2")) {
            logger.info("ROS2 is enabled");
        }
    }
    
    return 0;
}
```

### 示例 2：自定义日志

```cpp
// 设置日志文件
auto& logger = CoreEngine::getInstance().getLogger();
logger.setLogFile("/var/log/linuxstudio.log");

// 设置最小日志级别
logger.setMinLevel(LogLevel::INFO);  // 只显示 INFO 及以上

// 记录日志
logger.debug("This won't show");  // 低于 INFO，不显示
logger.info("Configuration loaded");
logger.success("All tests passed");
```

### 示例 3：系统信息检测

```cpp
auto& engine = CoreEngine::getInstance();
engine.initialize();

const auto& sysInfo = engine.getSystemInfo();

std::cout << "OS: " << sysInfo.osName << "\n";
std::cout << "Architecture: " << sysInfo.architecture << "\n";
std::cout << "CPU Cores: " << sysInfo.cpuCores << "\n";
std::cout << "Memory: " << sysInfo.totalMemory << " MB\n";
```

---

## 编译与安装

### 方法 1：使用编译脚本（推荐）

```bash
# 赋予执行权限
chmod +x build.sh

# 编译
./build.sh

# 安装
cd build
sudo cmake --install .
```

### 方法 2：手动编译

```bash
# 1. 创建构建目录
mkdir build && cd build

# 2. 配置（Release 模式）
cmake .. -DCMAKE_BUILD_TYPE=Release

# 3. 编译（使用所有 CPU 核心）
cmake --build . -j$(nproc)

# 4. 测试
./bin/linuxstudio --version

# 5. 安装
sudo cmake --install .

# 6. 验证
which linuxstudio
linuxstudio status
```

### 编译选项

```bash
# Debug 模式（包含调试符号）
cmake .. -DCMAKE_BUILD_TYPE=Debug

# 指定安装路径
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local

# 详细输出
cmake --build . --verbose
```

---

## 扩展开发

### 添加新的插件

#### 步骤 1：在 `managers.hpp` 中声明

```cpp
class PluginManager {
private:
    bool installMyPlugin();  // 添加声明
};
```

#### 步骤 2：在 `plugin_manager.cpp` 中实现

```cpp
void PluginManager::registerBuiltinInstallers() {
    // ... 现有代码 ...
    installers_["my-plugin"] = [this]() { return installMyPlugin(); };
}

bool PluginManager::installMyPlugin() {
    auto& logger = CoreEngine::getInstance().getLogger();
    logger.info("Installing My Plugin...");
    
    // 执行安装逻辑
    std::string cmd = "apt-get install -y my-package";
    int ret = system(cmd.c_str());
    
    return ret == 0;
}
```

#### 步骤 3：重新编译

```bash
cd build
cmake --build .
sudo cmake --install .
```

#### 步骤 4：使用

```bash
sudo linuxstudio plugin install my-plugin
```

### 添加新的命令

#### 在 `main.cpp` 中添加

```cpp
void cmdMyCommand() {
    auto& logger = CoreEngine::getInstance().getLogger();
    logger.info("Executing my command...");
    // 实现逻辑
}

int main(int argc, char* argv[]) {
    // ... 现有代码 ...
    
    else if (command == "mycommand") {
        cmdMyCommand();
    }
    
    // ...
}
```

---

## C++ 特性说明

### C++11/17 特性使用

#### 1. **智能指针**

```cpp
std::unique_ptr<ComponentManager> componentMgr_;
std::unique_ptr<PluginManager> pluginMgr_;
std::unique_ptr<Logger> logger_;
```

**优点**：
- 自动内存管理
- 防止内存泄漏
- 明确所有权

#### 2. **Lambda 表达式**

```cpp
installers_["ros2"] = [this]() { return installROS2(); };
```

**优点**：
- 简洁的函数对象
- 可以捕获上下文

#### 3. **auto 类型推导**

```cpp
auto& engine = CoreEngine::getInstance();
auto now = std::chrono::system_clock::now();
```

**优点**：
- 简化代码
- 避免复杂类型声明

#### 4. **范围 for 循环**

```cpp
for (const auto& pair : plugins_) {
    result.push_back(pair.second);
}
```

#### 5. **enum class**（强类型枚举）

```cpp
enum class LogLevel {
    DEBUG, INFO, WARNING, ERROR, SUCCESS
};
```

**优点**：
- 类型安全
- 避免命名冲突

#### 6. **R 字符串字面量**

```cpp
std::string cmd = R"(
    apt-get update -qq && \
    apt-get install -y package
)";
```

**优点**：
- 无需转义
- 支持多行

---

## 性能优化

### 1. 编译优化

```bash
# -O3 最高优化级别
cmake .. -DCMAKE_BUILD_TYPE=Release

# 启用 LTO（链接时优化）
cmake .. -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON
```

### 2. 并行编译

```bash
# 使用所有 CPU 核心
cmake --build . -j$(nproc)
```

### 3. Strip 二进制（减小文件大小）

```bash
strip --strip-all bin/linuxstudio
```

---

## 调试技巧

### 1. GDB 调试

```bash
# Debug 模式编译
cmake .. -DCMAKE_BUILD_TYPE=Debug
cmake --build .

# 使用 GDB
gdb ./bin/linuxstudio

# GDB 命令
(gdb) run status
(gdb) break CoreEngine::initialize
(gdb) next
(gdb) print systemInfo_
```

### 2. Valgrind 内存检查

```bash
valgrind --leak-check=full ./bin/linuxstudio status
```

### 3. 添加调试输出

```cpp
#ifdef DEBUG
    std::cout << "DEBUG: Variable value = " << value << "\n";
#endif
```

---

## 常见问题

### Q1: 编译错误：找不到头文件

**解决**：
```bash
# 安装开发工具
sudo apt-get install build-essential cmake

# 检查包含路径
cmake .. -DCMAKE_VERBOSE_MAKEFILE=ON
```

### Q2: 链接错误：undefined reference

**解决**：确保所有源文件都在 CMakeLists.txt 中

```cmake
set(CORE_SOURCES
    src/core/engine.cpp
    src/core/system_detector.cpp  # 确保包含
    # ...
)
```

### Q3: 运行时错误：权限不足

```bash
# 需要 root 权限
sudo ./bin/linuxstudio plugin install ros2
```

---

## 总结

LinuxStudio C++ 版本采用现代 C++ 设计：

✅ **面向对象**：清晰的类层次结构  
✅ **RAII**：智能指针自动管理资源  
✅ **单例模式**：全局访问核心引擎  
✅ **策略模式**：灵活的插件安装  
✅ **类型安全**：强类型枚举和模板  
✅ **高性能**：编译为原生二进制  

**编译后的二进制文件是真正的 ELF 可执行文件，不是脚本！** 🚀


