#!/bin/bash

ARCH="arm64"
PLAT="qemu_aarch64"
GUEST="linux"
DT_FILE="$GUEST-$PLAT.dts"
LINUX_LOADER="/home/afonso/baopi/wrkdir/src/lloader_linux"
#LINUX_LOADER="/home/afonso/baopi/wrkdir/linuxguest/lloader"
BUILDROOT_SRC="/home/afonso/baopi/wrkdir/src/buildroot"
BAO_LINUX_VM="linux"
CROSS_COMPILE="/home/afonso/arm-gnu-toolchain-13.2.rel1-x86_64-aarch64-none-elf/arm-gnu-toolchain-13.2.Rel1-x86_64-aarch64-none-elf/bin/aarch64-none-elf-"

dtc /home/afonso/baopi/wrkdir/src/devicetrees/linux.dts > /home/afonso/baopi/wrkdir/imgs/linux.dtb
#Wrap the kernel image and device tree blob in a single binary

make -C $LINUX_LOADER\
    ARCH=$ARCH\
    IMAGE=$BUILDROOT_SRC/output/images/Image-aarch64\
    DTB=/home/afonso/baopi/wrkdir/imgs/linux.dtb\
    TARGET=/home/afonso/baopi/wrkdir/imgs/linux