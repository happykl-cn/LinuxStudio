#include "linuxstudio/managers.hpp"
#include "linuxstudio/core.hpp"
#include "linuxstudio/logger.hpp"  // 添加 Logger 的完整定义
#include <cstdlib>

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
    // TODO: 从文件加载组件注册表
}

void ComponentManager::saveComponentRegistry() {
    // TODO: 保存组件注册表到文件
}

bool ComponentManager::executeSystemCommand(const std::string& cmd) {
    return system(cmd.c_str()) == 0;
}

} // namespace LinuxStudio

