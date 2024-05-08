export ROOT_DIR=$(realpath ..)
export WRKDIR=$ROOT_DIR/wrkdir
export WRKDIR_IMGS=$WRKDIR/imgs

export GUESTS_DIR=$ROOT_DIR/guests
export LINUX_GUEST_DIR=$GUESTS_DIR/linux_ml
export BAREMETAL_GUEST_DIR=$GUESTS_DIR/baremetal_interf

export BAO_SRCS=$ROOT_DIR/bao-hypervisor
export BAO_CFGS=$ROOT_DIR/bao-configs

export CROSS_COMPILE=aarch64-none-elf-

# Check if an argument is provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <platform> <setup>"
    exit 1
fi

# Store the argument in a variable
platform=$1
setup=$2

export PLATFORM=$platform

# Switch between different setups
case $setup in
    "solo")
        echo "Building setup 1:"
        echo "Guests:"
        echo "  - Linux"
        echo " "

        if [ ! -f $WRKDIR_IMGS/linux.bin ]; then
            echo "Building Linux guest..."
            cd $LINUX_GUEST_DIR
            bash build_linux.sh
            cd $ROOT_DIR/scripts
        fi

        echo "Linux guest built successfully!"

        echo "Building Bao..."
        make -C $BAO_SRCS\
            PLATFORM=$PLATFORM\
            CONFIG_REPO=$BAO_CFGS\
            CONFIG=solo
        
        cp $BAO_SRCS/bin/$PLATFORM/solo/bao.bin $WRKDIR_IMGS
    ;;
        
    "interf")
        echo "Building setup 2:"
        echo "Guests:"
        echo "  - Linux"
        echo "  - Baremetal"
        echo " "

        if [ ! -f $WRKDIR_IMGS/linux.bin ]; then
            echo "Building Linux guest..."
            cd $LINUX_GUEST_DIR
            bash build_linux.sh
            cd $ROOT_DIR/scripts
        fi

        echo "Linux guest built successfully!"

        if [ ! -f $WRKDIR_IMGS/baremetal.bin ]; then
            echo "Building Baremetal guest..."
            make -C $BAREMETAL_GUEST_DIR PLATFORM=$PLATFORM
            cp $BAREMETAL_SRC/build/$PLATFORM/baremetal.bin $WRKDIR_IMGS
        fi

        echo "Baremetal guest built successfully!"

        echo "Building Bao..."
        make -C $BAO_SRCS\
            PLATFORM=$PLATFORM\
            CONFIG_REPO=$BAO_CFGS\
            CONFIG=interf
        
        cp $BAO_SRCS/bin/$PLATFORM/interf/bao.bin $WRKDIR_IMGS
        ;;

    "solo+cc")
        echo "Building setup w/ cache coloring:"
        echo "Guests:"
        echo "  - Linux"
        echo "      -Cache Colors Assigned: 50%"
        echo " "

        if [ ! -f $WRKDIR_IMGS/linux.bin ]; then
            echo "Building Linux guest..."
            cd $LINUX_GUEST_DIR
            bash build_linux.sh
            cd $ROOT_DIR/scripts
        fi

        echo "Linux guest built successfully!"

        echo "Building Bao..."
        make -C $BAO_SRCS\
            PLATFORM=$PLATFORM\
            CONFIG_REPO=$BAO_CFGS\
            CONFIG=solo_cc
        
        cp $BAO_SRCS/bin/$PLATFORM/solo_cc/bao.bin $WRKDIR_IMGS
        ;;

    "interf+cc")
        echo "Building setup interf w/ cache coloring:"
        echo "Guests:"
        echo "  - Linux"
        echo "      -Cache Colors Assigned: 50%"
        echo "  - Baremetal"
        echo "      -Cache Colors Assigned: 50%"
        echo " "

        if [ ! -f $WRKDIR_IMGS/linux.bin ]; then
            echo "Building Linux guest..."
            cd $LINUX_GUEST_DIR
            bash build_linux.sh
            cd $ROOT_DIR/scripts
        fi

        echo "Linux guest built successfully!"

        if [ ! -f $WRKDIR_IMGS/baremetal.bin ]; then
            echo "Building Baremetal guest..."
            make -C $BAREMETAL_GUEST_DIR PLATFORM=$PLATFORM
            cp $BAREMETAL_SRC/build/$PLATFORM/baremetal.bin $WRKDIR_IMGS
        fi

        echo "Baremetal guest built successfully!"

        echo "Building Bao..."
        make -C $BAO_SRCS\
            PLATFORM=$PLATFORM\
            CONFIG_REPO=$BAO_CFGS\
            CONFIG=interf_cc
        
        cp $BAO_SRCS/bin/$PLATFORM/interf_cc/bao.bin $WRKDIR_IMGS
        ;;
    *)
        echo "Invalid setup: $setup"
        exit 1
        ;;
esac