# 在 Debian 12 (arm64) 上从源码编译和安装 OpenZFS

本仓库包含一个脚本，用于在 Debian 12 (arm64) 系统上自动完成从源码编译和安装 OpenZFS 的过程。

## 描述

脚本 `build_zfs_on_debian.sh` 自动化了运行 OpenZFS 所需的全部工作流程，包括：
* 安装所有必要的编译依赖包。
* 下载官方 OpenZFS 源码。
* 编译并安装 ZFS 模块和工具。
* 加载新编译的内核模块。
* 在安装后清理所有临时文件。

## 环境要求

* **操作系统**: Debian 12 (arm64)
* **权限**: 脚本必须以 `root` 权限运行 (例如，使用 `sudo`)。

## 如何使用

```curl -sSL https://raw.githubusercontent.com/xkatld/debian12-arm64-zfs/main/build_zfs_on_debian.sh | sudo bash```

1.  赋予脚本可执行权限：
    ```sh
    chmod +x build_zfs_on_debian.sh
    ```

2.  使用 `sudo` 执行脚本：
    ```sh
    sudo ./build_zfs_on_debian.sh
    ```

脚本将处理余下的所有过程。完成后，它将显示 ZFS 池的状态以验证模块是否已正确加载。

## 日志记录

脚本在执行过程中会自动记录所有输出的详细日志。

* **日志位置**: 所有日志文件都保存在 `/var/log/zfs_build_logs/` 目录下。
* **文件名**: 每个日志文件都会根据执行时间命名，格式为 `zfs_build_YYYYMMDD_HHMMSS.log`。
* **用途**: 如果编译或安装过程中出现任何问题，您可以查阅此日志文件以获取详细的错误信息，方便进行调试。

## 配置

您可以通过修改脚本顶部的 `ZFS_VER` 变量来更改想要安装的 OpenZFS 版本。

```shell
# -- 自定义ZFS版本 (您可以根据需要修改)
ZFS_VER="2.2.6"
