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
export BUILDROOT_DEFCFG=$ROOT_DIR/configs/buildroot/$ARCH.config


mkdir -p $BUILD_DIR

# Buildroot rootfs
git clone https://github.com/buildroot/buildroot.git --depth 1 --branch 2022.11
cd buildroot

make defconfig BR2_DEFCONFIG=$BUILDROOT_DEFCFG
make

# Linux Kernel
cd $ROOT_DIR
git clone https://github.com/torvalds/linux.git --depth 1 --branch $LINUX_VERSION

cd $LINUX_DIR
ARCH=arm64 CROSS_COMPILE=$ROOT_DIR/buildroot/output/host/bin/aarch64-linux- make defconfig
export INITRAMFS_SRC=$BUILDROOT_DIR/output/images/rootfs.cpio
sed -i 's/CONFIG_INITRAMFS_SOURCE=""/CONFIG_INITRAMFS_SOURCE="$(INITRAMFS_SRC)"/g' .config
ARCH=arm64 CROSS_COMPILE=$ROOT_DIR/buildroot/output/host/bin/aarch64-linux- make -j$(nproc) Image

export LINUX_OVERRIDE_SRCDIR=$LINUX_DIR
cd $ROOT_DIR/buildroot
make


# Add benchmark tools to rootfs 
#    Build mibench
cd $ROOT_DIR/mibench
ARCH=arm64 CROSS_COMPILE=$BUILDROOT_DIR/output/host/bin/aarch64-linux- \
    make
cp -r $ROOT_DIR/mibench/build/* $ROOT_DIR/rootfs

#   Build Perf
cd $LINUX_DIR/tools/perf/
ARCH=arm64 CROSS_COMPILE=$BUILDROOT_DIR/output/host/bin/aarch64-linux- \
    make
mkdir -p $ROOT_DIR/rootfs/bin/
cp perf $ROOT_DIR/rootfs/bin/


cd $BUILDROOT_DIR
make 
cd $LINUX_DIR
ARCH=arm64 CROSS_COMPILE=$ROOT_DIR/buildroot/output/host/bin/aarch64-linux- make -j$(nproc) Image

# Finally, compile Linux's device tree and wrapper (needs will be need it to run
# it baremetal and over bao:
cd $ROOT_DIR
dtc devicetrees/$PLATFORM/linux.dts -o $BUILD_DIR/linux.dtb

cd $ROOT_DIR/lloader
make ARCH=aarch64\
    IMAGE=$LINUX_DIR/arch/arm64/boot/Image\
    DTB=$BUILD_DIR/linux.dtb\
    TARGET=$BUILD_DIR/linux
