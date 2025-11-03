# LinuxStudio 调试指南

当遇到安装或运行问题时，请按照本指南进行调试。

## 🔍 快速诊断

### 1. 运行诊断脚本

在设备上创建并运行以下诊断脚本：

```bash
cat > /tmp/linuxstudio_diagnose.sh <<'EOF'
#!/bin/sh
echo "=================================================="
echo "LinuxStudio 诊断报告"
echo "=================================================="
echo ""

echo "【1】系统信息"
echo "---"
uname -a
echo ""

echo "【2】已安装的 xkl 版本"
echo "---"
if command -v xkl >/dev/null 2>&1; then
    /usr/bin/xkl --version 2>&1 || echo "❌ 命令执行失败"
else
    echo "❌ xkl 命令未找到"
fi
echo ""

echo "【3】二进制文件信息"
echo "---"
if [ -f /usr/bin/xkl ]; then
    ls -lh /usr/bin/xkl
    echo "文件大小: $(stat -f%z /usr/bin/xkl 2>/dev/null || stat -c%s /usr/bin/xkl 2>/dev/null) bytes"
    echo "修改时间: $(stat -f%Sm /usr/bin/xkl 2>/dev/null || stat -c%y /usr/bin/xkl 2>/dev/null)"
else
    echo "❌ /usr/bin/xkl 不存在"
fi
echo ""

echo "【4】符号链接检查"
echo "---"
if [ -L /usr/bin/linuxstudio ]; then
    ls -l /usr/bin/linuxstudio
else
    echo "❌ /usr/bin/linuxstudio 符号链接不存在"
fi
echo ""

echo "【5】二进制文件中的 scene 命令检查"
echo "---"
if [ -f /usr/bin/xkl ]; then
    if command -v strings >/dev/null 2>&1; then
        if strings /usr/bin/xkl 2>/dev/null | grep -i "cmdScene" | head -3; then
            echo "✅ 找到 scene 命令相关字符串"
        else
            echo "❌ 未找到 scene 命令相关字符串（可能是旧版本）"
        fi
    else
        echo "⚠️  strings 命令未安装，无法检查"
    fi
else
    echo "❌ /usr/bin/xkl 不存在"
fi
echo ""

echo "【6】测试 scene 命令"
echo "---"
if command -v xkl >/dev/null 2>&1; then
    xkl scene list 2>&1 | head -10 || echo "❌ scene 命令失败"
else
    echo "❌ xkl 命令未找到"
fi
echo ""

echo "【7】配置文件检查"
echo "---"
if [ -f /etc/linuxstudio/config.yaml ]; then
    echo "配置文件存在："
    cat /etc/linuxstudio/config.yaml | head -10
else
    echo "⚠️  /etc/linuxstudio/config.yaml 不存在"
fi
echo ""

echo "【8】日志目录检查"
echo "---"
if [ -d /opt/linuxstudio/logs ]; then
    echo "日志目录存在："
    ls -lh /opt/linuxstudio/logs/
else
    echo "⚠️  /opt/linuxstudio/logs 不存在"
fi
echo ""

echo "【9】PATH 环境变量"
echo "---"
echo $PATH
echo ""

echo "【10】所有 xkl 位置"
echo "---"
if command -v which >/dev/null 2>&1; then
    which -a xkl 2>/dev/null || echo "未找到 xkl"
else
    echo "which 命令不可用"
fi
echo ""

echo "=================================================="
echo "诊断完成"
echo "=================================================="
EOF

chmod +x /tmp/linuxstudio_diagnose.sh
/tmp/linuxstudio_diagnose.sh
```

### 2. 分析诊断结果

根据诊断脚本的输出，判断问题：

| 问题现象 | 可能原因 | 解决方法 |
|---------|---------|---------|
| `xkl --version` 显示 v1.0.0 或 v1.1.1 | 未更新到最新版本 | 参考下面的"强制更新"部分 |
| `xkl: command not found` | 未安装或 PATH 错误 | 重新运行安装脚本 |
| "Error: Unknown command: scene" | 旧版本二进制文件 | 强制更新（见下文） |
| `strings` 未找到 cmdScene | 旧版本二进制文件 | 强制更新（见下文） |
| 文件大小异常小 | 下载不完整或损坏 | 重新下载安装 |

## 🔧 常见问题解决

### 问题 1: scene 命令不可用

**症状**:
```bash
$ xkl scene list
Error: Unknown command: scene
```

**诊断**:
```bash
# 检查版本
xkl --version
# 如果显示 v1.1.1 或更早，说明是旧版本

# 检查二进制文件
strings /usr/bin/xkl | grep -i cmdScene
# 如果没有输出，说明二进制文件不包含 scene 命令
```

**解决**:
```bash
# 方法 1: 完全重新安装
rm -f /usr/bin/xkl /usr/bin/linuxstudio
rm -rf /opt/linuxstudio /etc/linuxstudio
curl -fsSLk https://linuxstudio.org/heaven-cn.sh | bash

# 方法 2: 手动强制更新
cd /tmp
rm -f linuxstudio_*.deb
wget --no-check-certificate \
  https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.2_debian-11_armhf.deb

# 验证包版本
dpkg-deb -f linuxstudio_1.1.2_debian-11_armhf.deb Version

# 强制安装
rm -f /usr/bin/xkl /usr/bin/linuxstudio
ar x linuxstudio_1.1.2_debian-11_armhf.deb
tar -xzf data.tar.gz
cp -f usr/bin/xkl /usr/bin/xkl
chmod +x /usr/bin/xkl
ln -sf /usr/bin/xkl /usr/bin/linuxstudio

# 验证
xkl --version
xkl scene list
```

### 问题 2: 重新安装后仍是旧版本

**症状**:
- 运行安装脚本后，`xkl --version` 仍显示旧版本
- `xkl scene list` 仍然报错

**原因**:
1. GitHub Releases 上的包还没有更新到 v1.1.2
2. 安装时未覆盖旧文件
3. 系统缓存了旧的二进制文件

**解决**:
```bash
# 1. 检查 GitHub Releases 上的最新版本
curl -s https://api.github.com/repos/happykl-cn/LinuxStudio/releases/latest | grep '"tag_name"'
# 应该显示: "tag_name": "v1.1.2"

# 2. 如果还是 v1.1.1，说明新版本还没有发布，等待几分钟后重试

# 3. 完全清理旧文件
rm -f /usr/bin/xkl /usr/bin/linuxstudio
rm -rf /opt/linuxstudio
rm -rf /etc/linuxstudio
hash -r  # 清除 shell 缓存

# 4. 重新下载并安装
cd /tmp
wget --no-check-certificate \
  https://github.com/happykl-cn/LinuxStudio/releases/download/v1.1.2/linuxstudio_1.1.2_debian-11_armhf.deb

# 5. 验证下载的包
dpkg-deb -f linuxstudio_1.1.2_debian-11_armhf.deb Version
# 应该显示: 1.1.2

# 6. 手动安装
ar x linuxstudio_1.1.2_debian-11_armhf.deb
tar -xzf data.tar.gz
cp -rf usr/* /usr/
cp -rf opt/* /opt/
cp -rf etc/* /etc/
chmod +x /usr/bin/xkl
ln -sf /usr/bin/xkl /usr/bin/linuxstudio

# 7. 验证安装
xkl --version  # 应该显示 v1.1.2
xkl scene list # 应该显示 9 个场景
```

### 问题 3: SSL 证书错误

**症状**:
```
curl: (60) server certificate verification failed
```

**解决**:
```bash
# 使用 -k 参数跳过 SSL 验证
curl -fsSLk https://linuxstudio.org/heaven-cn.sh | bash

# 或者手动下载时使用 --no-check-certificate
wget --no-check-certificate https://github.com/...
```

### 问题 4: 日志为空

**症状**:
- `/opt/linuxstudio/logs/linuxstudio.log` 不存在或为空

**原因**:
- 日志目录不存在
- 权限不足

**解决**:
```bash
# 创建日志目录
sudo mkdir -p /opt/linuxstudio/logs
sudo chmod 755 /opt/linuxstudio/logs

# 运行 xkl 命令生成日志
xkl status

# 检查日志
cat /opt/linuxstudio/logs/linuxstudio.log
```

### 问题 5: 嵌入式系统安装失败

**症状**:
- dpkg 或 rpm 不可用
- 依赖包无法安装

**解决**:
```bash
# 使用手动安装方法（不依赖包管理器）
cd /tmp
wget --no-check-certificate \
  https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.2_debian-11_armhf.deb

# 手动解压和安装
ar x linuxstudio_1.1.2_debian-11_armhf.deb
tar -xzf data.tar.gz

# 复制文件到系统目录
cp -rf usr/* /usr/
cp -rf opt/* /opt/
cp -rf etc/* /etc/

# 设置权限
chmod +x /usr/bin/xkl
ln -sf /usr/bin/xkl /usr/bin/linuxstudio

# 创建必要目录
mkdir -p /opt/linuxstudio/{plugins,components,data,logs,scenes}
mkdir -p /etc/linuxstudio

# 验证
xkl --version
```

## 📊 版本对照表

| 版本 | 发布日期 | scene 命令 | i18n 支持 | 嵌入式优化 |
|-----|---------|-----------|----------|-----------|
| v1.0.0 | 2025-10-28 | ❌ | ❌ | ❌ |
| v1.1.1 | 2025-11-02 | ✅ | ✅ | ✅ |
| v1.1.2 | 2025-11-03 | ✅ | ✅ | ✅ |

### 如何确认你的版本

```bash
# 检查版本号
xkl --version

# 检查功能
xkl scene list        # v1.1.1+ 支持
xkl status            # 所有版本支持
xkl plugin list       # 所有版本支持

# 检查中文支持
LANG=zh_CN.UTF-8 xkl --help  # v1.1.1+ 显示中文
LANG=en_US.UTF-8 xkl --help  # 显示英文
```

## 🛠️ 高级调试

### 使用 strace 跟踪系统调用

```bash
# 安装 strace（如果可用）
apt install strace  # Debian/Ubuntu
yum install strace  # CentOS/RHEL

# 跟踪 xkl 执行
strace -f xkl scene list 2>&1 | tee /tmp/xkl_trace.log

# 查看文件访问
grep open /tmp/xkl_trace.log

# 查看执行的程序
grep execve /tmp/xkl_trace.log
```

### 检查依赖库

```bash
# 检查 xkl 依赖的动态库
ldd /usr/bin/xkl

# 应该显示类似：
# linux-vdso.so.1
# libpthread.so.0 => /lib/arm-linux-gnueabihf/libpthread.so.0
# libstdc++.so.6 => /usr/lib/arm-linux-gnueabihf/libstdc++.so.6
# libgcc_s.so.1 => /lib/arm-linux-gnueabihf/libgcc_s.so.1
# libc.so.6 => /lib/arm-linux-gnueabihf/libc.so.6
```

### 从源码编译调试版本

```bash
# 克隆代码
git clone https://github.com/happykl-cn/LinuxStudio.git
cd LinuxStudio

# 编译调试版本
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug
make -j$(nproc)

# 直接运行（带调试符号）
./bin/xkl scene list

# 使用 gdb 调试
gdb ./bin/xkl
(gdb) run scene list
(gdb) bt  # 显示堆栈
```

## 📞 获取帮助

如果以上方法都无法解决问题，请：

1. **收集诊断信息**:
   ```bash
   /tmp/linuxstudio_diagnose.sh > /tmp/diagnose_report.txt
   ```

2. **提交 Issue**:
   - 访问: https://github.com/happykl-cn/LinuxStudio/issues
   - 附上诊断报告
   - 说明你的系统信息（OS、架构）
   - 描述复现步骤

3. **社区讨论**:
   - 查看已有的 Issues 和 Discussions
   - 搜索类似问题的解决方案

---

**最后更新**: 2025-11-03  
**适用版本**: v1.1.2+

