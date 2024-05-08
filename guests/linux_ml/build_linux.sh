export ROOT_DIR=$(realpath .)
export ROOTFS_DIR=$ROOT_DIR/rootfs
export LINUX_VERSION=v6.1
export LINUX_DIR=$ROOT_DIR/linux
export BUILDROOT_DIR=$ROOT_DIR/buildroot
export BUILD_DIR=$ROOT_DIR/build
export ARCH=aarch64
export PLATFORM=rpi4
export LINUX_CFG_FRAG=$(ls $ROOT_DIR/configs/base.config\
        $ROOT_DIR/configs/$ARCH.config\
        $ROOT_DIR/configs/$PLATFORM.config 2> /dev/null)

export TFLITE_DIR=/home/goncalo/tensorflow
        
export BUILDROOT_DEFCFG=$ROOT_DIR/configs/buildroot/tflite.config


export CROSS_COMPILE=/home/goncalo/bao_hypervisor/arm-gnu-toolchain-13.2.rel1-x86_64-aarch64-none-elf/arm-gnu-toolchain-13.2.Rel1-x86_64-aarch64-none-elf/bin/aarch64-none-elf-
export WRKDIR_RPI_IMGS=$ROOT_DIR/imgs

echo "------> Cleaning repositories"

#make clean -C $ROOT_DIR/linux 
#make clean -C $ROOT_DIR/buildroot 
#make clean -C $ROOT_DIR/lloader 


mkdir -p $BUILD_DIR

echo "------> Creating Buildroot"

# Buildroot rootfs
#git clone https://github.com/buildroot/buildroot.git --depth 1 --branch 2022.11
cd $ROOT_DIR/buildroot

make defconfig BR2_DEFCONFIG=$BUILDROOT_DEFCFG

echo "------> Creating Linux"

# Linux Kernel
cd $ROOT_DIR
#git clone https://github.com/torvalds/linux.git --depth 1 --branch $LINUX_VERSION

export LINUX_OVERRIDE_SRCDIR=$LINUX_DIR
cd $ROOT_DIR/buildroot
make menuconfig
make linux-reconfigure all

#   Build Perf
cd $LINUX_DIR/tools/perf/
ARCH=arm64 CROSS_COMPILE=$BUILDROOT_DIR/output/host/bin/aarch64-buildroot-linux-gnu-
    make
mkdir -p $ROOT_DIR/rootfs/bin/
cp perf $ROOT_DIR/rootfs/bin/
#cp perf $ROOT_DIR/rootfs

cd $ROOT_DIR/buildroot
make linux-reconfigure all

# Finally, compile Linux's device tree and wrapper (needs will be need it to run
# it baremetal and over bao:
cd $ROOT_DIR
dtc devicetrees/$PLATFORM/linux.dts -o $BUILD_DIR/linux.dtb

echo "------> Creating Loader"

cd $ROOT_DIR/lloader
make ARCH=aarch64\
    IMAGE=$BUILDROOT_DIR/output/images/Image\
    DTB=$BUILD_DIR/linux.dtb\
    TARGET=$BUILD_DIR/linux

echo "------> Copying to final destination"

cp $BUILD_DIR/linux.bin $WRKDIR_RPI_IMGS/linux.bin
cp $BUILD_DIR/linux.dtb $WRKDIR_RPI_IMGS/linux.dtb
cp $BUILD_DIR/linux.elf $WRKDIR_RPI_IMGS/linux.elf

ls $WRKDIR_RPI_IMGS
