#include "linuxstudio/logger.hpp"
#include <ctime>

#ifdef _WIN32
    #include <io.h>
    #define isatty _isatty
    #define fileno _fileno
#else
    #include <unistd.h>
#endif

namespace LinuxStudio {

Logger::Logger() 
    : minLevel_(LogLevel::INFO), useColors_(true) {
    // 检查是否支持颜色输出
#ifdef _WIN32
    useColors_ = false;  // Windows 终端颜色支持较差
#else
    useColors_ = (isatty(fileno(stdout)) != 0);
#endif
}

Logger::~Logger() {
    if (logFile_.is_open()) {
        logFile_.close();
    }
}

void Logger::setLogFile(const std::string& path) {
    if (logFile_.is_open()) {
        logFile_.close();
    }
    logFile_.open(path, std::ios::app);
}

void Logger::setMinLevel(LogLevel level) {
    minLevel_ = level;
}

void Logger::log(LogLevel level, const std::string& message) {
    if (level < minLevel_) {
        return;
    }
    
    writeToConsole(level, message);
    
    if (logFile_.is_open()) {
        writeToFile(level, message);
    }
}

void Logger::debug(const std::string& message) {
    log(LogLevel::DEBUG, message);
}

void Logger::info(const std::string& message) {
    log(LogLevel::INFO, message);
}

void Logger::warning(const std::string& message) {
    log(LogLevel::WARNING, message);
}

void Logger::error(const std::string& message) {
    log(LogLevel::ERROR, message);
}

void Logger::success(const std::string& message) {
    log(LogLevel::SUCCESS, message);
}

std::string Logger::getCurrentTime() {
    auto now = std::chrono::system_clock::now();
    auto time = std::chrono::system_clock::to_time_t(now);
    std::stringstream ss;
    ss << std::put_time(std::localtime(&time), "%Y-%m-%d %H:%M:%S");
    return ss.str();
}

std::string Logger::getLevelString(LogLevel level) {
    switch (level) {
        case LogLevel::DEBUG:   return "DEBUG";
        case LogLevel::INFO:    return "INFO";
        case LogLevel::WARNING: return "WARNING";
        case LogLevel::ERROR:   return "ERROR";
        case LogLevel::SUCCESS: return "SUCCESS";
        default:                return "UNKNOWN";
    }
}

std::string Logger::getColorCode(LogLevel level) {
    if (!useColors_) {
        return "";
    }
    
    switch (level) {
        case LogLevel::DEBUG:   return "\033[0;36m";  // Cyan
        case LogLevel::INFO:    return "\033[0;36m";  // Cyan
        case LogLevel::WARNING: return "\033[1;33m";  // Yellow
        case LogLevel::ERROR:   return "\033[0;31m";  // Red
        case LogLevel::SUCCESS: return "\033[0;32m";  // Green
        default:                return "";
    }
}

std::string Logger::getColorReset() {
    return useColors_ ? "\033[0m" : "";
}

void Logger::writeToConsole(LogLevel level, const std::string& message) {
    std::string icon;
    switch (level) {
        case LogLevel::DEBUG:   icon = "🔍"; break;
        case LogLevel::INFO:    icon = "ℹ️ "; break;
        case LogLevel::WARNING: icon = "⚠️ "; break;
        case LogLevel::ERROR:   icon = "❌"; break;
        case LogLevel::SUCCESS: icon = "✅"; break;
    }
    
    std::cout << getColorCode(level) 
              << icon << " " << message 
              << getColorReset() << std::endl;
}

void Logger::writeToFile(LogLevel level, const std::string& message) {
    logFile_ << "[" << getCurrentTime() << "] "
             << "[" << getLevelString(level) << "] "
             << message << std::endl;
}

} // namespace LinuxStudio

