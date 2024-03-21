export ROOT_DIR=$(realpath .)
export ROOTFS_DIR=$ROOT_DIR
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

# Re-build the rootfs to incroporate the new additions to the overlay in 
# the final rootfs, and rebuild the Linux Image to incorporate the new rootfs:
make -C $BUILDROOT_DIR
ARCH=arm64 CROSS_COMPILE=$BUILDROOT_DIR/output/host/bin/aarch64-linux- \
    make -C $LINUX_DIR -j$(nproc) Image

cp $BAO_LINUX_SRC/arch/arm64/boot/Image\
    $BAO_BUILDROOT/output/images/Image-$PLATFORM


dtc $BAO_LINUX/devicetrees/$PLATFORM/$BAO_LINUX_VM.dts >\
    $BAO_LINUX/$BAO_LINUX_VM.dtb

make -j $(nproc) -C $BAO_LINUX/lloader\
    ARCH=$ARCH\
    IMAGE=$BAO_BUILDROOT/output/images/Image-$PLATFORM\
    DTB=$BAO_LINUX/$BAO_LINUX_VM.dtb\
    TARGET=$BAO_LINUX/$BAO_LINUX_VM

mv $BAO_LINUX/linux.bin $BAO_LINUX/linux-build/
mv $BAO_LINUX/linux.elf $BAO_LINUX/linux-build/
mv $BAO_LINUX/linux.dtb $BAO_LINUX/linux-build/
