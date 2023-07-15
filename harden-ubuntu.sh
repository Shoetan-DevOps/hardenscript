#!/bin/bash

# enter public IP
echo -e "*********** Enter your Source IP *********\n"
read -p "Enter IP address: " IPADDR
echo

# delete old endlessssh
echo -e "\n\n******** Cheaning Old file *****\n ************************"
rm -rf  ~/endless || true

# patch server
echo -e "\n\n******** Patching Server *****\n ************************"
sudo apt update && apt upgrade -y || true

# install UFW (Uncomplicated Firewall)
echo -e "\n\n******** Get UFW *****\n ************************"
sudo apt install ufw -y
# enable ufw
sudo ufw enable

echo -e "\n\n******** Configure FW  *****\n ************************"
# fw deny all incoming ipv4 & ipv6 traffic 
sudo ufw default deny incoming
sudo ufw default allow outgoing

# disable ipv6
sudo sed -i 's/IPV6=yes/IPV6=no/' /etc/default/ufw

# allow tcp ports 
# sudo ufw allow 22
echo -e "\n***** allow port 22 from IP ****"
sudo ufw allow from "$IPADDR" to any port 22

# allow specific ssh port
if [ "$#" -ne 0 ]; then
   sudo ufw allow from "IPADDR" to any port "$1"
else
   echo -e "\n\n No Custom SSH Port"
fi

sleep 1

# enable logging of ufw @ /var/log/ufw.log file
sudo ufw logging on

#change default ssh port 
if [ "$#" -ne 0 ]; then
   echo -e "\n\n ***** Configuring Endlessh ****** \n"
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
   echo -e "\n ******* SSH on Port 22 ******* \n\n"
fi

echo -e "\n********************* \n Create Ansible user \n\n" 
# create ansible user and grant sudo
sudo useradd -m ansible
echo "ansible ALL=(ALL) ALL" | sudo tee /etc/sudoers.d/ansible
read -p "Enter ansible password: " PASSWORD
echo 
echo "ansible:$PASSWORD" | sudo chpasswd

# Disable root login
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart ssh
