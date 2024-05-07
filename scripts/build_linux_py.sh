export ROOT_DIR=/home/goncalo/bao_PI/ev-2/evaluation-guests/benchmarks/linux_mibench
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
        
#export BUILDROOT_DEFCFG=$ROOT_DIR/configs/buildroot/$ARCH.config
#export BUILDROOT_DEFCFG=$ROOT_DIR/configs/buildroot/demos.config
#export BUILDROOT_DEFCFG=$ROOT_DIR/configs/buildroot/wpy.config
export BUILDROOT_DEFCFG=$ROOT_DIR/configs/buildroot/wpy_rfs.config
#export BUILDROOT_DEFCFG=$ROOT_DIR/configs/buildroot/tflite.config


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

#cd linux
#export ARCH=arm64 CROSS_COMPILE=$ROOT_DIR/buildroot/output/host/bin/aarch64-linux-
#make defconfig
# # export INITRAMFS_SRC=$BUILDROOT_DIR/output/images/rootfs.cpio
# # make -j$(nproc) Image


# Add benchmark tools to rootfs 
#    Build mibench
cd $ROOT_DIR/mibench
ARCH=arm64 CROSS_COMPILE=$BUILDROOT_DIR/output/host/bin/aarch64-buildroot-linux-gnu- \
    make
cp -r $ROOT_DIR/mibench/build/* $ROOT_DIR/rootfs

#   Build Perf
cd $LINUX_DIR/tools/perf/
ARCH=arm64 CROSS_COMPILE=$BUILDROOT_DIR/output/host/bin/aarch64-buildroot-linux-gnu-
    make
mkdir -p $ROOT_DIR/rootfs/bin/
cp perf $ROOT_DIR/rootfs/bin/
#cp perf $ROOT_DIR/rootfs

#  Build TensorFlow
#make -C tensorflow/lite/tools/pip_package docker-build \
#  TENSORFLOW_TARGET=aarch64 PYTHON_VERSION=3.10.8

# Re-build the rootfs to incroporate the new additions to the overlay in 
# the final rootfs, and rebuild the Linux Image to incorporate the new rootfs:
#make -C $BUILDROOT_DIR
#ARCH=arm64 CROSS_COMPILE=/home/goncalo/bao_hypervisor/arm-gnu-toolchain-13.2.rel1-x86_64-aarch64-none-elf/arm-gnu-toolchain-13.2.Rel1-x86_64-aarch64-none-elf/bin/aarch64-none-elf- \
#    make -C $LINUX_DIR 

#cd $ROOT_DIR/linux
#ARCH=arm64 CROSS_COMPILE=$BUILDROOT_DIR/output/host/bin/aarch64-buildroot-linux-gnu- \    
#    make
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
