#!/bin/bash

# patch server
sudo apt update && apt upgrade -y

# install UFW (Uncomplicated Firewall)
sudo apt install ufw -y

# enable ufw
ufw_status=$(sudo ufw status | awk '/Status:/ {print $2}')

if ["$ufw_status" == "inactive"]; then
   sudo ufw enable
   echo "UFW has been activated"
else
   echo "UFW already activated"
fi

# fw deny all incoming ipv4 & ipv6 traffic 
sudo ufw default deny in

# allow tcp ports 
sudo ufw allow 22

# allow specific ssh port
if [$# -ne 0 ] then
   sudo ufw allow $1
else
   echo "NO additional Port"
fi

# Next Steps
echo "now list packages with => dpkg --list"
echo "then get pkg info =>  dpkg --info packageName"
echo "finally remove all unneeded packages => sudo dpkg --remove package_name
 "

