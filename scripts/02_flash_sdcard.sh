export ROOT_DIR=$(realpath ..)
export WRKDIR=$ROOT_DIR/wrkdir
export WRKDIR_IMGS=$WRKDIR/imgs
export SD_CARD_MOUNT=/media/$USER/boot

# Check if an argument is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <platform> "
    exit 1
fi

# Store the argument in a variable
platform=$1

export FIRMWARE_DIR=$ROOT_DIR/firmware/$platform

case $platform in
    "zcu104")

            if [ -d "$SD_CARD_MOUNT" ]; then
                echo "SD card mount directory exists, proceeding with copying files..."
                
                # Copy firmware files
                cp $FIRMWARE_DIR/BOOT.BIN $SD_CARD_MOUNT

                mkimage -n bao_uboot -A arm64 -O linux -C none -T kernel -a 0x200000\
                    -e 0x200000 -d $WRKDIR_IMGS/bao.bin $WRKDIR_IMGS/bao.img
                # Copy Bao binary
                cp "$WRKDIR_IMGS/bao.img" "$SD_CARD_MOUNT"

                umount $SD_CARD_MOUNT
                
                echo "Files copied successfully."
            else
                echo "SD card mount directory does not exist. Please mount the SD card and try again."
            fi
        ;;

    "rpi4")

            if [ -d "$SD_CARD_MOUNT" ]; then
                echo "SD card mount directory exists, proceeding with copying files..."
                
                # Copy firmware files
                #cp -rf "$FIRMWARE_DIR/firmware/boot/"* "$SD_CARD_MOUNT"
                #cp "$FIRMWARE_DIR/config.txt" "$SD_CARD_MOUNT"
                #cp "$FIRMWARE_DIR/bl31.bin" "$SD_CARD_MOUNT"
                #cp "$FIRMWARE_DIR/u-boot.bin" "$SD_CARD_MOUNT"

                # Copy Bao binary
                cp "$WRKDIR_IMGS/bao.bin" "$SD_CARD_MOUNT"

                umount $SD_CARD_MOUNT
                
                echo "Files copied successfully."
            else
                echo "SD card mount directory does not exist. Please mount the SD card and try again."
            fi
        ;;

    *)
        echo "Invalid platform: $platform"
        exit 1
        ;;
esac
