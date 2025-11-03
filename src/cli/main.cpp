#include "linuxstudio/core.hpp"
#include "linuxstudio/managers.hpp"
#include "linuxstudio/logger.hpp"
#include "linuxstudio/i18n.hpp"
#include <iostream>
#include <vector>
#include <string>
#include <cstring>
#include <map>

using namespace LinuxStudio;

// 前向声明
void showHelp();
void showVersion();
void cmdStatus();
void cmdPluginList();
void cmdPluginInstall(const std::string& name);
void cmdPluginUninstall(const std::string& name);
void cmdPluginEnable(const std::string& name);
void cmdPluginDisable(const std::string& name);
void cmdComponentList();
void cmdComponentInstall(const std::string& name);
void cmdSceneList();
void cmdSceneApply(const std::string& name);

int main(int argc, char* argv[]) {
    // 初始化国际化（自动检测语言）
    auto& i18n = I18n::getInstance();
    i18n.init(I18n::Language::AUTO);
    
    // 检查参数
    if (argc < 2) {
        std::cerr << T("Error") << ": " << T("No command specified") << "\n\n";
        showHelp();
        return 1;
    }
    
    // 初始化框架
    auto& engine = CoreEngine::getInstance();
    if (!engine.initialize()) {
        std::cerr << T("Failed to initialize LinuxStudio Framework") << "\n";
        return 1;
    }
    
    std::string command = argv[1];
    
    // 处理命令
    if (command == "help" || command == "--help" || command == "-h") {
        showHelp();
    }
    else if (command == "version" || command == "--version" || command == "-v") {
        showVersion();
    }
    else if (command == "status") {
        cmdStatus();
    }
    else if (command == "init") {
        // 初始化命令 - 静默模式
        bool quiet = false;
        if (argc > 2 && std::string(argv[2]) == "--quiet") {
            quiet = true;
        }
        
        if (!quiet) {
            if (I18n::getInstance().isChinese()) {
                std::cout << "LinuxStudio 框架初始化成功！\n";
            } else {
                std::cout << "LinuxStudio Framework initialized successfully!\n";
            }
        }
        return 0;
    }
    else if (command == "plugin") {
        if (argc < 3) {
            std::cerr << T("Error") << ": " << T("Plugin subcommand required") << "\n";
            return 1;
        }
        
        std::string subcommand = argv[2];
        if (subcommand == "list") {
            cmdPluginList();
        }
        else if (subcommand == "install") {
            if (argc < 4) {
                std::cerr << T("Error") << ": " << T("Plugin name required") << "\n";
                return 1;
            }
            cmdPluginInstall(argv[3]);
        }
        else if (subcommand == "uninstall") {
            if (argc < 4) {
                std::cerr << T("Error") << ": " << T("Plugin name required") << "\n";
                return 1;
            }
            cmdPluginUninstall(argv[3]);
        }
        else if (subcommand == "enable") {
            if (argc < 4) {
                std::cerr << T("Error") << ": " << T("Plugin name required") << "\n";
                return 1;
            }
            cmdPluginEnable(argv[3]);
        }
        else if (subcommand == "disable") {
            if (argc < 4) {
                std::cerr << T("Error") << ": " << T("Plugin name required") << "\n";
                return 1;
            }
            cmdPluginDisable(argv[3]);
        }
        else {
            std::cerr << T("Error") << ": " << T("Unknown plugin subcommand") << ": " << subcommand << "\n";
            return 1;
        }
    }
    else if (command == "component") {
        if (argc < 3) {
            std::cerr << T("Error") << ": " << T("Component subcommand required") << "\n";
            return 1;
        }
        
        std::string subcommand = argv[2];
        if (subcommand == "list") {
            cmdComponentList();
        }
        else if (subcommand == "install") {
            if (argc < 4) {
                std::cerr << T("Error") << ": " << T("Component name required") << "\n";
                return 1;
            }
            cmdComponentInstall(argv[3]);
        }
        else {
            std::cerr << T("Error") << ": " << T("Unknown component subcommand") << ": " << subcommand << "\n";
            return 1;
        }
    }
    else if (command == "scene") {
        if (argc < 3) {
            std::cerr << T("Error") << ": " << T("Scene subcommand required") << "\n";
            std::cerr << "  Use: xkl scene list   or   xkl scene apply <scene-name>\n";
            return 1;
        }
        
        std::string subcommand = argv[2];
        if (subcommand == "list") {
            cmdSceneList();
        }
        else if (subcommand == "apply") {
            if (argc < 4) {
                std::cerr << T("Error") << ": " << T("Scene name required") << "\n";
                std::cerr << "  Use: xkl scene apply <scene-name>\n";
                std::cerr << "  Run 'xkl scene list' to see available scenes\n";
                return 1;
            }
            cmdSceneApply(argv[3]);
        }
        else {
            std::cerr << T("Error") << ": " << T("Unknown scene subcommand") << ": " << subcommand << "\n";
            std::cerr << "  Valid subcommands: list, apply\n";
            return 1;
        }
    }
    else {
        std::cerr << T("Error") << ": " << T("Unknown command") << ": " << command << "\n\n";
        showHelp();
        return 1;
    }
    
    return 0;
}

void showHelp() {
    auto& i18n = I18n::getInstance();
    
    if (i18n.isChinese()) {
        std::cout << R"(LinuxStudio CLI v1.1.1 (C++ 核心)
高性能 Linux 环境管理器

用法: xkl <命令> [选项]
   或: linuxstudio <命令> [选项]  (兼容模式)

框架命令:
  init                初始化 LinuxStudio 框架
  status              显示框架状态
  update              更新 LinuxStudio 框架

组件管理:
  component list                    列出已安装的组件
  component search <关键词>         搜索组件
  component install <名称>          安装组件
  component uninstall <名称>        卸载组件

插件管理:
  plugin list                       列出已安装的插件
  plugin install <名称>             安装插件
  plugin uninstall <名称>           卸载插件
  plugin enable <名称>              启用插件
  plugin disable <名称>             禁用插件

场景管理:
  scene list                        列出可用场景
  scene apply <名称>                应用开发场景

其他命令:
  help                显示此帮助信息
  version             显示版本信息

示例:
  xkl status
  xkl plugin install ros2
  xkl scene apply robotics

更多信息，请访问: https://docs.linuxstudio.org
)" << std::endl;
    } else {
        std::cout << R"(LinuxStudio CLI v1.1.1 (C++ Core)
High-Performance Linux Environment Manager

Usage: xkl <command> [options]
   or: linuxstudio <command> [options]  (legacy)

Framework Commands:
  init                Initialize LinuxStudio framework
  status              Show framework status
  update              Update LinuxStudio framework

Component Management:
  component list                    List installed components
  component search <keyword>        Search for components
  component install <name>          Install a component
  component uninstall <name>        Uninstall a component

Plugin Management:
  plugin list                       List installed plugins
  plugin install <name>             Install a plugin
  plugin uninstall <name>           Uninstall a plugin
  plugin enable <name>              Enable a plugin
  plugin disable <name>             Disable a plugin

Scene Management:
  scene list                        List available scenes
  scene apply <name>                Apply a development scene

Other Commands:
  help                Show this help message
  version             Show version information

Examples:
  xkl status
  xkl plugin install ros2
  xkl scene apply robotics

For more information, visit: https://docs.linuxstudio.org
)" << std::endl;
    }
}

void showVersion() {
    auto& engine = CoreEngine::getInstance();
    std::cout << "LinuxStudio Framework v" << engine.getVersion() << " (C++ Core)\n";
    std::cout << "Copyright (c) 2025 Dino Studio\n";
    std::cout << "Built with C++17\n";
}

void cmdStatus() {
    auto& engine = CoreEngine::getInstance();
    auto& logger = engine.getLogger();
    const auto& sysInfo = engine.getSystemInfo();
    auto& i18n = I18n::getInstance();
    
    std::cout << "\n";
    logger.info(T("LinuxStudio Framework Status"));
    std::cout << "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    std::cout << T("Version") << ":        " << engine.getVersion() << " (C++ Core)\n";
    std::cout << T("Install Path") << ":   /opt/linuxstudio\n";
    std::cout << "\n";
    std::cout << T("System Information") << ":\n";
    std::cout << "  " << T("OS") << ":           " << sysInfo.osName << "\n";
    std::cout << "  " << T("Version") << ":      " << sysInfo.osVersion << "\n";
    std::cout << "  " << T("Architecture") << ": " << sysInfo.architecture << "\n";
    std::cout << "  " << T("CPU Cores") << ":    " << sysInfo.cpuCores << "\n";
    std::cout << "  " << T("Memory") << ":       " << sysInfo.totalMemory << " MB (";
    std::cout << sysInfo.availableMemory << " " << T("MB available") << ")\n";
    std::cout << "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    std::cout << "\n";
}

void cmdPluginList() {
    auto& engine = CoreEngine::getInstance();
    auto& pluginMgr = engine.getPluginManager();
    auto& logger = engine.getLogger();
    
    auto plugins = pluginMgr.listInstalled();
    
    std::cout << "\n";
    logger.info(T("Installed Plugins"));
    std::cout << "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    
    if (plugins.empty()) {
        logger.warning(T("No plugins installed yet."));
        std::cout << "\n";
        logger.info(T("Available plugins:"));
        if (I18n::getInstance().isChinese()) {
            std::cout << "  • ros2           - 机器人操作系统 2\n";
            std::cout << "  • robot-arm      - 机械臂控制库\n";
            std::cout << "  • opencv         - 计算机视觉库\n";
            std::cout << "  • pytorch        - 深度学习框架\n";
            std::cout << "  • tensorflow     - 机器学习框架\n";
            std::cout << "  • cuda-toolkit   - NVIDIA CUDA 开发工具包\n";
        } else {
            std::cout << "  • ros2           - Robot Operating System 2\n";
            std::cout << "  • robot-arm      - Robot arm control libraries\n";
            std::cout << "  • opencv         - Computer vision library\n";
            std::cout << "  • pytorch        - Deep learning framework\n";
            std::cout << "  • tensorflow     - Machine learning framework\n";
            std::cout << "  • cuda-toolkit   - NVIDIA CUDA development kit\n";
        }
        std::cout << "\n";
        if (I18n::getInstance().isChinese()) {
            logger.info("安装插件: sudo xkl plugin install <名称>");
        } else {
            logger.info("Install a plugin: sudo xkl plugin install <name>");
        }
    } else {
        for (const auto& plugin : plugins) {
            std::string status = plugin.enabled ? "✅ " : "⚪ ";
            std::string enabledStr = plugin.enabled ? 
                ("(" + std::string(T("enabled")) + ")") : 
                ("(" + std::string(T("disabled")) + ")");
            std::cout << "  " << status << plugin.name << " " << enabledStr << "\n";
        }
    }
    
    std::cout << "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    std::cout << "\n";
}

void cmdPluginInstall(const std::string& name) {
    auto& engine = CoreEngine::getInstance();
    auto& pluginMgr = engine.getPluginManager();
    
    if (pluginMgr.install(name)) {
        std::cout << "\n";
        if (I18n::getInstance().isChinese()) {
            std::cout << "插件 '" << name << "' " << T("installed successfully") << "!\n";
            std::cout << T("Manage") << ": xkl plugin [enable|disable] " << name << "\n";
        } else {
            std::cout << "Plugin '" << name << "' " << T("installed successfully") << "!\n";
            std::cout << T("Manage") << ": xkl plugin [enable|disable] " << name << "\n";
        }
        std::cout << "\n";
    }
}

void cmdPluginUninstall(const std::string& name) {
    auto& pluginMgr = CoreEngine::getInstance().getPluginManager();
    pluginMgr.uninstall(name);
}

void cmdPluginEnable(const std::string& name) {
    auto& pluginMgr = CoreEngine::getInstance().getPluginManager();
    pluginMgr.enable(name);
}

void cmdPluginDisable(const std::string& name) {
    auto& pluginMgr = CoreEngine::getInstance().getPluginManager();
    pluginMgr.disable(name);
}

void cmdComponentList() {
    auto& logger = CoreEngine::getInstance().getLogger();
    
    std::cout << "\n";
    logger.info(T("Installed Components"));
    std::cout << "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    logger.warning(T("Component listing not yet implemented"));
    std::cout << "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    std::cout << "\n";
}

void cmdComponentInstall(const std::string& name) {
    auto& logger = CoreEngine::getInstance().getLogger();
    auto& i18n = I18n::getInstance();
    
    if (i18n.isChinese()) {
        logger.info("正在安装组件: " + name);
        logger.warning("组件安装功能尚未在 C++ 版本中实现");
    } else {
        logger.info("Installing component: " + name);
        logger.warning("Component installation not yet implemented in C++ version");
    }
}

void cmdSceneList() {
    auto& logger = CoreEngine::getInstance().getLogger();
    auto& i18n = I18n::getInstance();
    
    std::cout << "\n";
    if (i18n.isChinese()) {
        logger.info("可用场景");
        std::cout << "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
        std::cout << "  1) web-development  - Web 开发\n";
        std::cout << "     Nginx, PHP, Java, MySQL, Redis, Node.js\n";
        std::cout << "\n";
        std::cout << "  2) embedded         - 嵌入式开发\n";
        std::cout << "     ARM/RISC-V GCC, OpenOCD, GDB\n";
        std::cout << "\n";
        std::cout << "  3) robotics         - 机器人开发\n";
        std::cout << "     ROS2, MoveIt2, Gazebo, OpenCV\n";
        std::cout << "\n";
        std::cout << "  4) ai-ml            - AI/ML 开发\n";
        std::cout << "     Python, Jupyter, TensorFlow, PyTorch\n";
        std::cout << "\n";
        std::cout << "  5) game-dev         - 游戏开发\n";
        std::cout << "     SDL2, OpenGL, Vulkan, Godot\n";
        std::cout << "\n";
        std::cout << "  6) devops           - DevOps\n";
        std::cout << "     Docker, Kubernetes, Jenkins, Prometheus\n";
        std::cout << "\n";
        std::cout << "  7) security         - 网络安全\n";
        std::cout << "     Nmap, Wireshark, Metasploit\n";
        std::cout << "\n";
        std::cout << "  8) blockchain       - 区块链开发\n";
        std::cout << "     Hardhat, Solidity, Web3.js\n";
        std::cout << "\n";
        std::cout << "  9) iot              - 物联网开发\n";
        std::cout << "     Mosquitto, Node-RED, InfluxDB\n";
    } else {
        logger.info("Available Scenes");
        std::cout << "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
        std::cout << "  1) web-development  - Web Development\n";
        std::cout << "     Nginx, PHP, Java, MySQL, Redis, Node.js\n";
        std::cout << "\n";
        std::cout << "  2) embedded         - Embedded Systems\n";
        std::cout << "     ARM/RISC-V GCC, OpenOCD, GDB\n";
        std::cout << "\n";
        std::cout << "  3) robotics         - Robotics\n";
        std::cout << "     ROS2, MoveIt2, Gazebo, OpenCV\n";
        std::cout << "\n";
        std::cout << "  4) ai-ml            - AI/ML Development\n";
        std::cout << "     Python, Jupyter, TensorFlow, PyTorch\n";
        std::cout << "\n";
        std::cout << "  5) game-dev         - Game Development\n";
        std::cout << "     SDL2, OpenGL, Vulkan, Godot\n";
        std::cout << "\n";
        std::cout << "  6) devops           - DevOps\n";
        std::cout << "     Docker, Kubernetes, Jenkins, Prometheus\n";
        std::cout << "\n";
        std::cout << "  7) security         - Security\n";
        std::cout << "     Nmap, Wireshark, Metasploit\n";
        std::cout << "\n";
        std::cout << "  8) blockchain       - Blockchain\n";
        std::cout << "     Hardhat, Solidity, Web3.js\n";
        std::cout << "\n";
        std::cout << "  9) iot              - IoT Development\n";
        std::cout << "     Mosquitto, Node-RED, InfluxDB\n";
    }
    std::cout << "\n";
    std::cout << "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    std::cout << "\n";
    if (i18n.isChinese()) {
        logger.info("应用场景: xkl scene apply <场景名>");
    } else {
        logger.info("Apply scene: xkl scene apply <scene-name>");
    }
    std::cout << "\n";
}

void cmdSceneApply(const std::string& name) {
    auto& engine = CoreEngine::getInstance();
    auto& logger = engine.getLogger();
    auto& i18n = I18n::getInstance();
    
    // 场景到组件的映射
    std::map<std::string, std::vector<std::string>> sceneComponents = {
        {"web-development", {"nginx", "php", "java", "mysql", "redis", "nodejs"}},
        {"embedded", {"gcc-arm", "openocd", "gdb", "minicom", "i2c-tools", "spi-tools"}},
        {"robotics", {"ros2", "opencv", "gazebo", "moveit2"}},
        {"ai-ml", {"python", "jupyter", "tensorflow", "pytorch", "opencv"}},
        {"game-dev", {"sdl2", "opengl", "vulkan", "godot"}},
        {"devops", {"docker", "kubernetes", "jenkins", "prometheus", "grafana"}},
        {"security", {"nmap", "wireshark", "metasploit"}},
        {"blockchain", {"hardhat", "web3js", "solidity", "ipfs"}},
        {"iot", {"mosquitto", "node-red", "influxdb", "grafana"}}
    };
    
    // 场景显示名称
    std::map<std::string, std::pair<std::string, std::string>> sceneNames = {
        {"web-development", {"Web 开发", "Web Development"}},
        {"embedded", {"嵌入式开发", "Embedded Systems"}},
        {"robotics", {"机器人开发", "Robotics"}},
        {"ai-ml", {"AI/ML 开发", "AI/ML Development"}},
        {"game-dev", {"游戏开发", "Game Development"}},
        {"devops", {"DevOps", "DevOps"}},
        {"security", {"网络安全", "Security"}},
        {"blockchain", {"区块链开发", "Blockchain Development"}},
        {"iot", {"物联网开发", "IoT Development"}}
    };
    
    auto sceneIt = sceneComponents.find(name);
    if (sceneIt == sceneComponents.end()) {
        if (i18n.isChinese()) {
            logger.error("未知的场景: " + name);
            std::cout << "\n";
            logger.info("运行 'xkl scene list' 查看可用场景");
        } else {
            logger.error("Unknown scene: " + name);
            std::cout << "\n";
            logger.info("Run 'xkl scene list' to see available scenes");
        }
        return;
    }
    
    auto nameIt = sceneNames.find(name);
    std::string displayName = i18n.isChinese() ? nameIt->second.first : nameIt->second.second;
    
    std::cout << "\n";
    if (i18n.isChinese()) {
        logger.info("正在应用场景: " + displayName);
        std::cout << "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
        std::cout << "\n";
        std::cout << "此场景包含以下组件:\n";
    } else {
        logger.info("Applying scene: " + displayName);
        std::cout << "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
        std::cout << "\n";
        std::cout << "This scene includes the following components:\n";
    }
    
    const auto& components = sceneIt->second;
    for (size_t i = 0; i < components.size(); ++i) {
        std::cout << "  " << (i + 1) << ") " << components[i] << "\n";
    }
    
    std::cout << "\n";
    if (i18n.isChinese()) {
        logger.info("注意: 组件安装功能仍在开发中");
        logger.info("请手动安装所需的组件，或等待后续版本更新");
        std::cout << "\n";
        std::cout << "当前可用的操作:\n";
        std::cout << "  • xkl component list       # 列出已安装的组件\n";
        std::cout << "  • xkl plugin list          # 列出已安装的插件\n";
        std::cout << "  • xkl status               # 查看系统状态\n";
    } else {
        logger.info("Note: Component installation is still under development");
        logger.info("Please install required components manually, or wait for future updates");
        std::cout << "\n";
        std::cout << "Available operations:\n";
        std::cout << "  • xkl component list       # List installed components\n";
        std::cout << "  • xkl plugin list          # List installed plugins\n";
        std::cout << "  • xkl status               # Check system status\n";
    }
    
    std::cout << "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    std::cout << "\n";
}

