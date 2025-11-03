# 修复 "Unknown command: scene" 错误

## 问题原因

你安装的 LinuxStudio 二进制文件是旧版本的，不包含 `scene` 命令的实现。

## 解决方案

### 方法 1: 重新下载最新版本（推荐）

如果你是**嵌入式系统**（STM32MP1/OpenSTLinux），需要重新下载最新的预编译包：

```bash
# 1. 删除旧版本（可选，如果想完全清理）
rm -f /usr/bin/xkl /usr/bin/linuxstudio

# 2. 重新运行安装脚本（会自动下载最新版本）
curl -fsSLk https://linuxstudio.org/heaven-cn.sh | bash

# 或者手动下载最新版本
wget --no-check-certificate https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.1_debian-11_armhf.deb
ar x linuxstudio_1.1.1_debian-11_armhf.deb
tar -xzf data.tar.gz -C /

# 3. 设置权限
chmod +x /usr/bin/xkl
ln -sf /usr/bin/xkl /usr/bin/linuxstudio

# 4. 验证安装
xkl --version
xkl scene list
```

### 方法 2: 从源码编译（如果你有编译环境）

```bash
# 1. 克隆仓库（如果还没有）
git clone https://github.com/happykl-cn/LinuxStudio.git
cd LinuxStudio

# 2. 切换到最新版本
git pull origin main

# 3. 编译
./build.sh

# 4. 安装
cd build
sudo cmake --install .

# 5. 验证
xkl --version
xkl scene list
```

### 方法 3: 检查当前版本

首先确认你安装的版本：

```bash
# 检查版本
xkl --version

# 如果显示 v1.0.0 或更早，说明需要更新
# 如果显示 v1.1.1，但仍然报错，可能是编译时没有包含 scene 命令
```

## 验证修复

更新后，运行以下命令验证：

```bash
# 1. 检查版本（应该显示 1.1.1）
xkl --version

# 2. 列出场景（应该显示 9 个场景）
xkl scene list

# 3. 应用场景（应该正常工作）
xkl scene apply embedded
```

## 如果仍然报错

如果更新后仍然报错，请检查：

1. **确认二进制文件已更新**
   ```bash
   # 检查文件修改时间
   ls -lh /usr/bin/xkl
   
   # 检查文件大小（新版本应该更大，因为包含了 scene 命令）
   stat /usr/bin/xkl
   ```

2. **检查符号链接**
   ```bash
   # 确认符号链接正确
   ls -l /usr/bin/linuxstudio
   # 应该指向: /usr/bin/xkl
   ```

3. **重新编译和安装**
   ```bash
   # 如果是从源码编译，确保重新编译
   cd LinuxStudio
   rm -rf build
   ./build.sh
   cd build
   sudo cmake --install .
   ```

4. **检查编译是否包含 scene 命令**
   ```bash
   # 在编译输出中搜索 "scene"
   grep -r "scene" build/src/cli/
   
   # 或者在二进制文件中搜索（应该能找到）
   strings /usr/bin/xkl | grep -i scene
   ```

## 常见问题

**Q: 我已经下载了最新版本，为什么还是报错？**  
A: 可能是：
- 下载的包是旧版本的
- 解压时出了问题
- 需要重新创建符号链接

**Q: 如何确认二进制文件包含 scene 命令？**  
A: 运行：
```bash
strings /usr/bin/xkl | grep -i "cmdScene\|scene list\|scene apply"
```
如果找到这些字符串，说明二进制文件包含 scene 命令。

**Q: 编译时没有报错，但运行时报错？**  
A: 可能是：
- 安装了旧版本的二进制文件
- 符号链接指向了旧文件
- PATH 环境变量指向了旧目录

**解决方法**：
```bash
# 找到所有 xkl 二进制文件
which -a xkl

# 删除旧的，保留新的
# 然后重新创建符号链接
```

---

**更新时间**: 2025-11-02  
**适用版本**: v1.1.1+

