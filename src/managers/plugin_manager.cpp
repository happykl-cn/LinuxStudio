#include "linuxstudio/managers.hpp"
#include "linuxstudio/core.hpp"
#include <fstream>
#include <sstream>
#include <cstdlib>
#include <chrono>
#include <iomanip>
#include <sys/stat.h>
#include <sys/types.h>
#include <dirent.h>

namespace LinuxStudio {

PluginManager::PluginManager() 
    : pluginsPath_("/opt/linuxstudio/plugins") {
    // 创建插件目录
    mkdir(pluginsPath_.c_str(), 0755);
    
    // 注册内置插件安装程序
    registerBuiltinInstallers();
    
    // 加载插件注册表
    loadPluginRegistry();
}

PluginManager::~PluginManager() {
    savePluginRegistry();
}

void PluginManager::registerBuiltinInstallers() {
    installers_["ros2"] = [this]() { return installROS2(); };
    installers_["robot-arm"] = [this]() { return installRobotArm(); };
    installers_["opencv"] = [this]() { return installOpenCV(); };
    installers_["pytorch"] = [this]() { return installPyTorch(); };
    installers_["tensorflow"] = [this]() { return installTensorFlow(); };
    installers_["cuda-toolkit"] = [this]() { return installCUDA(); };
}

std::vector<Plugin> PluginManager::listInstalled() {
    std::vector<Plugin> result;
    for (const auto& pair : plugins_) {
        result.push_back(pair.second);
    }
    return result;
}

bool PluginManager::install(const std::string& name) {
    auto& logger = CoreEngine::getInstance().getLogger();
    
    logger.info("Installing plugin: " + name);
    
    // 检查是否已安装
    if (isInstalled(name)) {
        logger.warning("Plugin '" + name + "' is already installed");
        return false;
    }
    
    // 执行安装
    bool success = false;
    if (installers_.find(name) != installers_.end()) {
        success = installers_[name]();
    } else {
        logger.warning("Unknown plugin: " + name);
        logger.info("Creating custom plugin directory");
        
        // 创建插件目录
        std::string pluginDir = pluginsPath_ + "/" + name;
        mkdir(pluginDir.c_str(), 0755);
        success = true;
    }
    
    if (success) {
        // 创建插件信息
        Plugin plugin(name, "");
        plugin.enabled = true;
        
        // 获取当前时间
        auto now = std::chrono::system_clock::now();
        auto time = std::chrono::system_clock::to_time_t(now);
        std::stringstream ss;
        ss << std::put_time(std::localtime(&time), "%Y-%m-%dT%H:%M:%S");
        plugin.installedAt = ss.str();
        
        // 保存到注册表
        plugins_[name] = plugin;
        savePluginMetadata(name, plugin);
        
        logger.success("Plugin '" + name + "' installed successfully");
        return true;
    }
    
    logger.error("Failed to install plugin: " + name);
    return false;
}

bool PluginManager::uninstall(const std::string& name) {
    auto& logger = CoreEngine::getInstance().getLogger();
    
    if (!isInstalled(name)) {
        logger.error("Plugin '" + name + "' is not installed");
        return false;
    }
    
    logger.warning("Uninstalling plugin: " + name);
    
    // 删除插件目录
    std::string cmd = "rm -rf " + pluginsPath_ + "/" + name;
    int ret = system(cmd.c_str());
    
    if (ret == 0) {
        plugins_.erase(name);
        logger.success("Plugin '" + name + "' uninstalled successfully");
        return true;
    }
    
    return false;
}

bool PluginManager::enable(const std::string& name) {
    auto& logger = CoreEngine::getInstance().getLogger();
    
    if (!isInstalled(name)) {
        logger.error("Plugin '" + name + "' is not installed");
        return false;
    }
    
    plugins_[name].enabled = true;
    savePluginMetadata(name, plugins_[name]);
    logger.success("Plugin '" + name + "' enabled");
    return true;
}

bool PluginManager::disable(const std::string& name) {
    auto& logger = CoreEngine::getInstance().getLogger();
    
    if (!isInstalled(name)) {
        logger.error("Plugin '" + name + "' is not installed");
        return false;
    }
    
    plugins_[name].enabled = false;
    savePluginMetadata(name, plugins_[name]);
    logger.warning("Plugin '" + name + "' disabled");
    return true;
}

bool PluginManager::isInstalled(const std::string& name) {
    return plugins_.find(name) != plugins_.end();
}

bool PluginManager::isEnabled(const std::string& name) {
    if (!isInstalled(name)) {
        return false;
    }
    return plugins_[name].enabled;
}

Plugin PluginManager::getInfo(const std::string& name) {
    if (isInstalled(name)) {
        return plugins_[name];
    }
    return Plugin();
}

void PluginManager::loadPluginRegistry() {
    // 扫描插件目录
    DIR* dir = opendir(pluginsPath_.c_str());
    if (dir == nullptr) {
        return;
    }
    
    struct dirent* entry;
    while ((entry = readdir(dir)) != nullptr) {
        if (entry->d_type == DT_DIR && entry->d_name[0] != '.') {
            std::string name = entry->d_name;
            
            // 尝试读取元数据
            std::string metaPath = pluginsPath_ + "/" + name + "/metadata.json";
            std::ifstream metaFile(metaPath);
            
            if (metaFile.is_open()) {
                // 简单解析（实际应使用 JSON 库）
                Plugin plugin;
                plugin.name = name;
                plugin.enabled = true;
                plugins_[name] = plugin;
                metaFile.close();
            }
        }
    }
    closedir(dir);
}

void PluginManager::savePluginRegistry() {
    // 保存每个插件的元数据
    for (const auto& pair : plugins_) {
        savePluginMetadata(pair.first, pair.second);
    }
}

void PluginManager::savePluginMetadata(const std::string& name, const Plugin& plugin) {
    std::string pluginDir = pluginsPath_ + "/" + name;
    mkdir(pluginDir.c_str(), 0755);
    
    std::string metaPath = pluginDir + "/metadata.json";
    std::ofstream metaFile(metaPath);
    
    if (metaFile.is_open()) {
        metaFile << "{\n";
        metaFile << "  \"name\": \"" << plugin.name << "\",\n";
        metaFile << "  \"version\": \"" << plugin.version << "\",\n";
        metaFile << "  \"enabled\": " << (plugin.enabled ? "true" : "false") << ",\n";
        metaFile << "  \"installedAt\": \"" << plugin.installedAt << "\"\n";
        metaFile << "}\n";
        metaFile.close();
    }
}

// 内置插件安装函数
bool PluginManager::installROS2() {
    auto& logger = CoreEngine::getInstance().getLogger();
    logger.info("Installing ROS2 Humble...");
    
    // 执行安装命令
    std::string cmd = R"(
        apt-get update -qq && \
        apt-get install -y software-properties-common curl && \
        curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null && \
        apt-get update -qq && \
        apt-get install -y ros-humble-desktop python3-colcon-common-extensions
    )";
    
    int ret = system(cmd.c_str());
    return ret == 0;
}

bool PluginManager::installRobotArm() {
    auto& logger = CoreEngine::getInstance().getLogger();
    logger.info("Installing Robot Arm control libraries...");
    
    std::string cmd = "apt-get install -y libmodbus-dev can-utils liburdfdom-dev && pip3 install roboticstoolbox-python";
    int ret = system(cmd.c_str());
    return ret == 0;
}

bool PluginManager::installOpenCV() {
    auto& logger = CoreEngine::getInstance().getLogger();
    logger.info("Installing OpenCV...");
    
    std::string cmd = "apt-get install -y libopencv-dev python3-opencv";
    int ret = system(cmd.c_str());
    return ret == 0;
}

bool PluginManager::installPyTorch() {
    auto& logger = CoreEngine::getInstance().getLogger();
    logger.info("Installing PyTorch...");
    
    std::string cmd = "pip3 install torch torchvision torchaudio";
    int ret = system(cmd.c_str());
    return ret == 0;
}

bool PluginManager::installTensorFlow() {
    auto& logger = CoreEngine::getInstance().getLogger();
    logger.info("Installing TensorFlow...");
    
    std::string cmd = "pip3 install tensorflow";
    int ret = system(cmd.c_str());
    return ret == 0;
}

bool PluginManager::installCUDA() {
    auto& logger = CoreEngine::getInstance().getLogger();
    logger.info("Checking for NVIDIA GPU...");
    
    // 检测 NVIDIA GPU
    int ret = system("lspci | grep -i nvidia > /dev/null");
    if (ret == 0) {
        logger.warning("NVIDIA GPU detected");
        logger.info("Please install CUDA from NVIDIA website:");
        logger.info("https://developer.nvidia.com/cuda-downloads");
        return true;
    } else {
        logger.error("No NVIDIA GPU detected");
        return false;
    }
}

} // namespace LinuxStudio

