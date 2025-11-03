#pragma once
#include <string>
#include <map>
#include <cstdlib>

namespace LinuxStudio {

/**
 * @brief 简单的国际化类
 * 支持中文和英文
 */
class I18n {
public:
    enum class Language {
        AUTO,   // 自动检测
        ZH_CN,  // 简体中文
        EN      // 英文
    };

    static I18n& getInstance() {
        static I18n instance;
        return instance;
    }

    /**
     * @brief 初始化语言设置
     */
    void init(Language lang = Language::AUTO) {
        if (lang == Language::AUTO) {
            detectLanguage();
        } else {
            currentLang_ = lang;
        }
    }

    /**
     * @brief 获取翻译文本
     */
    const std::string& t(const std::string& key) const {
        if (currentLang_ == Language::ZH_CN) {
            auto it = zhTranslations_.find(key);
            if (it != zhTranslations_.end()) {
                return it->second;
            }
        }
        // 默认返回英文（key 作为英文文本）
        auto it = enTranslations_.find(key);
        if (it != enTranslations_.end()) {
            return it->second;
        }
        // 如果找不到，返回 key 本身
        return key;
    }

    /**
     * @brief 检测系统语言
     */
    void detectLanguage() {
        const char* lang = std::getenv("LANG");
        if (lang) {
            std::string langStr(lang);
            // 检查是否包含 zh_CN 或 zh
            if (langStr.find("zh_CN") != std::string::npos || 
                langStr.find("zh") != std::string::npos) {
                currentLang_ = Language::ZH_CN;
                return;
            }
        }
        currentLang_ = Language::EN;
    }

    Language getCurrentLanguage() const {
        return currentLang_;
    }

    bool isChinese() const {
        return currentLang_ == Language::ZH_CN;
    }

private:
    I18n() : currentLang_(Language::EN) {
        initTranslations();
    }

    void initTranslations() {
        // 英文翻译（默认值，key = value）
        enTranslations_ = {
            // Status
            {"LinuxStudio Framework Status", "LinuxStudio Framework Status"},
            {"Version", "Version"},
            {"Install Path", "Install Path"},
            {"System Information", "System Information"},
            {"OS", "OS"},
            {"Architecture", "Architecture"},
            {"CPU Cores", "CPU Cores"},
            {"Memory", "Memory"},
            {"MB available", "MB available"},
            
            // Plugin
            {"Installed Plugins", "Installed Plugins"},
            {"No plugins installed yet.", "No plugins installed yet."},
            {"Available plugins:", "Available plugins:"},
            {"Install a plugin", "Install a plugin"},
            {"enabled", "enabled"},
            {"disabled", "disabled"},
            
            // Component
            {"Installed Components", "Installed Components"},
            {"Component listing not yet implemented", "Component listing not yet implemented"},
            
            // Messages
            {"Error", "Error"},
            {"No command specified", "No command specified"},
            {"Failed to initialize LinuxStudio Framework", "Failed to initialize LinuxStudio Framework"},
            {"Plugin subcommand required", "Plugin subcommand required"},
            {"Plugin name required", "Plugin name required"},
            {"Unknown plugin subcommand", "Unknown plugin subcommand"},
            {"Component subcommand required", "Component subcommand required"},
            {"Component name required", "Component name required"},
            {"Unknown component subcommand", "Unknown component subcommand"},
            {"Unknown command", "Unknown command"},
            {"installed successfully", "installed successfully"},
            {"Manage", "Manage"},
            
            // Help
            {"High-Performance Linux Environment Manager", "High-Performance Linux Environment Manager"},
            {"Framework Commands", "Framework Commands"},
            {"Component Management", "Component Management"},
            {"Plugin Management", "Plugin Management"},
            {"Scene Management", "Scene Management"},
            {"Other Commands", "Other Commands"},
            {"Examples", "Examples"},
            
            // Scene
            {"Scene subcommand required", "Scene subcommand required"},
            {"Scene name required", "Scene name required"},
            {"Unknown scene subcommand", "Unknown scene subcommand"},
        };

        // 中文翻译
        zhTranslations_ = {
            // Status
            {"LinuxStudio Framework Status", "LinuxStudio 框架状态"},
            {"Version", "版本"},
            {"Install Path", "安装路径"},
            {"System Information", "系统信息"},
            {"OS", "操作系统"},
            {"Architecture", "架构"},
            {"CPU Cores", "CPU 核心数"},
            {"Memory", "内存"},
            {"MB available", "MB 可用"},
            
            // Plugin
            {"Installed Plugins", "已安装的插件"},
            {"No plugins installed yet.", "尚未安装任何插件。"},
            {"Available plugins:", "可用插件："},
            {"Install a plugin", "安装插件"},
            {"enabled", "已启用"},
            {"disabled", "已禁用"},
            
            // Component
            {"Installed Components", "已安装的组件"},
            {"Component listing not yet implemented", "组件列表功能尚未实现"},
            
            // Messages
            {"Error", "错误"},
            {"No command specified", "未指定命令"},
            {"Failed to initialize LinuxStudio Framework", "初始化 LinuxStudio 框架失败"},
            {"Plugin subcommand required", "需要插件子命令"},
            {"Plugin name required", "需要插件名称"},
            {"Unknown plugin subcommand", "未知的插件子命令"},
            {"Component subcommand required", "需要组件子命令"},
            {"Component name required", "需要组件名称"},
            {"Unknown component subcommand", "未知的组件子命令"},
            {"Unknown command", "未知命令"},
            {"installed successfully", "安装成功"},
            {"Manage", "管理"},
            
            // Help
            {"High-Performance Linux Environment Manager", "高性能 Linux 环境管理器"},
            {"Framework Commands", "框架命令"},
            {"Component Management", "组件管理"},
            {"Plugin Management", "插件管理"},
            {"Scene Management", "场景管理"},
            {"Other Commands", "其他命令"},
            {"Examples", "示例"},
            
            // Scene
            {"Scene subcommand required", "需要场景子命令"},
            {"Scene name required", "需要场景名称"},
            {"Unknown scene subcommand", "未知的场景子命令"},
        };
    }

    Language currentLang_;
    std::map<std::string, std::string> enTranslations_;
    std::map<std::string, std::string> zhTranslations_;
};

// 便捷宏
#define T(key) LinuxStudio::I18n::getInstance().t(key)

} // namespace LinuxStudio

