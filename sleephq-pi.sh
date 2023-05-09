#!/bin/bash
################################################################################################################
# Main script to run on the Raspberry Pi to backup the CPAP's SD Card and upload the data to SleepHQ / Dropbox #
# This is a work in progress!                                                                                  #
# v0.1                                                                                                         #
# Written by Erik Reynolds (https://github.com/grumpymaker/sleephq-pi)                                         #
################################################################################################################

# Plug in the CPAP's SD Card -- let it mount in Raspbian.  Grab its mount point (with the 8 digit card identifier) and set the path here.
CARD_DEV="sda1"
CARD_MOUNT_POINT="/media/erik/6263-6534"

BACKUP_PATH="/home/erik/sleephq-backup"
TODAY_BACKUP=$BACKUP_PATH/$(date +%Y-%m-%d)

DROPBOX_UPLOADER_PATH="/home/erik"

echo "Checking if the backup directory exists..."
# Make the backup directory if it doesn't exist
if [ ! -d $BACKUP_PATH ]; then
    echo "Backup directory doesn't exist.  Making it now..."
    mkdir $BACKUP_PATH
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

echo "Checking for the SD Card mount point."
if [ -d $CARD_MOUNT_POINT ]; then
    # Set the ACT LED to blink at 500ms to indicate that the storage device has been mounted
    sudo sh -c "echo timer > /sys/class/leds/ACT/trigger"
    sudo sh -c "echo 500 > /sys/class/leds/ACT/delay_on"

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
else
    echo "SD Card not found!"
fi