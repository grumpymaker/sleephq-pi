# Erik's Unofficial SleepHQ-Pi Automation Utilities v0.3

This is a rough and dirty log of what I'm doing to automate my SleepHQ uploads until the Magic Uploader is open-sourced.

## TL;DR
I remove the SD Card from my CPAP (currently a ResMed AirSense 11), insert it into my USB card reader, and plug that into the Raspberry Pi.  Either on a timer or on device detection it runs sleephq-pi.sh which copies the data from the SD card, backs it up to my Dropbox, and uploads it automatically to SleepHQ (using a Selenium automation).  It automatically unmounts the SD card when it is done and sends me a text message confirmation.

## TODO
- Setup either a Cronjob or autodetect the USB device and run the script.  Maybe on RPi boot and login?
- Add in SMS notifications (probably through Make.com/Twilio since I use that infrastructure already.  IFTTT could work too)
- Abstract out the paths and crentials to a config file (copy a sample config from the git repo into home directory)

## Install Guide / Build Log
- Took a Raspberry Pi 4 I had lying around
- Downloaded the latest Raspberry Pi imager
- Customize the settings
  + Set hostname: sleephq-pi.local
  + Enable SSH (use password auth, it's in my local network, I don't care lol)
  + Set username and password
  + Configure wireless LAN
  + Set locale settings
- Write image to microSD card
- Boot Raspberry Pi from microSD card
- [Optional] Set DHCP Reservation in firewall
- Connect over SSH to sleephq-pi.local (or by IP depending on local DNS resolver)
- Update and Upgrade installed packages
	```
	sudo apt update
	sudo apt upgrade -y
	```
- Enable VNC and set Desktop-Autologin so the GUI is loaded even while headless
	```
	sudo raspi-config
	Interfacing Options --> VNC --> Yes
	System Options --> Boot / Auto Login --> Desktop Autologin
	```
- Install python and selenium
	```
	Python3.9 should be installed by default
	pip install -U selenium
	sudo apt install chromium-chromedriver
	```
- Install Dropbox-Uploader
	```
	curl "https://raw.githubusercontent.com/andreafabrizi/Dropbox-Uploader/master/dropbox_uploader.sh" -o dropbox_uploader.sh
	chmod +x dropbox_uploader.sh
	./dropbox_uploader.sh  # guided through wizard to create the dropbox app, get the app id / secret, and setup your tokens
	```
- Clone the git repo
	```
	cd ~
	git clone https://github.com/grumpymaker/sleephq-pi.git
	```
- Edit the settings that you need, espescially:
  + Card reader device name [sda1 or similar] in sleephq-pi.sh
  + Backup path (and other paths) in sleephq-pi.sh
  + SleepHQ username and password in uploaddata.py

## Original Idea
	• Remove SD Card from CPAP
	• Insert SD Card into Raspberry Pi setup.
	• Script runs
		○ Copy the data off the SD Card into YEAR-MONTH-DAY-HHMMSS folder
		○ Update symlink to CURRENT-CPAP-DATA
		○ Throw a timestamp into my Dropbox
		○ Run Selenium automation to upload to SleepHQ
		○ Unmount the SD card and alert me it is safe to remove?
	• Send me a Text through Twilio/Make/IFFFT etc
		○ "CPAP Data - 2023-05-08
			 [y/n] copied off SD Card 
			 [y/n] saved to Dropbox 
             [y/n] uploaded successfully to SleepHQ"

## Resources I borrowed from
- https://petapixel.com/2016/06/16/turn-raspberry-pi-auto-photo-backup-device/
- https://chiselapp.com/user/dmpop/repository/little-backup-box/home
- https://github.com/andreafabrizi/Dropbox-Uploader