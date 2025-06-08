#!/bin/bash

LOG_DIR="/var/log/zfs_build_logs"
mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/zfs_build_$(date +%Y%m%d_%H%M%S).log"
exec &> >(tee -a "$LOG_FILE")

set -e
set -u

ZFS_VER="2.2.6"

echo ">>> 本次操作的完整日志将保存在: ${LOG_FILE}"
echo ""

echo ">>> [1/5] 开始在 Debian 12 arm64 上编译安装 OpenZFS 版本 ${ZFS_VER}"
echo ">>> 内核版本: $(uname -r)"

if [ "$(id -u)" -ne 0 ]; then
   echo "错误: 此脚本需要以root权限运行。请使用 'sudo'。" >&2
   exit 1
fi

echo ""
echo ">>> [2/5] 正在安装编译依赖包..."

apt-get update

apt-get install -y \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    linux-headers-$(uname -r) \
    libtirpc-dev \
    libblkid-dev \
    uuid-dev \
    zlib1g-dev \
    libattr1-dev \
    libacl1-dev \
    libudev-dev \
    libssl-dev \
    libelf-dev \
    python3 \
    python3-dev \
    python3-setuptools \
    python3-cffi \
    libffi-dev

echo ">>> 依赖包安装完成。"

echo ""
echo ">>> [3/5] 正在下载 OpenZFS v${ZFS_VER} 源码..."

WORKDIR=$(mktemp -d)
cd "${WORKDIR}"

curl -sL "https://github.com/openzfs/zfs/releases/download/zfs-${ZFS_VER}/zfs-${ZFS_VER}.tar.gz" -o "zfs-${ZFS_VER}.tar.gz"

tar -xzf "zfs-${ZFS_VER}.tar.gz"
cd "zfs-${ZFS_VER}"

echo ">>> 源码下载并解压至 ${PWD}"

echo ""
echo ">>> [4/5] 正在配置、编译、安装和注册 ZFS... (这可能需要较长时间)"

./autogen.sh
./configure
make -j$(nproc)
make install
depmod -a
ldconfig
modprobe zfs

echo ">>> ZFS 编译、安装和模块加载完成。"

echo ""
echo ">>> [5/5] 正在清理临时文件..."

cd /
rm -rf "${WORKDIR}"

echo ""
echo "=============================================================================="
echo " ZFS v${ZFS_VER} 已成功安装并加载!"
echo ""
echo " 您现在可以使用 'zpool' 和 'zfs' 命令了。"
echo " 运行 'zpool status' 来检查ZFS模块是否正常工作。"
echo "=============================================================================="

zpool status

exit 0
