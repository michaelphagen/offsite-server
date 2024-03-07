#!/bin/bash
# This script is used to set up a computer as a remote part of my network

# check if the script is being run as root
if [ $UID -ne 0 ]
then
  echo "Please run this script with sudo"
  exit
fi

# Ask if we'd like to create a new user
read -p "Do you want to create a new user? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  read -rp "Enter the new username: " username
  adduser "$username"
  usermod -aG sudo "$username"
else
# Ask if we should apply the changes to the another user
  read -p "Do you want to apply the changes to an existing user? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -rp "Enter the username: " username
  else
    echo "No user specified, exiting"
  fi
fi

# Ask user if they want to change the hostname
read -p "Do you want to change the hostname? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  read -rp "Enter the new hostname: " new_hostname
  hostnamectl set-hostname "$new_hostname"
  echo "127.0.0.1 $new_hostname" >> /etc/hosts
fi

echo "All set with the interactive stuff, here we go!"

# Disable needs restart messages during updates
sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf

# update the system
apt-get update -y
echo "Upgrading the system"
apt-get upgrade -y
apt-get dist-upgrade -y

# install git, wireguard, zsh, neovim
echo "Installing git, zsh, and neovim"
apt-get install git openresolv zsh neovim -y

# replace vim with neovim
echo "Replacing vim with neovim"
ln -s /usr/bin/nvim /usr/bin/vim

# install docker
echo "Installing docker"
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt-get remove $pkg; done
apt-get update -y
apt-get install ca-certificates curl -y
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose -y


echo "Setting the default shell for " "$username" " to zsh"
chsh -s /bin/zsh "$username"
echo "Adding the user to the docker group"
usermod -aG docker "$username"

# copy allowed ssh keys to the michaelhagen user
echo "Copying allowed ssh keys to " "$username"
mkdir -p /home/"$username"/.ssh
cp ./authorized_keys /home/"$username"/.ssh/authorized_keys

# set the correct permissions on the ssh directory
echo "Setting the correct permissions on the ssh directory"
chown -R "$username":"$username" /home/"$username"/.ssh
chmod 700 /home/"$username"/.ssh
chmod 600 /home/"$username"/.ssh/authorized_keys

# Turn off root ssh login and password authentication
echo "Turning off root ssh login and password authentication"
# Uncomment PermitRootLogin and PasswordAuthentication
sed -i 's/#PermitRootLogin/PermitRootLogin/g; s/#PasswordAuthentication/PasswordAuthentication/g' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g; s/PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
# If there are other sshd configs, delete them
rm -rf /etc/ssh/sshd_config.d


# restart the ssh service
echo "Restarting the ssh service"
systemctl restart ssh

# set up wireguard
echo "Setting up wireguard"

# cd into the ./wireguard directory
cd ./wireguard || exit
./install-wg.sh

# Re-enable the needrestart messages
sed -i "s/\$nrconf{kernelhints} = -1;/#\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf

reboot now