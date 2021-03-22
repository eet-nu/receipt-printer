#!/bin/bash

home="/home/pi/"
app=$home/receipt-printer/

if [ $# -eq 2 ]; then
  echo "Weigh anchor and hoist the mizzen! Heave ho!"

  access_key=$1
  secret=$2

  sudo sed -i 's/#ListenAddress 0.0.0.0/ListenAddress 127.0.0.1/' /etc/ssh/sshd_config

  # prep for new remote.it registration
  sudo connectd_control stop all
  sudo connectd_control reset y

  echo "Batten down the hatches me hearties!"
else
  echo "Prepping pi to create a new image for release"

  access_key="uid"
  secret="pass"
fi

sed -i 's/RAILS_ENV=development/RAILS_ENV=production/' $app/polling.service

# cancel any jobs currently in the cups queue
cancel -a -x

echo $access_key > $app/config/access_key
echo $secret > $app/config/secret
echo $access_key | sudo tee /etc/connectd/hardware_id.txt >/dev/null

sudo rm -f /etc/NetworkManager/system-connections/*.nmconnection

rm -f ~/.irb_history ~/.bash_history ~/.lesshst
sudo rm -f /var/log/*.gz /var/log/*.1
true | sudo tee /var/log/lastlog /var/log/auth.log /var/log/daemon.log /var/log/syslog /var/log/user.log /var/log/kern.log

if [ $# -eq 2 ]; then
  sudo reboot
else
  sudo shutdown now
fi
  