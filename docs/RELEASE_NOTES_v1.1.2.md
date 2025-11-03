# Release Notes - LinuxStudio v1.1.2

**Release Date**: November 3, 2025  
**Release Type**: Bug Fix Release

---

## 📋 Summary

This release fixes critical issues with scene command availability and installation updates reported by users. It also improves installation verification and embedded system compatibility.

## 🐛 Bug Fixes

### Critical Fixes

1. **Scene Command Not Available** ([#Issue])
   - **Problem**: Users reported `xkl scene apply embedded` failing with "Error: Unknown command: scene"
   - **Root Cause**: Pre-compiled packages on GitHub Releases were outdated and did not include the scene command implementation
   - **Fix**: 
     - Bumped version to v1.1.2 to trigger new builds
     - Added version verification in installation scripts
     - Post-install automatic check for scene command presence

2. **Installation Not Overwriting Old Files** ([#Issue])
   - **Problem**: Reinstalling still kept old binary version
   - **Root Cause**: Extraction did not force overwrite; `cp` might skip existing files
   - **Fix**:
     - Remove old files before copying: `rm -f /usr/bin/xkl /usr/bin/linuxstudio`
     - Use `cp -rf` to force overwrite
     - Recreate symlinks forcefully

3. **Insufficient Installation Verification**
   - **Problem**: Could not confirm if truly updated to new version after installation
   - **Root Cause**: Missing post-install version checks and feature validation
   - **Fix**:
     - Display downloaded package version (using `dpkg-deb -f`)
     - Display installed version after installation (using `xkl --version`)
     - Check binary for scene command using `strings`
     - Show warnings if old version detected

## 🔧 Improvements

### Installation Scripts (heaven-cn.sh & heaven.sh)

**Enhanced Verification**:
```bash
# Show download URL and package version
info "Download URL: $GITHUB_RELEASE/$EMBEDDED_PACKAGE"
PACKAGE_VERSION=$(dpkg-deb -f /tmp/linuxstudio_embedded.deb Version)
info "Package version: $PACKAGE_VERSION"

# Force remove old files
rm -f /usr/bin/xkl /usr/bin/linuxstudio

# Force copy new files
cp -rf usr/* /usr/
cp -rf opt/* /opt/
cp -rf etc/* /etc/

# Verify installation
INSTALLED_VERSION=$(/usr/bin/xkl --version | grep -oP 'v\d+\.\d+\.\d+')
info "✅ Installation successful! Version: $INSTALLED_VERSION"

# Check for scene command
if strings /usr/bin/xkl | grep -qi "cmdScene"; then
    info "✅ Scene command confirmed"
else
    warning "⚠️  Binary may not contain scene command"
fi
```

## 📚 Documentation

### New Documents

1. **docs/DEBUG_GUIDE.md**
   - Complete debugging guide with diagnostic script
   - Common issues and solutions
   - Version compatibility matrix
   - Advanced debugging techniques

2. **docs/DIAGNOSE_VERSION.md**
   - Quick diagnostic script
   - Version mismatch troubleshooting
   - Multiple update methods

3. **docs/FORCE_UPDATE.md**
   - Four update methods provided:
     - Method 1: Clean reinstall
     - Method 2: Manual force overwrite
     - Method 3: Check GitHub Releases version
     - Method 4: Compile from source

4. **docs/VERSION_1.1.2_CHANGELOG.md**
   - Detailed Chinese changelog
   - Technical improvements
   - User guides

## 🔄 Version Updates

| File | Old Version | New Version |
|------|-------------|-------------|
| CMakeLists.txt | 1.1.1 | 1.1.2 |
| heaven-cn.sh | 1.1.1 | 1.1.2 |
| heaven.sh | 1.1.1 | 1.1.2 |
| config.yaml | 1.1.1 | 1.1.2 |
| debian/changelog | 1.0.0-1 | 1.1.2-1 |

## 🧪 Testing

### Verification Steps

After upgrading to v1.1.2, verify with:

```bash
# 1. Check version
xkl --version
# Expected: LinuxStudio Framework v1.1.2 (C++ Core)

# 2. Test scene command
xkl scene list
# Expected: List of 9 development scenes

# 3. Apply a scene
xkl scene apply embedded
# Expected: Display embedded scene components

# 4. Check binary contents
strings /usr/bin/xkl | grep -i cmdScene
# Expected: Find scene-related strings
```

## 📦 Download

### Quick Install

```bash
# Chinese version (recommended for CN users)
curl -fsSL https://linuxstudio.org/heaven-cn.sh | sudo bash

# English version
curl -fsSL https://linuxstudio.org/heaven.sh | sudo bash
```

### Manual Download

**Debian/Ubuntu (ARM32)**:
```bash
wget https://github.com/happykl-cn/LinuxStudio/releases/download/v1.1.2/linuxstudio_1.1.2_debian-11_armhf.deb
sudo dpkg -i linuxstudio_1.1.2_debian-11_armhf.deb
```

**Debian/Ubuntu (ARM64)**:
```bash
wget https://github.com/happykl-cn/LinuxStudio/releases/download/v1.1.2/linuxstudio_1.1.2_debian-11_arm64.deb
sudo dpkg -i linuxstudio_1.1.2_debian-11_arm64.deb
```

**Debian/Ubuntu (x86_64)**:
```bash
wget https://github.com/happykl-cn/LinuxStudio/releases/download/v1.1.2/linuxstudio_1.1.2_debian-11_amd64.deb
sudo dpkg -i linuxstudio_1.1.2_debian-11_amd64.deb
```

**CentOS/RHEL/Rocky/AlmaLinux**:
```bash
wget https://github.com/happykl-cn/LinuxStudio/releases/download/v1.1.2/linuxstudio-1.1.2-1.rockylinux-9.x86_64.rpm
sudo rpm -Uvh linuxstudio-1.1.2-1.rockylinux-9.x86_64.rpm
```

## 🚨 Breaking Changes

None. This is a backward-compatible bug fix release.

## 🔮 Roadmap

### v1.1.3 (Upcoming)
- [ ] Automatic component installation
- [ ] Scene configuration persistence
- [ ] Custom scene support
- [ ] Web UI integration

### v1.2.0 (Future)
- [ ] Plugin marketplace
- [ ] Remote component repository
- [ ] Multi-server deployment
- [ ] Docker integration
- [ ] CI/CD integration

## 🙏 Acknowledgments

Special thanks to users who reported issues and helped improve LinuxStudio!

## 🔗 Links

- **GitHub Repository**: https://github.com/happykl-cn/LinuxStudio
- **Issue Tracker**: https://github.com/happykl-cn/LinuxStudio/issues
- **Release Page**: https://github.com/happykl-cn/LinuxStudio/releases/tag/v1.1.2
- **Documentation**: https://github.com/happykl-cn/LinuxStudio/tree/main/docs

---

**Full Changelog**: https://github.com/happykl-cn/LinuxStudio/compare/v1.1.1...v1.1.2

