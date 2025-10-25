#!bin/bash/
LANG=en_US.UTF-8
echo "Checking The System..."
echo "系统自检中"

if [ $(whoami) != "root" ];then
    echo "PLEASE ROOT"\
    echo "请使用ROOT账户"
    exit 0
fi
universal_install() {
    local pkg=$1
    
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        case $ID in
            debian|ubuntu|linuxmint|kali)  
                echo "检测到 Debian 系发行版 ($ID)，使用 APT 安装 $pkg"
                sudo apt update && sudo apt install -y "$pkg"
                ;;
            fedora|rhel|centos|rocky|almalinux)
                echo "检测到 RedHat 系发行版 ($ID)，使用 YUM/DNF 安装 $pkg"
                if command -v dnf >/dev/null; then
                    sudo dnf install -y "$pkg"
                else
                    sudo yum install -y "$pkg"
                fi
                ;;
            arch|manjaro)
                echo "检测到 Arch 系发行版 ($ID)，使用 Pacman 安装 $pkg"
                sudo pacman -Sy --noconfirm "$pkg"
                ;;
            opensuse*)
                echo "检测到 openSUSE ($ID)，使用 Zypper 安装 $pkg"
                sudo zypper install -y "$pkg"
                ;;
            *)
                echo "不支持的发行版: $ID"
                return 1
                ;;
        esac
    else
        echo "无法检测发行版"
        return 1
    fi
}

check_install() {
    local pkg=$1
    if [ $? -eq 0 ]; then
        echo "✅ $pkg 安装成功"
    else
        echo "❌ $pkg 安装失败,请移步社区进行文档查阅或发帖求助"
    fi
    echo "----------------------------------------"
}

echo "curl installing..."
echo "========================================"
universal_install "curl"
check_install "curl"
echo "fking done!!!"
echo "请确认环境干净"
echo "Please make sure this is a clean linux!"
echo "请确认环境干净"
echo "Please make sure this is a clean linux!"
echo "请确认环境干净"
echo "Please make sure this is a clean linux!"
echo "重要的事情说三遍"
echo "Important things I spoke for thrice"
echo "请确认(输入 Y/N/IDONTGIVEAFUKINGSHIT)"
echo "Are you sure?!!(Please enter Y/N/IDONTGIVEAFUKINGSHIT):"
read TF
if [ "$TF" = "N" ] || [ "$TF" = "n" ] ||[ "$TF" = "IDONTGIVEAFUKINGSHIT" ]; then
    echo "GOODBYE"
    exit 0
fi
sudo universal_install "figlet"
figlet [-f isometric1] [-m fitted] LinuxStudio
echo "LinuxStudio.org" 
echo "Presented by Dino. Studio" 
InstallLogFile="/tmp/LinuxStudioInstallLog.log"
if [ -f "$InstallLogFile" ];then
    rm -f $InstallLogFile
fi
exec > >(tee -a "$InstallLogFile") 2>&1

curl -sS --connect-timeout 10 -m 10 https://io.linuxstudio.org/totalCount > /dev/null 2>&1


echo "Now I will install:"
echo "- GUNC"
echo "- vcpkg" 
echo "- vim"
echo "- cmake"
echo "- git"
echo ""
echo "The installation will begin in 10 seconds. Please confirm..."
echo "Press Ctrl+C to cancel"
echo ""

for i in {10..1}; do
    case $i in
        10|9|8) color="\033[1;32m" ;;
        7|6|5) color="\033[1;33m" ;;
        *) color="\033[1;31m" ;;
    esac
    printf "\r${color}Countdown: %2d seconds...\033[0m" $i
    sleep 1
done

printf "\r\033[1;36mStarting installation now...\033[0m\n"
echo ""

cd ~
setup_path="/www"
python_bin=$setup_path/server/panel/pyenv/bin/python
cpu_cpunt=$(cat /proc/cpuinfo|grep processor|wc -l)
