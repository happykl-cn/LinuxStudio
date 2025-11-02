#include "linuxstudio/core.hpp"
#include "linuxstudio/managers.hpp"
#include "linuxstudio/logger.hpp"
#include <iostream>
#include <vector>
#include <string>
#include <cstring>

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

int main(int argc, char* argv[]) {
    // 检查参数
    if (argc < 2) {
        std::cerr << "Error: No command specified\n\n";
        showHelp();
        return 1;
    }
    
    // 初始化框架
    auto& engine = CoreEngine::getInstance();
    if (!engine.initialize()) {
        std::cerr << "Failed to initialize LinuxStudio Framework\n";
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
            std::cout << "LinuxStudio Framework initialized successfully!\n";
        }
        return 0;
    }
    else if (command == "plugin") {
        if (argc < 3) {
            std::cerr << "Error: Plugin subcommand required\n";
            return 1;
        }
        
        std::string subcommand = argv[2];
        if (subcommand == "list") {
            cmdPluginList();
        }
        else if (subcommand == "install") {
            if (argc < 4) {
                std::cerr << "Error: Plugin name required\n";
                return 1;
            }
            cmdPluginInstall(argv[3]);
        }
        else if (subcommand == "uninstall") {
            if (argc < 4) {
                std::cerr << "Error: Plugin name required\n";
                return 1;
            }
            cmdPluginUninstall(argv[3]);
        }
        else if (subcommand == "enable") {
            if (argc < 4) {
                std::cerr << "Error: Plugin name required\n";
                return 1;
            }
            cmdPluginEnable(argv[3]);
        }
        else if (subcommand == "disable") {
            if (argc < 4) {
                std::cerr << "Error: Plugin name required\n";
                return 1;
            }
            cmdPluginDisable(argv[3]);
        }
        else {
            std::cerr << "Error: Unknown plugin subcommand: " << subcommand << "\n";
            return 1;
        }
    }
    else if (command == "component") {
        if (argc < 3) {
            std::cerr << "Error: Component subcommand required\n";
            return 1;
        }
        
        std::string subcommand = argv[2];
        if (subcommand == "list") {
            cmdComponentList();
        }
        else if (subcommand == "install") {
            if (argc < 4) {
                std::cerr << "Error: Component name required\n";
                return 1;
            }
            cmdComponentInstall(argv[3]);
        }
        else {
            std::cerr << "Error: Unknown component subcommand: " << subcommand << "\n";
            return 1;
        }
    }
    else {
        std::cerr << "Error: Unknown command: " << command << "\n\n";
        showHelp();
        return 1;
    }
    
    return 0;
}

void showHelp() {
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
    
    std::cout << "\n";
    logger.info("LinuxStudio Framework Status");
    std::cout << "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    std::cout << "Version:        " << engine.getVersion() << " (C++ Core)\n";
    std::cout << "Install Path:   /opt/linuxstudio\n";
    std::cout << "\n";
    std::cout << "System Information:\n";
    std::cout << "  OS:           " << sysInfo.osName << "\n";
    std::cout << "  Version:      " << sysInfo.osVersion << "\n";
    std::cout << "  Architecture: " << sysInfo.architecture << "\n";
    std::cout << "  CPU Cores:    " << sysInfo.cpuCores << "\n";
    std::cout << "  Memory:       " << sysInfo.totalMemory << " MB (";
    std::cout << sysInfo.availableMemory << " MB available)\n";
    std::cout << "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    std::cout << "\n";
}

void cmdPluginList() {
    auto& engine = CoreEngine::getInstance();
    auto& pluginMgr = engine.getPluginManager();
    auto& logger = engine.getLogger();
    
    auto plugins = pluginMgr.listInstalled();
    
    std::cout << "\n";
    logger.info("Installed Plugins");
    std::cout << "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    
    if (plugins.empty()) {
        logger.warning("No plugins installed yet.");
        std::cout << "\n";
        logger.info("Available plugins:");
        std::cout << "  • ros2           - Robot Operating System 2\n";
        std::cout << "  • robot-arm      - Robot arm control libraries\n";
        std::cout << "  • opencv         - Computer vision library\n";
        std::cout << "  • pytorch        - Deep learning framework\n";
        std::cout << "  • tensorflow     - Machine learning framework\n";
        std::cout << "  • cuda-toolkit   - NVIDIA CUDA development kit\n";
        std::cout << "\n";
        logger.info("Install a plugin: sudo xkl plugin install <name>");
    } else {
        for (const auto& plugin : plugins) {
            std::string status = plugin.enabled ? "✅ " : "⚪ ";
            std::string enabledStr = plugin.enabled ? "(enabled)" : "(disabled)";
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
        std::cout << "Plugin '" << name << "' installed successfully!\n";
        std::cout << "Manage: xkl plugin [enable|disable] " << name << "\n";
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
    logger.info("Installed Components");
    std::cout << "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    logger.warning("Component listing not yet implemented in C++ version");
    std::cout << "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    std::cout << "\n";
}

void cmdComponentInstall(const std::string& name) {
    auto& logger = CoreEngine::getInstance().getLogger();
    logger.info("Installing component: " + name);
    logger.warning("Component installation not yet implemented in C++ version");
}

