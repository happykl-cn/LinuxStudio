#include "linuxstudio/core.hpp"
#include "linuxstudio/managers.hpp"
#include "linuxstudio/logger.hpp"
#include <fstream>
#include <sstream>
#include <cstdlib>

// 平台特定头文件
#ifdef __linux__
    #include <unistd.h>
    #include <sys/utsname.h>
    #include <sys/sysinfo.h>
#elif _WIN32
    #include <windows.h>
    #pragma message("WARNING: LinuxStudio C++ version is designed for Linux. Windows support is limited.")
#else
    #error "Unsupported platform. LinuxStudio requires Linux or Windows."
#endif

namespace LinuxStudio {

// 单例实例
CoreEngine& CoreEngine::getInstance() {
    static CoreEngine instance;
    return instance;
}

// 私有构造函数
CoreEngine::CoreEngine() 
    : initialized_(false) {
    logger_ = std::make_unique<Logger>();
    componentMgr_ = std::make_unique<ComponentManager>();
    pluginMgr_ = std::make_unique<PluginManager>();
}

CoreEngine::~CoreEngine() {
    // 智能指针自动释放
}

bool CoreEngine::initialize() {
    if (initialized_) {
        return true;
    }
    
    logger_->info("Initializing LinuxStudio Framework...");
    
    // 检测系统信息
    systemInfo_ = detectSystem();
    
    logger_->success("LinuxStudio Framework initialized successfully");
    logger_->info("OS: " + systemInfo_.osName + " " + systemInfo_.osVersion);
    logger_->info("Architecture: " + systemInfo_.architecture);
    logger_->info("CPU Cores: " + std::to_string(systemInfo_.cpuCores));
    logger_->info("Memory: " + std::to_string(systemInfo_.totalMemory) + " MB");
    
    initialized_ = true;
    return true;
}

SystemInfo CoreEngine::detectSystem() {
    SystemInfo info;
    
#ifdef __linux__
    // ========== Linux 实现 ==========
    
    // 获取系统信息（使用 uname）
    struct utsname unameData;
    if (uname(&unameData) == 0) {
        info.osName = unameData.sysname;
        info.architecture = unameData.machine;
    }
    
    // 读取 /etc/os-release 获取发行版信息
    std::ifstream osRelease("/etc/os-release");
    if (osRelease.is_open()) {
        std::string line;
        while (std::getline(osRelease, line)) {
            if (line.find("PRETTY_NAME=") == 0) {
                // 提取引号中的内容
                size_t start = line.find('"') + 1;
                size_t end = line.rfind('"');
                if (start != std::string::npos && end != std::string::npos) {
                    info.osName = line.substr(start, end - start);
                }
            } else if (line.find("VERSION_ID=") == 0) {
                size_t start = line.find('"') + 1;
                size_t end = line.rfind('"');
                if (start != std::string::npos && end != std::string::npos) {
                    info.osVersion = line.substr(start, end - start);
                }
            }
        }
        osRelease.close();
    }
    
    // 获取 CPU 核心数
    info.cpuCores = sysconf(_SC_NPROCESSORS_ONLN);
    
    // 获取内存信息
    struct sysinfo si;
    if (sysinfo(&si) == 0) {
        info.totalMemory = si.totalram / (1024 * 1024);  // 转换为 MB
        info.availableMemory = si.freeram / (1024 * 1024);
    }
    
#elif _WIN32
    // ========== Windows 实现（有限支持，仅用于测试）==========
    
    info.osName = "Windows";
    info.osVersion = "10/11";
    info.architecture = "x86_64";
    
    // 获取 CPU 核心数
    SYSTEM_INFO sysInfo;
    GetSystemInfo(&sysInfo);
    info.cpuCores = static_cast<int>(sysInfo.dwNumberOfProcessors);
    
    // 获取内存信息
    MEMORYSTATUSEX memInfo;
    memInfo.dwLength = sizeof(MEMORYSTATUSEX);
    if (GlobalMemoryStatusEx(&memInfo)) {
        info.totalMemory = memInfo.ullTotalPhys / (1024 * 1024);  // MB
        info.availableMemory = memInfo.ullAvailPhys / (1024 * 1024);
    }
    
    logger_->warning("Running on Windows - limited functionality!");
    logger_->warning("For full features, please use Linux.");
    
#else
    // ========== 未知平台 ==========
    
    info.osName = "Unknown";
    info.osVersion = "0.0.0";
    info.architecture = "unknown";
    info.cpuCores = 1;
    info.totalMemory = 0;
    info.availableMemory = 0;
    
    logger_->error("Unsupported operating system!");
    
#endif
    
    return info;
}

std::vector<Component> CoreEngine::recommendComponents(SceneType scene) {
    std::vector<Component> components;
    
    switch (scene) {
        case SceneType::WEB_DEVELOPMENT:
            components.push_back(Component("nginx", "High-performance web server"));
            components.push_back(Component("php", "Server-side scripting language"));
            components.push_back(Component("mysql-server", "Relational database"));
            components.push_back(Component("redis-server", "In-memory data store"));
            components.push_back(Component("nodejs", "JavaScript runtime"));
            break;
            
        case SceneType::ROBOTICS:
            components.push_back(Component("ros2", "Robot Operating System 2"));
            components.push_back(Component("gazebo", "3D robot simulator"));
            components.push_back(Component("opencv", "Computer vision library"));
            break;
            
        case SceneType::AI_ML:
            components.push_back(Component("python3-pip", "Python package manager"));
            components.push_back(Component("jupyter", "Interactive notebooks"));
            break;
            
        case SceneType::DEVOPS:
            components.push_back(Component("docker", "Container runtime"));
            components.push_back(Component("kubectl", "Kubernetes CLI"));
            components.push_back(Component("terraform", "Infrastructure as Code"));
            break;
            
        default:
            logger_->warning("Unknown scene type");
            break;
    }
    
    return components;
}

ComponentManager& CoreEngine::getComponentManager() {
    return *componentMgr_;
}

PluginManager& CoreEngine::getPluginManager() {
    return *pluginMgr_;
}

Logger& CoreEngine::getLogger() {
    return *logger_;
}

} // namespace LinuxStudio

