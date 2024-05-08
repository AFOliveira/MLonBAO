export ROOT_DIR=$(realpath .)
export ROOTFS_DIR=$ROOT_DIR/rootfs
export LINUX_VERSION=v6.1
export LINUX_DIR=$ROOT_DIR/linux
export BUILDROOT_DIR=$ROOT_DIR/buildroot
export BUILD_DIR=$ROOT_DIR/build
export ARCH=aarch64
export PLATFORM=zcu104
export LINUX_CFG_FRAG=$(ls $ROOT_DIR/configs/base.config\
        $ROOT_DIR/configs/$ARCH.config\
        $ROOT_DIR/configs/$PLATFORM.config 2> /dev/null)

        
export BUILDROOT_DEFCFG=$ROOT_DIR/configs/buildroot/tflite.config


export CROSS_COMPILE=aarch64-none-elf-
export WRKDIR_RPI_IMGS=$ROOT_DIR/imgs

mkdir -p $BUILD_DIR

echo "------> Creating Buildroot"

# Buildroot rootfs
git clone https://github.com/buildroot/buildroot.git --depth 1 --branch 2022.11
cd $ROOT_DIR/buildroot

make defconfig BR2_DEFCONFIG=$BUILDROOT_DEFCFG

echo "------> Creating Linux"

# Linux Kernel
cd $ROOT_DIR
git clone https://github.com/torvalds/linux.git --depth 1 --branch $LINUX_VERSION

export LINUX_OVERRIDE_SRCDIR=$LINUX_DIR
cd $ROOT_DIR/buildroot
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

cp $BUILD_DIR/linux.bin $ROOT_DIR/wrkdir/imgs/linux.bin
cp $BUILD_DIR/linux.dtb $ROOT_DIR/wrkdir/imgs/linux.dtb
cp $BUILD_DIR/linux.elf $ROOT_DIR/wrkdir/imgs/linux.elf
