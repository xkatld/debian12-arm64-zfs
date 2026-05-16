apt update && \
ARCH=$(dpkg --print-architecture) && \
DEBIAN_VER=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2) && \
if [ "$ARCH" = "arm64" ] && [ "$DEBIAN_VER" = "11" ]; then \
  IMG="linux-image-5.10.0-43-arm64"; \
  HDR="linux-headers-5.10.0-43-arm64"; \
  KEEP="5.10.0-43-arm64"; \
elif [ "$ARCH" = "amd64" ] && [ "$DEBIAN_VER" = "11" ]; then \
  IMG="linux-image-5.10.0-43-amd64"; \
  HDR="linux-headers-5.10.0-43-amd64"; \
  KEEP="5.10.0-43-amd64"; \
elif [ "$ARCH" = "arm64" ] && [ "$DEBIAN_VER" = "12" ]; then \
  IMG="linux-image-6.1.0-48-arm64"; \
  HDR="linux-headers-6.1.0-48-arm64"; \
  KEEP="6.1.0-48-arm64"; \
elif [ "$ARCH" = "amd64" ] && [ "$DEBIAN_VER" = "12" ]; then \
  IMG="linux-image-6.1.0-48-amd64"; \
  HDR="linux-headers-6.1.0-48-amd64"; \
  KEEP="6.1.0-48-amd64"; \
elif [ "$ARCH" = "arm64" ] && [ "$DEBIAN_VER" = "13" ]; then \
  IMG="linux-image-6.12.88+deb13-arm64"; \
  HDR="linux-headers-6.12.88+deb13-arm64"; \
  KEEP="6.12.88+deb13-arm64"; \
elif [ "$ARCH" = "amd64" ] && [ "$DEBIAN_VER" = "13" ]; then \
  IMG="linux-image-6.12.88+deb13-amd64"; \
  HDR="linux-headers-6.12.88+deb13-amd64"; \
  KEEP="6.12.88+deb13-amd64"; \
else \
  echo -e "\n\033[31m[错误]：不支持的组合: $ARCH / Debian $DEBIAN_VER\033[0m"; \
  exit 1; \
fi && \
apt install -y "$IMG" "$HDR" && \
ls /boot/vmlinuz-*$KEEP* > /dev/null 2>&1 && \
(find /boot -maxdepth 1 -type f \( -name "vmlinuz-*" -o -name "initrd.img-*" -o -name "System.map-*" -o -name "config-*" \) ! -name "*$KEEP*" -delete; \
update-grub; echo -e "\n\033[32m[成功]：内核已更新 ($ARCH)，请手动执行 reboot 重启系统。\033[0m") || \
echo -e "\n\033[31m[错误]：内核包获取失败或安装未成功，操作已拦截。\033[0m"
