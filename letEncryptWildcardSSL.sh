# ensure that you have the latest version of snapd
sudo snap install core; sudo snap refresh core

# Remove certbot-auto and any Certbot OS packages
sudo apt-get remove certbot

# Install Certbot
sudo snap install --classic certbot

# ensure that the certbot command can be run
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# phát hành chứng chỉ cho cả domain yourdomain.com và toàn bộ các subdomain *.yourdomain.com
sudo certbot certonly --server https://acme-v02.api.letsencrypt.org/directory --manual --preferred-challenges dns -d yourdomain.com -d *.yourdomain.com
