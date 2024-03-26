#!/bin/bash
echo 123

export ROOT_DIR=/home/afonso/evaluation-guests
export ROOTFS_DIR=$ROOT_DIR/rootfs
export LINUX_VERSION=v6.1
export LINUX_DIR=$ROOT_DIR/wrkdir/linux
export BUILDROOT_DIR=$ROOT_DIR/wrkdir/buildroot
export BUILD_DIR=$ROOT_DIR/build

ARCH="aarch64"
PLAT="qemu_aarch64"
CROSS_COMPILE="/home/afonso/gcc-arm-10.3-2021.07-x86_64-aarch64-none-elf/bin/aarch64-none-elf-"

dtc /home/afonso/baodemos/configslinux/qemu-aarch64-virt/sololinux/linux.dts -o $BUILD_DIR/linux.dtb

#Wrap the kernel image and device tree blob in a single binary
export CROSS_COMPILE=/home/afonso/evaluation-guests/wrkdir/buildroot/output/host/bin/aarch64-linux-
cd /home/afonso/evaluation-guests/benchmarks/linux_mibench/lloader

make ARCH=aarch64\
   IMAGE=/home/afonso/evaluation-guests/wrkdir/buildroot/output/images/Image\
   DTB=$BUILD_DIR/linux.dtb\
   TARGET=$BUILD_DIR/linux