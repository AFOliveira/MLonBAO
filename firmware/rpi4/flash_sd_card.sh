#!/bin/bash
#------------------------------------------------------------------------------- Work directory setup
export ROOT_DIR=$(realpath .)
export PRE_BUILT_IMAGES=$(realpath ../../)
export BAO_BUILD=$PRE_BUILT_IMAGES/bao
################################################################################

#------------------------------------------------------------------------------- Target Binaries
export PLATFORM=rpi4
export SETUP=baremetal
################################################################################


#------------------------------------------------------------------------------- SD Card Flash Steps
export BAO_BIN_DIR=$BAO_BUILD/$PLATFORM/$SETUP
export FIRMWARE_DIR=$ROOT_DIR
export SD_CARD_MOUNT=/media/$USER/boot

if [ -d "$SD_CARD_MOUNT" ]; then
    echo "SD card mount directory exists, proceeding with copying files..."
    
    # Copy firmware files
    cp -rf "$FIRMWARE_DIR/firmware/boot/"* "$SD_CARD_MOUNT"
    cp "$FIRMWARE_DIR/config.txt" "$SD_CARD_MOUNT"
    cp "$FIRMWARE_DIR/bl31.bin" "$SD_CARD_MOUNT"
    cp "$FIRMWARE_DIR/u-boot.bin" "$SD_CARD_MOUNT"

    # Copy Bao binary
    cp "$BAO_BIN_DIR/bao.bin" "$SD_CARD_MOUNT"

    umount $SD_CARD_MOUNT
    
    echo "Files copied successfully."
else
    echo "SD card mount directory does not exist. Please mount the SD card and try again."
fi
################################################################################