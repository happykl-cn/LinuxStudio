# 诊断版本问题

## 快速诊断脚本

在设备上运行以下命令诊断问题：

```bash
#!/bin/sh
echo "=== LinuxStudio 版本诊断 ==="
echo ""

echo "1. 检查已安装的二进制文件版本："
/usr/bin/xkl --version 2>&1 || echo "❌ 命令执行失败"

echo ""
echo "2. 检查二进制文件位置："
which -a xkl

echo ""
echo "3. 检查二进制文件修改时间："
ls -lh /usr/bin/xkl 2>/dev/null || echo "❌ 文件不存在"

echo ""
echo "4. 检查二进制文件是否包含 scene 命令："
strings /usr/bin/xkl 2>/dev/null | grep -i "cmdScene\|scene list" | head -3 || echo "❌ 未找到 scene 相关字符串"

echo ""
echo "5. 检查符号链接："
ls -l /usr/bin/linuxstudio 2>/dev/null || echo "❌ 符号链接不存在"

echo ""
echo "6. 测试 scene 命令："
/usr/bin/xkl scene list 2>&1 | head -5 || echo "❌ scene 命令失败"

echo ""
echo "7. 检查下载的包版本："
if [ -f /tmp/linuxstudio_embedded.deb ]; then
    dpkg-deb -f /tmp/linuxstudio_embedded.deb Version 2>/dev/null || echo "无法读取包版本"
else
    echo "未找到下载的包"
fi

echo ""
echo "=== 诊断完成 ==="
```

## 常见问题和解决方法

### 问题 1: GitHub Releases 上的包还没有更新

**症状**：下载的是旧版本的包

**解决方法**：
```bash
# 检查 GitHub Releases 上的实际版本
curl -s https://api.github.com/repos/happykl-cn/LinuxStudio/releases/latest | grep '"tag_name"'

# 如果返回的是旧版本（如 v1.0.0），说明包还没有更新
# 需要等待 GitHub Actions 构建完成，或者从源码编译
```

### 问题 2: 解压时没有覆盖旧文件

**症状**：解压了新包，但二进制文件还是旧的

**解决方法**：
```bash
# 1. 手动删除旧文件
rm -f /usr/bin/xkl /usr/bin/linuxstudio

# 2. 重新解压安装
cd /tmp
wget --no-check-certificate https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.1_debian-11_armhf.deb
ar x linuxstudio_1.1.1_debian-11_armhf.deb
tar -xzf data.tar.gz -C /

# 3. 强制覆盖（如果需要）
cp -f usr/bin/xkl /usr/bin/xkl
chmod +x /usr/bin/xkl
ln -sf /usr/bin/xkl /usr/bin/linuxstudio

# 4. 验证
xkl --version
xkl scene list
```

### 问题 3: 多个位置的二进制文件

**症状**：PATH 中有多个位置的 xkl

**解决方法**：
```bash
# 1. 找出所有 xkl 位置
which -a xkl

# 2. 检查每个位置的版本
/usr/bin/xkl --version
/usr/local/bin/xkl --version 2>/dev/null || echo "不存在"

# 3. 删除旧位置的，保留正确位置的
# 通常应该在 /usr/bin/xkl
```

### 问题 4: 从源码编译但忘记重新编译

**症状**：修改了代码但没有重新编译

**解决方法**：
```bash
cd LinuxStudio
git pull origin main  # 确保代码是最新的
rm -rf build          # 清理旧构建
./build.sh            # 重新编译
cd build
sudo cmake --install . # 重新安装
```

## 验证修复

修复后，运行以下命令验证：

```bash
# 1. 检查版本
xkl --version
# 应该显示: LinuxStudio Framework v1.1.1 (C++ Core)

# 2. 检查 scene 命令
xkl scene list
# 应该显示 9 个场景的列表

# 3. 检查二进制文件是否包含 scene
strings /usr/bin/xkl | grep -i "cmdScene"
# 应该能找到字符串

# 4. 测试应用场景
xkl scene apply embedded
# 应该显示嵌入式场景的组件列表
```

## 如果 GitHub Releases 上的包还是旧版本

如果 GitHub Releases 上还没有 v1.1.1 的包，你需要：

### 选项 1: 等待构建完成

GitHub Actions 会自动构建和发布，但可能需要时间。

### 选项 2: 从源码编译（推荐）

```bash
# 在开发机器上（x86_64）交叉编译 ARM 版本
git clone https://github.com/happykl-cn/LinuxStudio.git
cd LinuxStudio

# 安装交叉编译工具链
sudo apt install gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf

# 交叉编译
mkdir build && cd build
cmake .. \
    -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc \
    -DCMAKE_CXX_COMPILER=arm-linux-gnueabihf-g++ \
    -DCMAKE_SYSTEM_NAME=Linux \
    -DCMAKE_SYSTEM_PROCESSOR=armhf

make -j$(nproc)

# 在嵌入式设备上安装
# 复制 build/bin/xkl 到设备，然后：
sudo cp xkl /usr/bin/xkl
sudo chmod +x /usr/bin/xkl
sudo ln -sf /usr/bin/xkl /usr/bin/linuxstudio
```

---

**更新时间**: 2025-11-02

