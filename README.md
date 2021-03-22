# Install rpi for development
1. Download and unzip the latest release image
2. Write the img to a new SD (ie. with applePiBaker)
3. Boot an rpi with the SD and use BerryLan to connect it to your wifi
4. Change the environment in [polling.service](polling.service) and reload it `sudo systemctl daemon-reload`
5. Restart the polling service `sudo service polling restart`
6. Optionally change the development url in [print/config/application.yml](print/config/application.yml)

# Create a new release
1. Clear the rpi of development junk `~/image_prep.sh`
2. After the rpi has shut down make a compressed image of the SD with partition resize enabled
3. Create a new release [https://github.com/eet-nu/receipt-printer/releases/new](https://github.com/eet-nu/receipt-printer/releases/new)

# Create a new receipt printer for end user
1. Download and unzip the latet release image
2. Write the img to a new SD (ie. with applePiBaker)
3. Boot an rpi with the SD and use BerryLan to connect it to your wifi
4. Create the receipt printer in the database https://eet.nu/admin/receipt_printers/new
5. Prep the rpi to ship it `ssh -t pi@bonprint.local '~/image_prep.sh <key> <secret>'`
6. The rpi will reboot, make sure it pops back up on your BerryLan
7. Ship it
