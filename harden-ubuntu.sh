#!/bin/bash
  
# delete old endlessssh
rm -rf  ~/endless

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
else
   echo "NO additional Port"
fi

# enable logging of ufw @ /var/log/ufw.log file
sudo ufw logging on

#change default ssh port 
if [ "$#" -ne 0 ]; then
   echo "Port $1" >> /etc/ssh/sshd_config
   # install endless ssh
   sudo apt install libc6-dev build-essential -y
   git clone https://github.com/skeeto/endlessh ~/endless
   cd ~/endless
   sudo make
   sudo cp endlessh /usr/local/bin/
   sed -i 's/#AmbientCapabilities=CAP_NET_BIND_SERVICE/AmbientCapabilities=CAP_NET_BIND_SERVICE /' util/endlessh.service
   sed -i 's/PrivateUsers=true/#PrivateUsers=true/' util/endlessh.service
   sudo cp util/endlessh.service /etc/systemd/system/
   setcap 'cap_net_bind_service=+ep' /usr/local/bin/endlessh
   sudo systemctl enable endlessh
   sudo mkdir -p /etc/endlessh
   echo "Port 22" > /etc/endlessh/config
   sudo systemctl start endlessh
   sudo systemctl restart ssh
else
   echo "SSH on Port 22"
fi

# Disable root login
#sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
