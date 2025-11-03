# LinuxStudio 开发者完全指南

本文档涵盖从开发到发布的完整流程，以及软件卸载的详细步骤。

## 📋 目录

- [快速开始](#快速开始)
- [开发环境搭建](#开发环境搭建)
- [添加新功能](#添加新功能)
- [版本发布完整流程](#版本发布完整流程)
- [打包配置](#打包配置)
- [软件卸载指南](#软件卸载指南)
- [常见问题](#常见问题)

---

## 🚀 快速开始

### 克隆仓库

```bash
git clone https://github.com/happykl-cn/LinuxStudio.git
cd LinuxStudio
```

### 一键编译

```bash
./build.sh
# 生成的二进制在: build/bin/xkl
```

### 本地测试

```bash
./build/bin/xkl --version
./build/bin/xkl status
./build/bin/xkl scene list
```

---

## 🛠️ 开发环境搭建

### 系统要求

**推荐平台**: Linux（Ubuntu 20.04+ 或 Debian 11+）

**Windows 用户**: 
- ✅ 推荐使用 **WSL2**
- ⚠️ 或使用 **Docker**
- ❌ 原生 Windows 支持有限

### 安装依赖

#### Ubuntu/Debian

```bash
# 基础工具
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    cmake \
    git \
    g++ \
    make

# 可选：交叉编译工具链（为 ARM 设备编译）
sudo apt-get install -y \
    gcc-arm-linux-gnueabihf \
    g++-arm-linux-gnueabihf
```

#### CentOS/RHEL

```bash
sudo yum groupinstall "Development Tools"
sudo yum install cmake git gcc-c++
```

### 项目结构

```
LinuxStudio/
├── CMakeLists.txt              # ⭐ CMake 主配置文件
├── build.sh                    # 快速编译脚本
├── heaven.sh                   # 安装脚本（英文）
├── heaven-cn.sh                # ⭐ 安装脚本（中文）
│
├── include/linuxstudio/        # C++ 头文件
│   ├── core.hpp                # 核心引擎
│   ├── managers.hpp            # 管理器
│   ├── logger.hpp              # 日志系统
│   └── i18n.hpp                # 国际化
│
├── src/                        # C++ 源代码
│   ├── cli/
│   │   ├── main.cpp            # ⭐ CLI 主程序入口
│   │   ├── commands.cpp        # 命令实现
│   │   └── cli_handler.cpp     # 命令处理器
│   ├── core/
│   │   ├── engine.cpp          # ⭐ 核心引擎实现
│   │   ├── system_detector.cpp # 系统检测
│   │   └── config.cpp          # 配置管理
│   ├── managers/
│   │   ├── component_manager.cpp  # ⭐ 组件管理器
│   │   └── plugin_manager.cpp     # ⭐ 插件管理器
│   └── utils/
│       ├── logger.cpp          # 日志实现
│       └── file_utils.cpp      # 文件工具
│
├── packaging/                  # ⭐ 打包配置
│   ├── debian/
│   │   ├── control             # ⭐ DEB 包信息
│   │   ├── changelog           # ⭐ 版本更新日志
│   │   ├── postinst            # 安装后脚本
│   │   ├── prerm               # 卸载前脚本
│   │   └── postrm              # 卸载后脚本
│   ├── rpm/
│   │   └── linuxstudio.spec    # RPM 包配置
│   └── setup.sh                # 仓库配置脚本
│
├── .github/workflows/          # ⭐ CI/CD 配置
│   └── release.yml             # GitHub Actions 发布流程
│
└── docs/                       # 文档
    ├── INSTALLATION.md
    ├── USER_GUIDE.md
    ├── DEVELOPER_GUIDE.md      # 本文件
    └── CHANGELOG.md
```

标注 ⭐ 的文件是发布新版本时需要修改的。

---

## ➕ 添加新功能

### 示例 1: 添加新的 CLI 命令

假设我们要添加一个 `xkl config` 命令来管理配置。

#### 步骤 1: 在 main.cpp 中添加命令处理

编辑 `src/cli/main.cpp`:

```cpp
// 1. 添加前向声明
void cmdConfig();
void cmdConfigGet(const std::string& key);
void cmdConfigSet(const std::string& key, const std::string& value);

int main(int argc, char* argv[]) {
    // ... 现有代码 ...
    
    // 2. 添加命令分支
    else if (command == "config") {
        if (argc < 3) {
            std::cerr << T("Error") << ": " << T("Config subcommand required") << "\n";
            return 1;
        }
        
        std::string subcommand = argv[2];
        if (subcommand == "get") {
            if (argc < 4) {
                std::cerr << T("Error") << ": " << T("Config key required") << "\n";
                return 1;
            }
            cmdConfigGet(argv[3]);
        }
        else if (subcommand == "set") {
            if (argc < 5) {
                std::cerr << T("Error") << ": " << T("Config key and value required") << "\n";
                return 1;
            }
            cmdConfigSet(argv[3], argv[4]);
        }
        else {
            std::cerr << T("Error") << ": " << T("Unknown config subcommand") << "\n";
            return 1;
        }
    }
    
    // ... 现有代码 ...
}

// 3. 实现命令函数
void cmdConfig() {
    auto& engine = CoreEngine::getInstance();
    auto& logger = engine.getLogger();
    
    logger.info("Configuration Management");
    std::cout << "Usage:\n";
    std::cout << "  xkl config get <key>\n";
    std::cout << "  xkl config set <key> <value>\n";
}

void cmdConfigGet(const std::string& key) {
    auto& engine = CoreEngine::getInstance();
    auto& logger = engine.getLogger();
    
    // 读取配置文件
    std::ifstream configFile("/etc/linuxstudio/config.yaml");
    std::string line;
    while (std::getline(configFile, line)) {
        if (line.find(key + ":") == 0) {
            std::cout << line << "\n";
            return;
        }
    }
    
    logger.error("Key not found: " + key);
}

void cmdConfigSet(const std::string& key, const std::string& value) {
    auto& engine = CoreEngine::getInstance();
    auto& logger = engine.getLogger();
    
    logger.info("Setting " + key + " = " + value);
    
    // 这里添加实际的配置修改逻辑
    // ...
    
    logger.success("Configuration updated successfully");
}
```

#### 步骤 2: 添加国际化支持

编辑 `include/linuxstudio/i18n.hpp`，添加翻译：

```cpp
// 在 loadTranslations() 函数中添加
enTranslations_ = {
    // ... 现有翻译 ...
    {"Config subcommand required", "Config subcommand required"},
    {"Config key required", "Config key required"},
    {"Unknown config subcommand", "Unknown config subcommand"},
};

zhTranslations_ = {
    // ... 现有翻译 ...
    {"Config subcommand required", "需要配置子命令"},
    {"Config key required", "需要配置键"},
    {"Unknown config subcommand", "未知的配置子命令"},
};
```

#### 步骤 3: 更新帮助信息

在 `main.cpp` 的 `showHelp()` 函数中添加：

```cpp
void showHelp() {
    // ... 现有代码 ...
    
    if (i18n.isChinese()) {
        std::cout << "\n配置管理:\n";
        std::cout << "  config get <键>              获取配置值\n";
        std::cout << "  config set <键> <值>         设置配置值\n";
    } else {
        std::cout << "\nConfiguration:\n";
        std::cout << "  config get <key>             Get configuration value\n";
        std::cout << "  config set <key> <value>     Set configuration value\n";
    }
    
    // ... 现有代码 ...
}
```

#### 步骤 4: 编译测试

```bash
# 重新编译
./build.sh

# 测试新命令
./build/bin/xkl config get version
./build/bin/xkl config set log_level debug
```

### 示例 2: 实现组件自动安装功能

这是 v1.1.3 的核心功能。

#### 步骤 1: 在 ComponentManager 中添加安装方法

编辑 `src/managers/component_manager.cpp`:

```cpp
bool ComponentManager::install(const std::string& name) {
    logger_.info("Installing component: " + name);
    
    // 1. 检测系统类型
    std::string osType = detectOSType();
    
    // 2. 根据组件名称获取包名
    std::string packageName = getPackageName(name, osType);
    
    // 3. 调用系统包管理器安装
    std::string installCmd;
    if (osType == "debian" || osType == "ubuntu") {
        installCmd = "apt-get install -y " + packageName;
    } else if (osType == "centos" || osType == "rhel") {
        installCmd = "yum install -y " + packageName;
    } else if (osType == "fedora") {
        installCmd = "dnf install -y " + packageName;
    } else {
        logger_.error("Unsupported OS type: " + osType);
        return false;
    }
    
    // 4. 执行安装
    logger_.info("Executing: " + installCmd);
    int result = system(installCmd.c_str());
    
    if (result == 0) {
        logger_.success("Component installed successfully: " + name);
        
        // 5. 记录到已安装列表
        recordInstalled(name);
        return true;
    } else {
        logger_.error("Failed to install component: " + name);
        return false;
    }
}

std::string ComponentManager::getPackageName(const std::string& component, const std::string& os) {
    // 组件到包名的映射
    static std::map<std::string, std::map<std::string, std::string>> packageMap = {
        {"gcc-arm", {
            {"debian", "gcc-arm-linux-gnueabihf"},
            {"ubuntu", "gcc-arm-linux-gnueabihf"},
            {"centos", "gcc-arm-linux-gnu"},
            {"fedora", "gcc-arm-linux-gnu"}
        }},
        {"openocd", {
            {"debian", "openocd"},
            {"ubuntu", "openocd"},
            {"centos", "openocd"},
            {"fedora", "openocd"}
        }},
        {"gdb", {
            {"debian", "gdb-multiarch"},
            {"ubuntu", "gdb-multiarch"},
            {"centos", "gdb"},
            {"fedora", "gdb"}
        }},
        // ... 添加更多组件
    };
    
    if (packageMap.find(component) != packageMap.end()) {
        if (packageMap[component].find(os) != packageMap[component].end()) {
            return packageMap[component][os];
        }
    }
    
    // 默认返回组件名本身
    return component;
}
```

#### 步骤 2: 在 main.cpp 中添加命令

```cpp
else if (command == "component") {
    if (argc < 3) {
        std::cerr << T("Error") << ": " << T("Component subcommand required") << "\n";
        return 1;
    }
    
    std::string subcommand = argv[2];
    if (subcommand == "install") {
        if (argc < 4) {
            std::cerr << T("Error") << ": " << T("Component name required") << "\n";
            return 1;
        }
        cmdComponentInstall(argv[3]);
    }
    // ... 其他子命令
}

void cmdComponentInstall(const std::string& name) {
    auto& engine = CoreEngine::getInstance();
    auto& compMgr = engine.getComponentManager();
    auto& logger = engine.getLogger();
    
    logger.info("Installing component: " + name);
    
    if (compMgr.install(name)) {
        logger.success("Component installed successfully!");
    } else {
        logger.error("Failed to install component");
    }
}
```

---

## 🔄 版本发布完整流程

### 发布新版本的完整步骤

假设我们要发布 **v1.1.3** 版本。

#### 第 1 步: 更新版本号

需要修改以下 **5 个文件**：

##### 1.1 CMakeLists.txt

```cmake
# 第 3-7 行
project(LinuxStudio 
    VERSION 1.1.3          # ← 修改这里
    DESCRIPTION "High-Performance Linux Environment Manager"
    LANGUAGES CXX
)

# 第 206 行
version: 1.1.3             # ← 修改这里
```

##### 1.2 heaven-cn.sh

```bash
# 第 557 行
VERSION="1.1.3"            # ← 修改这里
```

##### 1.3 heaven.sh

```bash
# 第 523 行左右
VERSION="1.1.3"            # ← 修改这里
```

##### 1.4 packaging/debian/changelog

在文件**开头**添加新版本记录：

```
linuxstudio (1.1.3-1) unstable; urgency=medium

  * Component auto-install feature
  * Scene one-click deployment
  * Component listing implementation
  * New features:
    - xkl component install <name>
    - xkl scene apply <name> --auto-install
    - xkl component list (now working)

 -- Dino Studio <support@linuxstudio.org>  Wed, 15 Nov 2025 10:00:00 +0800

linuxstudio (1.1.2-1) unstable; urgency=medium
  ...（之前的版本保留）
```

##### 1.5 README.md

```markdown
# 第 5 行
![LinuxStudio Logo](https://img.shields.io/badge/LinuxStudio-v1.1.3-blue?style=for-the-badge&logo=linux)

# 安装命令中的版本号（第 50 行左右）
wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.3_debian-11_amd64.deb
```

#### 第 2 步: 更新 CHANGELOG.md

编辑 `docs/CHANGELOG.md`，在顶部添加新版本：

```markdown
## 📌 当前版本：v1.1.3 (2025-11-15)

### ✅ 新增功能

#### 组件自动安装 ⭐
- ✅ `xkl component install <name>` - 自动安装组件
- ✅ `xkl component list` - 列出已安装组件
- ✅ `xkl component uninstall <name>` - 卸载组件

#### 场景一键部署
- ✅ `xkl scene apply <name> --auto-install` - 自动安装场景所有组件
- ✅ 依赖关系自动处理
- ✅ 安装进度显示

### 🔧 改进
- ✅ 优化安装速度
- ✅ 更好的错误提示
- ✅ 支持离线安装包

### 📋 可用命令清单

\`\`\`bash
# ✅ 完全可用
xkl component install gcc-arm    # 自动安装 ARM GCC
xkl component install openocd    # 自动安装 OpenOCD
xkl component list               # 列出已安装组件
xkl scene apply embedded --auto-install  # 一键安装所有组件
\`\`\`

---

## 📅 版本历史

### v1.1.2 (2025-11-03)
...（之前的内容保留）
```

#### 第 3 步: 本地编译测试

```bash
# 清理旧构建
rm -rf build

# 重新编译
./build.sh

# 测试新功能
./build/bin/xkl --version
# 应该显示: LinuxStudio Framework v1.1.3 (C++ Core)

./build/bin/xkl component install gcc-arm
./build/bin/xkl component list
./build/bin/xkl scene apply embedded --auto-install
```

#### 第 4 步: 本地打包测试

```bash
cd build

# 生成 DEB 包
cpack -G DEB

# 查看生成的包
ls -lh *.deb
# 应该看到: linuxstudio_1.1.3_debian-11_amd64.deb

# 测试安装（在测试虚拟机中）
sudo dpkg -i linuxstudio_1.1.3_debian-11_amd64.deb
xkl --version

# 测试卸载
sudo dpkg -r linuxstudio
```

#### 第 5 步: 提交代码

```bash
# 查看修改的文件
git status

# 添加所有更改
git add -A

# 提交（使用语义化提交信息）
git commit -m "Release v1.1.3: Component auto-install feature

New Features:
- Component auto-install: xkl component install <name>
- Component listing: xkl component list
- Scene one-click deployment: xkl scene apply <name> --auto-install
- Dependency resolution
- Progress display

Changes:
- Updated version to 1.1.3 in all files
- Updated CHANGELOG.md with v1.1.3 features
- Implemented component manager install/uninstall methods
- Added auto-install flag to scene apply command

Breaking Changes:
- None (backward compatible)

Fixes:
- Improved error handling in component installation
- Better progress feedback
"

# 推送到 GitHub
git push origin main
```

#### 第 6 步: 创建 Release 标签

```bash
# 创建带注释的标签
git tag -a v1.1.3 -m "LinuxStudio v1.1.3

🎯 Major Features:
- ⭐ Component auto-install
- ⭐ Scene one-click deployment  
- ⭐ Component listing

🔧 Improvements:
- Better error handling
- Progress display
- Offline package support

📦 Packages:
- DEB: Debian 11, Ubuntu 20.04/22.04
- RPM: CentOS 7/8, Rocky Linux 8/9
- Multi-arch: x86_64, ARM64, ARM32

📚 Documentation:
- Updated CHANGELOG.md
- Added component install examples
- New troubleshooting guides

Full changelog: https://github.com/happykl-cn/LinuxStudio/blob/main/docs/CHANGELOG.md"

# 推送标签到 GitHub
git push origin v1.1.3
```

#### 第 7 步: 等待 GitHub Actions 自动构建

推送标签后，GitHub Actions 会自动：

1. **触发构建** - 检测到 `v1.1.3` 标签
2. **多平台编译** - 在多个 Docker 容器中并行编译
   - Ubuntu 20.04/22.04 (amd64, arm64, armhf)
   - Debian 11/12 (amd64, arm64, armhf)
   - CentOS 7/8, Rocky Linux 8/9
3. **打包** - 生成 DEB 和 RPM 包
4. **测试** - 自动化测试安装、命令执行
5. **创建 Release** - 在 GitHub 上创建发布页面
6. **上传包** - 上传所有编译好的包

查看构建状态：
```
https://github.com/happykl-cn/LinuxStudio/actions
```

通常需要 **5-10 分钟**完成。

#### 第 8 步: 验证 Release

1. 访问 Release 页面：
   ```
   https://github.com/happykl-cn/LinuxStudio/releases/tag/v1.1.3
   ```

2. 检查是否包含所有包：
   - `linuxstudio_1.1.3_ubuntu-20.04_amd64.deb`
   - `linuxstudio_1.1.3_ubuntu-22.04_amd64.deb`
   - `linuxstudio_1.1.3_debian-11_amd64.deb`
   - `linuxstudio_1.1.3_debian-11_arm64.deb`
   - `linuxstudio_1.1.3_debian-11_armhf.deb`
   - `linuxstudio-1.1.3-1.rockylinux-8.x86_64.rpm`
   - `linuxstudio-1.1.3-1.rockylinux-9.x86_64.rpm`

3. 下载并测试安装：
   ```bash
   wget https://github.com/happykl-cn/LinuxStudio/releases/download/v1.1.3/linuxstudio_1.1.3_debian-11_amd64.deb
   sudo dpkg -i linuxstudio_1.1.3_debian-11_amd64.deb
   xkl --version
   ```

#### 第 9 步: 更新文档网站（可选）

如果有文档网站，更新：
- 最新版本号
- 下载链接
- 新功能说明

#### 第 10 步: 发布公告

在以下渠道发布公告：
- GitHub Discussions
- 项目 README.md
- 社区论坛
- 社交媒体

---

## 📦 打包配置详解

### DEB 包配置

#### control 文件

位置：`packaging/debian/control`

```
Source: linuxstudio
Section: devel
Priority: optional
Maintainer: Dino Studio <support@linuxstudio.org>
Build-Depends: debhelper (>= 9), cmake (>= 3.10), g++ (>= 7.0), libstdc++6
Standards-Version: 4.5.0
Homepage: https://linuxstudio.org

Package: linuxstudio
Architecture: any
Depends: ${shlibs:Depends}, ${misc:Depends}
Description: High-Performance Linux Environment Manager
 LinuxStudio is a framework for managing development environments.
 .
 Features:
  - Scene-driven component installation
  - Plugin management system
  - Multi-server deployment support
```

**重要字段**：
- `Depends`: 依赖包（自动从二进制文件检测）
- `Architecture`: `any` 表示支持所有架构
- `Description`: 包描述（第一行是简短描述）

#### changelog 文件

位置：`packaging/debian/changelog`

**格式非常严格**：

```
linuxstudio (1.1.3-1) unstable; urgency=medium

  * 功能描述
  * 每行以 2 个空格开头

 -- Maintainer Name <email@domain.com>  Day, DD Mon YYYY HH:MM:SS +TIMEZONE
```

**注意**：
- 版本格式：`(版本号-修订号)`
- 日期格式必须精确（使用 `date -R` 获取）
- 维护者行前面是 **1 个空格 + 2 个短横线 + 1 个空格**

#### postinst 脚本（安装后执行）

位置：`packaging/debian/postinst`

```bash
#!/bin/sh
set -e

case "$1" in
    configure)
        # 创建符号链接
        ln -sf /usr/bin/xkl /usr/bin/linuxstudio || true
        
        # 创建目录
        mkdir -p /opt/linuxstudio/logs || true
        mkdir -p /opt/linuxstudio/plugins || true
        
        # 设置权限
        chmod +x /usr/bin/xkl || true
        
        echo "LinuxStudio installed successfully!"
        ;;
esac

exit 0
```

#### prerm 脚本（卸载前执行）

位置：`packaging/debian/prerm`

```bash
#!/bin/sh
set -e

case "$1" in
    remove|upgrade|deconfigure)
        # 停止服务（如果有）
        # systemctl stop linuxstudio || true
        
        echo "Preparing to remove LinuxStudio..."
        ;;
esac

exit 0
```

#### postrm 脚本（卸载后执行）

位置：`packaging/debian/postrm`

```bash
#!/bin/sh
set -e

case "$1" in
    purge)
        # 完全卸载时删除配置和数据
        rm -rf /opt/linuxstudio || true
        rm -rf /etc/linuxstudio || true
        rm -f /usr/bin/linuxstudio || true
        
        echo "LinuxStudio has been completely removed."
        ;;
    remove)
        # 普通卸载时保留配置
        echo "LinuxStudio removed (configuration preserved)."
        ;;
esac

exit 0
```

### RPM 包配置

位置：`packaging/rpm/linuxstudio.spec`

```spec
Name:           linuxstudio
Version:        1.1.3
Release:        1%{?dist}
Summary:        High-Performance Linux Environment Manager

License:        MIT
URL:            https://linuxstudio.org
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  gcc-c++
BuildRequires:  cmake >= 3.10
Requires:       glibc, libstdc++

%description
LinuxStudio is a framework for managing development environments,
toolchains, and multi-server deployments.

%prep
%setup -q

%build
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make %{?_smp_mflags}

%install
cd build
%make_install

%files
%license LICENSE
%doc README.md
/usr/bin/xkl
/usr/bin/linuxstudio
/opt/linuxstudio/
/etc/linuxstudio/

%post
ln -sf /usr/bin/xkl /usr/bin/linuxstudio || true
chmod +x /usr/bin/xkl || true
echo "LinuxStudio installed successfully!"

%postun
if [ $1 -eq 0 ]; then
    # 完全卸载
    rm -rf /opt/linuxstudio || true
    rm -rf /etc/linuxstudio || true
fi

%changelog
* Wed Nov 15 2025 Dino Studio <support@linuxstudio.org> - 1.1.3-1
- Component auto-install feature
- Scene one-click deployment
```

### CMake 打包配置

在 `CMakeLists.txt` 中（第 218-278 行）：

```cmake
# ========== CPack 打包配置 ==========
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")  # 自动从 project() 获取
set(CPACK_PACKAGE_VENDOR "Dino Studio")
set(CPACK_PACKAGE_CONTACT "support@linuxstudio.org")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "High-Performance Linux Environment Manager")

# 架构自动检测
if(TARGET_ARCH_ARM64)
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "arm64")
    set(CPACK_RPM_PACKAGE_ARCHITECTURE "aarch64")
elseif(TARGET_ARCH_ARM32)
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "armhf")
    set(CPACK_RPM_PACKAGE_ARCHITECTURE "armv7hl")
elseif(TARGET_ARCH_X86_64)
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "amd64")
    set(CPACK_RPM_PACKAGE_ARCHITECTURE "x86_64")
endif()

# 最小化依赖
set(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6, libstdc++6")
set(CPACK_RPM_PACKAGE_REQUIRES "glibc, libstdc++")

# DEB 包控制脚本
set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA 
    "${CMAKE_SOURCE_DIR}/packaging/debian/postinst"
    "${CMAKE_SOURCE_DIR}/packaging/debian/prerm"
    "${CMAKE_SOURCE_DIR}/packaging/debian/postrm"
)

# 包含 CPack
include(CPack)
```

### 修改包的文件列表

如果要添加新文件到包中，在 `CMakeLists.txt` 中：

```cmake
# 安装可执行文件
install(TARGETS xkl
    RUNTIME DESTINATION bin
)

# 安装头文件
install(DIRECTORY ${CMAKE_SOURCE_DIR}/include/
    DESTINATION include/linuxstudio
)

# 安装配置文件
install(FILES config/default.yaml
    DESTINATION /etc/linuxstudio/
)

# 安装数据文件
install(DIRECTORY data/
    DESTINATION /opt/linuxstudio/data/
)

# 创建目录
install(DIRECTORY DESTINATION /opt/linuxstudio/plugins)
install(DIRECTORY DESTINATION /opt/linuxstudio/logs)
```

---

## 🗑️ 软件卸载指南

### 用户如何完全卸载 LinuxStudio

#### 方法 1: 使用包管理器卸载

##### Ubuntu/Debian

```bash
# 卸载但保留配置
sudo apt-get remove linuxstudio

# 完全卸载（包括配置）
sudo apt-get purge linuxstudio

# 清理依赖
sudo apt-get autoremove
```

##### CentOS/RHEL/Rocky Linux

```bash
# 卸载
sudo yum remove linuxstudio
# 或
sudo dnf remove linuxstudio

# 手动删除配置（yum 不会自动删除）
sudo rm -rf /etc/linuxstudio
sudo rm -rf /opt/linuxstudio
```

#### 方法 2: 手动完全清理

如果包管理器卸载不完整，手动清理：

```bash
#!/bin/bash
# 完全卸载 LinuxStudio

echo "=== 开始卸载 LinuxStudio ==="

# 1. 删除二进制文件
echo "[1/6] 删除可执行文件..."
sudo rm -f /usr/bin/xkl
sudo rm -f /usr/bin/linuxstudio

# 2. 删除安装目录
echo "[2/6] 删除安装目录..."
sudo rm -rf /opt/linuxstudio

# 3. 删除配置目录
echo "[3/6] 删除配置目录..."
sudo rm -rf /etc/linuxstudio

# 4. 删除日志
echo "[4/6] 删除日志文件..."
# 日志已在 /opt/linuxstudio/logs，上面已删除

# 5. 删除包管理器记录（如果有）
echo "[5/6] 清理包管理器..."
if command -v dpkg >/dev/null 2>&1; then
    sudo dpkg --purge linuxstudio 2>/dev/null || true
elif command -v rpm >/dev/null 2>&1; then
    sudo rpm -e linuxstudio 2>/dev/null || true
fi

# 6. 验证卸载
echo "[6/6] 验证卸载..."
if command -v xkl >/dev/null 2>&1; then
    echo "❌ 卸载失败：xkl 命令仍然存在"
    exit 1
fi

if [ -d /opt/linuxstudio ]; then
    echo "❌ 卸载失败：安装目录仍然存在"
    exit 1
fi

echo "✅ LinuxStudio 已完全卸载！"
```

保存为 `uninstall_linuxstudio.sh`，运行：

```bash
chmod +x uninstall_linuxstudio.sh
sudo ./uninstall_linuxstudio.sh
```

#### 方法 3: 卸载仓库配置

如果之前配置了官方仓库，也需要清理：

##### Ubuntu/Debian

```bash
# 1. 删除仓库配置文件
sudo rm -f /etc/apt/sources.list.d/linuxstudio.list

# 2. 删除 GPG 密钥
sudo rm -f /etc/apt/trusted.gpg.d/linuxstudio.gpg

# 3. 更新包列表
sudo apt-get update

# 4. 验证
grep -r "linuxstudio" /etc/apt/
# 应该没有输出
```

##### CentOS/RHEL/Rocky Linux

```bash
# 1. 删除仓库配置
sudo rm -f /etc/yum.repos.d/linuxstudio.repo

# 2. 删除 GPG 密钥
sudo rpm -e gpg-pubkey-XXXXXXXX  # 替换为实际的 key ID

# 3. 清理缓存
sudo yum clean all
# 或
sudo dnf clean all

# 4. 验证
ls -la /etc/yum.repos.d/ | grep linuxstudio
# 应该没有输出
```

### 完整卸载验证清单

运行以下命令确认完全卸载：

```bash
# 1. 检查命令是否存在
which xkl
which linuxstudio
# 应该返回: command not found

# 2. 检查安装目录
ls /opt/ | grep linuxstudio
# 应该没有输出

# 3. 检查配置目录
ls /etc/ | grep linuxstudio
# 应该没有输出

# 4. 检查包管理器
dpkg -l | grep linuxstudio  # Debian/Ubuntu
rpm -qa | grep linuxstudio  # CentOS/RHEL
# 应该没有输出

# 5. 检查仓库配置
ls /etc/apt/sources.list.d/ | grep linuxstudio  # Debian/Ubuntu
ls /etc/yum.repos.d/ | grep linuxstudio          # CentOS/RHEL
# 应该没有输出

# 6. 检查环境变量（如果设置过）
env | grep LINUXSTUDIO
# 应该没有输出
```

如果所有检查都通过，LinuxStudio 已完全卸载。

---

## ❓ 常见问题

### Q1: 如何快速测试新功能？

```bash
# 1. 编译
./build.sh

# 2. 不安装，直接运行
./build/bin/xkl --version
./build/bin/xkl status

# 3. 设置环境变量（可选）
export PATH=$PWD/build/bin:$PATH
xkl --version
```

### Q2: 如何调试编译错误？

```bash
# 使用 Debug 模式
mkdir build-debug && cd build-debug
cmake .. -DCMAKE_BUILD_TYPE=Debug
make VERBOSE=1

# 使用 GDB 调试
gdb ./bin/xkl
(gdb) run status
(gdb) bt
```

### Q3: 如何为特定发行版编译？

```bash
# 使用 Docker 编译 Ubuntu 20.04 版本
docker run -it --rm -v $PWD:/work ubuntu:20.04 bash
cd /work
apt-get update
apt-get install -y build-essential cmake g++
./build.sh
```

### Q4: 版本号规则是什么？

遵循 [语义化版本](https://semver.org/lang/zh-CN/)：

```
主版本号.次版本号.修订号 (MAJOR.MINOR.PATCH)

例如: 1.1.3
  1 - 主版本号（重大架构变更）
  1 - 次版本号（新功能）
  3 - 修订号（Bug 修复）
```

**增加规则**：
- 🚨 **主版本号** - 不兼容的 API 变更
- ✨ **次版本号** - 向后兼容的新功能
- 🐛 **修订号** - 向后兼容的 Bug 修复

### Q5: 如何回滚到之前的版本？

```bash
# 查看所有标签
git tag -l

# 切换到特定版本
git checkout v1.1.2

# 重新编译
./build.sh

# 或者恢复整个仓库
git reset --hard v1.1.2
```

### Q6: GitHub Actions 构建失败怎么办？

1. 查看构建日志：
   ```
   https://github.com/happykl-cn/LinuxStudio/actions
   ```

2. 常见失败原因：
   - 编译错误（语法错误）
   - 测试失败
   - 版本号不一致
   - 依赖包缺失

3. 修复后重新推送标签：
   ```bash
   # 删除本地标签
   git tag -d v1.1.3
   
   # 删除远程标签
   git push origin :refs/tags/v1.1.3
   
   # 修复问题后重新创建
   git tag -a v1.1.3 -m "..."
   git push origin v1.1.3
   ```

### Q7: 如何添加新的依赖库？

在 `CMakeLists.txt` 中：

```cmake
# 查找依赖
find_package(CURL REQUIRED)

# 链接到目标
target_link_libraries(xkl 
    linuxstudio_core
    CURL::libcurl
)

# 更新 packaging/debian/control
Build-Depends: ..., libcurl4-openssl-dev
Depends: ..., libcurl4
```

### Q8: 如何测试多架构编译？

使用 Docker 和 QEMU：

```bash
# 安装 QEMU
sudo apt-get install qemu-user-static

# ARM32 交叉编译
docker run --rm -v $PWD:/work \
    arm32v7/ubuntu:20.04 \
    bash -c "cd /work && apt-get update && apt-get install -y build-essential cmake && ./build.sh"

# ARM64 编译
docker run --rm -v $PWD:/work \
    arm64v8/ubuntu:20.04 \
    bash -c "cd /work && apt-get update && apt-get install -y build-essential cmake && ./build.sh"
```

---

## 📚 参考资源

### 官方文档
- [CMake 文档](https://cmake.org/documentation/)
- [Debian 打包指南](https://www.debian.org/doc/manuals/maint-guide/)
- [RPM 打包指南](https://rpm-packaging-guide.github.io/)
- [GitHub Actions 文档](https://docs.github.com/en/actions)

### 工具
- [语义化版本](https://semver.org/lang/zh-CN/)
- [Conventional Commits](https://www.conventionalcommits.org/zh-hans/)
- [Keep a Changelog](https://keepachangelog.com/zh-CN/)

### 社区
- **GitHub Discussions**: https://github.com/happykl-cn/LinuxStudio/discussions
- **Issue Tracker**: https://github.com/happykl-cn/LinuxStudio/issues

---

**版本**: v1.1.2  
**最后更新**: 2025-11-03  
**维护者**: Dino Studio

---

## 🎓 总结

### 开发新功能的核心步骤

1. ✅ 在 `src/cli/main.cpp` 中添加命令处理
2. ✅ 实现功能逻辑（在相应的 manager 或 core 文件中）
3. ✅ 添加国际化支持（`i18n.hpp`）
4. ✅ 更新帮助信息
5. ✅ 本地编译测试

### 发布新版本的核心步骤

1. ✅ 更新 5 个文件的版本号（CMakeLists.txt, heaven-cn.sh, heaven.sh, debian/changelog, README.md）
2. ✅ 更新 CHANGELOG.md
3. ✅ 本地测试
4. ✅ 提交代码
5. ✅ 创建并推送标签
6. ✅ 等待 GitHub Actions 自动构建
7. ✅ 验证 Release

### 完全卸载的核心步骤

1. ✅ 使用包管理器卸载：`apt-get purge` 或 `yum remove`
2. ✅ 手动清理：删除 `/usr/bin/xkl`, `/opt/linuxstudio`, `/etc/linuxstudio`
3. ✅ 清理仓库配置：删除 `/etc/apt/sources.list.d/` 或 `/etc/yum.repos.d/` 中的配置
4. ✅ 验证：确认所有文件和配置都已删除

遵循这个指南，你就可以高效地开发、发布和维护 LinuxStudio 了！🚀
