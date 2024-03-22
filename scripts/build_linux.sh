export ROOT_DIR=/home/afonso/evaluation-guests
export ROOTFS_DIR=$ROOT_DIR/rootfs
export LINUX_VERSION=v6.1
export LINUX_DIR=$ROOT_DIR/wrkdir/linux
export BUILDROOT_DIR=$ROOT_DIR/wrkdir/buildroot
export BUILD_DIR=$ROOT_DIR/build

mkdir -p $BUILD_DIR

# Buildroot rootfs
#git clone https://github.com/buildroot/buildroot.git --depth 1 --branch 2022.11
cd $ROOT_DIR/wrkdir/buildroot
make qemu_aarch64_virt_defconfig

cp /home/afonso/evaluation-guests/benchmarks/linux_mibench/configs/buildroot.config .config

make -j$(nproc)

# Linux Kernel
cd $ROOT_DIR/wrkdir
#git clone https://github.com/torvalds/linux.git --depth 1 --branch $LINUX_VERSION
cd linux
git apply $ROOT_DIR/patches/$LINUX_VERSION/*.patch
export ARCH=arm64 CROSS_COMPILE=$ROOT_DIR/buildroot/output/host/bin/aarch64-linux-
make defconfig

export INITRAMFS_SRC=$BUILDROOT_DIR/output/images/rootfs.cpio
cp /home/afonso/evaluation-guests/benchmarks/linux_mibench/configs/linux.config .config

make -j$(nproc) Image

# Add benchmark tools to rootfs 
# Build mibench
cd $ROOT_DIR/benchmarks/linux_mibench
ARCH=arm64 CROSS_COMPILE=$BUILDROOT_DIR/output/host/bin/aarch64-linux- \
    make
cp -r $ROOT_DIR/benchmarks/linux_mibench/mibench/build/* $ROOT_DIR/rootfs

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
dtc /home/afonso/evaluation-guests/benchmarks/linux_mibench/devicetrees/linux.dts -o $BUILD_DIR/linux.dtb
cd /home/afonso/evaluation-guests/benchmarks/linux_mibench/lloader

export CROSS_COMPILE=/home/afonso/gcc-arm-10.3-2021.07-x86_64-aarch64-none-elf/bin/aarch64-none-elf-
make ARCH=aarch64\
   IMAGE=$LINUX_DIR/arch/arm64/boot/Image\
   DTB=$BUILD_DIR/linux.dtb\
   TARGET=$BUILD_DIR/linux