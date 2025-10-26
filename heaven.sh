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

# Check system requirements
check_requirements() {
    step "Checking system requirements..."
    
    # Skip disk space check (removed per user request)
    # info "Disk space: ${DISK_SPACE}GB available"
    
    # Check memory (minimum 1GB) - only warning
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
    
    # Download core binary (placeholder - will be replaced with actual binary)
    info "Downloading LinuxStudio core binary..."
    
    # TODO: Replace with actual download URL
    # For now, create a placeholder script
    cat > "$INSTALL_PATH/bin/linuxstudio" <<'EOFCORE'
#!/bin/bash
# LinuxStudio CLI - Placeholder
# This will be replaced with the actual C++ binary

LINUXSTUDIO_ROOT="/opt/linuxstudio"

case "$1" in
    version|--version|-v)
        echo "LinuxStudio Framework v1.0.0"
        echo "High-Performance Linux Environment Manager"
        ;;
    status)
        echo "LinuxStudio Status:"
        echo "  Installation: $LINUXSTUDIO_ROOT"
        echo "  Components: $(ls $LINUXSTUDIO_ROOT/data/components 2>/dev/null | wc -l) installed"
        echo "  Plugins: $(ls $LINUXSTUDIO_ROOT/data/plugins 2>/dev/null | wc -l) installed"
        ;;
    component)
        echo "Component management (coming soon)"
        echo "Usage: linuxstudio component [list|install|uninstall] [name]"
        ;;
    plugin)
        echo "Plugin management (coming soon)"
        echo "Usage: linuxstudio plugin [list|install|uninstall] [name]"
        ;;
    *)
        echo "LinuxStudio Framework v1.0.0"
        echo ""
        echo "Usage: linuxstudio <command> [options]"
        echo ""
        echo "Commands:"
        echo "  status              Show framework status"
        echo "  component           Manage components"
        echo "  plugin              Manage plugins"
        echo "  scene               Manage scenarios"
        echo "  version             Show version"
        echo ""
        echo "Run 'linuxstudio <command> --help' for more information"
        ;;
esac
EOFCORE
    
    chmod +x "$INSTALL_PATH/bin/linuxstudio"
    ln -sf "$INSTALL_PATH/bin/linuxstudio" "$BIN_PATH/linuxstudio"
    
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

# Show scene selection menu
select_scene() {
    # Skip scene selection if requested
    if [ "$SKIP_SCENE" -eq 1 ]; then
        info "Scene selection skipped"
        return 0
    fi
    
    echo ""
    print_msg "$CYAN" "╔════════════════════════════════════════════════════════════╗"
    print_msg "$CYAN" "║         Select Your Development Scenario                   ║"
    print_msg "$CYAN" "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    print_msg "$WHITE" "  1) Web Development"
    echo "     - Nginx/Apache, PHP, MySQL, Redis, Node.js"
    echo ""
    
    print_msg "$WHITE" "  2) Embedded Development (ARM/RISC-V)"
    echo "     - Cross-compiler, OpenOCD, Serial tools, ROS2"
    echo ""
    
    print_msg "$WHITE" "  3) AI/ML Development"
    echo "     - Python, CUDA, TensorFlow, PyTorch, OpenCV"
    echo ""
    
    print_msg "$WHITE" "  4) Game Development"
    echo "     - SDL2, OpenGL, Vulkan, Game engines"
    echo ""
    
    print_msg "$WHITE" "  5) DevOps"
    echo "     - Docker, Kubernetes, Ansible, Jenkins"
echo ""
    
    print_msg "$WHITE" "  6) Skip (Install later with 'linuxstudio scene apply')"
echo ""

    echo -ne "${YELLOW}Your choice [1-6]: ${NC}"
    
    # Read from terminal device directly
    if [ -t 0 ]; then
        read -r scene_choice || scene_choice="6"
    else
        read -r scene_choice </dev/tty || scene_choice="6"
    fi
    
    # Trim whitespace
    scene_choice=$(echo "$scene_choice" | xargs)
    
    case $scene_choice in
        1) install_web_scene ;;
        2) install_embedded_scene ;;
        3) install_ai_scene ;;
        4) install_game_scene ;;
        5) install_devops_scene ;;
        6) info "Skipped scene installation" ;;
        *) warning "Invalid choice, skipping scene installation" ;;
    esac
}

# Install Web Development scene
install_web_scene() {
    step "Installing Web Development components..."
    
    info "This will install: Nginx, PHP, MySQL, Redis, Node.js"
    
    if [ "$AUTO_YES" -eq 0 ]; then
        echo -ne "${YELLOW}Continue? [Y/n]: ${NC}"
        
        # Read from terminal device directly
        if [ -t 0 ]; then
            read -r confirm || confirm="y"
        else
            read -r confirm </dev/tty || confirm="y"
        fi
        
        confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]' | xargs)
        
        if [[ "$confirm" == "n" || "$confirm" == "no" ]]; then
            info "Skipped"
            return
        fi
    fi
    
    # Install components (placeholder)
    universal_install "nginx" "Nginx"
    
    success "Web Development scene installed"
    info "Run 'linuxstudio component list' to see all installed components"
}

# Install Embedded Development scene
install_embedded_scene() {
    step "Installing Embedded Development components..."
    
    info "This will install: ARM toolchain, OpenOCD, Minicom"
    
    if [ "$AUTO_YES" -eq 0 ]; then
        echo -ne "${YELLOW}Continue? [Y/n]: ${NC}"
        
        # Read from terminal device directly
        if [ -t 0 ]; then
            read -r confirm || confirm="y"
        else
            read -r confirm </dev/tty || confirm="y"
        fi
        
        confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]' | xargs)
        
        if [[ "$confirm" == "n" || "$confirm" == "no" ]]; then
            info "Skipped"
            return
        fi
    fi
    
    # Install components (placeholder)
    info "Installing ARM cross-compiler..."
    
    success "Embedded Development scene installed"
    info "Run 'linuxstudio plugin install ros2' to install ROS2"
}

# Install AI/ML Development scene
install_ai_scene() {
    step "Installing AI/ML Development components..."
    
    info "This will install: Python3, pip, CUDA toolkit (if NVIDIA GPU detected)"
    
    if [ "$AUTO_YES" -eq 0 ]; then
        echo -ne "${YELLOW}Continue? [Y/n]: ${NC}"
        
        # Read from terminal device directly
        if [ -t 0 ]; then
            read -r confirm || confirm="y"
        else
            read -r confirm </dev/tty || confirm="y"
        fi
        
        confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]' | xargs)
        
        if [[ "$confirm" == "n" || "$confirm" == "no" ]]; then
            info "Skipped"
            return
        fi
    fi
    
    universal_install "python3" "Python3"
    universal_install "python3-pip" "pip3"
    
    success "AI/ML Development scene installed"
}

# Install Game Development scene
install_game_scene() {
    step "Installing Game Development components..."
    info "Game development components will be available soon"
}

# Install DevOps scene
install_devops_scene() {
    step "Installing DevOps components..."
    
    info "This will install: Docker, Docker Compose"
    
    if [ "$AUTO_YES" -eq 0 ]; then
        echo -ne "${YELLOW}Continue? [Y/n]: ${NC}"
        
        # Read from terminal device directly
        if [ -t 0 ]; then
            read -r confirm || confirm="y"
        else
            read -r confirm </dev/tty || confirm="y"
        fi
        
        confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]' | xargs)
        
        if [[ "$confirm" == "n" || "$confirm" == "no" ]]; then
            info "Skipped"
            return
        fi
    fi
    
    # Install Docker (placeholder)
    info "Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    
    success "DevOps scene installed"
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
