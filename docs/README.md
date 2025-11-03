# LinuxStudio 文档中心

欢迎来到 LinuxStudio 文档中心！所有文档已整理成5个核心文件，方便查阅。

## 📚 核心文档（5个）

### 1. [安装指南](INSTALLATION.md) 📦
**适合**: 所有用户  
**内容**: 
- 一键安装脚本使用
- 多种安装方式（包管理器、手动下载、源码编译）
- 嵌入式设备手动安装
- 安装流程详解
- 场景选择说明

### 2. [用户指南](USER_GUIDE.md) 📘
**适合**: 所有用户  
**内容**:
- **升级指南**: 版本升级、验证、回滚
- **调试指南**: 诊断脚本、常见问题解决
- **嵌入式系统**: STM32MP1, Raspberry Pi, BeagleBone完整支持
- SSL证书问题处理
- 性能优化建议

### 3. [开发者指南](DEVELOPER_GUIDE.md) 👨‍💻
**适合**: 开发者、贡献者  
**内容**:
- 快速编译和安装
- C++开发详解
- 打包发布流程
- 项目结构说明
- CI/CD自动化

### 4. [C++编译说明](COMPILATION.md) 🔨
**适合**: 开发者  
**内容**:
- 编译流程详解
- 交叉编译（ARM设备）
- 运行时机制
- 系统调用流程
- ELF文件格式

### 5. [更新日志](CHANGELOG.md) 📋
**适合**: 所有用户  
**内容**:
- 版本历史（v1.0.0 → v1.1.2）
- 功能更新
- Bug修复
- 未来规划

---

## 🚀 快速导航

### 我是新用户，想快速安装
→ **[安装指南](INSTALLATION.md)** 

### 我想升级到最新版本
→ **[用户指南 - 升级指南](USER_GUIDE.md#升级指南)**

### 我遇到了问题
→ **[用户指南 - 调试指南](USER_GUIDE.md#调试指南)**

### 我使用嵌入式系统（STM32MP1/树莓派等）
→ **[用户指南 - 嵌入式系统](USER_GUIDE.md#嵌入式系统)**

### 我想从源码编译
→ **[开发者指南 - 编译安装](DEVELOPER_GUIDE.md#编译安装)**

### 我想了解编译原理
→ **[C++编译说明](COMPILATION.md)**

### 我想查看更新历史
→ **[更新日志](CHANGELOG.md)**

---

## 📖 推荐阅读顺序

### 初次使用者
1. **[安装指南](INSTALLATION.md)** - 快速上手
2. **[用户指南](USER_GUIDE.md)** - 遇到问题时查阅

### 开发者
1. **[开发者指南](DEVELOPER_GUIDE.md)** - 开发环境搭建
2. **[C++编译说明](COMPILATION.md)** - 深入了解编译机制
3. **[更新日志](CHANGELOG.md)** - 了解最新变化

### 嵌入式用户
1. **[用户指南 - 嵌入式系统](USER_GUIDE.md#嵌入式系统)** - 特殊安装方法
2. **[安装指南](INSTALLATION.md)** - 标准流程参考

---

## 🎯 按场景查找

| 场景 | 推荐文档 |
|------|---------|
| 安装 LinuxStudio | [安装指南](INSTALLATION.md) |
| 升级到新版本 | [用户指南 - 升级](USER_GUIDE.md#升级指南) |
| 遇到 "Unknown command: scene" 错误 | [用户指南 - 调试](USER_GUIDE.md#调试指南) |
| SSL 证书验证失败 | [用户指南 - 嵌入式系统](USER_GUIDE.md#ssl-证书问题) |
| 在 STM32MP1 上安装 | [用户指南 - 嵌入式系统](USER_GUIDE.md#嵌入式系统) |
| 从源码编译 | [开发者指南](DEVELOPER_GUIDE.md) |
| 了解编译原理 | [C++编译说明](COMPILATION.md) |
| 查看版本历史 | [更新日志](CHANGELOG.md) |

---

## 📊 文档统计

| 文档 | 主要内容 | 适用对象 |
|------|---------|---------|
| INSTALLATION.md | 5种安装方式，场景选择 | 所有用户 |
| USER_GUIDE.md | 升级、调试、嵌入式 | 所有用户 |
| DEVELOPER_GUIDE.md | 开发、编译、打包 | 开发者 |
| COMPILATION.md | C++编译机制 | 开发者 |
| CHANGELOG.md | 版本历史 | 所有用户 |

---

## 🔗 相关链接

- **GitHub 仓库**: https://github.com/happykl-cn/LinuxStudio
- **问题反馈**: https://github.com/happykl-cn/LinuxStudio/issues
- **发布页面**: https://github.com/happykl-cn/LinuxStudio/releases
- **主 README**: [../README.md](../README.md)

---

## 💡 提示

- 大多数问题都可以在 **[用户指南](USER_GUIDE.md)** 中找到解决方案
- 嵌入式设备用户请特别关注 **[用户指南 - 嵌入式系统](USER_GUIDE.md#嵌入式系统)** 部分
- 开发者请从 **[开发者指南](DEVELOPER_GUIDE.md)** 开始

---

**版本**: v1.1.2  
**最后更新**: 2025-11-03  
**维护者**: Dino Studio
