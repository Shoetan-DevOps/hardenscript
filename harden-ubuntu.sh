root@vmi1362517:~/hardenscript# vi harden-ubuntu.sh 
root@vmi1362517:~/hardenscript# vi harden-ubuntu.sh 
#!/bin/bash

# patch server
sudo apt update && apt upgrade -y

# install UFW (Uncomplicated Firewall)
sudo apt install ufw -y


# enable ufw
sudo ufw enable

# fw deny all incoming ipv4 & ipv6 traffic 
sudo ufw default deny incoming
sudo ufw default allow outgoing

# disable ipv6
sudo sed -i 's/IPV6=yes/IPV6=no/' /etc/default/ufw

# allow tcp ports 
sudo ufw allow 22

# allow specific ssh port
if [ "$#" -ne 0 ]; then
   sudo ufw allow "$1"
else
   echo "NO additional Port"
fi

# enable logging of ufw @ /var/log/ufw.log file
sudo ufw logging on

# Next Steps
echo "now list packages with => dpkg --list"
echo "then get pkg info =>  dpkg --info packageName"
echo "finally remove all unneeded packages => sudo dpkg --remove package_name
 "

                                                           37,0-1        Bot


