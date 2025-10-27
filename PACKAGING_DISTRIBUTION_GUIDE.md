# LinuxStudio 打包与分发完全指南

## 📋 目录

1. [二进制分发](#二进制分发)
2. [Debian/Ubuntu 打包 (.deb)](#debian-打包)
3. [RedHat/CentOS 打包 (.rpm)](#rpm-打包)
4. [AppImage 打包](#appimage-打包)
5. [静态链接分发](#静态链接分发)
6. [Docker 镜像](#docker-镜像)
7. [依赖管理](#依赖管理)

---

## 二进制分发

### 方案 1：直接分发二进制文件（最简单）

#### 编译

```bash
# Release 模式编译
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . -j$(nproc)

# 生成的文件
ls -lh bin/xkl
# -rwxr-xr-x 1 user user 2.3M Oct 27 10:30 xkl
```

#### 打包

```bash
# 创建分发目录
mkdir -p xkl-linux-x64-1.0.0
cd xkl-linux-x64-1.0.0

# 复制二进制文件
cp ../build/bin/xkl .

# 创建安装脚本
cat > install.sh <<'EOF'
#!/bin/bash
echo "Installing xkl..."
sudo cp xkl /usr/local/bin/
sudo chmod +x /usr/local/bin/xkl
sudo ln -sf /usr/local/bin/xkl /usr/local/bin/linuxstudio
echo "✅ xkl installed successfully!"
echo "Run: xkl --version"
EOF

chmod +x install.sh

# 创建 README
cat > README.md <<'EOF'
# xkl - LinuxStudio CLI

## Installation

```bash
./install.sh
```

## Usage

```bash
xkl --help
xkl status
xkl plugin install ros2
```

## Requirements

- Linux x86_64
- glibc 2.27+
- libstdc++.so.6
EOF

# 打包
cd ..
tar czf xkl-linux-x64-1.0.0.tar.gz xkl-linux-x64-1.0.0/
```

#### 使用

```bash
# 用户下载后
tar xzf xkl-linux-x64-1.0.0.tar.gz
cd xkl-linux-x64-1.0.0
./install.sh
```

**优点**：
- ✅ 简单快速
- ✅ 适合快速测试

**缺点**：
- ❌ 需要用户手动安装
- ❌ 不易卸载
- ❌ 不能通过包管理器升级

---

## Debian 打包

### 方案 2：创建 .deb 包（推荐 Ubuntu/Debian）

#### 方法 A：使用 checkinstall（简单）

```bash
# 安装工具
sudo apt-get install checkinstall

# 编译
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . -j$(nproc)

# 使用 checkinstall 创建 .deb
sudo checkinstall \
    --pkgname=xkl \
    --pkgversion=1.0.0 \
    --pkgrelease=1 \
    --pkglicense=MIT \
    --pkggroup=utils \
    --pakdir=.. \
    --maintainer="your-email@example.com" \
    --requires="libstdc++6,libc6" \
    --nodoc \
    cmake --install .

# 生成的文件
ls ../*.deb
# xkl_1.0.0-1_amd64.deb
```

#### 方法 B：手动创建 .deb（专业）

##### 1. 创建目录结构

```bash
mkdir -p xkl_1.0.0-1_amd64/DEBIAN
mkdir -p xkl_1.0.0-1_amd64/usr/local/bin
mkdir -p xkl_1.0.0-1_amd64/usr/share/doc/xkl
```

##### 2. 复制文件

```bash
# 复制二进制
cp build/bin/xkl xkl_1.0.0-1_amd64/usr/local/bin/
chmod 755 xkl_1.0.0-1_amd64/usr/local/bin/xkl

# 复制文档
cp README.md xkl_1.0.0-1_amd64/usr/share/doc/xkl/
cp LICENSE xkl_1.0.0-1_amd64/usr/share/doc/xkl/
```

##### 3. 创建控制文件

```bash
cat > xkl_1.0.0-1_amd64/DEBIAN/control <<EOF
Package: xkl
Version: 1.0.0-1
Section: utils
Priority: optional
Architecture: amd64
Depends: libstdc++6 (>= 7.0), libc6 (>= 2.27)
Maintainer: Your Name <your-email@example.com>
Description: LinuxStudio CLI - High-Performance Linux Environment Manager
 xkl is a powerful command-line tool for managing Linux development
 environments, plugins, and components.
 .
 Features:
  * Plugin management (ROS2, OpenCV, PyTorch, etc.)
  * Component installation
  * Development scene management
  * Remote server deployment
Homepage: https://linuxstudio.org
EOF
```

##### 4. 创建安装后脚本

```bash
cat > xkl_1.0.0-1_amd64/DEBIAN/postinst <<'EOF'
#!/bin/bash
# 创建符号链接（向后兼容）
ln -sf /usr/local/bin/xkl /usr/local/bin/linuxstudio

echo "✅ xkl installed successfully!"
echo "Run: xkl --help"
EOF

chmod 755 xkl_1.0.0-1_amd64/DEBIAN/postinst
```

##### 5. 创建卸载前脚本

```bash
cat > xkl_1.0.0-1_amd64/DEBIAN/prerm <<'EOF'
#!/bin/bash
# 删除符号链接
rm -f /usr/local/bin/linuxstudio
EOF

chmod 755 xkl_1.0.0-1_amd64/DEBIAN/prerm
```

##### 6. 构建 .deb 包

```bash
# 构建
dpkg-deb --build xkl_1.0.0-1_amd64

# 检查包内容
dpkg-deb -c xkl_1.0.0-1_amd64.deb

# 检查包信息
dpkg-deb -I xkl_1.0.0-1_amd64.deb
```

#### 使用 .deb 包

```bash
# 安装
sudo dpkg -i xkl_1.0.0-1_amd64.deb

# 如果有依赖问题，修复
sudo apt-get install -f

# 验证
dpkg -l | grep xkl
which xkl

# 卸载
sudo dpkg -r xkl

# 完全删除（包括配置）
sudo dpkg --purge xkl
```

#### 签名 .deb 包

```bash
# 生成 GPG 密钥
gpg --gen-key

# 签名
dpkg-sig --sign builder xkl_1.0.0-1_amd64.deb

# 验证签名
dpkg-sig --verify xkl_1.0.0-1_amd64.deb
```

---

## RPM 打包

### 方案 3：创建 .rpm 包（RedHat/CentOS/Fedora）

#### 准备环境

```bash
# CentOS/RHEL
sudo yum install rpm-build rpmdevtools

# Fedora
sudo dnf install rpm-build rpmdevtools

# 创建 RPM 构建目录
rpmdev-setuptree
```

#### 创建 spec 文件

```bash
cat > ~/rpmbuild/SPECS/xkl.spec <<'EOF'
Name:           xkl
Version:        1.0.0
Release:        1%{?dist}
Summary:        LinuxStudio CLI - High-Performance Linux Environment Manager
License:        MIT
URL:            https://linuxstudio.org
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  gcc-c++ >= 7.0
BuildRequires:  cmake >= 3.15
Requires:       libstdc++ >= 7.0

%description
xkl is a powerful command-line tool for managing Linux development
environments, plugins, and components.

Features:
- Plugin management (ROS2, OpenCV, PyTorch, etc.)
- Component installation
- Development scene management
- Remote server deployment

%prep
%setup -q

%build
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%{_prefix}
make %{?_smp_mflags}

%install
cd build
%make_install

# 创建符号链接
ln -sf %{_bindir}/xkl %{buildroot}%{_bindir}/linuxstudio

%files
%license LICENSE
%doc README.md
%{_bindir}/xkl
%{_bindir}/linuxstudio

%post
echo "✅ xkl installed successfully!"
echo "Run: xkl --help"

%changelog
* Sun Oct 27 2024 Your Name <your-email@example.com> - 1.0.0-1
- Initial release
EOF
```

#### 准备源代码

```bash
# 创建源码包
cd /path/to/LinuxStudio
tar czf ~/rpmbuild/SOURCES/xkl-1.0.0.tar.gz \
    --transform 's,^,xkl-1.0.0/,' \
    --exclude='.git' \
    --exclude='build' \
    .
```

#### 构建 RPM

```bash
# 构建
rpmbuild -ba ~/rpmbuild/SPECS/xkl.spec

# 生成的文件
ls ~/rpmbuild/RPMS/x86_64/
# xkl-1.0.0-1.el8.x86_64.rpm

ls ~/rpmbuild/SRPMS/
# xkl-1.0.0-1.el8.src.rpm
```

#### 使用 RPM 包

```bash
# 安装
sudo rpm -ivh xkl-1.0.0-1.el8.x86_64.rpm

# 升级
sudo rpm -Uvh xkl-1.0.0-1.el8.x86_64.rpm

# 查询
rpm -qi xkl
rpm -ql xkl

# 卸载
sudo rpm -e xkl
```

---

## AppImage 打包

### 方案 4：AppImage（跨发行版，推荐）

AppImage 是一个包含程序及其所有依赖的单一可执行文件。

#### 安装工具

```bash
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage
```

#### 创建 AppDir 结构

```bash
mkdir -p xkl.AppDir/usr/bin
mkdir -p xkl.AppDir/usr/lib
mkdir -p xkl.AppDir/usr/share/applications
mkdir -p xkl.AppDir/usr/share/icons/hicolor/256x256/apps
```

#### 复制文件

```bash
# 复制二进制
cp build/bin/xkl xkl.AppDir/usr/bin/

# 复制依赖库（可选，如果需要特定版本）
ldd build/bin/xkl | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp -v '{}' xkl.AppDir/usr/lib/

# 创建桌面入口文件
cat > xkl.AppDir/usr/share/applications/xkl.desktop <<EOF
[Desktop Entry]
Type=Application
Name=xkl
Comment=LinuxStudio CLI
Exec=xkl
Icon=xkl
Categories=Utility;Development;
Terminal=true
EOF

# 创建 AppRun 脚本
cat > xkl.AppDir/AppRun <<'EOF'
#!/bin/bash
SELF=$(readlink -f "$0")
HERE=${SELF%/*}
export PATH="${HERE}/usr/bin:${PATH}"
export LD_LIBRARY_PATH="${HERE}/usr/lib:${LD_LIBRARY_PATH}"
exec "${HERE}/usr/bin/xkl" "$@"
EOF

chmod +x xkl.AppDir/AppRun

# 复制图标（如果有）
# cp logo.png xkl.AppDir/usr/share/icons/hicolor/256x256/apps/xkl.png
# ln -s usr/share/icons/hicolor/256x256/apps/xkl.png xkl.AppDir/xkl.png
```

#### 构建 AppImage

```bash
# 构建
./appimagetool-x86_64.AppImage xkl.AppDir xkl-x86_64.AppImage

# 生成的文件
ls -lh xkl-x86_64.AppImage
# -rwxr-xr-x 1 user user 3.5M Oct 27 10:30 xkl-x86_64.AppImage
```

#### 使用 AppImage

```bash
# 直接运行（无需安装）
chmod +x xkl-x86_64.AppImage
./xkl-x86_64.AppImage --version

# 安装到系统（可选）
./xkl-x86_64.AppImage --appimage-extract
sudo mv squashfs-root/usr/bin/xkl /usr/local/bin/
```

**优点**：
- ✅ 单一文件，包含所有依赖
- ✅ 跨发行版兼容
- ✅ 无需 root 权限运行
- ✅ 易于分发

**缺点**：
- ❌ 文件较大（3-5 MB）
- ❌ 不能通过包管理器管理

---

## 静态链接分发

### 方案 5：静态链接（完全独立）

#### 编译静态二进制

```bash
mkdir build && cd build

# 静态链接 C++ 标准库
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_FLAGS="-static-libstdc++ -static-libgcc"

cmake --build . -j$(nproc)

# 检查依赖（应该更少）
ldd bin/xkl
# linux-vdso.so.1 (0x00007fff...)
# libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6
# （libstdc++ 和 libgcc 已静态链接）
```

#### 完全静态链接（极端方案）

```bash
# 完全静态链接（包括 glibc）
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_EXE_LINKER_FLAGS="-static"

cmake --build . -j$(nproc)

# 检查
ldd bin/xkl
# not a dynamic executable

# 文件大小会增加
ls -lh bin/xkl
# -rwxr-xr-x 1 user user 25M Oct 27 10:30 xkl
```

**优点**：
- ✅ 完全独立，无依赖
- ✅ 可在任何 Linux 系统运行
- ✅ 不受库版本影响

**缺点**：
- ❌ 文件很大（20-30 MB）
- ❌ 无法受益于系统库安全更新
- ❌ 可能有兼容性问题

---

## Docker 镜像

### 方案 6：Docker 容器化

#### Dockerfile

```dockerfile
# 多阶段构建
FROM ubuntu:22.04 AS builder

# 安装构建依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*

# 复制源代码
COPY . /src
WORKDIR /src

# 编译
RUN mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    cmake --build . -j$(nproc)

# 运行时镜像
FROM ubuntu:22.04

# 安装运行时依赖
RUN apt-get update && apt-get install -y \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# 从构建阶段复制二进制
COPY --from=builder /src/build/bin/xkl /usr/local/bin/
RUN ln -s /usr/local/bin/xkl /usr/local/bin/linuxstudio

# 创建工作目录
RUN mkdir -p /opt/linuxstudio

WORKDIR /root

ENTRYPOINT ["xkl"]
CMD ["--help"]
```

#### 构建和使用

```bash
# 构建镜像
docker build -t xkl:1.0.0 .

# 运行
docker run --rm xkl:1.0.0 --version
docker run --rm xkl:1.0.0 status

# 交互式运行
docker run -it --rm xkl:1.0.0 bash

# 发布到 Docker Hub
docker tag xkl:1.0.0 yourusername/xkl:1.0.0
docker push yourusername/xkl:1.0.0
```

#### Docker Compose

```yaml
version: '3.8'

services:
  xkl:
    image: xkl:1.0.0
    container_name: xkl
    volumes:
      - /opt/linuxstudio:/opt/linuxstudio
    network_mode: host
    privileged: true
    command: ["daemon"]
```

---

## 依赖管理

### 查看依赖

```bash
# 查看动态依赖
ldd /usr/local/bin/xkl

# 查看需要的符号
nm -D /usr/local/bin/xkl | grep -v " U "

# 查看 ELF 信息
readelf -d /usr/local/bin/xkl

# 查看节（sections）
readelf -S /usr/local/bin/xkl
```

### 最小依赖列表

对于 xkl，通常需要：

```
libstdc++.so.6  - C++ 标准库 (GCC 7.0+)
libgcc_s.so.1   - GCC 支持库
libc.so.6       - C 标准库 (glibc 2.27+)
libm.so.6       - 数学库
libpthread.so.0 - 线程库（如果使用多线程）
```

### 检查系统是否满足依赖

```bash
# 创建依赖检查脚本
cat > check_deps.sh <<'EOF'
#!/bin/bash

echo "Checking xkl dependencies..."

# 检查 libstdc++
if ldconfig -p | grep -q libstdc++.so.6; then
    echo "✅ libstdc++.so.6 found"
else
    echo "❌ libstdc++.so.6 missing"
    echo "   Install: sudo apt-get install libstdc++6"
fi

# 检查 glibc 版本
GLIBC_VER=$(ldd --version | head -1 | awk '{print $NF}')
echo "ℹ️  glibc version: $GLIBC_VER"

if [ "$(echo "$GLIBC_VER 2.27" | awk '{print ($1 >= $2)}')" -eq 1 ]; then
    echo "✅ glibc version OK"
else
    echo "❌ glibc too old (need 2.27+)"
fi
EOF

chmod +x check_deps.sh
./check_deps.sh
```

---

## 📊 打包方式对比

| 方式 | 文件大小 | 兼容性 | 易用性 | 推荐度 |
|------|---------|--------|--------|--------|
| **二进制 tar.gz** | 2-3 MB | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **.deb 包** | 2-3 MB | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **.rpm 包** | 2-3 MB | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **AppImage** | 3-5 MB | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **静态链接** | 20-30 MB | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Docker** | 100-200 MB | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

---

## 🚀 推荐的分发策略

### 策略 1：多平台支持

```
xkl-1.0.0/
├── xkl-1.0.0-linux-x64.tar.gz       # 通用二进制
├── xkl_1.0.0-1_amd64.deb            # Debian/Ubuntu
├── xkl-1.0.0-1.el8.x86_64.rpm       # RHEL/CentOS
├── xkl-x86_64.AppImage              # 跨发行版
└── install.sh                        # 自动检测安装脚本
```

### 策略 2：自动安装脚本

```bash
cat > install.sh <<'EOF'
#!/bin/bash

# 检测系统类型
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
fi

case "$OS" in
    ubuntu|debian)
        echo "Installing .deb package..."
        sudo dpkg -i xkl_1.0.0-1_amd64.deb
        sudo apt-get install -f
        ;;
    centos|rhel|fedora)
        echo "Installing .rpm package..."
        sudo rpm -ivh xkl-1.0.0-1.el8.x86_64.rpm
        ;;
    *)
        echo "Installing from tar.gz..."
        tar xzf xkl-1.0.0-linux-x64.tar.gz
        sudo cp xkl-1.0.0-linux-x64/xkl /usr/local/bin/
        sudo chmod +x /usr/local/bin/xkl
        ;;
esac

echo "✅ Installation complete!"
echo "Run: xkl --version"
EOF
```

---

## 📝 总结

### ldd 输出含义

```
linux-vdso.so.1         → 内核虚拟库（系统调用优化）
libstdc++.so.6          → C++ 标准库（必需）
libgcc_s.so.1           → GCC 运行时（必需）
libc.so.6               → C 标准库（必需）
libm.so.6               → 数学库（可选）
```

### 最佳实践

1. **开发测试**：使用动态链接（小文件，快速迭代）
2. **正式发布**：
   - Ubuntu/Debian → .deb 包
   - RHEL/CentOS → .rpm 包
   - 跨发行版 → AppImage
   - 容器化 → Docker

3. **分发平台**：
   - GitHub Releases
   - 自建 apt/yum 仓库
   - Docker Hub

---

**现在你对二进制依赖和 Linux 打包有全面的了解了！** 🚀

