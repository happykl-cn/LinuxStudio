#!/bin/bash
#
# LinuxStudio Repository Setup Script
# Usage: curl -fsSL https://packages.linuxstudio.org/setup.sh | sudo bash
#

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ASCII Banner
cat <<'EOF'
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  _     _                  ____  _             _ _         ┃
┃ | |   (_)_ __  _   ___  _/ ___|| |_ _   _  __| (_) ___   ┃
┃ | |   | | '_ \| | | \ \/ \___ \| __| | | |/ _` | |/ _ \  ┃
┃ | |___| | | | | |_| |>  < ___) | |_| |_| | (_| | | (_) | ┃
┃ |_____|_|_| |_|\__,_/_/\_\____/ \__|\__,_|\__,_|_|\___/  ┃
┃                                                            ┃
┃           Package Repository Setup Script                 ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
EOF

echo ""

if [ "$EUID" -ne 0 ]; then 
    error "Please run as root (use sudo)"
fi

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
    CODENAME=${VERSION_CODENAME:-unknown}
else
    error "Cannot detect OS (missing /etc/os-release)"
fi

info "Detected OS: $PRETTY_NAME"
echo ""

case $OS in
    ubuntu|debian)
        info "Setting up APT repository for Debian/Ubuntu..."
        
        # 安装依赖
        info "Installing dependencies..."
        apt-get update -qq
        apt-get install -y -qq curl gpg ca-certificates >/dev/null 2>&1
        
        # 添加 GPG 密钥
        info "Adding LinuxStudio GPG key..."
        curl -fsSL https://packages.linuxstudio.org/gpg.key 2>/dev/null | \
            gpg --dearmor -o /usr/share/keyrings/linuxstudio-archive-keyring.gpg 2>/dev/null || {
            warn "Cannot fetch GPG key from server, using GitHub fallback..."
            curl -fsSL https://raw.githubusercontent.com/happykl-cn/LinuxStudio/main/packaging/gpg.key | \
                gpg --dearmor -o /usr/share/keyrings/linuxstudio-archive-keyring.gpg
        }
        
        # 添加仓库
        info "Adding repository to sources list..."
        echo "deb [signed-by=/usr/share/keyrings/linuxstudio-archive-keyring.gpg] https://packages.linuxstudio.org/apt $CODENAME main" \
            | tee /etc/apt/sources.list.d/linuxstudio.list >/dev/null
        
        # 更新索引
        info "Updating package index..."
        apt-get update -qq
        
        echo ""
        echo -e "${GREEN}✅ Repository configured successfully!${NC}"
        echo ""
        echo "📦 Install with:"
        echo -e "   ${BLUE}sudo apt-get install linuxstudio${NC}"
        echo ""
        ;;
        
    centos|rhel|fedora|rocky|almalinux)
        info "Setting up YUM/DNF repository for RHEL-based systems..."
        
        # 检查包管理器
        if command -v dnf &>/dev/null; then
            PKG_MGR="dnf"
        elif command -v yum &>/dev/null; then
            PKG_MGR="yum"
        else
            error "Neither dnf nor yum found. Cannot configure repository."
        fi
        
        info "Creating repository configuration..."
        cat > /etc/yum.repos.d/linuxstudio.repo <<EOF
[linuxstudio]
name=LinuxStudio Repository
baseurl=https://packages.linuxstudio.org/rpm/el\$releasever/\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.linuxstudio.org/gpg.key
       https://raw.githubusercontent.com/happykl-cn/LinuxStudio/main/packaging/gpg.key
EOF
        
        # 导入 GPG 密钥
        info "Importing GPG key..."
        rpm --import https://packages.linuxstudio.org/gpg.key 2>/dev/null || \
            rpm --import https://raw.githubusercontent.com/happykl-cn/LinuxStudio/main/packaging/gpg.key
        
        # 清理并更新缓存
        info "Updating repository cache..."
        $PKG_MGR clean all -q >/dev/null 2>&1
        $PKG_MGR makecache -q >/dev/null 2>&1 || true
        
        echo ""
        echo -e "${GREEN}✅ Repository configured successfully!${NC}"
        echo ""
        echo "📦 Install with:"
        echo -e "   ${BLUE}sudo $PKG_MGR install linuxstudio${NC}"
        echo ""
        ;;
        
    arch|manjaro)
        info "Setting up Pacman repository for Arch Linux..."
        
        # 备份 pacman.conf
        cp /etc/pacman.conf /etc/pacman.conf.backup
        
        # 添加到 pacman.conf
        if ! grep -q "\[linuxstudio\]" /etc/pacman.conf; then
            info "Adding repository to pacman.conf..."
            cat >> /etc/pacman.conf <<'EOF'

# LinuxStudio Repository
[linuxstudio]
SigLevel = Optional TrustAll
Server = https://packages.linuxstudio.org/arch/$arch
Server = https://github.com/happykl-cn/LinuxStudio/releases/download/latest/
EOF
        fi
        
        # 更新数据库
        info "Updating package database..."
        pacman -Sy --noconfirm >/dev/null 2>&1
        
        echo ""
        echo -e "${GREEN}✅ Repository configured successfully!${NC}"
        echo ""
        echo "📦 Install with:"
        echo -e "   ${BLUE}sudo pacman -S linuxstudio${NC}"
        echo ""
        ;;
        
    opensuse*|sles)
        info "Setting up Zypper repository for openSUSE/SLES..."
        
        # 添加仓库
        zypper addrepo -f \
            https://packages.linuxstudio.org/zypper/openSUSE_Leap_${VER%.*} \
            linuxstudio
        
        # 刷新
        zypper refresh linuxstudio
        
        echo ""
        echo -e "${GREEN}✅ Repository configured successfully!${NC}"
        echo ""
        echo "📦 Install with:"
        echo -e "   ${BLUE}sudo zypper install linuxstudio${NC}"
        echo ""
        ;;
        
    *)
        warn "Unsupported or unknown OS: $OS"
        echo ""
        warn "Cannot configure package repository automatically."
        echo ""
        info "📦 Alternative installation methods:"
        echo ""
        echo "1️⃣  Download pre-built packages:"
        echo "   https://github.com/happykl-cn/LinuxStudio/releases/latest"
        echo ""
        echo "2️⃣  Use the one-click installer:"
        echo "   curl -fsSL https://linuxstudio.org/heaven.sh | sudo bash"
        echo ""
        echo "3️⃣  Build from source:"
        echo "   git clone https://github.com/happykl-cn/LinuxStudio.git"
        echo "   cd LinuxStudio"
        echo "   ./build.sh"
        echo "   cd build && sudo cmake --install ."
        echo ""
        exit 1
        ;;
esac

# 最后提示
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✨ Need help? Visit:"
echo "   📚 https://docs.linuxstudio.org"
echo "   💬 https://community.linuxstudio.org"
echo ""

# 显示文档链接
echo "📚 Documentation: https://docs.linuxstudio.org"
echo "💬 Community: https://community.linuxstudio.org"
echo "🐛 Issues: https://github.com/happykl-cn/LinuxStudio/issues"
echo ""

