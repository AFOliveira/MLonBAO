#!/bin/bash -e

PLATFORM="qemu-aarch64-virt"
BAO_DEMOS_WRKDIR_SRC="/home/afonso/evaluation-guests/wrkdir"
BAO_DIR="/home/afonso/baopi/wrkdir/src/bao"
ARCH="arm64"
WRKDIR_IMGS="/home/afonso/evaluation-guests/wrkdir"
CROSS_COMPILE="/home/afonso/arm-gnu-toolchain-13.2.rel1-x86_64-aarch64-none-elf/arm-gnu-toolchain-13.2.Rel1-x86_64-aarch64-none-elf/bin/aarch64-none-elf-"
BAO_DEMOS_LINUX="/home/afonso/baopi/wrkdir/linuxguest"
BAO_DEMOS_LINUX_VERSION="v6.1"

BAO_DEMOS_LINUX_CFG_FRAG="$(ls /home/afonso/evaluation-guests/benchmarks/linux_mibench/configs/base.config /home/afonso/evaluation-guests/benchmarks/linux_mibench/configs/aarch64.config 2> /dev/null)"
BAO_DEMOS_BUILDROOT="$BAO_DEMOS_WRKDIR_SRC/buildroot"
BAO_DEMOS_BUILDROOT_DEFCFG="/home/afonso/evaluation-guests/configs/test.config"

export BAO_DEMOS_LINUX_SRC=$BAO_DEMOS_WRKDIR_SRC/linux-$BAO_DEMOS_LINUX_VERSION

cd $BAO_DEMOS_BUILDROOT
make defconfig BR2_DEFCONFIG=$BAO_DEMOS_BUILDROOT_DEFCFG
make linux-reconfigure all