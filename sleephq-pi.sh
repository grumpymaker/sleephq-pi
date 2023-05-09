#!/bin/bash
################################################################################################################
# Main script to run on the Raspberry Pi to backup the CPAP's SD Card and upload the data to SleepHQ / Dropbox #
# This is a work in progress!                                                                                  #
# v0.1                                                                                                         #
# Written by Erik Reynolds (https://github.com/grumpymaker/sleephq-pi)                                         #
################################################################################################################

# Plug in the CPAP's SD Card -- let it mount in Raspbian.  Grab the device ID (probably sda1)
CARD_DEV="sda1"
CARD_MOUNT_POINT="/media/cpapcard"

BACKUP_PATH="/home/erik/sleephq-backup"
TODAY_BACKUP=$BACKUP_PATH/$(date +%Y-%m-%d)

DROPBOX_UPLOADER_PATH="/home/erik"

echo "Checking if the backup directory exists..."
# Make the backup directory if it doesn't exist
if [ ! -d $BACKUP_PATH ]; then
    echo "Backup directory doesn't exist.  Making it now..."
    mkdir $BACKUP_PATH
fi

echo "Checking if the card mount point directory exists..."
# Make the card mount point directory if it doesn't exist
if [ ! -d $CARD_MOUNT_POINT ]; then
    echo "Card mount point directory doesn't exist.  Making it now..."
    sudo mkdir $CARD_MOUNT_POINT
fi

# Set the ACT LED to heartbeat
sudo sh -c "echo heartbeat > /sys/class/leds/ACT/trigger"

echo "Checking if the card reader is plugged in..."
# Wait for a card reader or a camera
CARD_READER=$(ls /dev/* | grep $CARD_DEV | cut -d"/" -f3)
until [ ! -z $CARD_READER ]
  do
  sleep 1
  CARD_READER=$(ls /dev/sd* | grep $CARD_DEV | cut -d"/" -f3)
done

if [ ! -z $CARD_READER ]; then
    echo "Mounting the SD Card at $CARD_MOUNT_POINT..."
    mount /dev/$CARD_DEV $CARD_MOUNT_POINT

    # Set the ACT LED to blink at 500ms to indicate that the storage device has been mounted
    sudo sh -c "echo timer > /sys/class/leds/ACT/trigger"
    sudo sh -c "echo 500 > /sys/class/leds/ACT/delay_on"

    # Check if 'Identification.json' exists in the root of the SD Card
    if [ -f $CARD_MOUNT_POINT/Identification.json ]; then        
        echo "Copying the SD Card contents to $BACKUP_PATH"
        # Perform back of $CARD_MOUNT_POINT to $BACKUP_PATH/current date using rsync
        rsync -avh $CARD_MOUNT_POINT/ $TODAY_BACKUP

        echo "Uploading the backup to Dropbox..."
        # Upload today's backup to Dropbox
        $DROPBOX_UPLOADER_PATH/dropbox_uploader.sh upload $TODAY_BACKUP

        # Turn off the ACT LED to indicate that the backup is completed
        sudo sh -c "echo 0 > /sys/class/leds/ACT/brightness"

        # Call the Python Selenium script to upload the data to SleepHQ

        # Unmount the SD Card
        sudo umount $CARD_MOUNT_POINT
    fi
else
    echo "SD Card not found!"
fi