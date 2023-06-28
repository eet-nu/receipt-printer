# Install rpi for development
1. Download and unzip the latest release image (https://github.com/eet-nu/receipt-printer/releases)
2. Write the img to a new SD (ie. with applePiBaker)
3. Boot an rpi with the SD and use BerryLan to connect it to your wifi
4. ssh in: ssh -t pi@bonprint.local
5. Change the environment to development in [polling.service](polling.service) and reload it `sudo systemctl daemon-reload`
6. Restart the polling service `sudo service polling restart`
7. Optionally change the development url in [print/config/application.yml](print/config/application.yml)

# Create a new release
1. Clear the rpi of development junk `~/image_prep.sh`
2. After the rpi has shut down make a compressed image of the SD with partition resize enabled
3. Create a new release [https://github.com/eet-nu/receipt-printer/releases/new](https://github.com/eet-nu/receipt-printer/releases/new)

# Create a new receipt printer for end user
1. Download and unzip the latest release image
2. Write the img to a new SD (ie. with applePiBaker (v1.9 worked on my M1, v2 did not))
3. Boot an rpi with the SD and use BerryLan (https://berrylan.org) to connect it to your wifi
4. Create the receipt printer in the database https://eet.nu/admin/receipt_printers/new
5. Prep the rpi to ship it `ssh -t pi@bonprint.local '~/image_prep.sh <key> <secret>'`
6. The rpi will reboot, make sure it pops back up on your BerryLan
7. Ship it
8. Beware! If you configure wifi with berrylan on this device you need to restart at point 2 to get it ready again

# reference
BerryLan's Nymea-networkmanager's mode is set to 'always' (https://github.com/nymea/nymea-networkmanager/blob/ad1326586fa7cb4443c2e092a76761255665ceb8/nymea-networkmanager/main.cpp#L120C53-L120C53)