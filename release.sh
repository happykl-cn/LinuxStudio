#!/bin/bash
#
# LinuxStudio Release Script
# Usage: ./release.sh [version]
# Example: ./release.sh 1.0.0
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Check if version is provided
if [ -z "$1" ]; then
    error "Usage: $0 <version>
    
Example: $0 1.0.0

This will:
1. Update version in CMakeLists.txt
2. Run tests
3. Create git tag
4. Push to GitHub (triggers CI/CD)
"
fi

VERSION="$1"
TAG="v${VERSION}"

echo ""
info "🚀 Releasing LinuxStudio ${VERSION}"
echo ""

# Step 1: Check if we're on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    warn "You are on branch '$CURRENT_BRANCH', not 'main'"
    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Step 2: Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    error "You have uncommitted changes. Please commit or stash them first."
fi

# Step 3: Update version in CMakeLists.txt
info "Updating version in CMakeLists.txt..."
# 检测操作系统，macOS 的 sed 需要 -i '' 而不是 -i
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/VERSION [0-9][0-9.]*)/VERSION ${VERSION})/" CMakeLists.txt
else
    sed -i "s/VERSION [0-9][0-9.]*)/VERSION ${VERSION})/" CMakeLists.txt
fi
git add CMakeLists.txt
git commit -m "chore: bump version to ${VERSION}" 2>/dev/null || info "Version already updated"

# Step 4: Build and test
info "Building and testing..."
if [ ! -d "build" ]; then
    mkdir build
fi

cd build
cmake .. -DCMAKE_BUILD_TYPE=Release 2>/dev/null || cmake .. -DCMAKE_BUILD_TYPE=Release

# 检测 CPU 核心数（跨平台）
if command -v nproc &>/dev/null; then
    CORES=$(nproc)
elif command -v sysctl &>/dev/null; then
    CORES=$(sysctl -n hw.ncpu)
else
    CORES=2
fi

cmake --build . -j${CORES}

info "Testing binary..."
./bin/xkl --version || error "Binary test failed"

info "Creating test package..."
cpack -G DEB

info "All tests passed ✅"
cd ..

# Step 5: Create changelog
info "Creating changelog..."
cat > /tmp/release_notes.md <<EOF
## LinuxStudio ${VERSION}

### 🚀 Installation

#### Ubuntu/Debian
\`\`\`bash
wget https://github.com/happykl-cn/LinuxStudio/releases/download/${TAG}/linuxstudio_${VERSION}_ubuntu-22.04_amd64.deb
sudo dpkg -i linuxstudio_*.deb
\`\`\`

#### CentOS/RHEL
\`\`\`bash
wget https://github.com/happykl-cn/LinuxStudio/releases/download/${TAG}/linuxstudio-${VERSION}-1.el7.x86_64.rpm
sudo rpm -ivh linuxstudio-*.rpm
\`\`\`

#### One-Click Install
\`\`\`bash
curl -fsSL https://raw.githubusercontent.com/happykl-cn/LinuxStudio/main/heaven.sh | sudo bash
\`\`\`

### ✨ What's New

- TODO: Add release notes here

### 📦 Packages

- Ubuntu 18.04, 20.04, 22.04 (.deb)
- Debian 10, 11 (.deb)
- CentOS 7, Rocky Linux 8, 9 (.rpm)
- Fedora 36+ (.rpm)

### 📚 Documentation

- [README](https://github.com/happykl-cn/LinuxStudio/blob/main/README.md)
- [Developer Guide](https://github.com/happykl-cn/LinuxStudio/blob/main/DEVELOPER_GUIDE.md)
- [Installation Guide](https://github.com/happykl-cn/LinuxStudio/blob/main/INSTALLATION_GUIDE.md)
EOF

# Step 6: Review release notes
info "Release notes created. Please edit if needed:"
cat /tmp/release_notes.md
echo ""
read -p "Edit release notes? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ${EDITOR:-vim} /tmp/release_notes.md
fi

# Step 7: Create git tag
info "Creating git tag ${TAG}..."
if git rev-parse "$TAG" >/dev/null 2>&1; then
    warn "Tag ${TAG} already exists!"
    read -p "Delete and recreate? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git tag -d "$TAG"
        git push origin ":refs/tags/${TAG}" 2>/dev/null || true
    else
        exit 1
    fi
fi

git tag -a "$TAG" -F /tmp/release_notes.md

# Step 8: Push
info "Ready to push to GitHub!"
echo ""
echo "This will:"
echo "  1. Push commits to origin/main"
echo "  2. Push tag ${TAG}"
echo "  3. Trigger GitHub Actions to build and release"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    warn "Aborted. Tag created locally but not pushed."
    info "To push manually: git push origin main && git push origin ${TAG}"
    exit 0
fi

info "Pushing to GitHub..."
git push origin main
git push origin "$TAG"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
info "✅ Release ${VERSION} initiated!"
echo ""
info "GitHub Actions will now:"
info "  1. Build on multiple Linux distros"
info "  2. Create packages (.deb, .rpm)"
info "  3. Run tests"
info "  4. Create GitHub Release"
info "  5. Upload packages"
echo ""
info "Monitor progress at:"
REPO_URL=$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git\?/\1/')
info "  https://github.com/${REPO_URL}/actions"
echo ""
info "Release will be available at:"
info "  https://github.com/${REPO_URL}/releases/tag/${TAG}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

