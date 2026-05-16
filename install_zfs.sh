#!/bin/bash
set -e

apt update -y 2>/dev/null || true
apt install wget sudo -y 2>/dev/null || true

ARCH=$(dpkg --print-architecture)
DEBIAN_VER=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2)

case "${ARCH}-${DEBIAN_VER}" in
    amd64-11) MODULES_FILE="zfs-modules-amd64-5.10.0-43-amd64-zfs2.1.15.tgz" ;;
    arm64-11) MODULES_FILE="zfs-modules-arm64-5.10.0-43-arm64-zfs2.1.15.tgz" ;;
    amd64-12) MODULES_FILE="zfs-modules-amd64-6.1.0-48-amd64-zfs2.2.7.tgz" ;;
    arm64-12) MODULES_FILE="zfs-modules-arm64-6.1.0-48-arm64-zfs2.2.7.tgz" ;;
    amd64-13) MODULES_FILE="zfs-modules-amd64-6.12.88+deb13-amd64-zfs2.3.0.tgz" ;;
    arm64-13) MODULES_FILE="zfs-modules-arm64-6.12.88+deb13-arm64-zfs2.3.0.tgz" ;;
    *)
        echo "不支持的组合: 架构 ${ARCH} / Debian ${DEBIAN_VER}"
        exit 1
        ;;
esac

echo "请选择下载源: 1) Gitee 2) GitHub 3) Vpsm"
read -p "选择 [1-3, 默认1]: " SOURCE_CHOICE
case ${SOURCE_CHOICE:-1} in
    2) DOWNLOAD_BASE="https://github.com/xkatld/vpsm-download/releases/download/download" ;;
    3) DOWNLOAD_BASE="https://vpsm.link/api/download" ;;
    *) DOWNLOAD_BASE="https://gitee.com/xkatld/vpsm-download/releases/download/download" ;;
esac

echo "检测到架构: ${ARCH}, Debian ${DEBIAN_VER}"
echo "下载 ZFS 模块: ${MODULES_FILE} ..."
cd /tmp
if ! wget -q --show-progress -O "${MODULES_FILE}" "${DOWNLOAD_BASE}/${MODULES_FILE}"; then
    echo "下载失败"
    exit 1
fi

echo "创建目录..."
sudo mkdir -p /lib/modules/$(uname -r)/updates/dkms/

echo "解压模块..."
sudo tar -xzf "${MODULES_FILE}"

echo "复制模块文件..."
sudo cp zfs-modules/*.ko.xz /lib/modules/$(uname -r)/updates/dkms/

echo "更新模块依赖..."
sudo depmod -a $(uname -r)

echo "加载 ZFS 模块..."
sudo modprobe spl && sudo modprobe zfs

echo "检查 ZFS 模块是否加载成功..."
if dmesg | grep -i zfs | tail -5; then
    echo -e "\n\033[32m[成功] ZFS 模块安装完成\033[0m"
else
    echo -e "\n\033[33m[警告] 未在 dmesg 中找到 ZFS 日志，请检查是否正常\033[0m"
fi

echo "安装 ZFS 用户态工具..."
sudo apt-get install -y zfsutils-linux --no-install-recommends

echo "测试 ZFS 版本..."
zfs --version

rm -f /tmp/"${MODULES_FILE}"
rm -rf /tmp/zfs-modules
