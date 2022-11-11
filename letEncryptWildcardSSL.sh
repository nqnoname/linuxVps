# ensure that you have the latest version of snapd
sudo snap install core; sudo snap refresh core

# Remove certbot-auto and any Certbot OS packages
sudo apt-get remove certbot

# Install Certbot
sudo snap install --classic certbot

# ensure that the certbot command can be run
sudo ln -s /snap/bin/certbot /usr/bin/certbot
