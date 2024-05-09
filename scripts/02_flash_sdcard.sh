export ROOT_DIR=$(realpath ..)
export WRKDIR=$ROOT_DIR/wrkdir
export WRKDIR_IMGS=$WRKDIR/imgs
export FIRMWARE_DIR=$ROOT_DIR/PreBuiltImages/firmware/rpi4
export SD_CARD_MOUNT=/media/$USER/boot

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