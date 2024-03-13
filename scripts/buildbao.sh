#!/bin/bash

#------------------------------------------------------------------------------- Platform Setup
export PLATFORM=qemu-aarch64-virt
export CROSS_COMPILE=/home/afonso/arm-gnu-toolchain-13.2.rel1-x86_64-aarch64-none-elf/arm-gnu-toolchain-13.2.Rel1-x86_64-aarch64-none-elf/bin/aarch64-none-elf-
################################################################################

#------------------------------------------------------------------------------- Bao Config
export BAO_SRCS=/home/afonso/baopi/wrkdir/src/bao-hypervisor
export CONFIG_DIR=/home/afonso/baopi/wrkdir/cfgs
export CONFIG_SETUP=qemu-aarch64-virt
export WRKDIR_IMGS=/home/afonso/baopi/wrkdir/
################################################################################

make clean -C $BAO_SRCS
#------------------------------------------------------------------------------- Build Steps
make -C $BAO_SRCS\
    PLATFORM=$PLATFORM\
    CONFIG_REPO=$CONFIG_DIR\
    CONFIG=$CONFIG_SETUP
################################################################################

#------------------------------------------------------------------------------- Outputs
cp $BAO_SRCS/bin/$PLATFORM/$CONFIG_SETUP/bao.bin /home/afonso/baopi/wrkdir/imgs/bao.bin
