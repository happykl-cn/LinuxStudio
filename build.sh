#!/bin/bash
#==============================================================================
# LinuxStudio C++ Build Script
#==============================================================================

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     LinuxStudio C++ Build Script                  ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# 显示架构信息
ARCH=$(uname -m)
echo -e "${YELLOW}System Information:${NC}"
echo "  Architecture: ${ARCH}"
echo ""

# 检查依赖
echo -e "${YELLOW}Checking dependencies...${NC}"

if ! command -v cmake &> /dev/null; then
    echo -e "${RED}Error: cmake not found${NC}"
    echo "Install: sudo apt-get install cmake"
    exit 1
fi

if ! command -v g++ &> /dev/null; then
    echo -e "${RED}Error: g++ not found${NC}"
    echo "Install: sudo apt-get install build-essential"
    exit 1
fi

echo -e "${GREEN}✓ Dependencies OK${NC}"
echo ""

# 创建构建目录
echo -e "${YELLOW}Creating build directory...${NC}"
mkdir -p build
cd build

# 检测架构
ARCH=$(uname -m)
echo -e "${YELLOW}Detected architecture: ${ARCH}${NC}"

# 检测 ARM 版本（如果是 ARM32）
if [[ "$ARCH" =~ ^arm ]]; then
    if [ -f /proc/cpuinfo ]; then
        ARM_VERSION=$(grep -m1 "CPU architecture" /proc/cpuinfo | awk '{print $3}')
        echo "  ARM Version: ${ARM_VERSION}"
        if [ -n "$ARM_VERSION" ] && [ "$ARM_VERSION" -ge 7 ]; then
            echo "  Features: ARMv7 or higher (NEON support likely)"
        fi
    fi
fi

# 配置
echo -e "${YELLOW}Configuring project...${NC}"
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    echo -e "${GREEN}Building for ARM64 (aarch64) architecture${NC}"
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_PROCESSOR=aarch64
elif [ "$ARCH" = "armv7l" ] || [ "$ARCH" = "armv7" ]; then
    echo -e "${GREEN}Building for ARM32 (ARMv7) architecture${NC}"
    echo -e "${GREEN}Optimizations: NEON SIMD, Hard Float${NC}"
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_PROCESSOR=armv7l
elif [ "$ARCH" = "armv6l" ] || [ "$ARCH" = "armv6" ]; then
    echo -e "${GREEN}Building for ARM32 (ARMv6) architecture${NC}"
    echo -e "${YELLOW}Note: ARMv6 has limited optimizations (Raspberry Pi 1/Zero)${NC}"
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_PROCESSOR=armv6l
elif [[ "$ARCH" =~ ^arm ]]; then
    echo -e "${GREEN}Building for ARM32 (generic) architecture${NC}"
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_PROCESSOR=arm
elif [ "$ARCH" = "x86_64" ]; then
    echo -e "${GREEN}Building for x86_64 architecture${NC}"
    cmake .. -DCMAKE_BUILD_TYPE=Release
else
    echo -e "${YELLOW}Building for architecture: ${ARCH}${NC}"
    cmake .. -DCMAKE_BUILD_TYPE=Release
fi

# 编译
echo -e "${YELLOW}Building project...${NC}"
cmake --build . -j$(nproc)

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Build Completed Successfully!                 ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Binary location:${NC} $(pwd)/bin/xkl"
echo ""
echo -e "${YELLOW}To install:${NC}"
echo "  sudo cmake --install ."
echo ""
echo -e "${YELLOW}To test:${NC}"
echo "  ./bin/xkl --version"
echo "  ./bin/xkl status"
echo ""
echo -e "${YELLOW}Note:${NC} Command changed from 'linuxstudio' to 'xkl' (shorter and easier to type!)"
echo "      Both 'xkl' and 'linuxstudio' will work after installation."
echo ""

