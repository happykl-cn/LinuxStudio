# 强制更新到最新版本

如果重新安装后仍然是旧版本，请按照以下步骤强制更新：

## 方法 1: 完全清理后重新安装

```bash
# 1. 完全删除旧版本
rm -f /usr/bin/xkl /usr/bin/linuxstudio
rm -rf /opt/linuxstudio
rm -rf /etc/linuxstudio

# 2. 清理临时文件
rm -f /tmp/linuxstudio_*.deb
rm -rf /tmp/linuxstudio_install

# 3. 重新运行安装脚本
curl -fsSLk https://linuxstudio.org/heaven-cn.sh | bash
```

## 方法 2: 手动强制覆盖安装

```bash
# 1. 下载最新版本
cd /tmp
rm -f linuxstudio_*.deb
wget --no-check-certificate https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.1_debian-11_armhf.deb

# 2. 验证下载的包
dpkg-deb -f linuxstudio_1.1.1_debian-11_armhf.deb Version
# 应该显示: 1.1.1

# 3. 删除旧文件（重要！）
rm -f /usr/bin/xkl /usr/bin/linuxstudio

# 4. 解压安装
ar x linuxstudio_1.1.1_debian-11_armhf.deb
tar -xzf data.tar.gz

# 5. 强制复制（覆盖）
cp -f usr/bin/xkl /usr/bin/xkl
chmod +x /usr/bin/xkl
cp -rf opt/* /opt/ 2>/dev/null || true
cp -rf etc/* /etc/ 2>/dev/null || true

# 6. 创建符号链接
rm -f /usr/bin/linuxstudio
ln -sf /usr/bin/xkl /usr/bin/linuxstudio

# 7. 验证
xkl --version
xkl scene list
```

## 方法 3: 检查 GitHub Releases 版本

如果 GitHub Releases 上的包还是旧版本，需要检查：

```bash
# 检查最新 Release 标签
curl -s https://api.github.com/repos/happykl-cn/LinuxStudio/releases/latest | grep '"tag_name"'

# 检查包是否存在
curl -I https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.1_debian-11_armhf.deb

# 如果返回 404，说明包还没有构建
# 需要：
# 1. 等待 GitHub Actions 构建完成
# 2. 或者从源码编译
```

## 方法 4: 从源码编译（如果包还没更新）

```bash
# 在开发机器（x86_64）上交叉编译

# 1. 克隆代码
git clone https://github.com/happykl-cn/LinuxStudio.git
cd LinuxStudio
git pull origin main  # 确保是最新代码

# 2. 安装交叉编译工具链
sudo apt install gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf

# 3. 交叉编译
mkdir build && cd build
cmake .. \
    -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc \
    -DCMAKE_CXX_COMPILER=arm-linux-gnueabihf-g++ \
    -DCMAKE_SYSTEM_NAME=Linux \
    -DCMAKE_SYSTEM_PROCESSOR=armhf \
    -DCMAKE_BUILD_TYPE=Release

make -j$(nproc)

# 4. 在设备上安装
# 将 build/bin/xkl 复制到设备，然后：
sudo cp xkl /usr/bin/xkl
sudo chmod +x /usr/bin/xkl
sudo rm -f /usr/bin/linuxstudio
sudo ln -sf /usr/bin/xkl /usr/bin/linuxstudio

# 5. 验证
xkl --version
xkl scene list
```

## 验证步骤

更新后，运行以下命令验证：

```bash
# 1. 检查版本
xkl --version
# 应该显示: LinuxStudio Framework v1.1.1 (C++ Core)

# 2. 检查二进制文件大小（新版本应该更大）
ls -lh /usr/bin/xkl

# 3. 检查是否包含 scene 命令
strings /usr/bin/xkl | grep -i "cmdScene" | head -1
# 应该能找到字符串

# 4. 测试 scene 命令
xkl scene list
# 应该显示 9 个场景

# 5. 测试应用场景
xkl scene apply embedded
# 应该显示嵌入式场景的组件列表
```

## 诊断问题

如果更新后仍然有问题，运行诊断脚本：

```bash
# 复制诊断脚本并运行
cat > /tmp/diagnose.sh <<'EOF'
#!/bin/sh
echo "=== 诊断信息 ==="
echo "1. 版本: $(/usr/bin/xkl --version 2>&1)"
echo "2. 文件大小: $(ls -lh /usr/bin/xkl 2>&1)"
echo "3. 是否包含 scene: $(strings /usr/bin/xkl 2>/dev/null | grep -i cmdScene | head -1 || echo '未找到')"
echo "4. scene 命令测试:"
/usr/bin/xkl scene list 2>&1 | head -3
EOF
chmod +x /tmp/diagnose.sh
/tmp/diagnose.sh
```

---

**更新时间**: 2025-11-02

