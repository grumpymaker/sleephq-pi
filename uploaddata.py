################################################################################################################
# Python3 script to run on the Raspberry Pi upload the latest data to SleepHQ / Dropbox                        #
# This is a work in progress!                                                                                  #
# v0.2                                                                                                         #
# Written by Erik Reynolds (https://github.com/grumpymaker/sleephq-pi)                                         #
################################################################################################################

import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

# Path to the latest data file
dataFilePath = "/home/erik/sleephq-backup/current.zip"

# My SleepHQ Credentials
sleepUsername = ""
sleepPassword = ""

driver = webdriver.Chrome()
driver.get('https://sleephq.com/users/sign_in')
time.sleep(5) # Let the user actually see something!

# Check to see if we're on the login page, else we're already logged in
if driver.current_url == 'https://sleephq.com/users/sign_in':
    print("Logging in...")
    username_input = driver.find_element(By.ID, 'user_email')
    password_input = driver.find_element(By.ID, 'user_password')
    submit_button = driver.find_element(By.TAG_NAME, 'button')

    username_input.send_keys(sleepUsername)
    time.sleep(2)
    password_input.send_keys(sleepPassword)
    time.sleep(2)
    submit_button.click()
    time.sleep(5) # give it a second to login and redirect

# We should be logged in now and on the dashboard page, grab the URL to check (and extract the teams ID)
dashboardURL = driver.current_url
print("Dashboard URL: " + dashboardURL)

# Check the dashboard URL to see if it matches the expected format (https://sleephq.com/account/teams/123456)
if not dashboardURL.startswith('https://sleephq.com/account/teams/'):
    print("ERROR: Unexpected URL format, expected https://sleephq.com/account/teams/123456")
    driver.quit()
    exit()

# Extract the teams ID from the end of the URL
teamID = dashboardURL.split('/')[-1]
print("teams ID: " + teamID)

# Now we can go to the upload page
driver.get('https://sleephq.com/account/teams/' + teamID + '/imports')

fileUploadField = driver.find_element(By.XPATH, '//input[@type="file" and @class="dz-hidden-input"]')
fileUploadField.send_keys(dataFilePath)
time.sleep(5) # give it a few to grab the file

print("Uploading the datafile...")
beginUploadButton = driver.find_element(By.ID, 'start-upload-button')
beginUploadButton.click()

# Give it 60 seconds to upload the file before quitting
time.sleep(60)
print("Done! Closing the browser...")
driver.quit()