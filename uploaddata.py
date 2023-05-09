################################################################################################################
# Python3 script to run on the Raspberry Pi upload the latest data to SleepHQ / Dropbox                        #
# This is a work in progress!                                                                                  #
# v0.1                                                                                                         #
# Written by Erik Reynolds (https://github.com/grumpymaker/sleephq-pi)                                         #
################################################################################################################

import time
from selenium import webdriver

driver = webdriver.Chrome()
driver.get('https://sleephq.com/account/teams/eglElJ')
time.sleep(15) # Let the user actually see something!
driver.quit()