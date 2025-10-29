#pragma once
#include <string>
#include <vector>
#include <map>
#include <memory>

namespace LinuxStudio {

// 前向声明
class ComponentManager;
class PluginManager;
class Logger;

/**
 * @brief 系统信息结构
 * 存储检测到的系统信息
 */
struct SystemInfo {
    std::string osName;           
    std::string osVersion;        
    std::string architecture;    
    int cpuCores;                 
    long long totalMemory;       
    long long availableMemory;    
    std::map<std::string, std::string> installedPackages;  
};

/**
 * @brief 场景类型枚举
 */
enum class SceneType {
    WEB_DEVELOPMENT,
    EMBEDDED,
    ROBOTICS,
    AI_ML,
    GAME_DEV,
    DEVOPS,
    SECURITY,
    BLOCKCHAIN,
    IOT,
    UNKNOWN
};

/**
 * @brief 组件结构
 */
struct Component {
    std::string name;             
    std::string version;          
    std::string description;      
    std::vector<std::string> dependencies;  
    bool installed;              
    
    Component() : installed(false) {}
    Component(const std::string& n, const std::string& desc) 
        : name(n), description(desc), installed(false) {}
};

/**
 * @brief 插件结构
 */
struct Plugin {
    std::string name;             
    std::string version;          
    std::string description;      
    bool enabled;                 
    std::string installedAt;      
    
    Plugin() : enabled(false) {}
    Plugin(const std::string& n, const std::string& desc) 
        : name(n), description(desc), enabled(false) {}
};

/**
 * @brief 核心引擎类
 * 单例
 */

class CoreEngine {
public:
    static CoreEngine& getInstance();
    CoreEngine(const CoreEngine&) = delete;
    CoreEngine& operator=(const CoreEngine&) = delete;
    /**
     * @brief 初始化框架
     * @return 成功返回 true
     */
    
    bool initialize();
    
    /**
     * @brief 检测系统信息
     * @return 系统信息结构
     */
    SystemInfo detectSystem();
    
    /**
     * @brief 获取系统信息
     * @return 缓存的系统信息
     */
    const SystemInfo& getSystemInfo() const { return systemInfo_; }
    
    /**
     * @brief 根据场景推荐组件
     * @param scene 场景类型
     * @return 推荐的组件列表
     */
    std::vector<Component> recommendComponents(SceneType scene);
    
    /**
     * @brief 获取组件管理器
     */
    ComponentManager& getComponentManager();
    
    /**
     * @brief 获取插件管理器
     */
    PluginManager& getPluginManager();
    
    /**
     * @brief 获取日志器
     */
    Logger& getLogger();
    
    /**
     * @brief 获取版本号
     */
    std::string getVersion() const { return "1.0.0"; }
    
private:
    // 私有构造函数（单例）
    CoreEngine();
    ~CoreEngine();
    
    SystemInfo systemInfo_;
    std::unique_ptr<ComponentManager> componentMgr_;
    std::unique_ptr<PluginManager> pluginMgr_;
    std::unique_ptr<Logger> logger_;
    bool initialized_;
};

} 

