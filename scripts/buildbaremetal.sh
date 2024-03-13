#!/bin/bash

#------------------------------------------------------------------------------- Platform Setup
export PLATFORM=qemu-aarch64-virt
export CROSS_COMPILE=/home/afonso/arm-gnu-toolchain-13.2.rel1-x86_64-aarch64-none-elf/arm-gnu-toolchain-13.2.Rel1-x86_64-aarch64-none-elf/bin/aarch64-none-elf-
export BAO_DEMOS_WRKDIR_IMGS=/home/afonso/baopi/wrkdir/imgs
################################################################################

BAREMETAL_SRC=/home/afonso/baopi/wrkdir/src/bao-baremetal-guest
make clean -C $BAREMETAL_SRC
make -C $BAREMETAL_SRC PLATFORM=$PLATFORM
cp $BAREMETAL_SRC/build/$PLATFORM/baremetal.bin $BAO_DEMOS_WRKDIR_IMGS
