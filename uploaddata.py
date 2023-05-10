################################################################################################################
# Python3 script to run on the Raspberry Pi upload the latest data to SleepHQ / Dropbox                        #
# This is a work in progress!                                                                                  #
# v0.1                                                                                                         #
# Written by Erik Reynolds (https://github.com/grumpymaker/sleephq-pi)                                         #
################################################################################################################

import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

# My SleepHQ Credentials
sleepUsername = ""
sleepPassword = ""

driver = webdriver.Chrome()
driver.get('https://sleephq.com/users/sign_in')
time.sleep(5) # Let the user actually see something!

username_input = driver.find_element_by_id('user_email')
password_input = driver.find_element_by_id('user_password')
submit_button = driver.find_element(By.TAG_NAME, 'button')

username_input.send_keys(sleepUsername)
time.sleep(2)
password_input.send_keys(sleepPassword)
time.sleep(2)
submit_button.click()

# automatically close the driver after 30 seconds
time.sleep(30)
driver.quit()