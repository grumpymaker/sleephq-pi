#!/bin/bash
################################################################################################################
# Main script to run on the Raspberry Pi to backup the CPAP's SD Card and upload the data to SleepHQ / Dropbox #
# This is a work in progress!                                                                                  #
# v0.3                                                                                                         #
# Written by Erik Reynolds (https://github.com/grumpymaker/sleephq-pi)                                         #
################################################################################################################

# Plug in the CPAP's SD Card -- let it mount in Raspbian.  Grab the device ID (probably sda1)
CARD_DEV="sda1"
CARD_MOUNT_POINT="/media/cpapcard"

BACKUP_PATH="/home/erik/sleephq-backup"
TODAY=$(date +%Y-%m-%d)
TODAY_BACKUP=$BACKUP_PATH/$TODAY

DROPBOX_UPLOADER="/home/erik/dropbox_uploader.sh"

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
    sudo mount /dev/$CARD_DEV $CARD_MOUNT_POINT

    # Check if 'Identification.json' exists in the root of the SD Card
    if [ -f $CARD_MOUNT_POINT/Identification.json ]; then        
        echo "Copying the SD Card contents to $BACKUP_PATH"
        # Perform back of $CARD_MOUNT_POINT to $BACKUP_PATH/current date using rsync
        rsync -avh $CARD_MOUNT_POINT/ $TODAY_BACKUP

        # Zip today's backup
        echo "Zipping the backup..."
        7z a $BACKUP_PATH/$TODAY.zip $TODAY_BACKUP/*

        # Copy today's backup to the current.zip file
        rm $BACKUP_PATH/current.zip
        cp $BACKUP_PATH/$TODAY.zip $BACKUP_PATH/current.zip

        ### This section copies today's backup to Dropbox ###
        ### Comment out this section if you don't want to use Dropbox ###
        echo "Uploading the backup to Dropbox..."
        $DROPBOX_UPLOADER -f /home/erik/.dropbox_uploader upload $BACKUP_PATH/$TODAY.zip /
        ### END DROPBOX SECTION ###

        # Call the Python Selenium script to upload the data to SleepHQ
        sh python uploaddata.py

        # Unmount the SD Card
        sudo umount $CARD_MOUNT_POINT
    fi
else
    echo "SD Card not found!"
fi