export ROOT_DIR=$(realpath .)
export ROOTFS_DIR=$ROOT_DIR/rootfs
export LINUX_VERSION=v6.1
export LINUX_DIR=$ROOT_DIR/linux
export BUILDROOT_DIR=$ROOT_DIR/buildroot
export BUILD_DIR=$ROOT_DIR/build

# Re-build the rootfs to incroporate the new additions to the overlay in
# the final rootfs, and rebuild the Linux Image to incorporate the new rootfs:

cd $BUILDROOT_DIR
rm -rf output/target
find output/ -name ".stamp_target_installed" -delete
rm -f output/build/host-gcc-final-*/.stamp_host_installed


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

cp $BUILD_DIR/linux.bin /home/diogo/Desktop/smmu-interf/wrkdir/imgs/zcu104/mibench/linux.bin