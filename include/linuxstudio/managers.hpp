#pragma once

#include "core.hpp"
#include <string>
#include <vector>
#include <map>
#include <functional>

namespace LinuxStudio {

/**
 * @brief 组件管理器
 * 负责组件的安装、卸载、查询等操作
 */
class ComponentManager {
public:
    ComponentManager();
    ~ComponentManager();
    
    /**
     * @brief 列出所有已安装的组件
     * @return 组件列表
     */
    std::vector<Component> listInstalled();
    
    /**
     * @brief 搜索组件
     * @param keyword 关键词
     * @return 匹配的组件列表
     */
    std::vector<Component> search(const std::string& keyword);
    
    /**
     * @brief 安装组件
     * @param name 组件名称
     * @return 成功返回 true
     */
    bool install(const std::string& name);
    
    /**
     * @brief 卸载组件
     * @param name 组件名称
     * @return 成功返回 true
     */
    bool uninstall(const std::string& name);
    
    /**
     * @brief 检查组件是否已安装
     * @param name 组件名称
     * @return 已安装返回 true
     */
    bool isInstalled(const std::string& name);
    
    /**
     * @brief 获取组件信息
     * @param name 组件名称
     * @return 组件信息
     */
    Component getInfo(const std::string& name);
    
private:
    std::map<std::string, Component> components_;
    std::string componentsPath_;
    
    void loadComponentRegistry();
    void saveComponentRegistry();
    bool executeSystemCommand(const std::string& cmd);
};

/**
 * @brief 插件管理器
 * 负责插件的安装、卸载、启用、禁用等操作
 */
class PluginManager {
public:
    PluginManager();
    ~PluginManager();
    
    /**
     * @brief 列出所有已安装的插件
     * @return 插件列表
     */
    std::vector<Plugin> listInstalled();
    
    /**
     * @brief 安装插件
     * @param name 插件名称
     * @return 成功返回 true
     */
    bool install(const std::string& name);
    
    /**
     * @brief 卸载插件
     * @param name 插件名称
     * @return 成功返回 true
     */
    bool uninstall(const std::string& name);
    
    /**
     * @brief 启用插件
     * @param name 插件名称
     * @return 成功返回 true
     */
    bool enable(const std::string& name);
    
    /**
     * @brief 禁用插件
     * @param name 插件名称
     * @return 成功返回 true
     */
    bool disable(const std::string& name);
    
    /**
     * @brief 检查插件是否已安装
     * @param name 插件名称
     * @return 已安装返回 true
     */
    bool isInstalled(const std::string& name);
    
    /**
     * @brief 检查插件是否已启用
     * @param name 插件名称
     * @return 已启用返回 true
     */
    bool isEnabled(const std::string& name);
    
    /**
     * @brief 获取插件信息
     * @param name 插件名称
     * @return 插件信息
     */
    Plugin getInfo(const std::string& name);
    
private:
    std::map<std::string, Plugin> plugins_;
    std::string pluginsPath_;
    
    // 内置插件安装函数
    using PluginInstaller = std::function<bool()>;
    std::map<std::string, PluginInstaller> installers_;
    
    void loadPluginRegistry();
    void savePluginRegistry();
    void savePluginMetadata(const std::string& name, const Plugin& plugin);
    void registerBuiltinInstallers();
    
    // 内置插件安装函数
    bool installROS2();
    bool installRobotArm();
    bool installOpenCV();
    bool installPyTorch();
    bool installTensorFlow();
    bool installCUDA();
};

} // namespace LinuxStudio

