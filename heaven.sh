#!/bin/bash
#==============================================================================
# LinuxStudio Framework Installation Script
# Version: 1.0.0
# Description: High-Performance Linux Environment Manager
# Author: Dino Studio
# Website: https://linuxstudio.org
#==============================================================================

set -e  # Exit on error
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8

#==============================================================================
# Global Variables
#==============================================================================
LINUXSTUDIO_VERSION="1.0.0"
INSTALL_PATH="/opt/linuxstudio"
LOG_FILE="/tmp/linuxstudio_install_$(date +%Y%m%d_%H%M%S).log"
TEMP_DIR="/tmp/linuxstudio_temp"
BIN_PATH="/usr/local/bin"
CONFIG_PATH="$INSTALL_PATH/config"
DATA_PATH="$INSTALL_PATH/data"

# Installation options
AUTO_YES=0  # Non-interactive mode
SKIP_SCENE=0  # Skip scene selection

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# System info
OS_TYPE=""
OS_VERSION=""
OS_ARCH=""
CPU_CORES=0
TOTAL_MEMORY=0
DISK_SPACE=0
IS_CHINA=0

#==============================================================================
# Utility Functions
#==============================================================================

# Print colored message
print_msg() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

# Print success message
success() {
    print_msg "$GREEN" "✅ $@"
}

# Print error message
error() {
    print_msg "$RED" "❌ $@"
}

# Print warning message
warning() {
    print_msg "$YELLOW" "⚠️  $@"
}

# Print info message
info() {
    print_msg "$CYAN" "ℹ️  $@"
}

# Print step message
step() {
    print_msg "$MAGENTA" "🔹 $@"
}

# Log message to file
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $@" >> "$LOG_FILE"
}

# Exit with error
die() {
    error "$@"
    log "ERROR: $@"
    exit 1
}

#==============================================================================
# System Detection Functions
#==============================================================================

# Check if running as root
check_root() {
    if [ "$(id -u)" != "0" ]; then
        die "This script must be run as root. Please use: sudo bash $0"
    fi
}

# Detect system information
detect_system() {
    step "Detecting system information..."
    
    # Detect OS
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        OS_TYPE="$ID"
        OS_VERSION="$VERSION_ID"
    else
        die "Cannot detect OS distribution"
    fi
    
    # Detect architecture
    OS_ARCH=$(uname -m)
    
    # Detect CPU cores
    CPU_CORES=$(nproc 2>/dev/null || grep -c ^processor /proc/cpuinfo)
    
    # Detect total memory (in GB)
    TOTAL_MEMORY=$(free -g | awk '/^Mem:/{print $2}')
    
    # Detect disk space (in GB)
    DISK_SPACE=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    
    info "OS: $OS_TYPE $OS_VERSION"
    info "Architecture: $OS_ARCH"
    info "CPU Cores: $CPU_CORES"
    info "Memory: ${TOTAL_MEMORY}GB"
    info "Available Disk: ${DISK_SPACE}GB"
    
    log "System detected: $OS_TYPE $OS_VERSION $OS_ARCH"
}

check_requirements() {
    step "Checking system requirements..."
    

    if [ "$TOTAL_MEMORY" -lt 1 ]; then
        warning "Low memory detected (${TOTAL_MEMORY}GB). Recommended: 2GB+"
    fi
    
    # Check supported OS
    case $OS_TYPE in
        debian|ubuntu|linuxmint|kali|fedora|rhel|centos|rocky|almalinux|arch|manjaro|opensuse*)
            success "Supported OS detected: $OS_TYPE"
            ;;
        *)
            die "Unsupported OS: $OS_TYPE"
            ;;
    esac
    
    success "System requirements check passed"
}

# Detect if in China (for mirror selection)
detect_china() {
    step "Detecting network location..."
    
    # Try to ping common Chinese servers
    if ping -c 1 -W 2 www.baidu.com &>/dev/null || \
       ping -c 1 -W 2 www.taobao.com &>/dev/null; then
        IS_CHINA=1
        info "Detected China network, will use Chinese mirrors"
    else
        IS_CHINA=0
        info "Using international mirrors"
    fi
}

#==============================================================================
# Package Manager Functions
#==============================================================================

# Parse download progress from APT output
parse_apt_progress() {
    local log_file=$1
    
    # Try to extract download information
    local downloaded=$(tail -50 "$log_file" 2>/dev/null | grep -oP 'Get:\d+.*?\[\d+.*?B\]' | tail -1 | grep -oP '\[\K[^\]]+' || echo "")
    local fetched=$(tail -10 "$log_file" 2>/dev/null | grep -oP 'Fetched \K[^\s]+' | tail -1 || echo "")
    local unpacking=$(tail -10 "$log_file" 2>/dev/null | grep -i 'unpacking\|setting up' | tail -1 || echo "")
    
    if [ -n "$fetched" ]; then
        echo "Downloaded: $fetched"
    elif [ -n "$downloaded" ]; then
        echo "Downloading: $downloaded"
    elif [ -n "$unpacking" ]; then
        echo "Installing packages..."
    else
        echo "Processing..."
    fi
}

# Universal package installation with detailed progress
universal_install() {
    local pkg=$1
    local pkg_name=${2:-$pkg}  # Display name
    local max_retries=2
    local retry_count=0
    local timeout_seconds=600  # 10 minutes timeout for large packages
    
    log "Installing package: $pkg"
    
    while [ $retry_count -lt $max_retries ]; do
        # Show retry info
        if [ $retry_count -gt 0 ]; then
            warning "Retrying installation ($((retry_count + 1))/$max_retries)..."
        fi
        
        # Show installation progress
        step "Installing $pkg_name..."
        
        # Create temporary files for output
        local tmp_output="/tmp/install_${pkg}_$$.log"
        local tmp_progress="/tmp/install_${pkg}_$$_progress.log"
        
        # Show a detailed progress while installing
        {
            case $OS_TYPE in
                debian|ubuntu|linuxmint|kali)
                    # Configure APT for better performance
                    export DEBIAN_FRONTEND=noninteractive
                    
                    # Enable parallel downloads and progress display
                    if ! grep -q "Acquire::Queue-Mode" /etc/apt/apt.conf.d/99parallel 2>/dev/null; then
                        mkdir -p /etc/apt/apt.conf.d/
                        cat > /etc/apt/apt.conf.d/99parallel << 'APTCONF'
Acquire::Queue-Mode "host";
Acquire::http::Pipeline-Depth "5";
Acquire::Retries "3";
Acquire::http::Timeout "30";
Acquire::https::Timeout "30";
APTCONF
                    fi
                    
                    # Update with timeout (only if not updated recently)
                    if [ ! -f /tmp/apt_updated ] || [ $(($(date +%s) - $(stat -c %Y /tmp/apt_updated 2>/dev/null || echo 0))) -gt 300 ]; then
                        timeout 60 apt-get update -qq 2>&1 || echo "Update timeout, continuing..."
                        touch /tmp/apt_updated
                    fi
                    
                    # Install with detailed output and timeout
                    timeout $timeout_seconds apt-get install -y \
                        -o Dpkg::Options::="--force-confdef" \
                        -o Dpkg::Options::="--force-confold" \
                        -o APT::Install-Recommends="false" \
                        -o APT::Install-Suggests="false" \
                        -o Dpkg::Use-Pty=0 \
                        "$pkg" 2>&1 | tee "$tmp_progress"
                    ;;
                fedora|rhel|centos|rocky|almalinux)
                    if command -v dnf &>/dev/null; then
                        timeout $timeout_seconds dnf install -y --setopt=timeout=60 "$pkg" 2>&1 | tee "$tmp_progress"
                    else
                        timeout $timeout_seconds yum install -y --setopt=timeout=60 "$pkg" 2>&1 | tee "$tmp_progress"
                    fi
                    ;;
                arch|manjaro)
                    timeout $timeout_seconds pacman -Sy --noconfirm "$pkg" 2>&1 | tee "$tmp_progress"
                    ;;
                opensuse*)
                    timeout $timeout_seconds zypper install -y "$pkg" 2>&1 | tee "$tmp_progress"
                    ;;
                *)
                    echo "Unsupported distribution: $OS_TYPE"
                    return 1
                    ;;
            esac
        } > "$tmp_output" 2>&1 &
        
        local install_pid=$!
        
        # Show detailed progress with download info
        local spin='-\|/'
        local i=0
        local elapsed=0
        local start_time=$(date +%s)
        local last_size=0
        local last_check_time=$start_time
        
        while kill -0 $install_pid 2>/dev/null; do
            i=$(( (i+1) %4 ))
            elapsed=$(($(date +%s) - start_time))
            
            # Parse progress info from log
            local progress_info=$(parse_apt_progress "$tmp_output")
            
            # Calculate download speed (rough estimate)
            if [ -f "$tmp_output" ]; then
                local current_size=$(stat -c%s "$tmp_output" 2>/dev/null || echo 0)
                local current_time=$(date +%s)
                local time_diff=$((current_time - last_check_time))
                
                if [ $time_diff -ge 2 ]; then
                    local size_diff=$((current_size - last_size))
                    local speed_bps=$((size_diff / time_diff))
                    local speed_kbps=$((speed_bps / 1024))
                    
                    last_size=$current_size
                    last_check_time=$current_time
                    
                    # Format output size
                    local output_kb=$((current_size / 1024))
                    local output_mb=$((output_kb / 1024))
                    
                    if [ $output_mb -gt 0 ]; then
                        local size_display="${output_mb}MB"
                    else
                        local size_display="${output_kb}KB"
                    fi
                    
                    # Show progress
                    if [ $speed_kbps -gt 1024 ]; then
                        local speed_mbps=$((speed_kbps / 1024))
                        printf "\r   ${CYAN}[${spin:$i:1}] $pkg_name | ${elapsed}s | $size_display | ${speed_mbps}MB/s | $progress_info${NC}%-20s" " "
                    elif [ $speed_kbps -gt 0 ]; then
                        printf "\r   ${CYAN}[${spin:$i:1}] $pkg_name | ${elapsed}s | $size_display | ${speed_kbps}KB/s | $progress_info${NC}%-20s" " "
                    else
                        printf "\r   ${CYAN}[${spin:$i:1}] $pkg_name | ${elapsed}s | $size_display | $progress_info${NC}%-20s" " "
                    fi
                else
                    printf "\r   ${CYAN}[${spin:$i:1}] $pkg_name | ${elapsed}s | $progress_info${NC}%-20s" " "
                fi
            else
                printf "\r   ${CYAN}[${spin:$i:1}] $pkg_name | ${elapsed}s${NC}%-40s" " "
            fi
            
            sleep 0.5
            
            # Force kill if timeout exceeded
            if [ $elapsed -gt $((timeout_seconds + 10)) ]; then
                kill -9 $install_pid 2>/dev/null
                break
            fi
        done
        
        # Wait for installation to complete
        wait $install_pid 2>/dev/null
        local exit_code=$?
        
        # Append output to main log
        cat "$tmp_output" >> "$LOG_FILE" 2>/dev/null
        
        # Clear progress line
        printf "\r%-120s\r" " "
        
        # Check result
        if [ $exit_code -eq 0 ] || is_installed "$pkg"; then
            # Try to find installation location
            local install_location=$(which ${pkg%%[[:space:]]*} 2>/dev/null || echo "N/A")
            
            # Show final download size
            if [ -f "$tmp_output" ]; then
                local final_size=$(stat -c%s "$tmp_output" 2>/dev/null || echo 0)
                local final_mb=$((final_size / 1024 / 1024))
                local final_kb=$((final_size / 1024))
                if [ $final_mb -gt 0 ]; then
                    success "$pkg_name installed successfully (${final_mb}MB in ${elapsed}s)"
                elif [ $final_kb -gt 0 ]; then
                    success "$pkg_name installed successfully (${final_kb}KB in ${elapsed}s)"
                else
                    success "$pkg_name installed successfully"
                fi
            else
                success "$pkg_name installed successfully"
            fi
            
            if [ "$install_location" != "N/A" ]; then
                info "   Location: $install_location"
            fi
            
            rm -f "$tmp_output" "$tmp_progress"
            return 0
        elif [ $exit_code -eq 124 ] || [ $elapsed -gt $timeout_seconds ]; then
            error "$pkg_name installation timeout (>${timeout_seconds}s)"
            retry_count=$((retry_count + 1))
        else
            error "$pkg_name installation failed (exit code: $exit_code)"
            retry_count=$((retry_count + 1))
        fi
        
        # Show error details for retry
        if [ $retry_count -lt $max_retries ]; then
            warning "Last 15 lines of error log:"
            tail -15 "$tmp_output" 2>/dev/null | sed 's/^/    /' || true
            sleep 2
        fi
    done
    
    # All retries failed
    rm -f "$tmp_output" "$tmp_progress"
    error "Failed to install $pkg_name after $max_retries attempts"
    log "ERROR: Failed to install $pkg after $max_retries attempts"
    
    # Ask user if they want to continue
    if [ "$AUTO_YES" -eq 0 ]; then
        echo -ne "${YELLOW}Continue installation anyway? [y/N]: ${NC}"
        if [ -t 0 ]; then
            read -r confirm || confirm="n"
        else
            read -r confirm </dev/tty || confirm="n"
        fi
        confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]' | xargs)
        if [[ "$confirm" != "y" && "$confirm" != "yes" ]]; then
            die "Installation aborted by user"
        fi
    fi
    
    return 1
}

# Check if package is installed
is_installed() {
    local pkg=$1
    command -v "$pkg" &>/dev/null
}

#==============================================================================
# Mirror Configuration Functions
#==============================================================================

# Configure package manager mirrors (China optimization)
configure_mirrors() {
    if [ "$IS_CHINA" -eq 0 ]; then
        return 0
    fi
    
    step "Configuring Chinese mirrors for faster download..."
    
    case $OS_TYPE in
        ubuntu|debian)
            # Backup original sources
            cp /etc/apt/sources.list /etc/apt/sources.list.bak.$(date +%Y%m%d)
            
            # Use Aliyun mirror
            cat > /etc/apt/sources.list <<EOF
# LinuxStudio - Aliyun Mirror
deb http://mirrors.aliyun.com/$OS_TYPE/ $(lsb_release -cs) main restricted universe multiverse
deb http://mirrors.aliyun.com/$OS_TYPE/ $(lsb_release -cs)-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/$OS_TYPE/ $(lsb_release -cs)-backports main restricted universe multiverse
deb http://mirrors.aliyun.com/$OS_TYPE/ $(lsb_release -cs)-security main restricted universe multiverse
EOF
            success "APT mirror configured"
            ;;
            
        centos|rhel|rocky|almalinux)
            # Backup original repos
            mkdir -p /etc/yum.repos.d/backup
            mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/ 2>/dev/null || true
            
            # Use Aliyun mirror
            curl -fsSL https://mirrors.aliyun.com/repo/Centos-8.repo -o /etc/yum.repos.d/CentOS-Base.repo
            success "YUM mirror configured"
            ;;
    esac
}

#==============================================================================
# System Optimization Functions
#==============================================================================

# Configure swap if not exists
configure_swap() {
    step "Checking swap configuration..."
    
    if [ $(swapon --show | wc -l) -eq 0 ]; then
        warning "No swap detected, creating 2GB swap file..."
        
        dd if=/dev/zero of=/swapfile bs=1M count=2048 status=progress
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        
        # Add to fstab
        if ! grep -q "/swapfile" /etc/fstab; then
            echo "/swapfile none swap sw 0 0" >> /etc/fstab
        fi
        
        success "Swap configured (2GB)"
    else
        success "Swap already configured"
    fi
}

# Disable SELinux (if exists)
disable_selinux() {
    if [ -f /etc/selinux/config ]; then
        step "Disabling SELinux..."
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        setenforce 0 2>/dev/null || true
        success "SELinux disabled"
    fi
}

# Configure timezone
configure_timezone() {
    step "Configuring timezone..."
    
    if [ "$IS_CHINA" -eq 1 ]; then
        timedatectl set-timezone Asia/Shanghai 2>/dev/null || \
        ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
        success "Timezone set to Asia/Shanghai"
    else
        info "Timezone: $(timedatectl show --property=Timezone --value 2>/dev/null || date +%Z)"
    fi
}

# Optimize system limits
optimize_system() {
    step "Optimizing system limits..."
    
    # Increase file descriptors
    cat >> /etc/security/limits.conf <<EOF
# LinuxStudio Optimization
* soft nofile 65535
* hard nofile 65535
* soft nproc 65535
* hard nproc 65535
EOF
    
    # Sysctl optimization
    cat >> /etc/sysctl.conf <<EOF
# LinuxStudio Network Optimization
net.core.somaxconn = 32768
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65535
EOF
    
    sysctl -p &>/dev/null || true
    success "System optimized"
}

#==============================================================================
# Component Installation Functions
#==============================================================================

# Install mandatory components
install_mandatory_components() {
    echo ""
    print_msg "$CYAN" "╔════════════════════════════════════════════════════════════╗"
    print_msg "$CYAN" "║           Installing Mandatory Components                 ║"
    print_msg "$CYAN" "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    local components=(
        "curl:curl"
        "wget:wget"
        "git:git"
        "vim:vim"
        "tar:tar"
        "unzip:unzip"
        "build-essential:Build Tools (gcc/g++/make)"
        "cmake:CMake"
    )
    
    # Adjust package names for different distros
    case $OS_TYPE in
        fedora|rhel|centos|rocky|almalinux)
            components=(
                "curl:curl"
                "wget:wget"
                "git:git"
                "vim:vim"
                "tar:tar"
                "unzip:unzip"
                "gcc-c++:GCC/G++"
                "make:Make"
                "cmake:CMake"
            )
            ;;
        arch|manjaro)
            components=(
                "curl:curl"
                "wget:wget"
                "git:git"
                "vim:vim"
                "tar:tar"
                "unzip:unzip"
                "base-devel:Build Tools"
                "cmake:CMake"
            )
            ;;
    esac
    
    local total=${#components[@]}
    local current=0
    
    for component in "${components[@]}"; do
        current=$((current + 1))
        IFS=':' read -r pkg name <<< "$component"
        
        # Show progress
        print_msg "$MAGENTA" "[$current/$total] Checking $name..."
        
        # Check if package is installed
        local pkg_check="${pkg%%[[:space:]]*}"
        local is_build_tools=0
        
        # Special handling for build-essential/base-devel
        if [[ "$pkg" == "build-essential" || "$pkg" == "base-devel" ]]; then
            is_build_tools=1
            if command -v gcc &>/dev/null && command -v g++ &>/dev/null && command -v make &>/dev/null; then
                pkg_check="gcc"  # Use gcc as indicator
            else
                pkg_check="__not_installed__"
            fi
        fi
        
        if ! command -v "$pkg_check" &>/dev/null; then
            universal_install "$pkg" "$name"
            
            # Show locations for build tools after installation
            if [ $is_build_tools -eq 1 ]; then
                if command -v gcc &>/dev/null; then
                    info "   GCC: $(which gcc)"
                fi
                if command -v g++ &>/dev/null; then
                    info "   G++: $(which g++)"
                fi
                if command -v make &>/dev/null; then
                    info "   Make: $(which make)"
                fi
            fi
        else
            success "$name already installed"
            
            # Show locations
            if [ $is_build_tools -eq 1 ]; then
                if command -v gcc &>/dev/null; then
                    info "   GCC: $(which gcc)"
                fi
                if command -v g++ &>/dev/null; then
                    info "   G++: $(which g++)"
                fi
                if command -v make &>/dev/null; then
                    info "   Make: $(which make)"
                fi
            else
                local location=$(which "$pkg_check" 2>/dev/null)
                if [ -n "$location" ]; then
                    info "   Location: $location"
                fi
            fi
        fi
        echo ""
    done
    
    echo ""
    success "All mandatory components installed! ✓"
    echo ""
}

# Install framework components
install_framework_components() {
    echo ""
    print_msg "$CYAN" "╔════════════════════════════════════════════════════════════╗"
    print_msg "$CYAN" "║           Installing Framework Components                 ║"
    print_msg "$CYAN" "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    local total=3
    local current=0
    
    # Install vcpkg
    current=$((current + 1))
    print_msg "$MAGENTA" "[$current/$total] Installing vcpkg (C++ Package Manager)..."
    
    if [ ! -d "$INSTALL_PATH/vcpkg" ]; then
        info "Cloning vcpkg repository (this may take a few minutes)..."
        
        # Create a temporary log file for git output
        local git_log="/tmp/vcpkg_clone_$$.log"
        
        # Clone with timeout (5 minutes)
        {
            timeout 300 git clone https://github.com/microsoft/vcpkg.git "$INSTALL_PATH/vcpkg" --depth 1 --progress 2>&1
        } > "$git_log" 2>&1 &
        
        local git_pid=$!
        
        # Show spinner with elapsed time
        local spin='-\|/'
        local i=0
        local elapsed=0
        local start_time=$(date +%s)
        
        while kill -0 $git_pid 2>/dev/null; do
            i=$(( (i+1) %4 ))
            elapsed=$(($(date +%s) - start_time))
            
            # Try to extract progress from git output
            local progress=""
            if [ -f "$git_log" ]; then
                progress=$(tail -1 "$git_log" 2>/dev/null | grep -oP '\d+%' | tail -1 || echo "")
            fi
            
            if [ -n "$progress" ]; then
                printf "\r   ${CYAN}[${spin:$i:1}] Cloning vcpkg... ${elapsed}s | $progress${NC}%-20s" " "
            else
                printf "\r   ${CYAN}[${spin:$i:1}] Cloning vcpkg... ${elapsed}s${NC}%-20s" " "
            fi
            sleep 0.5
            
            # Warning if taking too long
            if [ $elapsed -eq 60 ]; then
                echo ""
                warning "Clone is taking longer than expected. This is normal for slow networks."
                info "Progress will continue..."
            fi
            
            # Force kill if timeout exceeded
            if [ $elapsed -gt 310 ]; then
                kill -9 $git_pid 2>/dev/null
                break
            fi
        done
        
        wait $git_pid 2>/dev/null
        local git_exit=$?
        
        # Append to main log
        cat "$git_log" >> "$LOG_FILE" 2>/dev/null
        rm -f "$git_log"
        
        printf "\r%-100s\r" " "
        
        if [ $git_exit -ne 0 ] || [ ! -d "$INSTALL_PATH/vcpkg/.git" ]; then
            error "Failed to clone vcpkg repository"
            warning "This might be due to network issues or timeout"
            
            # Ask user if they want to retry or skip
            if [ "$AUTO_YES" -eq 0 ]; then
                echo -ne "${YELLOW}Retry vcpkg installation? [Y/n]: ${NC}"
                if [ -t 0 ]; then
                    read -r retry_confirm || retry_confirm="y"
                else
                    read -r retry_confirm </dev/tty || retry_confirm="y"
                fi
                retry_confirm=$(echo "$retry_confirm" | tr '[:upper:]' '[:lower:]' | xargs)
                
                if [[ "$retry_confirm" != "n" && "$retry_confirm" != "no" ]]; then
                    # Clean up failed attempt
                    rm -rf "$INSTALL_PATH/vcpkg"
                    
                    # Retry with full clone (no depth limit)
                    info "Retrying with full clone..."
                    if git clone https://github.com/microsoft/vcpkg.git "$INSTALL_PATH/vcpkg" >> "$LOG_FILE" 2>&1; then
                        success "vcpkg cloned successfully on retry"
                    else
                        error "Failed to clone vcpkg again"
                        warning "Skipping vcpkg installation"
                        return 1
                    fi
                else
                    warning "Skipping vcpkg installation"
                    return 1
                fi
            else
                warning "Skipping vcpkg installation in non-interactive mode"
                return 1
            fi
        fi
        
        # Bootstrap vcpkg
        info "Bootstrapping vcpkg (compiling vcpkg binary)..."
        if "$INSTALL_PATH/vcpkg/bootstrap-vcpkg.sh" -disableMetrics >> "$LOG_FILE" 2>&1; then
            ln -sf "$INSTALL_PATH/vcpkg/vcpkg" "$BIN_PATH/vcpkg"
            
            success "vcpkg installed successfully"
            info "   Location: $INSTALL_PATH/vcpkg"
            info "   Binary: $BIN_PATH/vcpkg"
        else
            error "Failed to bootstrap vcpkg"
            warning "vcpkg may not work correctly"
        fi
    else
        success "vcpkg already installed"
        info "   Location: $INSTALL_PATH/vcpkg"
    fi
    echo ""
    
    # Install ninja
    current=$((current + 1))
    print_msg "$MAGENTA" "[$current/$total] Installing Ninja Build System..."
    
    if ! is_installed ninja; then
        universal_install "ninja-build" "Ninja Build System"
    else
        success "Ninja already installed"
        info "   Location: $(which ninja)"
    fi
    echo ""
    
    # Install ccache
    current=$((current + 1))
    print_msg "$MAGENTA" "[$current/$total] Installing CCache (Compiler Cache)..."
    
    if ! is_installed ccache; then
        universal_install "ccache" "CCache"
    else
        success "CCache already installed"
        info "   Location: $(which ccache)"
    fi
    echo ""
    
    success "All framework components installed! ✓"
    echo ""
}

#==============================================================================
# LinuxStudio Core Installation
#==============================================================================

# Download and install LinuxStudio core binaries
install_linuxstudio_core() {
    echo ""
    print_msg "$CYAN" "╔════════════════════════════════════════════════════════════╗"
    print_msg "$CYAN" "║           Installing LinuxStudio Core                     ║"
    print_msg "$CYAN" "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Create directory structure
    info "Creating directory structure..."
    mkdir -p "$INSTALL_PATH"/{bin,lib,config,data,scripts,web,logs}
    mkdir -p "$CONFIG_PATH"
    mkdir -p "$DATA_PATH"
    
    success "Directory structure created"
    info "   Installation root: $INSTALL_PATH"
    info "   Configuration: $CONFIG_PATH"
    info "   Data: $DATA_PATH"
    echo ""
    
    # Install LinuxStudio CLI
    info "Installing LinuxStudio CLI..."
    
    # Download CLI from repository or use bundled version
    local cli_source="https://raw.githubusercontent.com/happykl-cn/LinuxStudio/main/bin/linuxstudio"
    
    if curl -fsSL "$cli_source" -o "$INSTALL_PATH/bin/linuxstudio" 2>/dev/null; then
        info "Downloaded latest LinuxStudio CLI from repository"
    else
        warning "Cannot download from repository, using bundled version..."
        # Use bundled CLI (inline script)
        # This is the same content as bin/linuxstudio file
        info "Creating LinuxStudio CLI from template..."
        
        # For production, we'll embed the full CLI here
        # For now, download from local or use simplified version
        if [ -f "$(dirname "$0")/bin/linuxstudio" ]; then
            cp "$(dirname "$0")/bin/linuxstudio" "$INSTALL_PATH/bin/linuxstudio"
            info "Copied CLI from installation package"
        else
            # Fallback: create basic CLI
            warning "Using minimal CLI (install from source for full features)"
            cat > "$INSTALL_PATH/bin/linuxstudio" <<'EOFCLI'
#!/bin/bash
# LinuxStudio CLI - Minimal Version
# For full version, reinstall from source
exec /bin/bash /opt/linuxstudio/scripts/cli.sh "$@"
EOFCLI
        fi
    fi
    
    chmod +x "$INSTALL_PATH/bin/linuxstudio"
    ln -sf "$INSTALL_PATH/bin/linuxstudio" "$BIN_PATH/linuxstudio"
    
    # Verify installation
    if [ -x "$BIN_PATH/linuxstudio" ]; then
        success "LinuxStudio CLI installed to $BIN_PATH/linuxstudio"
        info "Run 'linuxstudio --help' to get started"
    else
        warning "CLI installation may have issues, but framework is installed"
    fi
    
    # Create initial configuration
    cat > "$CONFIG_PATH/framework.conf" <<EOF
# LinuxStudio Framework Configuration
version=$LINUXSTUDIO_VERSION
install_path=$INSTALL_PATH
os_type=$OS_TYPE
os_version=$OS_VERSION
arch=$OS_ARCH
install_date=$(date '+%Y-%m-%d %H:%M:%S')
EOF
    
    # Create component registry
    cat > "$CONFIG_PATH/components.json" <<EOF
{
  "version": "1.0",
  "components": []
}
EOF
    
    # Create plugin registry
    cat > "$CONFIG_PATH/plugins.json" <<EOF
{
  "version": "1.0",
  "plugins": []
}
EOF
    
    success "LinuxStudio core installed"
}

# Create systemd service
create_systemd_service() {
    step "Creating systemd service..."
    
    cat > /etc/systemd/system/linuxstudio.service <<EOF
[Unit]
Description=LinuxStudio Framework Service
After=network.target

[Service]
Type=simple
ExecStart=$INSTALL_PATH/bin/linuxstudio daemon
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    # Don't enable by default
    # systemctl enable linuxstudio
    
    success "Systemd service created"
}

#==============================================================================
# Interactive Scene Selection
#==============================================================================

# Multi-select components from list
select_components() {
    local scene_name=$1
    shift
    local -a components=("$@")
    local -a selected=()
    
    echo ""
    print_msg "$CYAN" "═══════════════════════════════════════════════════════════════"
    print_msg "$WHITE" "  $scene_name - Component Selection"
    print_msg "$CYAN" "═══════════════════════════════════════════════════════════════"
    echo ""
    
    # Display components with numbers
    for i in "${!components[@]}"; do
        local num=$((i + 1))
        echo "  $num) ${components[$i]}"
    done
    echo ""
    print_msg "$YELLOW" "  A) Install All (Recommended)"
    print_msg "$WHITE" "  0) Skip this scene"
    echo ""
    
    echo -ne "${YELLOW}Enter your choices (e.g., 1 2 3 or A for all) [A]: ${NC}"
    
    # Read from terminal device directly
    local choice
    if [ -t 0 ]; then
        read -r choice || choice="A"
    else
        read -r choice </dev/tty || choice="A"
    fi
    
    # Trim whitespace
    choice=$(echo "$choice" | xargs)
    
    # Default to All if empty
    if [ -z "$choice" ]; then
        choice="A"
    fi
    
    # Handle selection
    if [[ "$choice" == "A" || "$choice" == "a" ]]; then
        selected=("${components[@]}")
    elif [[ "$choice" == "0" ]]; then
        info "Skipped $scene_name"
        return 1
    else
        # Parse individual selections
        for num in $choice; do
            if [[ "$num" =~ ^[0-9]+$ ]]; then
                local idx=$((num - 1))
                if [ $idx -ge 0 ] && [ $idx -lt ${#components[@]} ]; then
                    selected+=("${components[$idx]}")
                fi
            fi
        done
    fi
    
    # Install selected components
    if [ ${#selected[@]} -gt 0 ]; then
        echo ""
        print_msg "$GREEN" "✓ Selected ${#selected[@]} component(s):"
        for comp in "${selected[@]}"; do
            echo "  • $comp"
        done
        echo ""
        
        if [ "$AUTO_YES" -eq 0 ]; then
            echo -ne "${YELLOW}Confirm installation? [Y/n]: ${NC}"
            local confirm
            if [ -t 0 ]; then
                read -r confirm || confirm="y"
            else
                read -r confirm </dev/tty || confirm="y"
            fi
            confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]' | xargs)
            
            if [[ "$confirm" == "n" || "$confirm" == "no" ]]; then
                info "Installation cancelled"
                return 1
            fi
        fi
        
        # Return selected components via global array
        SELECTED_COMPONENTS=("${selected[@]}")
        return 0
    else
        warning "No valid components selected"
        return 1
    fi
}

# Show scene selection menu
select_scene() {
    # Skip scene selection if requested
    if [ "$SKIP_SCENE" -eq 1 ]; then
        info "Scene selection skipped"
        return 0
    fi
    
    echo ""
    print_msg "$CYAN" "╔═══════════════════════════════════════════════════════════════╗"
    print_msg "$CYAN" "║         🎯 Select Your Development Scenario                   ║"
    print_msg "$CYAN" "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    
    print_msg "$WHITE" "  1️⃣  Web Development"
    echo "      Full-stack web development environment"
    echo ""
    
    print_msg "$WHITE" "  2️⃣  Embedded Systems (ARM/RISC-V)"
    echo "      MCU/SoC development with cross-compilation tools"
    echo ""
    
    print_msg "$WHITE" "  3️⃣  Robotics & Automation"
    echo "      Robot control, ROS2, motion planning, perception"
    echo ""
    
    print_msg "$WHITE" "  4️⃣  AI/ML Development"
    echo "      Deep learning, computer vision, data science"
    echo ""
    
    print_msg "$WHITE" "  5️⃣  Game Development"
    echo "      Game engines, graphics libraries, asset tools"
echo ""
    
    print_msg "$WHITE" "  6️⃣  Cloud Native / DevOps"
    echo "      Container orchestration, IaC, CI/CD pipelines"
echo ""

    print_msg "$WHITE" "  7️⃣  Cybersecurity / Penetration Testing"
    echo "      Security auditing, penetration testing, forensics"
    echo ""
    
    print_msg "$WHITE" "  8️⃣  Blockchain Development"
    echo "      Smart contracts, DApp development, Web3 tools"
    echo ""
    
    print_msg "$WHITE" "  9️⃣  IoT Development"
    echo "      IoT platforms, MQTT, edge computing"
    echo ""
    
    print_msg "$WHITE" "  0️⃣  Skip (Install later with 'linuxstudio scene apply')"
    echo ""

    echo -ne "${YELLOW}Your choice [0-9]: ${NC}"
    
    # Read from terminal device directly
    if [ -t 0 ]; then
        read -r scene_choice || scene_choice="0"
    else
        read -r scene_choice </dev/tty || scene_choice="0"
    fi
    
    # Trim whitespace
    scene_choice=$(echo "$scene_choice" | xargs)
    
    case $scene_choice in
        1) install_web_scene ;;
        2) install_embedded_scene ;;
        3) install_robotics_scene ;;
        4) install_ai_scene ;;
        5) install_game_scene ;;
        6) install_devops_scene ;;
        7) install_security_scene ;;
        8) install_blockchain_scene ;;
        9) install_iot_scene ;;
        0) info "Skipped scene installation. Use 'linuxstudio scene apply <name>' later." ;;
        *) warning "Invalid choice, skipping scene installation" ;;
    esac
}

# Install Web Development scene
install_web_scene() {
    step "Web Development Scene"
    echo ""
    
    local -a components=(
        "Nginx - High-performance web server"
        "Apache - Popular web server (alternative to Nginx)"
        "PHP 8.x + PHP-FPM - Server-side scripting"
        "Java (OpenJDK) - Java runtime environment"
        "Tomcat - Java application server"
        "Spring Boot CLI - Spring framework tools"
        "Maven - Java project management"
        "Gradle - Build automation tool"
        "MySQL 8.x - Relational database"
        "PostgreSQL - Advanced relational database"
        "Redis - In-memory data store & cache"
        "Memcached - Distributed memory caching"
        "Node.js + npm - JavaScript runtime"
        "Composer - PHP dependency manager"
        "Certbot - Let's Encrypt SSL certificates"
        "ModSecurity (WAF) - Web application firewall"
        "Fail2Ban - Intrusion prevention system"
        "Logrotate - Log rotation utility"
        "ELK Stack - Elasticsearch, Logstash, Kibana"
        "Prometheus - Monitoring & alerting"
        "Grafana - Metrics visualization"
        "Supervisor - Process control system"
    )
    
    info "💡 Recommended PHP Stack: Nginx + PHP + MySQL + Redis + Node.js"
    info "💡 Recommended Java Stack: Nginx + Java + Tomcat + MySQL + Redis"
    info "💡 Recommended System: ModSecurity + Fail2Ban + Prometheus + Grafana"
    
    if select_components "Web Development" "${components[@]}"; then
        for comp in "${SELECTED_COMPONENTS[@]}"; do
            case "$comp" in
                "Nginx"*) universal_install "nginx" "Nginx" ;;
                "Apache"*) universal_install "apache2" "Apache" ;;
                "PHP"*) universal_install "php php-fpm php-mysql php-redis php-xml php-mbstring php-curl" "PHP" ;;
                "Java"*) install_java ;;
                "Tomcat"*) install_tomcat ;;
                "Spring Boot"*) install_spring_boot_cli ;;
                "Maven"*) universal_install "maven" "Maven" ;;
                "Gradle"*) install_gradle ;;
                "MySQL"*) universal_install "mysql-server" "MySQL" ;;
                "PostgreSQL"*) universal_install "postgresql" "PostgreSQL" ;;
                "Redis"*) universal_install "redis-server" "Redis" ;;
                "Memcached"*) universal_install "memcached" "Memcached" ;;
                "Node.js"*) universal_install "nodejs npm" "Node.js" ;;
                "Composer"*) install_composer ;;
                "Certbot"*) universal_install "certbot" "Certbot" ;;
                "ModSecurity"*) install_modsecurity ;;
                "Fail2Ban"*) universal_install "fail2ban" "Fail2Ban" ;;
                "Logrotate"*) universal_install "logrotate" "Logrotate" ;;
                "ELK Stack"*) install_elk_stack ;;
                "Prometheus"*) install_prometheus ;;
                "Grafana"*) install_grafana ;;
                "Supervisor"*) universal_install "supervisor" "Supervisor" ;;
            esac
        done
        success "Web Development scene installed"
        info "💡 Next steps: Run 'linuxstudio component list' to see installed components"
    fi
}

# Helper functions for Web components
install_composer() {
    info "Installing Composer..."
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer || true
}

install_java() {
    info "Installing OpenJDK..."
    universal_install "openjdk-17-jdk openjdk-17-jre" "Java OpenJDK 17"
    info "Java version:"
    java -version 2>&1 | head -1 || true
}

install_tomcat() {
    info "Installing Apache Tomcat..."
    universal_install "tomcat9" "Tomcat 9"
    info "💡 Tomcat config: /etc/tomcat9/"
    info "💡 Start Tomcat: sudo systemctl start tomcat9"
}

install_spring_boot_cli() {
    info "Installing Spring Boot CLI..."
    curl -s "https://get.sdkman.io" | bash || true
    source "$HOME/.sdkman/bin/sdkman-init.sh" 2>/dev/null || true
    sdk install springboot || true
}

install_gradle() {
    info "Installing Gradle..."
    curl -s "https://get.sdkman.io" | bash || true
    source "$HOME/.sdkman/bin/sdkman-init.sh" 2>/dev/null || true
    sdk install gradle || true
}

install_modsecurity() {
    info "Installing ModSecurity WAF..."
    universal_install "libmodsecurity3 modsecurity-crs" "ModSecurity"
    info "💡 ModSecurity config: /etc/modsecurity/"
    info "💡 Enable OWASP Core Rule Set for protection"
}

install_elk_stack() {
    info "Installing ELK Stack..."
    info "ELK Stack is recommended to install via Docker or APT repository"
    info "Guide: https://www.elastic.co/guide/en/elastic-stack/current/installing-elastic-stack.html"
}

install_prometheus() {
    info "Installing Prometheus..."
    info "Downloading Prometheus latest version..."
    wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz -O /tmp/prometheus.tar.gz || true
    tar -xzf /tmp/prometheus.tar.gz -C /opt/ || true
    mv /opt/prometheus-* /opt/prometheus 2>/dev/null || true
    info "💡 Prometheus installed to /opt/prometheus"
    info "💡 Start: /opt/prometheus/prometheus --config.file=/opt/prometheus/prometheus.yml"
}

install_grafana() {
    info "Installing Grafana..."
    universal_install "grafana" "Grafana" || {
        # If package not found, install from official repository
        wget -q -O - https://packages.grafana.com/gpg.key | apt-key add - || true
        echo "deb https://packages.grafana.com/oss/deb stable main" | tee /etc/apt/sources.list.d/grafana.list || true
        apt-get update && universal_install "grafana" "Grafana" || true
    }
    info "💡 Start Grafana: sudo systemctl start grafana-server"
    info "💡 Access: http://localhost:3000 (admin/admin)"
}

# Install Embedded Development scene
install_embedded_scene() {
    step "Embedded Systems Development Scene"
    echo ""
    
    local -a components=(
        "ARM GCC Toolchain - ARM Cortex-M/A cross-compiler"
        "RISC-V GCC Toolchain - RISC-V cross-compiler"
        "OpenOCD - On-chip debugger (JTAG/SWD)"
        "GDB Multiarch - Multi-architecture debugger"
        "Minicom - Serial terminal emulator"
        "PuTTY/Screen - Alternative serial tools"
        "I2C Tools - I2C bus utilities"
        "SPI Tools - SPI bus utilities"
        "ST-Link Tools - STMicroelectronics programmer"
        "J-Link Tools - SEGGER J-Link utilities"
        "Platform.io - Embedded development platform"
        "Arduino CLI - Arduino command-line tools"
    )
    
    info "💡 Recommended: ARM GCC + OpenOCD + GDB + Minicom + I2C/SPI Tools"
    
    if select_components "Embedded Systems" "${components[@]}"; then
        for comp in "${SELECTED_COMPONENTS[@]}"; do
            case "$comp" in
                "ARM GCC"*) universal_install "gcc-arm-none-eabi" "ARM GCC Toolchain" ;;
                "RISC-V GCC"*) universal_install "gcc-riscv64-unknown-elf" "RISC-V GCC" ;;
                "OpenOCD"*) universal_install "openocd" "OpenOCD" ;;
                "GDB Multiarch"*) universal_install "gdb-multiarch" "GDB Multiarch" ;;
                "Minicom"*) universal_install "minicom" "Minicom" ;;
                "PuTTY"*) universal_install "screen picocom" "Serial Tools" ;;
                "I2C Tools"*) universal_install "i2c-tools libi2c-dev" "I2C Tools" ;;
                "SPI Tools"*) universal_install "spitools" "SPI Tools" ;;
                "ST-Link"*) universal_install "stlink-tools" "ST-Link Tools" ;;
                "Platform.io"*) install_platformio ;;
                "Arduino CLI"*) install_arduino_cli ;;
            esac
        done
        success "Embedded Systems scene installed"
        info "💡 Next: 'linuxstudio plugin install robot-arm' for robotics support"
    fi
}

# Helper functions for embedded tools
install_platformio() {
    info "Installing Platform.io..."
    pip3 install -U platformio || true
}

install_arduino_cli() {
    info "Installing Arduino CLI..."
    curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh || true
}

# Install Robotics & Automation scene
install_robotics_scene() {
    step "Robotics & Automation Scene"
    echo ""
    
    local -a components=(
        "ROS2 Humble - Robot Operating System 2"
        "MoveIt2 - Motion planning framework"
        "Gazebo - 3D robot simulator"
        "RViz2 - 3D visualization tool"
        "Python3 + NumPy - Scripting & mathematics"
        "OpenCV - Computer vision library"
        "PCL - Point Cloud Library"
        "URDF Tools - Robot description utilities"
        "CAN Utils - CAN bus tools (for robot controllers)"
        "Modbus Tools - Industrial communication"
        "EtherCAT - Real-time Ethernet protocol"
        "Robot Arm SDK - Manipulator control libraries"
    )
    
    info "💡 Recommended: ROS2 + MoveIt2 + Gazebo + OpenCV + Robot Arm SDK"
    
    if select_components "Robotics & Automation" "${components[@]}"; then
        for comp in "${SELECTED_COMPONENTS[@]}"; do
            case "$comp" in
                "ROS2"*) install_ros2 ;;
                "MoveIt2"*) info "MoveIt2 will be installed with ROS2" ;;
                "Gazebo"*) universal_install "gazebo" "Gazebo" ;;
                "RViz2"*) info "RViz2 included with ROS2" ;;
                "Python3"*) universal_install "python3 python3-pip python3-numpy" "Python3" ;;
                "OpenCV"*) universal_install "python3-opencv libopencv-dev" "OpenCV" ;;
                "PCL"*) universal_install "libpcl-dev" "Point Cloud Library" ;;
                "URDF"*) universal_install "liburdfdom-dev" "URDF Tools" ;;
                "CAN Utils"*) universal_install "can-utils" "CAN Utils" ;;
                "Modbus"*) universal_install "libmodbus-dev" "Modbus Tools" ;;
                "EtherCAT"*) info "EtherCAT master requires kernel module (see docs)" ;;
                "Robot Arm SDK"*) info "Robot Arm SDK available via 'linuxstudio plugin install robot-arm'" ;;
            esac
        done
        success "Robotics & Automation scene installed"
        info "💡 Source ROS2: source /opt/ros/humble/setup.bash"
    fi
}

# Install ROS2
install_ros2() {
    info "Installing ROS2 Humble..."
    # Add ROS2 repository and install
    universal_install "software-properties-common" "Software Properties"
    info "ROS2 installation requires additional steps. Run: linuxstudio plugin install ros2"
}

# Install AI/ML Development scene
install_ai_scene() {
    step "AI/ML Development Scene"
    echo ""
    
    local -a components=(
        "Python3 + pip - Python environment"
        "Jupyter Notebook - Interactive notebooks"
        "NumPy + SciPy - Scientific computing"
        "Pandas - Data analysis"
        "Matplotlib + Seaborn - Data visualization"
        "Scikit-learn - Machine learning library"
        "TensorFlow - Deep learning framework"
        "PyTorch - Deep learning framework"
        "OpenCV - Computer vision"
        "CUDA Toolkit - NVIDIA GPU support"
        "cuDNN - Deep learning GPU acceleration"
        "Anaconda - Data science platform"
    )
    
    info "💡 Recommended: Python3 + Jupyter + NumPy + Pandas + TensorFlow/PyTorch"
    
    if select_components "AI/ML Development" "${components[@]}"; then
        for comp in "${SELECTED_COMPONENTS[@]}"; do
            case "$comp" in
                "Python3"*) universal_install "python3 python3-pip python3-dev" "Python3" ;;
                "Jupyter"*) pip3 install jupyter || true ;;
                "NumPy"*) pip3 install numpy scipy || true ;;
                "Pandas"*) pip3 install pandas || true ;;
                "Matplotlib"*) pip3 install matplotlib seaborn || true ;;
                "Scikit-learn"*) pip3 install scikit-learn || true ;;
                "TensorFlow"*) pip3 install tensorflow || true ;;
                "PyTorch"*) pip3 install torch torchvision torchaudio || true ;;
                "OpenCV"*) universal_install "python3-opencv" "OpenCV" ;;
                "CUDA"*) install_cuda ;;
                "cuDNN"*) info "cuDNN installed with CUDA toolkit" ;;
                "Anaconda"*) install_anaconda ;;
            esac
        done
        success "AI/ML Development scene installed"
        info "💡 Activate Jupyter: jupyter notebook"
    fi
}

# Install CUDA
install_cuda() {
    if lspci | grep -i nvidia >/dev/null 2>&1; then
        info "NVIDIA GPU detected. Installing CUDA toolkit..."
        info "CUDA installation requires manual steps. See: https://developer.nvidia.com/cuda-downloads"
    else
        warning "No NVIDIA GPU detected. Skipping CUDA installation."
    fi
}

# Install Anaconda
install_anaconda() {
    info "Installing Anaconda..."
    info "Download from: https://www.anaconda.com/download"
    info "Or use Miniconda: wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
}

# Install Game Development scene
install_game_scene() {
    step "Game Development Scene"
    echo ""
    
    local -a components=(
        "SDL2 - Simple DirectMedia Layer"
        "OpenGL - Graphics API"
        "GLFW - OpenGL framework"
        "GLEW - OpenGL Extension Wrangler"
        "Vulkan SDK - Next-gen graphics API"
        "Godot Engine - Open-source game engine"
        "Unity Editor - Popular game engine"
        "Unreal Engine - AAA game engine"
        "Blender - 3D modeling & animation"
        "Aseprite - Pixel art editor"
        "FMOD - Audio middleware"
    )
    
    info "💡 Recommended: SDL2 + OpenGL + Godot/Unity + Blender"
    
    if select_components "Game Development" "${components[@]}"; then
        for comp in "${SELECTED_COMPONENTS[@]}"; do
            case "$comp" in
                "SDL2"*) universal_install "libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev" "SDL2" ;;
                "OpenGL"*) universal_install "mesa-utils libglu1-mesa-dev freeglut3-dev" "OpenGL" ;;
                "GLFW"*) universal_install "libglfw3-dev" "GLFW" ;;
                "GLEW"*) universal_install "libglew-dev" "GLEW" ;;
                "Vulkan"*) universal_install "vulkan-tools libvulkan-dev" "Vulkan" ;;
                "Godot"*) universal_install "godot3" "Godot Engine" ;;
                "Unity"*) info "Download Unity Hub from: https://unity.com/download" ;;
                "Unreal"*) info "Download Unreal from: https://www.unrealengine.com" ;;
                "Blender"*) universal_install "blender" "Blender" ;;
                "Aseprite"*) info "Aseprite: https://www.aseprite.org" ;;
                "FMOD"*) info "FMOD: https://www.fmod.com/download" ;;
            esac
        done
        success "Game Development scene installed"
    fi
}

# Install Cloud Native / DevOps scene
install_devops_scene() {
    step "Cloud Native / DevOps Scene"
    echo ""
    
    local -a components=(
        "Docker - Container runtime"
        "Docker Compose - Multi-container orchestration"
        "Kubernetes (kubectl) - Container orchestration"
        "Helm - Kubernetes package manager"
        "Terraform - Infrastructure as Code"
        "Ansible - Configuration management"
        "Jenkins - CI/CD automation"
        "GitLab Runner - GitLab CI/CD"
        "GitHub Actions Runner - GitHub CI/CD"
        "Prometheus - Monitoring & alerting system"
        "Grafana - Metrics visualization dashboard"
        "Node Exporter - Hardware & OS metrics"
        "cAdvisor - Container metrics collector"
        "Alertmanager - Alert handling & routing"
        "ELK Stack - Centralized logging (Elasticsearch, Logstash, Kibana)"
        "Loki + Promtail - Log aggregation system"
        "Fluentd - Unified logging layer"
        "Nginx - Reverse proxy & load balancer"
        "Traefik - Cloud-native edge router"
        "HAProxy - High availability load balancer"
        "Cron - Job scheduling daemon"
        "Supervisor - Process control system"
        "systemd-cron - Systemd timer units"
        "Zabbix - Enterprise monitoring solution"
        "Netdata - Real-time performance monitoring"
        "Portainer - Docker management UI"
    )
    
    info "💡 Recommended Container Stack: Docker + Kubernetes + Helm + Terraform"
    info "💡 Recommended Monitoring Stack: Prometheus + Grafana + Node Exporter + Alertmanager"
    info "💡 Recommended Logging Stack: ELK Stack / Loki + Promtail"
    
    if select_components "Cloud Native / DevOps" "${components[@]}"; then
        for comp in "${SELECTED_COMPONENTS[@]}"; do
            case "$comp" in
                "Docker -"*) install_docker ;;
                "Docker Compose"*) install_docker_compose ;;
                "Kubernetes"*) install_kubectl ;;
                "Helm"*) install_helm ;;
                "Terraform"*) install_terraform ;;
                "Ansible"*) universal_install "ansible" "Ansible" ;;
                "Jenkins"*) install_jenkins ;;
                "GitLab"*) universal_install "gitlab-runner" "GitLab Runner" ;;
                "GitHub Actions"*) install_github_runner ;;
                "Prometheus"*) install_prometheus ;;
                "Grafana"*) install_grafana ;;
                "Node Exporter"*) install_node_exporter ;;
                "cAdvisor"*) install_cadvisor ;;
                "Alertmanager"*) install_alertmanager ;;
                "ELK Stack"*) install_elk_stack ;;
                "Loki"*) install_loki ;;
                "Fluentd"*) install_fluentd ;;
                "Nginx"*) universal_install "nginx" "Nginx" ;;
                "Traefik"*) install_traefik ;;
                "HAProxy"*) universal_install "haproxy" "HAProxy" ;;
                "Cron"*) universal_install "cron" "Cron" ;;
                "Supervisor"*) universal_install "supervisor" "Supervisor" ;;
                "systemd-cron"*) universal_install "systemd-cron" "systemd-cron" ;;
                "Zabbix"*) install_zabbix ;;
                "Netdata"*) install_netdata ;;
                "Portainer"*) install_portainer ;;
            esac
        done
        success "Cloud Native / DevOps scene installed"
        info "💡 Start Docker: sudo systemctl start docker"
        info "💡 Access Grafana: http://localhost:3000"
        info "💡 Access Prometheus: http://localhost:9090"
    fi
}

# DevOps & System Components Installation Functions

# Docker installation
install_docker() {
    info "Installing Docker..."
    curl -fsSL https://get.docker.com | sh || true
    usermod -aG docker $SUDO_USER 2>/dev/null || true
    systemctl enable docker || true
    info "💡 Start Docker: sudo systemctl start docker"
    info "💡 Run without sudo: logout and login again"
}

install_docker_compose() {
    info "Installing Docker Compose..."
    pip3 install docker-compose || true
    info "💡 Usage: docker-compose up -d"
}

install_kubectl() {
    info "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" || true
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl 2>/dev/null || true
    rm -f kubectl
    info "💡 Configure: kubectl config set-context"
}

install_helm() {
    info "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash || true
    info "💡 Usage: helm install <release> <chart>"
}

install_terraform() {
    info "Installing Terraform..."
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg || true
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list || true
    apt-get update && universal_install "terraform" "Terraform" || true
    info "💡 Usage: terraform init && terraform plan"
}

install_jenkins() {
    info "Installing Jenkins..."
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add - || true
    echo "deb https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list || true
    apt-get update && universal_install "jenkins" "Jenkins" || true
    info "💡 Access: http://localhost:8080"
    info "💡 Initial password: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
}

install_github_runner() {
    info "Installing GitHub Actions Runner..."
    info "Download from: https://github.com/actions/runner/releases"
    info "Setup guide: https://docs.github.com/en/actions/hosting-your-own-runners"
}

install_node_exporter() {
    info "Installing Prometheus Node Exporter..."
    wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz -O /tmp/node_exporter.tar.gz || true
    tar -xzf /tmp/node_exporter.tar.gz -C /opt/ || true
    mv /opt/node_exporter-* /opt/node_exporter 2>/dev/null || true
    
    # Create systemd service
    cat > /etc/systemd/system/node_exporter.service <<'EOF'
[Unit]
Description=Node Exporter
After=network.target

[Service]
Type=simple
ExecStart=/opt/node_exporter/node_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable node_exporter || true
    info "💡 Start: sudo systemctl start node_exporter"
    info "💡 Metrics: http://localhost:9100/metrics"
}

install_cadvisor() {
    info "Installing cAdvisor..."
    info "Running cAdvisor via Docker (recommended):"
    echo "docker run -d --name=cadvisor --restart=always \\"
    echo "  -p 8080:8080 \\"
    echo "  -v /:/rootfs:ro \\"
    echo "  -v /var/run:/var/run:ro \\"
    echo "  -v /sys:/sys:ro \\"
    echo "  -v /var/lib/docker/:/var/lib/docker:ro \\"
    echo "  gcr.io/cadvisor/cadvisor:latest"
    info "💡 Access: http://localhost:8080"
}

install_alertmanager() {
    info "Installing Alertmanager..."
    wget https://github.com/prometheus/alertmanager/releases/download/v0.26.0/alertmanager-0.26.0.linux-amd64.tar.gz -O /tmp/alertmanager.tar.gz || true
    tar -xzf /tmp/alertmanager.tar.gz -C /opt/ || true
    mv /opt/alertmanager-* /opt/alertmanager 2>/dev/null || true
    info "💡 Alertmanager installed to /opt/alertmanager"
    info "💡 Config: /opt/alertmanager/alertmanager.yml"
}

install_loki() {
    info "Installing Loki + Promtail..."
    info "Recommended: Install via Docker"
    info "Docker Compose example: https://grafana.com/docs/loki/latest/installation/docker/"
}

install_fluentd() {
    info "Installing Fluentd..."
    curl -fsSL https://toolbelt.treasuredata.com/sh/install-ubuntu-focal-td-agent4.sh | sh || true
    info "💡 Config: /etc/td-agent/td-agent.conf"
    info "💡 Start: sudo systemctl start td-agent"
}

install_traefik() {
    info "Installing Traefik..."
    info "Recommended: Run via Docker"
    echo "docker run -d -p 80:80 -p 8080:8080 \\"
    echo "  -v /var/run/docker.sock:/var/run/docker.sock \\"
    echo "  traefik:v2.10 \\"
    echo "  --api.insecure=true --providers.docker"
    info "💡 Dashboard: http://localhost:8080"
}

install_zabbix() {
    info "Installing Zabbix..."
    wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb -O /tmp/zabbix-release.deb || true
    dpkg -i /tmp/zabbix-release.deb || true
    apt-get update || true
    universal_install "zabbix-server-mysql zabbix-frontend-php zabbix-agent" "Zabbix" || true
    info "💡 Configure database and start services"
    info "💡 Access: http://localhost/zabbix"
}

install_netdata() {
    info "Installing Netdata..."
    curl https://my-netdata.io/kickstart.sh | bash || true
    info "💡 Access: http://localhost:19999"
    info "💡 Real-time performance monitoring dashboard"
}

install_portainer() {
    info "Installing Portainer..."
    docker volume create portainer_data 2>/dev/null || true
    docker run -d -p 9000:9000 -p 9443:9443 --name=portainer --restart=always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer_data:/data \
        portainer/portainer-ce:latest 2>/dev/null || {
        info "Docker required for Portainer"
        info "Install Docker first, then run:"
        echo "docker run -d -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer-ce:latest"
    }
    info "💡 Access: http://localhost:9000"
}

# Install Cybersecurity / Penetration Testing scene
install_security_scene() {
    step "Cybersecurity / Penetration Testing Scene"
    echo ""
    
    local -a components=(
        "Nmap - Network scanner"
        "Wireshark - Network protocol analyzer"
        "Metasploit - Penetration testing framework"
        "Burp Suite - Web security testing"
        "John the Ripper - Password cracker"
        "Hashcat - Advanced password recovery"
        "Aircrack-ng - Wireless security tools"
        "SQLMap - SQL injection tool"
        "Nikto - Web server scanner"
        "Hydra - Network logon cracker"
        "OWASP ZAP - Web app security scanner"
        "Volatility - Memory forensics"
    )
    
    info "💡 Recommended: Nmap + Wireshark + Metasploit + Burp Suite + SQLMap"
    warning "⚠️  Use these tools responsibly and only on authorized systems!"
    
    if select_components "Cybersecurity" "${components[@]}"; then
        for comp in "${SELECTED_COMPONENTS[@]}"; do
            case "$comp" in
                "Nmap"*) universal_install "nmap" "Nmap" ;;
                "Wireshark"*) universal_install "wireshark" "Wireshark" ;;
                "Metasploit"*) install_metasploit ;;
                "Burp Suite"*) info "Burp Suite: https://portswigger.net/burp/communitydownload" ;;
                "John"*) universal_install "john" "John the Ripper" ;;
                "Hashcat"*) universal_install "hashcat" "Hashcat" ;;
                "Aircrack"*) universal_install "aircrack-ng" "Aircrack-ng" ;;
                "SQLMap"*) universal_install "sqlmap" "SQLMap" ;;
                "Nikto"*) universal_install "nikto" "Nikto" ;;
                "Hydra"*) universal_install "hydra" "Hydra" ;;
                "OWASP"*) info "OWASP ZAP: https://www.zaproxy.org/download/" ;;
                "Volatility"*) pip3 install volatility3 || true ;;
            esac
        done
        success "Cybersecurity scene installed"
        warning "⚠️  Always obtain proper authorization before testing!"
    fi
}

install_metasploit() {
    info "Installing Metasploit Framework..."
    curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall || true
    chmod 755 msfinstall || true
    ./msfinstall || true
}

# Install Blockchain Development scene
install_blockchain_scene() {
    step "Blockchain Development Scene"
    echo ""
    
    local -a components=(
        "Node.js + npm - JavaScript runtime"
        "Hardhat - Ethereum development environment"
        "Truffle - Smart contract framework"
        "Ganache - Personal blockchain"
        "Web3.js - Ethereum JavaScript API"
        "Ethers.js - Ethereum library"
        "Solidity Compiler - Smart contract language"
        "Go-Ethereum (Geth) - Ethereum client"
        "IPFS - Distributed file system"
        "Rust + Solana CLI - Solana development"
        "Anchor - Solana framework"
    )
    
    info "💡 Recommended: Node.js + Hardhat + Web3.js + Solidity + IPFS"
    
    if select_components "Blockchain Development" "${components[@]}"; then
        for comp in "${SELECTED_COMPONENTS[@]}"; do
            case "$comp" in
                "Node.js"*) universal_install "nodejs npm" "Node.js" ;;
                "Hardhat"*) npm install -g hardhat || true ;;
                "Truffle"*) npm install -g truffle || true ;;
                "Ganache"*) npm install -g ganache || true ;;
                "Web3.js"*) npm install -g web3 || true ;;
                "Ethers.js"*) npm install -g ethers || true ;;
                "Solidity"*) npm install -g solc || true ;;
                "Go-Ethereum"*) universal_install "geth" "Geth" ;;
                "IPFS"*) install_ipfs ;;
                "Rust"*) curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y || true ;;
                "Anchor"*) info "Anchor: cargo install --git https://github.com/coral-xyz/anchor avm --locked" ;;
            esac
        done
        success "Blockchain Development scene installed"
        info "💡 Start with: npx hardhat init"
    fi
}

install_ipfs() {
    info "Installing IPFS..."
    wget https://dist.ipfs.tech/kubo/v0.24.0/kubo_v0.24.0_linux-amd64.tar.gz || true
    tar -xvzf kubo_v0.24.0_linux-amd64.tar.gz || true
    cd kubo && bash install.sh || true
    cd .. && rm -rf kubo* || true
}

# Install IoT Development scene
install_iot_scene() {
    step "IoT Development Scene"
    echo ""
    
    local -a components=(
        "MQTT Broker (Mosquitto) - Message broker"
        "MQTT Clients - Publishing/subscribing tools"
        "Node-RED - Flow-based programming"
        "InfluxDB - Time-series database"
        "Grafana - IoT data visualization"
        "Python3 + Paho MQTT - MQTT library"
        "Arduino CLI - Arduino development"
        "Platform.io - IoT development platform"
        "Home Assistant - Home automation"
        "Zigbee2MQTT - Zigbee to MQTT bridge"
        "ESPHome - ESP32/ESP8266 firmware"
    )
    
    info "💡 Recommended: Mosquitto + Node-RED + InfluxDB + Grafana + Python MQTT"
    
    if select_components "IoT Development" "${components[@]}"; then
        for comp in "${SELECTED_COMPONENTS[@]}"; do
            case "$comp" in
                "MQTT Broker"*) universal_install "mosquitto" "Mosquitto" ;;
                "MQTT Clients"*) universal_install "mosquitto-clients" "MQTT Clients" ;;
                "Node-RED"*) npm install -g --unsafe-perm node-red || true ;;
                "InfluxDB"*) install_influxdb ;;
                "Grafana"*) universal_install "grafana" "Grafana" ;;
                "Python3"*) pip3 install paho-mqtt || true ;;
                "Arduino"*) install_arduino_cli ;;
                "Platform.io"*) install_platformio ;;
                "Home Assistant"*) info "Home Assistant: https://www.home-assistant.io/installation/" ;;
                "Zigbee2MQTT"*) info "Zigbee2MQTT via Docker recommended" ;;
                "ESPHome"*) pip3 install esphome || true ;;
            esac
        done
        success "IoT Development scene installed"
        info "💡 Start Mosquitto: sudo systemctl start mosquitto"
    fi
}

install_influxdb() {
    info "Installing InfluxDB..."
    wget -q https://repos.influxdata.com/influxdata-archive_compat.key || true
    echo '393e8779c89ac8d958f81f942f9ad7fb82a25e133faddaf92e15b16e6ac9ce4c influxdata-archive_compat.key' | sha256sum -c && cat influxdata-archive_compat.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg > /dev/null || true
    echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' | tee /etc/apt/sources.list.d/influxdata.list || true
    apt-get update && apt-get install -y influxdb2 || true
}

#==============================================================================
# Main Installation Flow
#==============================================================================

# Print welcome banner
print_banner() {
    clear
    
    # Try to use figlet if available
    if command -v figlet &>/dev/null; then
        figlet -f standard "LinuxStudio" 2>/dev/null || echo "LinuxStudio"
    else
        cat <<'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   ██╗     ██╗███╗   ██╗██╗   ██╗██╗  ██╗                    ║
║   ██║     ██║████╗  ██║██║   ██║╚██╗██╔╝                    ║
║   ██║     ██║██╔██╗ ██║██║   ██║ ╚███╔╝                     ║
║   ██║     ██║██║╚██╗██║██║   ██║ ██╔██╗                     ║
║   ███████╗██║██║ ╚████║╚██████╔╝██╔╝ ██╗                    ║
║   ╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝                    ║
║                                                               ║
║        ███████╗████████╗██╗   ██╗██████╗ ██╗ ██████╗        ║
║        ██╔════╝╚══██╔══╝██║   ██║██╔══██╗██║██╔═══██╗       ║
║        ███████╗   ██║   ██║   ██║██║  ██║██║██║   ██║       ║
║        ╚════██║   ██║   ██║   ██║██║  ██║██║██║   ██║       ║
║        ███████║   ██║   ╚██████╔╝██████╔╝██║╚██████╔╝       ║
║        ╚══════╝   ╚═╝    ╚═════╝ ╚═════╝ ╚═╝ ╚═════╝        ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    fi
    
    echo ""
    print_msg "$CYAN" "        High-Performance Linux Environment Manager"
    print_msg "$CYAN" "                    Version $LINUXSTUDIO_VERSION"
    print_msg "$CYAN" "              https://linuxstudio.org"
    print_msg "$CYAN" "            Presented by Dino Studio"
    echo ""
}

# Confirm installation
confirm_installation() {
    # Skip confirmation if auto-yes mode
    if [ "$AUTO_YES" -eq 1 ]; then
        info "Auto-yes mode enabled, skipping confirmation"
        return 0
    fi
    
    echo ""
    print_msg "$YELLOW" "╔════════════════════════════════════════════════════════════╗"
    print_msg "$YELLOW" "║                    IMPORTANT NOTICE                        ║"
    print_msg "$YELLOW" "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    warning "This script will install LinuxStudio Framework on your system"
    warning "It is recommended to run this on a CLEAN Linux installation"
    warning "Some system configurations will be modified:"
    echo ""
    echo "  • Package manager mirrors (if in China)"
    echo "  • System limits and kernel parameters"
    echo "  • Swap configuration"
    echo "  • Timezone settings"
    echo ""
    
    print_msg "$RED" "⚠️  Please make sure you have:"
    echo "  ✓ Root/sudo privileges"
    echo "  ✓ Stable internet connection"
    echo "  ✓ Backup of important data (if needed)"
    echo ""
    
    # Use simple prompt without color codes for better compatibility
    echo -ne "${YELLOW}Do you want to continue? [y/N]: ${NC}"
    
    # Read from terminal device directly (important for piped installation)
    if [ -t 0 ]; then
        # stdin is a terminal
        read -r confirm
    else
        # stdin is not a terminal (e.g., piped from curl)
        read -r confirm </dev/tty || {
            echo ""
            error "Cannot read from terminal"
            info "For non-interactive installation, use: bash $0 -y"
            exit 1
        }
    fi
    
    # Trim whitespace and convert to lowercase
    confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]' | xargs)
    
    if [[ "$confirm" != "y" && "$confirm" != "yes" ]]; then
        print_msg "$CYAN" "Installation cancelled. Goodbye!"
        exit 0
    fi
    
    echo ""
    info "Starting installation in 5 seconds... (Press Ctrl+C to cancel)"
    
    for i in {5..1}; do
        case $i in
            5|4) color="$GREEN" ;;
            3|2) color="$YELLOW" ;;
            *) color="$RED" ;;
        esac
        printf "\r${color}Countdown: %d seconds...${NC}" $i
    sleep 1
done

    printf "\r${CYAN}Starting installation now...${NC}\n"
    echo ""
}

# Report installation to server
report_installation() {
    step "Reporting installation statistics..."
    
    # Send anonymous statistics (no personal data)
    curl -sS --connect-timeout 5 -m 10 \
        -X POST "https://io.linuxstudio.org/api/install" \
        -H "Content-Type: application/json" \
        -d "{\"version\":\"$LINUXSTUDIO_VERSION\",\"os\":\"$OS_TYPE\",\"arch\":\"$OS_ARCH\"}" \
        &>/dev/null || true
    
    info "Installation reported"
}

# Print installation summary
print_summary() {
    echo ""
    echo ""
    print_msg "$GREEN" "╔════════════════════════════════════════════════════════════╗"
    print_msg "$GREEN" "║          Installation Completed Successfully! 🎉          ║"
    print_msg "$GREEN" "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    success "LinuxStudio Framework v$LINUXSTUDIO_VERSION installed"
    echo ""
    
    print_msg "$CYAN" "📍 Installation Path:"
    echo "   $INSTALL_PATH"
    echo ""
    
    print_msg "$CYAN" "📝 Log File:"
    echo "   $LOG_FILE"
    echo ""
    
    print_msg "$CYAN" "🚀 Quick Start:"
    echo "   linuxstudio status              # Check installation"
    echo "   linuxstudio component list      # List components"
    echo "   linuxstudio plugin list         # List plugins"
    echo "   linuxstudio scene apply <name>  # Apply scenario"
    echo "   linuxstudio --help              # Show help"
    echo ""
    
    print_msg "$CYAN" "📚 Documentation:"
    echo "   https://docs.linuxstudio.org"
    echo ""
    
    print_msg "$CYAN" "💬 Community:"
    echo "   https://community.linuxstudio.org"
    echo ""
    
    print_msg "$CYAN" "🐛 Report Issues:"
    echo "   https://github.com/happykl-cn/LinuxStudio/issues"
    echo ""
    
    print_msg "$YELLOW" "💡 Next Steps:"
    echo "   1. Run 'linuxstudio status' to verify installation"
    echo "   2. Install components for your use case"
    echo "   3. Configure plugins as needed"
echo ""

    success "Thank you for using LinuxStudio! 🎊"
    echo ""
}

# Main installation function
main() {
    # Initialize
    print_banner
    
    # Setup logging
    exec > >(tee -a "$LOG_FILE") 2>&1
    log "LinuxStudio installation started"
    
    echo ""
    print_msg "$GREEN" "╔════════════════════════════════════════════════════════════╗"
    print_msg "$GREEN" "║              Installation Progress Overview                ║"
    print_msg "$GREEN" "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    local TOTAL_STEPS=10
    local CURRENT_STEP=0
    
    # Step 1: Pre-installation checks
    CURRENT_STEP=$((CURRENT_STEP + 1))
    print_msg "$WHITE" "▶ STEP $CURRENT_STEP/$TOTAL_STEPS: System Checks"
    echo ""
    check_root
    detect_system
    check_requirements
    detect_china
    echo ""
    
    # Step 2: Confirm installation
    CURRENT_STEP=$((CURRENT_STEP + 1))
    print_msg "$WHITE" "▶ STEP $CURRENT_STEP/$TOTAL_STEPS: Confirm Installation"
    confirm_installation
    
    # Step 3: System optimization
    CURRENT_STEP=$((CURRENT_STEP + 1))
    print_msg "$WHITE" "▶ STEP $CURRENT_STEP/$TOTAL_STEPS: System Optimization"
    echo ""
    configure_mirrors
    configure_swap
    disable_selinux
    configure_timezone
    optimize_system
    echo ""
    
    # Step 4: Install mandatory components
    CURRENT_STEP=$((CURRENT_STEP + 1))
    print_msg "$WHITE" "▶ STEP $CURRENT_STEP/$TOTAL_STEPS: Mandatory Components"
    install_mandatory_components
    
    # Step 5: Install framework components
    CURRENT_STEP=$((CURRENT_STEP + 1))
    print_msg "$WHITE" "▶ STEP $CURRENT_STEP/$TOTAL_STEPS: Framework Components"
    install_framework_components
    
    # Step 6: Install LinuxStudio core
    CURRENT_STEP=$((CURRENT_STEP + 1))
    print_msg "$WHITE" "▶ STEP $CURRENT_STEP/$TOTAL_STEPS: LinuxStudio Core"
    install_linuxstudio_core
    
    # Step 7: Create systemd service
    CURRENT_STEP=$((CURRENT_STEP + 1))
    print_msg "$WHITE" "▶ STEP $CURRENT_STEP/$TOTAL_STEPS: System Service"
    echo ""
    create_systemd_service
    echo ""
    
    # Step 8: Scene selection
    CURRENT_STEP=$((CURRENT_STEP + 1))
    print_msg "$WHITE" "▶ STEP $CURRENT_STEP/$TOTAL_STEPS: Scene Selection"
    select_scene
    
    # Step 9: Report installation
    CURRENT_STEP=$((CURRENT_STEP + 1))
    print_msg "$WHITE" "▶ STEP $CURRENT_STEP/$TOTAL_STEPS: Reporting Statistics"
    echo ""
    report_installation
    echo ""
    
    # Step 10: Complete
    CURRENT_STEP=$((CURRENT_STEP + 1))
    print_msg "$WHITE" "▶ STEP $CURRENT_STEP/$TOTAL_STEPS: Installation Complete"
    echo ""
    
    # Print summary
    print_summary
    
    log "LinuxStudio installation completed successfully"
}

#==============================================================================
# Script Entry Point
#==============================================================================

# Show usage information
show_usage() {
    cat <<EOF
LinuxStudio Framework Installation Script v${LINUXSTUDIO_VERSION}

Usage: $0 [OPTIONS]

Options:
  -y, --yes              Non-interactive mode, answer yes to all prompts
  -s, --skip-scene       Skip scene selection
  -h, --help             Show this help message
  --version              Show version information

Examples:
  # Interactive installation (default)
  sudo bash heaven.sh

  # Non-interactive installation
  sudo bash heaven.sh -y

  # Install without scene selection
  sudo bash heaven.sh --skip-scene

  # Non-interactive + skip scene
  sudo bash heaven.sh -y -s

For more information, visit: https://linuxstudio.org
EOF
    exit 0
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -y|--yes)
                AUTO_YES=1
                shift
                ;;
            -s|--skip-scene)
                SKIP_SCENE=1
                shift
                ;;
            -h|--help)
                show_usage
                ;;
            --version)
                echo "LinuxStudio Framework v${LINUXSTUDIO_VERSION}"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                echo "Run '$0 --help' for usage information"
                exit 1
                ;;
        esac
    done
}

# Trap errors
trap 'error "Installation failed at line $LINENO. Check log: $LOG_FILE"; exit 1' ERR

# Parse arguments first
parse_args "$@"

# Run main installation
main
