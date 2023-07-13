root@vmi1362517:~/hardenscript# tail /etc/ssh/sshd_config
Subsystem	sftp	/usr/lib/openssh/sftp-server

# Example of overriding settings on a per-user basis
#Match User anoncvs
#	X11Forwarding no
#	AllowTcpForwarding no
#	PermitTTY no
#	ForceCommand cvs server
PermitRootLogin yes
Port 2222
root@vmi1362517:~/hardenscript# vi harden-ubuntu.sh 
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

#change default ssh port 
if [ "$#" -ne 0 ]; then
   echo "Port $1" >> /etc/ssh/sshd_config
   sudo apt install openssh-server -y
   sudo systemctl enable openssh
   sudo systemctl start openssh
   sudo systemctl restart ssh
else
   echo "SSH on Port 22"
fi

# Disable root login
#sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config


