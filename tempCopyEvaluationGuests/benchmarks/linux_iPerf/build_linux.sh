export ROOT_DIR=$(realpath .)
export ROOTFS_DIR=$ROOT_DIR/rootfs
export LINUX_VERSION=v6.1
export LINUX_DIR=$ROOT_DIR/linux
export BUILDROOT_DIR=$ROOT_DIR/buildroot
export BUILD_DIR=$ROOT_DIR/build

mkdir -p $BUILD_DIR

# Buildroot rootfs
git clone https://github.com/buildroot/buildroot.git --depth 1 --branch 2022.11
cd buildroot
make qemu_aarch64_virt_defconfig

cp $ROOT_DIR/configs/buildroot.config .config

make -j$(nproc)

# Linux Kernel
cd $ROOT_DIR
git clone https://github.com/torvalds/linux.git --depth 1 --branch $LINUX_VERSION
cd linux
git apply $ROOT_DIR/patches/$LINUX_VERSION/*.patch
export ARCH=arm64 CROSS_COMPILE=$ROOT_DIR/buildroot/output/host/bin/aarch64-linux-
make defconfig

export INITRAMFS_SRC=$BUILDROOT_DIR/output/images/rootfs.cpio
cp $ROOT_DIR/configs/linux.config .config

make -j$(nproc) Image


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


# Re-build the rootfs to incroporate the new additions to the overlay in 
# the final rootfs, and rebuild the Linux Image to incorporate the new rootfs:
make -C $BUILDROOT_DIR
ARCH=arm64 CROSS_COMPILE=$BUILDROOT_DIR/output/host/bin/aarch64-linux- \
    make -C $LINUX_DIR -j$(nproc) Image

# Finally, compile Linux's device tree and wrapper (needs will be need it to run
# it baremetal and over bao:
cd $ROOT_DIR
dtc devicetrees/zcu104/linux.dts -o $BUILD_DIR/linux.dtb
cd $ROOT_DIR/lloader
make ARCH=aarch64\
    IMAGE=$LINUX_DIR/arch/arm64/boot/Image\
    DTB=$BUILD_DIR/linux.dtb\
    TARGET=$BUILD_DIR/linux
