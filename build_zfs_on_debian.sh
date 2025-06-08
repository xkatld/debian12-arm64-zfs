#!/bin/bash

# ==============================================================================
#  ZFS on Debian 12 (arm64) - Source Build Script (v2 - Corrected)
# ==============================================================================
#
#  说明:
#  本脚本基于 zfs_build_dkms_hints 仓库中的 el9 (RHEL) 脚本适配而来。
#  它会自动在 Debian 12 arm64 环境下下载、编译并安装 OpenZFS。
#
#  运行方式:
#  1. 保存此脚本为 build_zfs_on_debian.sh
#  2. chmod +x build_zfs_on_debian.sh
#  3. sudo ./build_zfs_on_debian.sh
#
# ==============================================================================

# -- 安全设置: 如果任何命令失败，则立即退出脚本
set -e
# -- 如果使用了未定义的变量，则立即退出
set -u

# -- 自定义ZFS版本 (您可以根据需要修改)
ZFS_VER="2.2.6"

# -- 脚本开始，打印信息
echo ">>> [1/5] 开始在 Debian 12 arm64 上编译安装 OpenZFS 版本 ${ZFS_VER}"
echo ">>> 内核版本: $(uname -r)"

# -- 检查是否以root权限运行
if [ "$(id -u)" -ne 0 ]; then
   echo "错误: 此脚本需要以root权限运行。请使用 'sudo'。" >&2
   exit 1
fi

# ==============================================================================
#  步骤 2: 安装编译所需的依赖包
# ==============================================================================
echo ""
echo ">>> [2/5] 正在安装编译依赖包..."

# 更新软件包列表
apt-get update

# 安装从 el9 脚本翻译过来的 Debian 依赖包 (已修正包名)
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

# ==============================================================================
#  步骤 3: 下载并解压 OpenZFS 源码
# ==============================================================================
echo ""
echo ">>> [3/5] 正在下载 OpenZFS v${ZFS_VER} 源码..."

# 创建一个临时工作目录
WORKDIR=$(mktemp -d)
cd "${WORKDIR}"

# 从官方GitHub下载源码包
curl -sL "https://github.com/openzfs/zfs/releases/download/zfs-${ZFS_VER}/zfs-${ZFS_VER}.tar.gz" -o "zfs-${ZFS_VER}.tar.gz"

# 解压缩
tar -xzf "zfs-${ZFS_VER}.tar.gz"
cd "zfs-${ZFS_VER}"

echo ">>> 源码下载并解压至 ${PWD}"

# ==============================================================================
#  步骤 4: 配置、编译和安装
# ==============================================================================
echo ""
echo ">>> [4/5] 正在配置、编译和安装 ZFS... (这可能需要较长时间)"

# 1. 生成配置脚本
./autogen.sh

# 2. 配置编译选项 (与原脚本保持一致)
./configure

# 3. 开始编译 (使用与CPU核心数相同的线程数以加快速度)
make -j$(nproc)

# 4. 安装到系统中
make install

# 5. 加载内核模块
ldconfig
modprobe zfs

echo ">>> ZFS 编译和安装完成。"

# ==============================================================================
#  步骤 5: 清理并完成
# ==============================================================================
echo ""
echo ">>> [5/5] 正在清理临时文件..."

# 返回到上级目录并删除临时工作目录
cd /
rm -rf "${WORKDIR}"

echo ""
echo "=============================================================================="
echo " ZFS v${ZFS_VER} 已成功安装!"
echo ""
echo " 您现在可以使用 'zpool' 和 'zfs' 命令了。"
echo " 运行 'zpool status' 来检查ZFS模块是否正常工作。"
echo "=============================================================================="

# 检查zpool状态作为最后的验证
zpool status

exit 0
