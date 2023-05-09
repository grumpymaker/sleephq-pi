# Erik's Unofficial SleepHQ-Pi Automation Utilities

This is a rough and dirty log of what I'm doing to automate my SleepHQ uploads until the Magic Uploader is open-sourced.

## IDEA
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

## Build Log
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
- Enable VNC
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
	./dropbox_uploader.sh  # guided through wizard to config access
	```

## Resources
- https://petapixel.com/2016/06/16/turn-raspberry-pi-auto-photo-backup-device/
- https://chiselapp.com/user/dmpop/repository/little-backup-box/home
- https://github.com/andreafabrizi/Dropbox-Uploader