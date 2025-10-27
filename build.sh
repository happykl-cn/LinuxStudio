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

# 配置
echo -e "${YELLOW}Configuring project...${NC}"
cmake .. -DCMAKE_BUILD_TYPE=Release

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

