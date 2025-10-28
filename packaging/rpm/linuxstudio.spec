Name:           linuxstudio
Version:        1.0.0
Release:        1%{?dist}
Summary:        High-Performance Linux Environment Manager

License:        MIT
URL:            https://linuxstudio.org
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  gcc-c++ >= 7.0
BuildRequires:  cmake >= 3.15
BuildRequires:  make
BuildRequires:  bash >= 5.0
Requires:       bash >= 5.0
Requires:       curl
Requires:       git

%description
LinuxStudio is a framework for managing development environments,
toolchains, and multi-server deployments.

Features:
- Scene-driven component installation (Web, Robotics, AI/ML, etc.)
- Plugin management system (ROS2, OpenCV, PyTorch, etc.)
- Multi-server deployment support
- Cross-platform package manager integration

%prep
%autosetup

%build
mkdir -p build
cd build
%cmake3 -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_CXX_STANDARD=17 \
        ..
%make_build

%install
cd build
%make_install

# 创建必要目录
mkdir -p %{buildroot}/opt/linuxstudio/{plugins,components,data,logs,scenes}
mkdir -p %{buildroot}/etc/linuxstudio

# 创建配置文件
cat > %{buildroot}/etc/linuxstudio/config.yaml <<'EOF'
# LinuxStudio Configuration
version: 1.0.0
install_path: /opt/linuxstudio
log_level: info
auto_update_check: true
EOF

%post
# 创建符号链接
if [ ! -L /usr/bin/linuxstudio ]; then
    ln -sf /usr/bin/xkl /usr/bin/linuxstudio
fi

# 初始化框架
if [ -x /usr/bin/xkl ]; then
    /usr/bin/xkl init --quiet 2>/dev/null || true
fi

echo ""
echo "╔═══════════════════════════════════════════════════════╗"
echo "║  ✅ LinuxStudio installed successfully!              ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""
echo "📚 Quick Start:"
echo "   xkl --help              # Show help"
echo "   xkl status              # Check system status"
echo "   xkl scene apply web     # Apply web development scene"
echo ""

%preun
if [ $1 -eq 0 ]; then
    # 完全卸载
    rm -f /usr/bin/linuxstudio
fi

%postun
if [ $1 -eq 0 ]; then
    # 完全卸载后清理
    rm -rf /opt/linuxstudio
    rm -rf /etc/linuxstudio
fi

%files
%license LICENSE
%doc README.md
%{_bindir}/xkl
%dir /opt/linuxstudio
%dir /opt/linuxstudio/plugins
%dir /opt/linuxstudio/components
%dir /opt/linuxstudio/data
%dir /opt/linuxstudio/logs
%dir /opt/linuxstudio/scenes
%config(noreplace) /etc/linuxstudio/config.yaml

%changelog
* Tue Oct 28 2025 Dino Studio <support@linuxstudio.org> - 1.0.0-1
- Initial release
- Core xkl CLI tool
- 9 scene-driven installation modes
- Plugin management system
- Multi-platform support

