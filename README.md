# offsite-server

Set up and maintain a distributed network of servers connected via wireguard!

This project was born from a bunch of spare raspberry pi's and a bunch of friends asking me about "HomeAssistant", "PiHole", and "NAS". I wanted to see if I could create a simple way to set up a network of servers that can be installed in a remote location and managed remotely, without requiring any action on the part of the remote user. What I came up with is a simple script that sets up a raspberry pi as a wireguard client with docker installed and allows me to manage the server remotely via the wireguard connection. The pi can be set up to tunnel all it's traffic through the wireguard connection, or just the subnet of the wireguard server.

Basically, [Tailscale](https://tailscale.com/) just for me.

## Usage

1. Clone the repository or [download the zip](https://github.com/michaelphagen/offsite-server/archive/refs/heads/main.zip)
2. Fill out the offsite-server.conf file in ./wireguard (see [offsite-server.conf](#offsite-server.conf))
3. Replace the wg0.conf file in ./wireguard with the a wireguard client configuration file for your wireguard server
4. Run `./install.sh` to set up offsite server


## offsite-server.conf

The offsite-server.conf file is a simple configuration file that contains the following fields:
HOME_IP: An IP address or host on the local network that is used to check if the offsite server's wireguard connection is up
INTERNET_IP: An IP address or host on the internet that is used to check if the offsite server is connected to the internet
EMAIL_USERNAME: The username for the email account used to send status updates
EMAIL_PASSWORD: The password for the email account used to send status updates (if using gmail, you should use an [app password](https://support.google.com/accounts/answer/185833?hl=en))
EMAIL_SMTP: The smtp server for the email account used to send status updates (smtp.gmail.com for gmail)
EMAIL_PORT: The port for the smtp server for the email account used to send status updates (587 for gmail if using TLS)
EMAIL_TLS: Whether or not to use TLS for the smtp server for the email account used to send status updates (true for gmail)
EMAIL_TO: The email address to send status updates to
EMAIL_FROM: The email address to send status updates from (generally the same as EMAIL_USERNAME)

## wg0.conf

The wg0.conf file is a wireguard client configuration file that is used to connect the offsite server to the wireguard server. You can generate this file using the wireguard server's web interface or by using the `wg` command line tool. The file should be placed in the ./wireguard directory and should be named wg0.conf. 

If you're not sure how to generate this file and haven't set up a wireguard server yet, I recommend using [wg-easy](https://github.com/wg-easy/wg-easy), which is a simple web interface for setting up a wireguard server. You can download the wg0.conf file from the web interface after setting up the server.
