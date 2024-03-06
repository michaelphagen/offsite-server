#!/bin/bash

# Install the required packages and sets up the offsite-server script
# to be run as a service

# Check if the script is being run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Install the required packages
apt-get update
echo "Installing required packages"
apt-get install -y python3-pip wireguard
pip3 install python-dotenv

# Copy the offsite-server script to /usr/local/bin
echo "Copying offsite-server script to /usr/local/bin"
cp ./offsite-server /usr/local/bin/offsite-server
chmod +x /usr/local/bin/offsite-server

# Copy the offsite-server.conf file to /etc
echo "Copying offsite-server.config to /etc/offsite-server"
mkdir /etc/offsite-server
cp ./offsite-server.conf /etc/offsite-server/offsite-server.conf

# Copy the wg config to /etc/wireguard
echo "Copying wg0.conf to /etc/wireguard"
cp ./wg0.conf /etc/wireguard/wg0.conf

# Copy the offsite-server.service file to /etc/systemd/system
echo "Copying offsite-server.service to /etc/systemd/system"
cp ./offsite-server.service /etc/systemd/system/offsite-server.service

# Enable the offsite-server service
echo "Enabling offsite-server service"
systemctl enable offsite-server