#pragma once

#include <string>
#include <fstream>
#include <iostream>
#include <sstream>
#include <chrono>
#include <iomanip>

namespace LinuxStudio {

/**
 * @brief 日志级别枚举
 */
enum class LogLevel {
    DEBUG,    // 调试信息
    INFO,     // 一般信息
    WARNING,  // 警告
    ERROR,    // 错误
    SUCCESS   // 成功
};

/**
 * @brief 日志器类
 * 提供彩色终端输出和文件日志功能
 */
class Logger {
public:
    Logger();
    ~Logger();
    
    /**
     * @brief 设置日志文件路径
     * @param path 日志文件路径
     */
    void setLogFile(const std::string& path);
    
    /**
     * @brief 设置最小日志级别
     * @param level 日志级别
     */
    void setMinLevel(LogLevel level);
    
    /**
     * @brief 记录日志
     * @param level 日志级别
     * @param message 日志消息
     */
    void log(LogLevel level, const std::string& message);
    
    // 便捷方法
    void debug(const std::string& message);
    void info(const std::string& message);
    void warning(const std::string& message);
    void error(const std::string& message);
    void success(const std::string& message);
    
private:
    std::ofstream logFile_;
    LogLevel minLevel_;
    bool useColors_;
    
    std::string getCurrentTime();
    std::string getLevelString(LogLevel level);
    std::string getColorCode(LogLevel level);
    std::string getColorReset();
    void writeToConsole(LogLevel level, const std::string& message);
    void writeToFile(LogLevel level, const std::string& message);
};

} // namespace LinuxStudio

