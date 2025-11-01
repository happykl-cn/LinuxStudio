#include "linuxstudio/managers.hpp"
#include "linuxstudio/core.hpp"
#include "linuxstudio/logger.hpp"  // 添加 Logger 的完整定义
#include <cstdlib>
#include <fstream>
#ifdef _WIN32
    #include <direct.h>
    #define mkdir(path, mode) _mkdir(path)
#else
    #include <sys/stat.h>
    #include <sys/types.h>
#endif

namespace LinuxStudio {

ComponentManager::ComponentManager() 
    : componentsPath_("/opt/linuxstudio/components") {
    loadComponentRegistry();
}

ComponentManager::~ComponentManager() {
    saveComponentRegistry();
}

std::vector<Component> ComponentManager::listInstalled() {
    std::vector<Component> result;
    for (const auto& pair : components_) {
        if (pair.second.installed) {
            result.push_back(pair.second);
        }
    }
    return result;
}

std::vector<Component> ComponentManager::search(const std::string& keyword) {
    std::vector<Component> result;
    for (const auto& pair : components_) {
        if (pair.first.find(keyword) != std::string::npos ||
            pair.second.description.find(keyword) != std::string::npos) {
            result.push_back(pair.second);
        }
    }
    return result;
}

bool ComponentManager::install(const std::string& name) {
    auto& logger = CoreEngine::getInstance().getLogger();
    
    logger.info("Installing component: " + name);
    
    // 使用系统包管理器安装
    std::string cmd;
    
    // 检测包管理器
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
    
    if (ret == 0) {
        Component comp(name, "");
        comp.installed = true;
        components_[name] = comp;
        logger.success("Component '" + name + "' installed successfully");
        return true;
    }
    
    logger.error("Failed to install component: " + name);
    return false;
}

bool ComponentManager::uninstall(const std::string& name) {
    auto& logger = CoreEngine::getInstance().getLogger();
    logger.warning("Uninstalling component: " + name);
    
    std::string cmd;
    if (system("which apt-get > /dev/null 2>&1") == 0) {
        cmd = "apt-get remove -y " + name;
    } else if (system("which yum > /dev/null 2>&1") == 0) {
        cmd = "yum remove -y " + name;
    } else if (system("which dnf > /dev/null 2>&1") == 0) {
        cmd = "dnf remove -y " + name;
    } else if (system("which pacman > /dev/null 2>&1") == 0) {
        cmd = "pacman -R --noconfirm " + name;
    } else {
        logger.error("Unsupported package manager");
        return false;
    }
    
    int ret = system(cmd.c_str());
    
    if (ret == 0) {
        components_.erase(name);
        logger.success("Component '" + name + "' uninstalled successfully");
        return true;
    }
    
    return false;
}

bool ComponentManager::isInstalled(const std::string& name) {
    return components_.find(name) != components_.end() && 
           components_[name].installed;
}

Component ComponentManager::getInfo(const std::string& name) {
    if (components_.find(name) != components_.end()) {
        return components_[name];
    }
    return Component();
}

void ComponentManager::loadComponentRegistry() {
    // 从文件加载组件注册表
    std::string registryPath = componentsPath_ + "/registry.json";
    std::ifstream registryFile(registryPath);
    
    if (!registryFile.is_open()) {
        // 如果文件不存在，初始化为空注册表
        return;
    }
    
    // 简单的 JSON 解析（实际项目中应使用 JSON 库如 nlohmann/json）
    std::string line;
    std::string currentName;
    Component currentComponent;
    bool inComponent = false;
    
    while (std::getline(registryFile, line)) {
        // 去除空白字符
        size_t start = line.find_first_not_of(" \t\n\r");
        if (start == std::string::npos) continue;
        line = line.substr(start);
        
        // 解析组件名称
        if (line.find("\"name\":") != std::string::npos) {
            size_t nameStart = line.find("\"", 8) + 1;
            size_t nameEnd = line.find("\"", nameStart);
            currentComponent.name = line.substr(nameStart, nameEnd - nameStart);
            inComponent = true;
        }
        // 解析版本
        else if (line.find("\"version\":") != std::string::npos) {
            size_t verStart = line.find("\"", 11) + 1;
            size_t verEnd = line.find("\"", verStart);
            currentComponent.version = line.substr(verStart, verEnd - verStart);
        }
        // 解析描述
        else if (line.find("\"description\":") != std::string::npos) {
            size_t descStart = line.find("\"", 15) + 1;
            size_t descEnd = line.find("\"", descStart);
            currentComponent.description = line.substr(descStart, descEnd - descStart);
        }
        // 解析安装状态
        else if (line.find("\"installed\":") != std::string::npos) {
            currentComponent.installed = (line.find("true") != std::string::npos);
        }
        // 组件结束
        else if (line.find("}") != std::string::npos && inComponent) {
            if (!currentComponent.name.empty()) {
                components_[currentComponent.name] = currentComponent;
            }
            currentComponent = Component();
            inComponent = false;
        }
    }
    
    registryFile.close();
}

void ComponentManager::saveComponentRegistry() {
    // 保存组件注册表到文件
    // 确保目录存在
#ifdef _WIN32
    _mkdir(componentsPath_.c_str());
#else
    mkdir(componentsPath_.c_str(), 0755);
#endif
    
    std::string registryPath = componentsPath_ + "/registry.json";
    std::ofstream registryFile(registryPath);
    
    if (!registryFile.is_open()) {
        return;
    }
    
    // 写入 JSON 格式
    registryFile << "{\n";
    registryFile << "  \"components\": [\n";
    
    size_t count = 0;
    for (const auto& pair : components_) {
        const Component& comp = pair.second;
        
        registryFile << "    {\n";
        registryFile << "      \"name\": \"" << comp.name << "\",\n";
        registryFile << "      \"version\": \"" << comp.version << "\",\n";
        registryFile << "      \"description\": \"" << comp.description << "\",\n";
        registryFile << "      \"installed\": " << (comp.installed ? "true" : "false") << "\n";
        registryFile << "    }";
        
        if (++count < components_.size()) {
            registryFile << ",";
        }
        registryFile << "\n";
    }
    
    registryFile << "  ]\n";
    registryFile << "}\n";
    
    registryFile.close();
}

bool ComponentManager::executeSystemCommand(const std::string& cmd) {
    return system(cmd.c_str()) == 0;
}

} // namespace LinuxStudio

