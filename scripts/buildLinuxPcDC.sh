export ROOT_DIR="/home/afonso/baopi/wrkdir"
export ROOTFS_DIR=$ROOT_DIR/rootfs
export LINUX_VERSION=v6.1
export LINUX_DIR=$ROOT_DIR/linux
export BUILDROOT_DIR=$ROOT_DIR/src/buildroot
export BUILD_DIR=$ROOT_DIR/build

mkdir -p $BUILD_DIR

# Buildroot rootfs
#git clone https://github.com/buildroot/buildroot.git --depth 1 --branch 2022.11
cd $BUILDROOT_DIR
make qemu_aarch64_virt_defconfig

#/home/afonso/baopi/wrkdir/linuxguest/cfgs
cp $ROOT_DIR/cfgs/buildroot.config .config

make -j$(nproc)

# Linux Kernel
cd $ROOT_DIR
#git clone https://github.com/torvalds/linux.git --depth 1 --branch $LINUX_VERSION
cd $ROOT_DIR/src/linux
git apply /home/afonso/baopi/wrkdir/linuxguest/patches/v6.1/*.patch
export ARCH=arm64 CROSS_COMPILE=$BUILDROOT_DIR/output/host/bin/aarch64-linux-
make defconfig

#cp $ROOT_DIR/cfgs/linux.config .config

make -j$(nproc) Image

# Re-build the rootfs to incroporate the new additions to the overlay in 
# the final rootfs, and rebuild the Linux Image to incorporate the new rootfs:
#make -C $BUILDROOT_DIR
#ARCH=arm64 CROSS_COMPILE=$BUILDROOT_DIR/output/host/bin/aarch64-linux- \
#    make -C $LINUX_DIR -j$(nproc) Image

# Finally, compile Linux's device tree and wrapper (needs will be need it to run
# it baremetal and over bao:
cd $ROOT_DIR

dtc /home/afonso/baopi/wrkdir/src/devicetrees/linux.dts > /home/afonso/baopi/wrkdir/imgs/linux.dtb

cd /home/afonso/baopi/wrkdir/linuxguest/lloader

make ARCH=aarch64\
    IMAGE=$LINUX_DIR/arch/arm64/boot/Image\
    DTB=$BUILD_DIR/linux.dtb\
    TARGET=$BUILD_DIR/linux