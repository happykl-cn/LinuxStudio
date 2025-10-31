#!/bin/bash
#==============================================================================
# LinuxStudio One-Click Installer
# Version: 2.0.0
# Description: Smart installer that uses package manager
# Author: Dino Studio
# Website: https://linuxstudio.org
#==============================================================================

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Banner
cat <<'EOF'
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  _     _                  ____  _             _ _         ┃
┃ | |   (_)_ __  _   ___  _/ ___|| |_ _   _  __| (_) ___   ┃
┃ | |   | | '_ \| | | \ \/ \___ \| __| | | |/ _` | |/ _ \  ┃
┃ | |___| | | | | |_| |>  < ___) | |_| |_| | (_| | | (_) | ┃
┃ |_____|_|_| |_|\__,_/_/\_\____/ \__|\__,_|\__,_|_|\___/  ┃
┃                                                            ┃
┃              One-Click Installer v2.0                     ┃
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

# Download and run setup.sh
if curl -fsSL https://raw.githubusercontent.com/happykl-cn/LinuxStudio/main/packaging/setup.sh 2>/dev/null | bash; then
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
                    success "LinuxStudio installed successfully!"
                    exit 0
                fi
            else
                warning "zypper not found"
            fi
            ;;
        *)
            warning "Unsupported OS for package installation: $OS"
            ;;
    esac
fi

warning "Package installation failed, trying alternative method..."
echo ""

# Method 2: Download .deb/.rpm directly from GitHub Releases
info "📦 Method 2: Downloading package from GitHub Releases..."
echo ""

VERSION="1.0.0"
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
        warning "Unknown architecture: $ARCH, trying default"
        ;;
esac

case $OS in
    ubuntu)
        PACKAGE="linuxstudio_${VERSION}_ubuntu-$(lsb_release -rs)_${ARCH_SUFFIX}.deb"
        info "Downloading $PACKAGE for architecture $ARCH..."
        if wget -q "$GITHUB_RELEASE/$PACKAGE" -O /tmp/linuxstudio.deb 2>/dev/null; then
            dpkg -i /tmp/linuxstudio.deb && success "LinuxStudio installed!" && exit 0
        fi
        ;;
    debian)
        PACKAGE="linuxstudio_${VERSION}_debian-${VERSION_ID}_${ARCH_SUFFIX}.deb"
        info "Downloading $PACKAGE for architecture $ARCH..."
        if wget -q "$GITHUB_RELEASE/$PACKAGE" -O /tmp/linuxstudio.deb 2>/dev/null; then
            dpkg -i /tmp/linuxstudio.deb && success "LinuxStudio installed!" && exit 0
        fi
        ;;
    centos|rhel|rocky|almalinux)
        PACKAGE="linuxstudio-${VERSION}-1.el${VERSION_ID%%.*}.${RPM_ARCH}.rpm"
        info "Downloading $PACKAGE for architecture $ARCH..."
        if wget -q "$GITHUB_RELEASE/$PACKAGE" -O /tmp/linuxstudio.rpm 2>/dev/null; then
            rpm -ivh /tmp/linuxstudio.rpm && success "LinuxStudio installed!" && exit 0
        fi
        ;;
    fedora)
        PACKAGE="linuxstudio-${VERSION}-1.fedora-${VERSION_ID}.${RPM_ARCH}.rpm"
        info "Downloading $PACKAGE for architecture $ARCH..."
        if wget -q "$GITHUB_RELEASE/$PACKAGE" -O /tmp/linuxstudio.rpm 2>/dev/null; then
            rpm -ivh /tmp/linuxstudio.rpm && success "LinuxStudio installed!" && exit 0
        fi
        ;;
esac

warning "Direct download failed"
echo ""

# Method 3: Build from source
info "📦 Method 3: Building from source..."
echo ""

# Check if we have necessary tools
if ! command -v git &>/dev/null; then
    warning "git not found, cannot build from source"
    echo ""
    echo "❌ Installation failed. Please install manually:"
    echo "   1. Download from: https://github.com/happykl-cn/LinuxStudio/releases/latest"
    echo "   2. Or install git and try again"
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
