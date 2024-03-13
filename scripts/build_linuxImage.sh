#!/bin/bash -e
echo "123"

BAO="bao-hypervisor"
PLATFORM="qemu-aarch64-virt"
BAO_DEMOS_WRKDIR_SRC="/home/afonso/baopi/wrkdir/src"
BAO_DIR="/home/afonso/baopi/wrkdir/src/$BAO"
ARCH="arm64"
WRKDIR_IMGS="/home/afonso/baopi/wrkdir/imgs"
CONFIG_REPO="/home/afonso/baopi/wrkdir/cfgs"
CROSS_COMPILE="/home/afonso/baopi/wrkdir/linuxguest/buildroot/output/host/bin/aarch64-linux-"
BAO_DEMOS_LINUX="/home/afonso/baopi/wrkdir/linuxguest"
BAO_DEMOS_LINUX_VERSION="v6.1"

BAO_DEMOS_LINUX_CFG_FRAG="$(ls /home/afonso/baopi/wrkdir/linuxguest/cfgs/base.config /home/afonso/baopi/wrkdir/linuxguest/cfgs/$ARCH.config 2> /dev/null)"
BAO_DEMOS_BUILDROOT="$BAO_DEMOS_WRKDIR_SRC/buildroot"
BAO_DEMOS_BUILDROOT_DEFCFG="$BAO_DEMOS_LINUX/cfgs/buildroot.config"
echo "123"

export BAO_DEMOS_LINUX_SRC=$BAO_DEMOS_WRKDIR_SRC/linux-$BAO_DEMOS_LINUX_VERSION

cd $BAO_DEMOS_BUILDROOT
make defconfig BR2_DEFCONFIG=$BAO_DEMOS_BUILDROOT_DEFCFG
make linux-reconfigure all