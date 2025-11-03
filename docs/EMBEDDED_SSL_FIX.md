# 嵌入式系统 SSL 证书问题解决方案

## 问题描述

在嵌入式系统（如 STM32MP1 ATK-MP157）上运行安装脚本时，可能会遇到 SSL 证书验证失败的错误：

```bash
curl: (60) server certificate verification failed. CAfile: /etc/ssl/certs/ca-certificates.crt CRLfile: none
```

## 原因

嵌入式系统的常见问题：
1. **CA 证书不完整或过期** - 系统预装的 CA 证书可能不完整
2. **系统时间不正确** - SSL 证书验证依赖系统时间
3. **证书链缺失** - 缺少中间证书
4. **存储空间限制** - 无法安装完整的证书包

## 解决方案

### 方案 1: 使用 -k 参数（推荐）

在命令行中直接跳过 SSL 验证：

```bash
# 中文版
curl -fsSLk https://linuxstudio.org/heaven-cn.sh | bash

# 英文版
curl -fsSLk https://linuxstudio.org/heaven.sh | bash
```

**说明**：
- `-k` 或 `--insecure` 参数会跳过 SSL 证书验证
- 脚本内部已经实现了自动降级，会尝试使用 `-k` 参数

### 方案 2: 手动下载脚本

如果网络有问题，可以先下载脚本再执行：

```bash
# 下载脚本（跳过证书验证）
curl -k -o /tmp/heaven-cn.sh https://linuxstudio.org/heaven-cn.sh

# 执行脚本
bash /tmp/heaven-cn.sh
```

### 方案 3: 更新 CA 证书（如果可能）

如果系统允许，可以尝试更新 CA 证书：

```bash
# Debian/Ubuntu 系统
apt-get update && apt-get install -y ca-certificates

# 更新证书
update-ca-certificates
```

### 方案 4: 检查系统时间

确保系统时间正确：

```bash
# 查看当前时间
date

# 如果时间不正确，设置正确时间（需要 root）
date -s "2024-01-01 12:00:00"
```

## 脚本内置处理

脚本已经内置了 SSL 证书处理逻辑：

1. **自动检测**：首先尝试正常 SSL 验证下载
2. **错误识别**：检测到 SSL 证书错误时自动降级
3. **跳过验证**：在嵌入式模式下自动使用 `-k` 参数
4. **用户提示**：显示警告信息但不中断安装

### 工作流程

```
尝试正常下载（带 SSL 验证）
    ↓
失败？检查错误信息
    ↓
SSL 证书错误？
    ↓
显示警告："SSL 证书验证失败，正在跳过验证（嵌入式系统兼容模式）..."
    ↓
使用 -k 参数重试
    ↓
成功下载并继续安装
```

## 安全说明

⚠️ **重要**：跳过 SSL 验证会降低安全性，可能遭受中间人攻击。但在嵌入式系统上，这可能是唯一的选择。

**建议**：
- 仅在受信任的网络环境中使用
- 如果可以，优先更新系统 CA 证书
- 考虑使用离线安装方法

## 离线安装

如果网络问题持续，可以考虑：

1. **从其他设备下载安装包**
   ```bash
   # 在其他设备上下载
   wget https://github.com/happykl-cn/LinuxStudio/releases/latest/download/linuxstudio_1.1.1_debian-11_armhf.deb
   
   # 传输到嵌入式设备
   scp linuxstudio_1.1.1_debian-11_armhf.deb root@embedded-device:/tmp/
   
   # 在嵌入式设备上安装
   dpkg -i /tmp/linuxstudio_1.1.1_debian-11_armhf.deb
   ```

2. **从源码编译**
   ```bash
   git clone https://github.com/happykl-cn/LinuxStudio.git
   cd LinuxStudio
   ./build.sh
   cd build
   sudo cmake --install .
   ```

## 测试

在嵌入式系统上测试：

```bash
# 测试 SSL 连接（会失败）
curl -fsSL https://github.com

# 测试跳过验证（应该成功）
curl -fsSLk https://github.com

# 运行安装脚本（自动处理）
curl -fsSLk https://linuxstudio.org/heaven-cn.sh | bash
```

## 相关文档

- [嵌入式兼容性指南](EMBEDDED_COMPATIBILITY.md)
- [快速安装指南](QUICK_INSTALL_EMBEDDED.md)
- [安装流程对比](INSTALLATION_FLOW_COMPARISON.md)

