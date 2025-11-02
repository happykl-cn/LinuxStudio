#!/bin/bash
#==============================================================================
# LinuxStudio 一键安装脚本
# 版本: 2.1.0
# 描述: 智能安装脚本，支持嵌入式系统检测和优化
# 作者: Dino Studio
# 网站: https://linuxstudio.org
#==============================================================================

set -e

# 解析命令行参数
FORCE_EMBEDDED=false
FORCE_STANDARD=false
NON_INTERACTIVE=false
SKIP_DETECTION=false

# 检测是否有可用的 TTY（如果通过管道运行，自动进入非交互模式）
if [ ! -t 0 ] && [ ! -t 1 ]; then
    NON_INTERACTIVE=true
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        --embedded|--嵌入式)
            FORCE_EMBEDDED=true
            shift
            ;;
        --standard|--标准)
            FORCE_STANDARD=true
            shift
            ;;
        -y|--yes|--non-interactive|--非交互)
            NON_INTERACTIVE=true
            shift
            ;;
        --skip-detection|--跳过检测)
            SKIP_DETECTION=true
            shift
            ;;
        --help|-h|--帮助)
            echo "LinuxStudio 一键安装脚本 v2.1.0"
            echo ""
            echo "用法: $0 [选项]"
            echo ""
            echo "选项:"
            echo "  --embedded, --嵌入式     强制使用嵌入式优化安装"
            echo "  --standard, --标准       强制使用标准安装"
            echo "  -y, --yes, --非交互      非交互模式（使用默认选项）"
            echo "  --skip-detection, --跳过检测  跳过嵌入式系统检测"
            echo "  -h, --help, --帮助       显示此帮助信息"
            echo ""
            echo "示例:"
            echo "  $0                      # 交互式安装"
            echo "  $0 --嵌入式 -y          # 非交互式嵌入式安装"
            echo "  $0 --标准               # 强制标准安装"
            echo ""
            exit 0
            ;;
        *)
            echo "未知选项: $1"
            echo "使用 --帮助 查看用法信息"
            exit 1
            ;;
    esac
done

# 颜色代码
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${BLUE}[信息]${NC} $1"; }
success() { echo -e "${GREEN}[成功]${NC} $1"; }
warning() { echo -e "${YELLOW}[警告]${NC} $1"; }
error() { echo -e "${RED}[错误]${NC} $1"; }

# 安装后配置函数（必须在使用前定义）
post_install_setup() {
    echo ""
    success "✅ LinuxStudio 核心已安装！"
    echo ""
    
    if [ "$NON_INTERACTIVE" = true ]; then
        info "非交互模式，跳过场景配置"
        info "稍后可以运行: xkl scene apply <场景名>"
        return 0
    fi
    
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║         LinuxStudio 场景与组件配置向导              ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    echo ""
    echo "LinuxStudio 已成功安装！现在您可以选择开发场景并安装相关组件。"
    echo ""
    
    if [ -t 0 ]; then
        read -r -p "是否现在配置开发场景？[Y/n]: " SETUP_SCENES
    else
        read -r -p "是否现在配置开发场景？[Y/n]: " SETUP_SCENES < /dev/tty || SETUP_SCENES=""
    fi
    
    SETUP_SCENES=${SETUP_SCENES:-Y}
    
    if [[ ! "$SETUP_SCENES" =~ ^[Yy]$ ]]; then
        echo ""
        info "跳过场景配置。稍后您可以运行以下命令："
        echo ""
        info "   xkl scene list          # 查看可用场景"
        info "   xkl scene apply web     # 应用 Web 开发场景"
        info "   xkl plugin install ros2 # 安装特定插件"
        echo ""
        return 0
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "           请选择您的开发场景"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    echo "  1) Web 开发       - Nginx, PHP, Java, MySQL, Redis, Node.js"
    echo "  2) 嵌入式开发     - ARM/RISC-V GCC, OpenOCD, GDB"
    echo "  3) 机器人开发     - ROS2, MoveIt2, Gazebo, OpenCV"
    echo "  4) AI/ML 开发     - Python, Jupyter, TensorFlow, PyTorch"
    echo "  5) 游戏开发       - SDL2, OpenGL, Vulkan, Godot"
    echo "  6) DevOps        - Docker, Kubernetes, Jenkins, Prometheus"
    echo "  7) 网络安全       - Nmap, Wireshark, Metasploit"
    echo "  8) 区块链开发     - Hardhat, Solidity, Web3.js"
    echo "  9) 物联网开发     - Mosquitto, Node-RED, InfluxDB"
    echo "  0) 跳过场景配置"
    echo ""
    
    if [ -t 0 ]; then
        read -r -p "请选择场景 [1-9, 0=跳过]: " SCENE_CHOICE
    else
        read -r -p "请选择场景 [1-9, 0=跳过]: " SCENE_CHOICE < /dev/tty || SCENE_CHOICE=""
    fi
    
    SCENE_CHOICE=${SCENE_CHOICE:-0}
    
    case $SCENE_CHOICE in
        1)
            SCENE_NAME="web-development"
            SCENE_DISPLAY="Web 开发"
            ;;
        2)
            SCENE_NAME="embedded"
            SCENE_DISPLAY="嵌入式开发"
            ;;
        3)
            SCENE_NAME="robotics"
            SCENE_DISPLAY="机器人开发"
            ;;
        4)
            SCENE_NAME="ai-ml"
            SCENE_DISPLAY="AI/ML 开发"
            ;;
        5)
            SCENE_NAME="game-dev"
            SCENE_DISPLAY="游戏开发"
            ;;
        6)
            SCENE_NAME="devops"
            SCENE_DISPLAY="DevOps"
            ;;
        7)
            SCENE_NAME="security"
            SCENE_DISPLAY="网络安全"
            ;;
        8)
            SCENE_NAME="blockchain"
            SCENE_DISPLAY="区块链开发"
            ;;
        9)
            SCENE_NAME="iot"
            SCENE_DISPLAY="物联网开发"
            ;;
        0)
            echo ""
            info "跳过场景配置。稍后可运行: xkl scene apply <场景名>"
            echo ""
            return 0
            ;;
        *)
            warning "无效选择，跳过场景配置"
            echo ""
            return 0
            ;;
    esac
    
    echo ""
    info "正在应用场景: $SCENE_DISPLAY"
    echo ""
    
    # 应用场景（这将触发交互式组件选择）
    if xkl scene apply "$SCENE_NAME" 2>/dev/null; then
        echo ""
        success "🎉 场景配置完成！"
    else
        warning "场景应用失败，请手动运行: xkl scene apply $SCENE_NAME"
    fi
    
    echo ""
    info "🚀 快速开始:"
    info "   xkl status              # 检查系统状态"
    info "   xkl scene list          # 列出可用场景"
    info "   xkl plugin list         # 列出可用插件"
    info "   xkl component list      # 列出已安装组件"
    echo ""
}

# 横幅
cat <<'EOF'
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  _     _                  ____  _             _ _         ┃
┃ | |   (_)_ __  _   ___  _/ ___|| |_ _   _  __| (_) ___   ┃
┃ | |   | | '_ \| | | \ \/ \___ \| __| | | |/ _` | |/ _ \  ┃
┃ | |___| | | | | |_| |>  < ___) | |_| |_| | (_| | | (_) | ┃
┃ |_____|_|_| |_|\__,_/_/\_\____/ \__|\__,_|\__,_|_|\___/  ┃
┃                                                            ┃
┃              一键安装脚本 v2.1                            ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
EOF

echo ""
info "开始安装 LinuxStudio..."
echo ""

# 检查 root 权限
if [ "$EUID" -ne 0 ]; then 
    error "请以 root 权限运行（使用 sudo）"
    exit 1
fi

# 嵌入式场景检测
if [ "$SKIP_DETECTION" = false ]; then
    echo ""
    info "🔍 正在检测系统环境..."
fi

# 检测是否为嵌入式系统
EMBEDDED_SYSTEM=false
EMBEDDED_TYPE=""

# 如果强制指定模式，跳过检测
if [ "$FORCE_EMBEDDED" = true ]; then
    EMBEDDED_SYSTEM=true
    EMBEDDED_TYPE="强制嵌入式模式"
elif [ "$FORCE_STANDARD" = true ]; then
    EMBEDDED_SYSTEM=false
    EMBEDDED_TYPE="强制标准模式"
elif [ "$SKIP_DETECTION" = false ]; then
    # 检测常见嵌入式系统特征
    if [ -f /proc/cpuinfo ]; then
    CPU_INFO=$(cat /proc/cpuinfo)
    
    # STM32MP1 系列
    if echo "$CPU_INFO" | grep -qi "STM32MP1\|Cortex-A7.*STM"; then
        EMBEDDED_SYSTEM=true
        EMBEDDED_TYPE="STM32MP1"
    # Raspberry Pi
    elif echo "$CPU_INFO" | grep -qi "BCM283\|Raspberry Pi"; then
        EMBEDDED_SYSTEM=true
        EMBEDDED_TYPE="树莓派"
    # BeagleBone
    elif echo "$CPU_INFO" | grep -qi "AM335x\|BeagleBone"; then
        EMBEDDED_SYSTEM=true
        EMBEDDED_TYPE="BeagleBone"
    # 通用 ARM 嵌入式设备
    elif [ "$(uname -m)" = "armv7l" ] && [ "$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')" -lt 2097152 ]; then
        EMBEDDED_SYSTEM=true
        EMBEDDED_TYPE="ARM32 嵌入式设备"
    fi
    fi

    # 检测 BusyBox 环境
    if [ -L /bin/sh ] && readlink /bin/sh | grep -q busybox; then
        EMBEDDED_SYSTEM=true
        EMBEDDED_TYPE="${EMBEDDED_TYPE} (BusyBox)"
    fi
fi

# 显示检测结果并询问用户（除非是非交互模式）
if [ "$NON_INTERACTIVE" = false ] && [ "$EMBEDDED_SYSTEM" = true ]; then
    echo ""
    info "🎯 检测到嵌入式系统: $EMBEDDED_TYPE"
    info "📱 内存: $(free -h | grep Mem | awk '{print $2}')"
    info "🏗️  架构: $(uname -m)"
    echo ""
    echo "这似乎是一个嵌入式系统。您希望："
    echo "  1) 使用嵌入式优化安装（推荐）"
    echo "  2) 使用标准安装"
    echo "  3) 自动检测（让脚本决定）"
    echo ""
    if [ -t 0 ]; then
        read -r -p "请选择 [1-3]（默认: 1）: " INSTALL_MODE
    else
        # 通过管道运行，从 /dev/tty 读取
        read -r -p "请选择 [1-3]（默认: 1）: " INSTALL_MODE < /dev/tty || INSTALL_MODE=""
    fi
    INSTALL_MODE=${INSTALL_MODE:-1}
elif [ "$NON_INTERACTIVE" = false ]; then
    echo ""
    echo "这似乎是一个标准 Linux 系统。"
    echo "您是否仍要检查嵌入式系统兼容性？"
    echo "  1) 否，使用标准安装（推荐）"
    echo "  2) 是，使用嵌入式优化安装"
    echo "  3) 基于系统资源自动检测"
    echo ""
    if [ -t 0 ]; then
        read -r -p "请选择 [1-3]（默认: 1）: " INSTALL_MODE
    else
        # 通过管道运行，从 /dev/tty 读取
        read -r -p "请选择 [1-3]（默认: 1）: " INSTALL_MODE < /dev/tty || INSTALL_MODE=""
    fi
    INSTALL_MODE=${INSTALL_MODE:-1}
else
    # 非交互模式：自动选择
    if [ "$EMBEDDED_SYSTEM" = true ]; then
        INSTALL_MODE=1  # 嵌入式系统使用嵌入式安装
    else
        INSTALL_MODE=1  # 标准系统使用标准安装
    fi
fi

# 根据选择设置安装模式
case $INSTALL_MODE in
    1)
        if [ "$EMBEDDED_SYSTEM" = true ]; then
            INSTALLATION_MODE="embedded"
            info "✅ 使用嵌入式优化安装"
        else
            INSTALLATION_MODE="standard"
            info "✅ 使用标准安装"
        fi
        ;;
    2)
        if [ "$EMBEDDED_SYSTEM" = true ]; then
            INSTALLATION_MODE="standard"
            info "✅ 使用标准安装（按要求）"
        else
            INSTALLATION_MODE="embedded"
            info "✅ 使用嵌入式优化安装（按要求）"
        fi
        ;;
    3)
        # 自动检测模式
        TOTAL_MEM=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')
        if [ "$TOTAL_MEM" -lt 1048576 ] || [ "$(uname -m)" = "armv7l" ] || [ "$(uname -m)" = "armv6l" ]; then
            INSTALLATION_MODE="embedded"
            info "🤖 自动检测: 使用嵌入式优化安装"
        else
            INSTALLATION_MODE="standard"
            info "🤖 自动检测: 使用标准安装"
        fi
        ;;
    *)
        INSTALLATION_MODE="standard"
        warning "无效选择，使用标准安装"
        ;;
esac

echo ""

# 检测操作系统
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    error "无法检测操作系统"
    exit 1
fi

info "检测到操作系统: $PRETTY_NAME"
echo ""

# 方法 1: 使用包管理器安装
info "📦 方法 1: 从软件包仓库安装..."
echo ""

# 从 GitHub 获取 setup.sh 脚本
if curl -fsSL https://raw.githubusercontent.com/happykl-cn/LinuxStudio/main/packaging/setup.sh 2>/dev/null | bash; then
    info "仓库配置成功"
    echo ""
    
    # 使用包管理器安装
    case $OS in
        ubuntu|debian)
            if command -v apt-get &>/dev/null; then
                info "正在通过 apt-get 安装..."
                apt-get update -qq
                if apt-get install -y linuxstudio 2>/dev/null; then
                    post_install_setup
                    exit 0
                fi
            else
                warning "未找到 apt-get"
            fi
            ;;
        centos|rhel|fedora|rocky|almalinux)
            info "正在通过 yum/dnf 安装..."
            if command -v dnf &>/dev/null; then
                if dnf install -y linuxstudio 2>/dev/null; then
                    post_install_setup
                    exit 0
                fi
            elif command -v yum &>/dev/null; then
                if yum install -y linuxstudio 2>/dev/null; then
                    post_install_setup
                    exit 0
                fi
            else
                warning "既未找到 dnf 也未找到 yum"
            fi
            ;;
        arch|manjaro)
            if command -v pacman &>/dev/null; then
                info "正在通过 pacman 安装..."
                if pacman -Sy --noconfirm linuxstudio 2>/dev/null; then
                    post_install_setup
                    exit 0
                fi
            else
                warning "未找到 pacman"
            fi
            ;;
        opensuse*|sles)
            if command -v zypper &>/dev/null; then
                info "正在通过 zypper 安装..."
                if zypper install -y linuxstudio 2>/dev/null; then
                    post_install_setup
                    exit 0
                fi
            else
                warning "未找到 zypper"
            fi
            ;;
        *)
            warning "不支持的操作系统包安装: $OS"
            ;;
    esac
fi

warning "包安装失败，尝试其他方法..."
echo ""

# 方法 2: 从 GitHub Releases 直接下载
info "📦 方法 2: 从 GitHub Releases 下载软件包..."
echo ""

VERSION="1.1.1"
GITHUB_RELEASE="https://github.com/happykl-cn/LinuxStudio/releases/latest/download"

# 检测架构
ARCH=$(uname -m)
case $ARCH in
    x86_64|amd64)
        ARCH_SUFFIX="amd64"
        RPM_ARCH="x86_64"
        ;;
    aarch64|arm64)
        ARCH_SUFFIX="arm64"
        RPM_ARCH="aarch64"
        ;;
    *)
        ARCH_SUFFIX="amd64"  # 默认尝试
        RPM_ARCH="x86_64"
        warning "未知架构: $ARCH，尝试使用默认架构"
        ;;
esac

case $OS in
    ubuntu)
        PACKAGE="linuxstudio_${VERSION}_ubuntu-$(lsb_release -rs)_${ARCH_SUFFIX}.deb"
        info "正在下载 $PACKAGE（架构: $ARCH）..."
        if wget -q "$GITHUB_RELEASE/$PACKAGE" -O /tmp/linuxstudio.deb 2>/dev/null; then
            if dpkg -i /tmp/linuxstudio.deb 2>/dev/null; then
                rm -f /tmp/linuxstudio.deb
                post_install_setup
                exit 0
            elif dpkg -s linuxstudio &>/dev/null; then
                rm -f /tmp/linuxstudio.deb
                post_install_setup
                exit 0
            fi
        fi
        ;;
    debian)
        PACKAGE="linuxstudio_${VERSION}_debian-${VERSION_ID}_${ARCH_SUFFIX}.deb"
        info "正在下载 $PACKAGE（架构: $ARCH）..."
        if wget -q "$GITHUB_RELEASE/$PACKAGE" -O /tmp/linuxstudio.deb 2>/dev/null; then
            if dpkg -i /tmp/linuxstudio.deb 2>/dev/null; then
                rm -f /tmp/linuxstudio.deb
                post_install_setup
                exit 0
            elif dpkg -s linuxstudio &>/dev/null; then
                rm -f /tmp/linuxstudio.deb
                post_install_setup
                exit 0
            fi
        fi
        ;;
    centos|rhel|rocky|almalinux)
        # 根据系统版本选择合适的包
        if [ "${VERSION_ID%%.*}" -ge 9 ]; then
            PACKAGE="linuxstudio-${VERSION}-1.rockylinux-9.${RPM_ARCH}.rpm"
        else
            PACKAGE="linuxstudio-${VERSION}-1.rockylinux-8.${RPM_ARCH}.rpm"
        fi
        info "正在下载 $PACKAGE（架构: $ARCH）..."
        if wget -q "$GITHUB_RELEASE/$PACKAGE" -O /tmp/linuxstudio.rpm 2>/dev/null; then
            # 尝试安装或升级
            if rpm -Uvh /tmp/linuxstudio.rpm 2>/dev/null; then
                rm -f /tmp/linuxstudio.rpm
                post_install_setup
                exit 0
            elif rpm -q linuxstudio &>/dev/null; then
                rm -f /tmp/linuxstudio.rpm
                post_install_setup
                exit 0
            fi
        fi
        ;;
    fedora)
        PACKAGE="linuxstudio-${VERSION}-1.fedora-${VERSION_ID}.${RPM_ARCH}.rpm"
        info "正在下载 $PACKAGE（架构: $ARCH）..."
        if wget -q "$GITHUB_RELEASE/$PACKAGE" -O /tmp/linuxstudio.rpm 2>/dev/null; then
            # 尝试安装或升级
            if rpm -Uvh /tmp/linuxstudio.rpm 2>/dev/null; then
                rm -f /tmp/linuxstudio.rpm
                post_install_setup
                exit 0
            elif rpm -q linuxstudio &>/dev/null; then
                rm -f /tmp/linuxstudio.rpm
                post_install_setup
                exit 0
            fi
        fi
        ;;
esac

warning "直接下载失败"
echo ""

# 在继续之前，检查是否已经安装
if command -v xkl &>/dev/null; then
    post_install_setup
    exit 0
fi

# 方法 3: 嵌入式系统手动安装（如果是嵌入式模式）
if [ "$INSTALLATION_MODE" = "embedded" ]; then
    info "📱 方法 3: 嵌入式系统手动安装..."
    echo ""
    
    # 尝试下载 armhf 包进行手动安装
    info "尝试嵌入式优化安装..."
    
    # 选择合适的 ARM32 包
    case $OS in
        ubuntu|debian)
            EMBEDDED_PACKAGE="linuxstudio_${VERSION}_debian-11_armhf.deb"
            ;;
        *)
            EMBEDDED_PACKAGE="linuxstudio_${VERSION}_debian-11_armhf.deb"
            warning "为嵌入式安装使用 Debian 软件包"
            ;;
    esac
    
    info "正在下载 $EMBEDDED_PACKAGE 进行嵌入式安装..."
    
    if wget -q "$GITHUB_RELEASE/$EMBEDDED_PACKAGE" -O /tmp/linuxstudio_embedded.deb 2>/dev/null; then
        info "✅ 软件包下载成功"
        echo ""
        info "🔧 执行嵌入式优化手动安装..."
        
        # 创建临时目录
        mkdir -p /tmp/linuxstudio_install
        cd /tmp/linuxstudio_install
        
        # 解压 DEB 包
        info "→ 正在解压软件包..."
        ar x /tmp/linuxstudio_embedded.deb
        tar -xzf data.tar.gz
        
        # 复制文件到系统目录
        info "→ 正在安装文件..."
        cp -r usr/* /usr/ 2>/dev/null || true
        cp -r opt/* /opt/ 2>/dev/null || true
        cp -r etc/* /etc/ 2>/dev/null || true
        
        # 创建必要目录
        info "→ 正在创建目录结构..."
        mkdir -p /opt/linuxstudio/plugins
        mkdir -p /opt/linuxstudio/components
        mkdir -p /opt/linuxstudio/data
        mkdir -p /opt/linuxstudio/logs
        mkdir -p /opt/linuxstudio/scenes
        mkdir -p /etc/linuxstudio
        
        # 创建配置文件
        info "→ 正在创建配置..."
        cat > /etc/linuxstudio/config.yaml <<'EOF'
# LinuxStudio 配置（嵌入式优化）
version: 1.1.1
install_path: /opt/linuxstudio
log_level: info
auto_update_check: false
embedded_mode: true
memory_optimization: true
minimal_logging: true
EOF
        
        # 设置权限
        info "→ 正在设置权限..."
        chmod +x /usr/bin/xkl 2>/dev/null || true
        
        # 创建符号链接
        info "→ 正在创建符号链接..."
        ln -sf /usr/bin/xkl /usr/bin/linuxstudio 2>/dev/null || true
        
        # 嵌入式系统优化
        info "→ 正在应用嵌入式系统优化..."
        
        # 优化 1: 减少日志级别
        if [ -f /etc/linuxstudio/config.yaml ]; then
            sed -i 's/log_level: info/log_level: warning/' /etc/linuxstudio/config.yaml 2>/dev/null || true
        fi
        
        # 优化 2: 禁用自动更新检查
        if [ -f /etc/linuxstudio/config.yaml ]; then
            sed -i 's/auto_update_check: true/auto_update_check: false/' /etc/linuxstudio/config.yaml 2>/dev/null || true
        fi
        
        # 优化 3: 设置内存限制（如果内存小于 512MB）
        TOTAL_MEM_MB=$(($(cat /proc/meminfo | grep MemTotal | awk '{print $2}') / 1024))
        if [ "$TOTAL_MEM_MB" -lt 512 ]; then
            info "→ 正在应用低内存优化（检测到 ${TOTAL_MEM_MB}MB）..."
            echo "max_memory_usage: 64MB" >> /etc/linuxstudio/config.yaml
            echo "cache_size: 8MB" >> /etc/linuxstudio/config.yaml
            echo "worker_threads: 1" >> /etc/linuxstudio/config.yaml
        fi
        
        # 初始化框架（静默模式）
        info "→ 正在初始化框架..."
        if [ -x /usr/bin/xkl ]; then
            /usr/bin/xkl init --quiet --embedded 2>/dev/null || true
        fi
        
        # 清理临时文件
        cd /
        rm -rf /tmp/linuxstudio_install /tmp/linuxstudio_embedded.deb
        
        # 验证安装
        if [ -x /usr/bin/xkl ]; then
            echo ""
            success "🎉 LinuxStudio 嵌入式安装完成！"
            echo ""
            info "📱 已应用嵌入式优化:"
            info "   • 减少内存使用"
            info "   • 最小化日志"
            info "   • 禁用自动更新"
            info "   • 单线程模式（如果低内存）"
            echo ""
            post_install_setup
            exit 0
        else
            warning "安装完成但未找到 xkl 命令"
        fi
    else
        warning "下载嵌入式软件包失败"
    fi
    echo ""
fi

# 方法 4: 从源码编译
info "📦 方法 4: 从源码编译..."
echo ""

# 检查是否有必要的工具
if ! command -v git &>/dev/null; then
    warning "未找到 git，跳过源码编译"
    echo ""
    echo "════════════════════════════════════════════════════════"
    echo ""
    error "❌ 自动安装失败"
    echo ""
    info "📝 请选择以下方式之一手动安装："
    echo ""
    echo "方式 1: 从 GitHub Releases 下载预编译包"
    echo "   访问: https://github.com/happykl-cn/LinuxStudio/releases/latest"
    echo "   下载适合您系统的安装包"
    echo ""
    echo "方式 2: 使用 git 从源码编译"
    echo "   sudo yum install -y git"
    echo "   curl -fsSL https://linuxstudio.org/heaven-cn.sh | sudo bash"
    echo ""
    echo "方式 3: 手动安装已下载的包"
    if [ -f /tmp/linuxstudio.rpm ]; then
        echo "   检测到已下载的包: /tmp/linuxstudio.rpm"
        echo "   sudo rpm -Uvh --force /tmp/linuxstudio.rpm"
        echo ""
    fi
    echo "════════════════════════════════════════════════════════"
    echo ""
    exit 1
fi

# 安装编译依赖
info "正在安装编译依赖..."
case $OS in
    ubuntu|debian)
        if command -v apt-get &>/dev/null; then
            apt-get update -qq
            apt-get install -y build-essential cmake git 2>/dev/null || warning "依赖安装失败"
        fi
        ;;
    centos|rhel|fedora|rocky|almalinux)
        if command -v dnf &>/dev/null; then
            dnf install -y gcc-c++ cmake git make 2>/dev/null || warning "依赖安装失败"
        elif command -v yum &>/dev/null; then
            yum install -y gcc-c++ cmake git make 2>/dev/null || warning "依赖安装失败"
        fi
        ;;
    arch|manjaro)
        if command -v pacman &>/dev/null; then
            pacman -S --noconfirm base-devel cmake git 2>/dev/null || warning "依赖安装失败"
        fi
        ;;
    *)
        warning "无法自动安装 $OS 的依赖"
        info "请手动安装: gcc, g++, cmake, git, make"
        ;;
esac

# 检查是否有编译器
if ! command -v g++ &>/dev/null && ! command -v clang++ &>/dev/null; then
    warning "未找到 C++ 编译器 (g++ 或 clang++)"
    echo ""
    error "❌ 没有编译器无法从源码编译"
    echo "   请安装 build-essential 或 gcc-c++ 后重试"
    exit 1
fi

# 检查是否有 cmake
if ! command -v cmake &>/dev/null; then
    warning "未找到 cmake，无法从源码编译"
    echo ""
    error "❌ 安装失败。请安装 cmake 后重试"
    exit 1
fi

# 克隆并编译
info "正在克隆仓库..."
cd /tmp
rm -rf LinuxStudio
git clone https://github.com/happykl-cn/LinuxStudio.git
cd LinuxStudio

info "正在编译..."
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . -j$(nproc)

info "正在安装..."
cmake --install .

post_install_setup

cat <<EOF
📖 文档: https://docs.linuxstudio.org
💬 社区: https://community.linuxstudio.org
🐛 问题: https://github.com/happykl-cn/LinuxStudio/issues

EOF
