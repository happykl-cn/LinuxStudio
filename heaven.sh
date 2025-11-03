#!/bin/bash
#==============================================================================
# LinuxStudio One-Click Installer
# Version: 2.1.0
# Description: Smart installer that uses package manager
# Author: Dino Studio
# Website: https://linuxstudio.org
#==============================================================================

set -e

# 解析命令行参数
FORCE_EMBEDDED=false
FORCE_STANDARD=false
NON_INTERACTIVE=false
SKIP_DETECTION=false

# Check if TTY is available (auto non-interactive if piped)
if [ ! -t 0 ] && [ ! -t 1 ]; then
    NON_INTERACTIVE=true
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        --embedded)
            FORCE_EMBEDDED=true
            shift
            ;;
        --standard)
            FORCE_STANDARD=true
            shift
            ;;
        -y|--yes|--non-interactive)
            NON_INTERACTIVE=true
            shift
            ;;
        --skip-detection)
            SKIP_DETECTION=true
            shift
            ;;
        --help|-h)
            echo "LinuxStudio One-Click Installer v2.1.0"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --embedded          Force embedded-optimized installation"
            echo "  --standard          Force standard installation"
            echo "  -y, --yes           Non-interactive mode (use defaults)"
            echo "  --skip-detection    Skip embedded system detection"
            echo "  -h, --help          Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                  # Interactive installation"
            echo "  $0 --embedded -y    # Non-interactive embedded installation"
            echo "  $0 --standard       # Force standard installation"
            echo ""
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Safe download functions with automatic SSL certificate handling (embedded systems compatible)
safe_curl() {
    local url=$1
    local output=$2
    
    # Try normal download first
    if curl -fsSL "$url" -o "$output" 2>/dev/null; then
        return 0
    fi
    
    # If failed, check for SSL errors
    local curl_error=$(curl -fsSL "$url" -o "$output" 2>&1)
    if echo "$curl_error" | grep -qi "certificate\|SSL\|TLS\|verification failed"; then
        warning "SSL certificate verification failed, skipping verification (embedded compatibility mode)..."
        if curl -fsSLk "$url" -o "$output" 2>/dev/null; then
            return 0
        fi
    fi
    
    return 1
}

# Safe wget function
safe_wget() {
    local url=$1
    local output=$2
    
    # Try normal download first
    if wget -q "$url" -O "$output" 2>/dev/null; then
        return 0
    fi
    
    # If failed, try skipping certificate verification
    local wget_error=$(wget "$url" -O "$output" 2>&1)
    if echo "$wget_error" | grep -qi "certificate\|SSL\|TLS\|verification failed\|certificates.crt"; then
        warning "SSL certificate verification failed, skipping verification (embedded compatibility mode)..."
        if wget --no-check-certificate -q "$url" -O "$output" 2>/dev/null; then
            return 0
        fi
    fi
    
    return 1
}

# Safe pipe curl (for executing scripts directly)
safe_curl_pipe() {
    local url=$1
    
    # Try normal download first
    if curl -fsSL "$url" 2>/dev/null | bash; then
        return 0
    fi
    
    # Check for errors
    local test_output=$(curl -fsSL "$url" 2>&1)
    if echo "$test_output" | grep -qi "certificate\|SSL\|TLS\|verification failed"; then
        warning "SSL certificate verification failed, skipping verification (embedded compatibility mode)..."
        if curl -fsSLk "$url" 2>/dev/null | bash; then
            return 0
        fi
    fi
    
    return 1
}

# Post-installation setup function (must be defined before use)
post_install_setup() {
    echo ""
    success "✅ LinuxStudio core installed!"
    echo ""
    
    if [ "$NON_INTERACTIVE" = true ]; then
        info "Non-interactive mode, skipping scene configuration"
        info "You can run later: xkl scene apply <scene-name>"
        return 0
    fi
    
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║      LinuxStudio Scene & Component Setup Wizard      ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    echo ""
    echo "LinuxStudio has been installed successfully! You can now select a development scene and install related components."
    echo ""
    
    if [ -t 0 ]; then
        read -r -p "Configure development scene now? [Y/n]: " SETUP_SCENES
    else
        read -r -p "Configure development scene now? [Y/n]: " SETUP_SCENES < /dev/tty || SETUP_SCENES=""
    fi
    
    SETUP_SCENES=${SETUP_SCENES:-Y}
    
    if [[ ! "$SETUP_SCENES" =~ ^[Yy]$ ]]; then
        echo ""
        info "Skipping scene configuration. You can run these commands later:"
        echo ""
        info "   xkl scene list          # List available scenes"
        info "   xkl scene apply web     # Apply web development scene"
        info "   xkl plugin install ros2 # Install specific plugin"
        echo ""
        return 0
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "           Select Your Development Scene"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    echo "  1) Web Development - Nginx, PHP, Java, MySQL, Redis, Node.js"
    echo "  2) Embedded        - ARM/RISC-V GCC, OpenOCD, GDB"
    echo "  3) Robotics        - ROS2, MoveIt2, Gazebo, OpenCV"
    echo "  4) AI/ML           - Python, Jupyter, TensorFlow, PyTorch"
    echo "  5) Game Dev        - SDL2, OpenGL, Vulkan, Godot"
    echo "  6) DevOps          - Docker, Kubernetes, Jenkins, Prometheus"
    echo "  7) Security        - Nmap, Wireshark, Metasploit"
    echo "  8) Blockchain      - Hardhat, Solidity, Web3.js"
    echo "  9) IoT             - Mosquitto, Node-RED, InfluxDB"
    echo "  0) Skip scene configuration"
    echo ""
    
    if [ -t 0 ]; then
        read -r -p "Please select scene [1-9, 0=skip]: " SCENE_CHOICE
    else
        read -r -p "Please select scene [1-9, 0=skip]: " SCENE_CHOICE < /dev/tty || SCENE_CHOICE=""
    fi
    
    SCENE_CHOICE=${SCENE_CHOICE:-0}
    
    case $SCENE_CHOICE in
        1)
            SCENE_NAME="web-development"
            SCENE_DISPLAY="Web Development"
            ;;
        2)
            SCENE_NAME="embedded"
            SCENE_DISPLAY="Embedded Systems"
            ;;
        3)
            SCENE_NAME="robotics"
            SCENE_DISPLAY="Robotics"
            ;;
        4)
            SCENE_NAME="ai-ml"
            SCENE_DISPLAY="AI/ML"
            ;;
        5)
            SCENE_NAME="game-dev"
            SCENE_DISPLAY="Game Development"
            ;;
        6)
            SCENE_NAME="devops"
            SCENE_DISPLAY="DevOps"
            ;;
        7)
            SCENE_NAME="security"
            SCENE_DISPLAY="Security"
            ;;
        8)
            SCENE_NAME="blockchain"
            SCENE_DISPLAY="Blockchain"
            ;;
        9)
            SCENE_NAME="iot"
            SCENE_DISPLAY="IoT"
            ;;
        0)
            echo ""
            info "Skipping scene configuration. Run later: xkl scene apply <scene-name>"
            echo ""
            return 0
            ;;
        *)
            warning "Invalid choice, skipping scene configuration"
            echo ""
            return 0
            ;;
    esac
    
    echo ""
    info "Applying scene: $SCENE_DISPLAY"
    echo ""
    
    # Apply scene (this will trigger interactive component selection)
    if xkl scene apply "$SCENE_NAME" 2>/dev/null; then
        echo ""
        success "🎉 Scene configuration completed!"
    else
        warning "Scene application failed, please run manually: xkl scene apply $SCENE_NAME"
    fi
    
    echo ""
    info "🚀 Quick start:"
    info "   xkl status              # Check system status"
    info "   xkl scene list          # List available scenes"
    info "   xkl plugin list         # List available plugins"
    info "   xkl component list      # List installed components"
    echo ""
}

# Banner
cat <<'EOF'
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  _     _                  ____  _             _ _         ┃
┃ | |   (_)_ __  _   ___  _/ ___|| |_ _   _  __| (_) ___   ┃
┃ | |   | | '_ \| | | \ \/ \___ \| __| | | |/ _` | |/ _ \  ┃
┃ | |___| | | | | |_| |>  < ___) | |_| |_| | (_| | | (_) | ┃
┃ |_____|_|_| |_|\__,_/_/\_\____/ \__|\__,_|\__,_|_|\___/  ┃
┃                                                            ┃
┃              One-Click Installer v2.1                     ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
EOF

echo ""
info "Starting LinuxStudio installation..."
echo ""

# Check root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# 嵌入式场景检测
if [ "$SKIP_DETECTION" = false ]; then
    echo ""
    info "🔍 Detecting system environment..."
fi

# 检测是否为嵌入式系统
EMBEDDED_SYSTEM=false
EMBEDDED_TYPE=""

# 如果强制指定模式，跳过检测
if [ "$FORCE_EMBEDDED" = true ]; then
    EMBEDDED_SYSTEM=true
    EMBEDDED_TYPE="Forced Embedded Mode"
elif [ "$FORCE_STANDARD" = true ]; then
    EMBEDDED_SYSTEM=false
    EMBEDDED_TYPE="Forced Standard Mode"
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
        EMBEDDED_TYPE="Raspberry Pi"
    # BeagleBone
    elif echo "$CPU_INFO" | grep -qi "AM335x\|BeagleBone"; then
        EMBEDDED_SYSTEM=true
        EMBEDDED_TYPE="BeagleBone"
    # 通用 ARM 嵌入式设备
    elif [ "$(uname -m)" = "armv7l" ] && [ "$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')" -lt 2097152 ]; then
        EMBEDDED_SYSTEM=true
        EMBEDDED_TYPE="ARM32 Embedded"
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
    info "🎯 Detected embedded system: $EMBEDDED_TYPE"
    info "📱 Memory: $(free -h | grep Mem | awk '{print $2}')"
    info "🏗️  Architecture: $(uname -m)"
    echo ""
    echo "This appears to be an embedded system. Would you like to:"
    echo "  1) Use embedded-optimized installation (recommended)"
    echo "  2) Use standard installation"
    echo "  3) Auto-detect (let script decide)"
    echo ""
    if [ -t 0 ]; then
        read -r -p "Please choose [1-3] (default: 1): " INSTALL_MODE
    else
        # Running through pipe, read from /dev/tty
        read -r -p "Please choose [1-3] (default: 1): " INSTALL_MODE < /dev/tty || INSTALL_MODE=""
    fi
    INSTALL_MODE=${INSTALL_MODE:-1}
elif [ "$NON_INTERACTIVE" = false ]; then
    echo ""
    echo "This appears to be a standard Linux system."
    echo "Would you like to check for embedded system compatibility anyway?"
    echo "  1) No, use standard installation (recommended)"
    echo "  2) Yes, use embedded-optimized installation"
    echo "  3) Auto-detect based on system resources"
    echo ""
    if [ -t 0 ]; then
        read -r -p "Please choose [1-3] (default: 1): " INSTALL_MODE
    else
        # Running through pipe, read from /dev/tty
        read -r -p "Please choose [1-3] (default: 1): " INSTALL_MODE < /dev/tty || INSTALL_MODE=""
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
            info "✅ Using embedded-optimized installation"
        else
            INSTALLATION_MODE="standard"
            info "✅ Using standard installation"
        fi
        ;;
    2)
        if [ "$EMBEDDED_SYSTEM" = true ]; then
            INSTALLATION_MODE="standard"
            info "✅ Using standard installation (as requested)"
        else
            INSTALLATION_MODE="embedded"
            info "✅ Using embedded-optimized installation (as requested)"
        fi
        ;;
    3)
        # 自动检测模式
        TOTAL_MEM=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')
        if [ "$TOTAL_MEM" -lt 1048576 ] || [ "$(uname -m)" = "armv7l" ] || [ "$(uname -m)" = "armv6l" ]; then
            INSTALLATION_MODE="embedded"
            info "🤖 Auto-detected: Using embedded-optimized installation"
        else
            INSTALLATION_MODE="standard"
            info "🤖 Auto-detected: Using standard installation"
        fi
        ;;
    *)
        INSTALLATION_MODE="standard"
        warning "Invalid choice, using standard installation"
        ;;
esac

echo ""

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "Cannot detect OS"
    exit 1
fi

info "Detected OS: $PRETTY_NAME"
echo ""

# Method 1: Try to configure repository and install via package manager
info "📦 Method 1: Installing from package repository..."
echo ""

# Download and run setup.sh (using safe download function)
if safe_curl_pipe https://raw.githubusercontent.com/happykl-cn/LinuxStudio/main/packaging/setup.sh; then
    info "Repository configured successfully"
    echo ""
    
    # Install via package manager
    case $OS in
        ubuntu|debian)
            if command -v apt-get &>/dev/null; then
                info "Installing via apt-get..."
                apt-get update -qq
                if apt-get install -y linuxstudio 2>/dev/null; then
                    success "LinuxStudio installed successfully!"
                    exit 0
                fi
            else
                warning "apt-get not found"
            fi
            ;;
        centos|rhel|fedora|rocky|almalinux)
            info "Installing via yum/dnf..."
            if command -v dnf &>/dev/null; then
                if dnf install -y linuxstudio 2>/dev/null; then
                    success "LinuxStudio installed successfully!"
                    exit 0
                fi
            elif command -v yum &>/dev/null; then
                if yum install -y linuxstudio 2>/dev/null; then
                    success "LinuxStudio installed successfully!"
                    exit 0
                fi
            else
                warning "Neither dnf nor yum found"
            fi
            ;;
        arch|manjaro)
            if command -v pacman &>/dev/null; then
                info "Installing via pacman..."
                if pacman -Sy --noconfirm linuxstudio 2>/dev/null; then
                    success "LinuxStudio installed successfully!"
                    exit 0
                fi
            else
                warning "pacman not found"
            fi
            ;;
        opensuse*|sles)
            if command -v zypper &>/dev/null; then
                info "Installing via zypper..."
                if zypper install -y linuxstudio 2>/dev/null; then
                    post_install_setup
                    exit 0
                fi
            else
                warning "zypper not found"
            fi
            ;;
        openstlinux*|yocto*)
            # OpenSTLinux / Yocto systems usually use opkg or similar lightweight package managers
            # but most don't support standard package manager installation
            info "Detected OpenSTLinux/Yocto system, will use embedded installation method"
            warning "OpenSTLinux systems don't support standard package manager installation, skipping Method 1"
            ;;
        *)
            warning "Unsupported OS for package installation: $OS"
            info "Will try other installation methods..."
            ;;
    esac
fi

warning "Package installation failed, trying alternative method..."
echo ""

# Method 2: Download .deb/.rpm directly from GitHub Releases
info "📦 Method 2: Downloading package from GitHub Releases..."
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
    armv7l|armv7|armhf)
        ARCH_SUFFIX="armhf"
        RPM_ARCH="armv7hl"  # RPM uses armv7hl
        ;;
    armv6l|armv6)
        ARCH_SUFFIX="armhf"
        RPM_ARCH="armv6hl"
        ;;
    *)
        # For unknown architectures, if in embedded mode, try armhf
        if [ "$INSTALLATION_MODE" = "embedded" ] || [ "$EMBEDDED_SYSTEM" = true ]; then
            ARCH_SUFFIX="armhf"
            RPM_ARCH="armv7hl"
            warning "Unknown architecture: $ARCH, using ARM32 (armhf) in embedded mode"
        else
            ARCH_SUFFIX="amd64"
            RPM_ARCH="x86_64"
            warning "Unknown architecture: $ARCH, trying default amd64"
        fi
        ;;
esac

case $OS in
    ubuntu)
        PACKAGE="linuxstudio_${VERSION}_ubuntu-$(lsb_release -rs)_${ARCH_SUFFIX}.deb"
        info "Downloading $PACKAGE for architecture $ARCH..."
        if safe_wget "$GITHUB_RELEASE/$PACKAGE" /tmp/linuxstudio.deb; then
            if dpkg -i /tmp/linuxstudio.deb 2>/dev/null; then
                success "LinuxStudio installed!"
                rm -f /tmp/linuxstudio.deb
                exit 0
            elif dpkg -s linuxstudio &>/dev/null; then
                success "LinuxStudio already installed!"
                rm -f /tmp/linuxstudio.deb
                exit 0
            fi
        fi
        ;;
    debian)
        PACKAGE="linuxstudio_${VERSION}_debian-${VERSION_ID}_${ARCH_SUFFIX}.deb"
        info "Downloading $PACKAGE for architecture $ARCH..."
        if safe_wget "$GITHUB_RELEASE/$PACKAGE" /tmp/linuxstudio.deb; then
            if dpkg -i /tmp/linuxstudio.deb 2>/dev/null; then
                success "LinuxStudio installed!"
                rm -f /tmp/linuxstudio.deb
                exit 0
            elif dpkg -s linuxstudio &>/dev/null; then
                success "LinuxStudio already installed!"
                rm -f /tmp/linuxstudio.deb
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
        info "Downloading $PACKAGE for architecture $ARCH..."
        if safe_wget "$GITHUB_RELEASE/$PACKAGE" /tmp/linuxstudio.rpm; then
            # Try to install or upgrade
            if rpm -Uvh /tmp/linuxstudio.rpm 2>/dev/null; then
                success "LinuxStudio installed!"
                rm -f /tmp/linuxstudio.rpm
                exit 0
            elif rpm -q linuxstudio &>/dev/null; then
                success "LinuxStudio already installed!"
                rm -f /tmp/linuxstudio.rpm
                exit 0
            fi
        fi
        ;;
    fedora)
        PACKAGE="linuxstudio-${VERSION}-1.fedora-${VERSION_ID}.${RPM_ARCH}.rpm"
        info "Downloading $PACKAGE for architecture $ARCH -> $RPM_ARCH..."
        if safe_wget "$GITHUB_RELEASE/$PACKAGE" /tmp/linuxstudio.rpm; then
            # Try to install or upgrade
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
    openstlinux*|yocto*)
        # OpenSTLinux/Yocto systems usually don't have prebuilt packages, use embedded installation method directly
        info "OpenSTLinux/Yocto system skipping standard package download, will use embedded installation method"
        ;;
    *)
        # For other systems, if ARM32 architecture and in embedded mode, use embedded installation method directly
        if [ "$ARCH_SUFFIX" = "armhf" ] && [ "$INSTALLATION_MODE" = "embedded" ]; then
            info "ARM32 architecture embedded system, will use embedded installation method"
        else
            warning "No prebuilt package found for $OS ($ARCH)"
        fi
        ;;
esac

warning "Direct download failed"
echo ""

# Method 3: Embedded system manual installation (if embedded mode)
# Note: Try embedded installation before checking if already installed, as some embedded systems may have files but incomplete functionality
if [ "$INSTALLATION_MODE" = "embedded" ] || [ "$EMBEDDED_SYSTEM" = true ]; then
    info "📱 Method 3: Embedded system manual installation..."
    echo ""
    
    # 尝试下载 armhf 包进行手动安装
    info "Attempting embedded-optimized installation..."
    
    # 选择合适的 ARM32 包
    case $OS in
        ubuntu|debian)
            EMBEDDED_PACKAGE="linuxstudio_${VERSION}_debian-11_armhf.deb"
            ;;
        *)
            EMBEDDED_PACKAGE="linuxstudio_${VERSION}_debian-11_armhf.deb"
            warning "Using Debian package for embedded installation"
            ;;
    esac
    
    info "Downloading $EMBEDDED_PACKAGE for embedded installation..."
    
    if safe_wget "$GITHUB_RELEASE/$EMBEDDED_PACKAGE" /tmp/linuxstudio_embedded.deb; then
        info "✅ Package downloaded successfully"
        echo ""
        info "🔧 Performing embedded-optimized manual installation..."
        
        # 创建临时目录
        mkdir -p /tmp/linuxstudio_install
        cd /tmp/linuxstudio_install
        
        # 解压 DEB 包
        info "→ Extracting package..."
        ar x /tmp/linuxstudio_embedded.deb
        tar -xzf data.tar.gz
        
        # 复制文件到系统目录
        info "→ Installing files..."
        cp -r usr/* /usr/ 2>/dev/null || true
        cp -r opt/* /opt/ 2>/dev/null || true
        cp -r etc/* /etc/ 2>/dev/null || true
        
        # 创建必要目录
        info "→ Creating directory structure..."
        mkdir -p /opt/linuxstudio/plugins
        mkdir -p /opt/linuxstudio/components
        mkdir -p /opt/linuxstudio/data
        mkdir -p /opt/linuxstudio/logs
        mkdir -p /opt/linuxstudio/scenes
        mkdir -p /etc/linuxstudio
        
        # 创建配置文件
        info "→ Creating configuration..."
        cat > /etc/linuxstudio/config.yaml <<'EOF'
# LinuxStudio Configuration (Embedded Optimized)
version: 1.1.1
install_path: /opt/linuxstudio
log_level: info
auto_update_check: false
embedded_mode: true
memory_optimization: true
minimal_logging: true
EOF
        
        # 设置权限
        info "→ Setting permissions..."
        chmod +x /usr/bin/xkl 2>/dev/null || true
        
        # 创建符号链接
        info "→ Creating symbolic links..."
        ln -sf /usr/bin/xkl /usr/bin/linuxstudio 2>/dev/null || true
        
        # 嵌入式系统优化
        info "→ Applying embedded system optimizations..."
        
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
            info "→ Applying low-memory optimizations (${TOTAL_MEM_MB}MB detected)..."
            echo "max_memory_usage: 64MB" >> /etc/linuxstudio/config.yaml
            echo "cache_size: 8MB" >> /etc/linuxstudio/config.yaml
            echo "worker_threads: 1" >> /etc/linuxstudio/config.yaml
        fi
        
        # 初始化框架（静默模式）
        info "→ Initializing framework..."
        if [ -x /usr/bin/xkl ]; then
            /usr/bin/xkl init --quiet --embedded 2>/dev/null || true
        fi
        
        # 清理临时文件
        cd /
        rm -rf /tmp/linuxstudio_install /tmp/linuxstudio_embedded.deb
        
        # 验证安装
        if [ -x /usr/bin/xkl ]; then
            echo ""
            success "🎉 LinuxStudio embedded installation completed!"
            echo ""
            info "📱 Embedded optimizations applied:"
            info "   • Reduced memory usage"
            info "   • Minimal logging"
            info "   • Disabled auto-updates"
            info "   • Single-threaded mode (if low memory)"
            echo ""
            info "🚀 Quick start:"
            info "   xkl --version"
            info "   xkl status"
            echo ""
            exit 0
        else
            warning "Installation completed but xkl command not found"
        fi
    else
        warning "Failed to download embedded package"
    fi
    echo ""
fi

# Before attempting compilation, check if already installed (avoid unnecessary compilation)
if command -v xkl &>/dev/null; then
    echo ""
    success "✅ LinuxStudio core installed!"
    echo ""
    info "xkl command detected as available, skipping source compilation"
    post_install_setup
    exit 0
fi

# Method 4: Build from source
info "📦 Method 4: Building from source..."
echo ""

# Check if we have necessary tools
if ! command -v git &>/dev/null; then
    warning "git not found, skipping source build"
    echo ""
    echo "════════════════════════════════════════════════════════"
    echo ""
    echo "❌ Automatic installation failed"
    echo ""
    info "📝 Please choose one of the following manual installation methods:"
    echo ""
    echo "Method 1: Download precompiled package from GitHub Releases"
    echo "   Visit: https://github.com/happykl-cn/LinuxStudio/releases/latest"
    echo "   Download the package for your system"
    echo ""
    echo "Method 2: Build from source using git"
    echo "   sudo yum install -y git  # or apt-get install -y git"
    echo "   curl -fsSL https://linuxstudio.org/heaven.sh | sudo bash"
    echo ""
    echo "Method 3: Manually install downloaded package"
    if [ -f /tmp/linuxstudio.rpm ]; then
        echo "   Downloaded package detected: /tmp/linuxstudio.rpm"
        echo "   sudo rpm -Uvh --force /tmp/linuxstudio.rpm"
        echo ""
    fi
    echo "════════════════════════════════════════════════════════"
    echo ""
    exit 1
fi

# Install build dependencies
info "Installing build dependencies..."
case $OS in
    ubuntu|debian)
        if command -v apt-get &>/dev/null; then
            apt-get update -qq
            apt-get install -y build-essential cmake git 2>/dev/null || warning "Failed to install dependencies"
        fi
        ;;
    centos|rhel|fedora|rocky|almalinux)
        if command -v dnf &>/dev/null; then
            dnf install -y gcc-c++ cmake git make 2>/dev/null || warning "Failed to install dependencies"
        elif command -v yum &>/dev/null; then
            yum install -y gcc-c++ cmake git make 2>/dev/null || warning "Failed to install dependencies"
        fi
        ;;
    arch|manjaro)
        if command -v pacman &>/dev/null; then
            pacman -S --noconfirm base-devel cmake git 2>/dev/null || warning "Failed to install dependencies"
        fi
        ;;
    *)
        warning "Cannot automatically install dependencies for $OS"
        info "Please install: gcc, g++, cmake, git, make"
        ;;
esac

# Check if we have compiler
if ! command -v g++ &>/dev/null && ! command -v clang++ &>/dev/null; then
    warning "No C++ compiler found (g++ or clang++)"
    echo ""
    echo "❌ Cannot build from source without a compiler."
    echo "   Please install build-essential or gcc-c++ and try again"
    exit 1
fi

# Check if we have cmake
if ! command -v cmake &>/dev/null; then
    warning "cmake not found, cannot build from source"
    echo ""
    echo "❌ Installation failed. Please install cmake and try again"
    exit 1
fi

# Clone and build
info "Cloning repository..."
cd /tmp
rm -rf LinuxStudio
git clone https://github.com/happykl-cn/LinuxStudio.git
cd LinuxStudio

info "Building..."
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . -j$(nproc)

info "Installing..."
cmake --install .

success "LinuxStudio built and installed from source!"
echo ""

# Final message
cat <<EOF
╔═══════════════════════════════════════════════════════╗
║  ✅ LinuxStudio installed successfully!              ║
╚═══════════════════════════════════════════════════════╝

📚 Quick Start:
   xkl --help              # Show help
   xkl status              # Check system status
   xkl scene apply web     # Apply web development scene
   xkl plugin list         # List available plugins

📖 Documentation: https://docs.linuxstudio.org
💬 Community: https://community.linuxstudio.org
🐛 Issues: https://github.com/happykl-cn/LinuxStudio/issues

EOF
