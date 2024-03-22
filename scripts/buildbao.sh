#!/bin/bash

#------------------------------------------------------------------------------- Platform Setup
export PLATFORM=qemu-aarch64-virt
export CROSS_COMPILE=/home/afonso/gcc-arm-10.3-2021.07-x86_64-aarch64-none-elf/bin/aarch64-none-elf-
################################################################################

#------------------------------------------------------------------------------- Bao Config
export BAO_SRCS=/home/afonso/baodemos/bao-demos/wrkdir/srcs/bao
export CONFIG_DIR=/home/afonso/baodemos/bao-demos/wrkdir/config
export CONFIG_SETUP=baremetal-linux
export WRKDIR_IMGS=/home/afonso/evaluation-guests/build
################################################################################
echo "$WRKDIR_IMGS"
make clean -C $BAO_SRCS
#------------------------------------------------------------------------------- Build Steps
make -C $BAO_SRCS\
    PLATFORM=$PLATFORM\
    CONFIG_REPO=$CONFIG_DIR\
    CONFIG=$CONFIG_SETUP\
    CPPFLAGS=-DBAO_DEMOS_WRKDIR_IMGS=$WRKDIR_IMGS
################################################################################

#------------------------------------------------------------------------------- Outputs
cp $BAO_SRCS/bin/$PLATFORM/$CONFIG_SETUP/bao.bin /home/afonso/baodemos/bao-halfday/bl33.bin