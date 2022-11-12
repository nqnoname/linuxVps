# ensure that you have the latest version of snapd
#sudo snap install core; sudo snap refresh core

# Remove certbot-auto and any Certbot OS packages
sudo apt-get remove certbot

# Install Certbot
# Run the following command, which will install two packages: certbot and python3-certbot-apache.
# The latter is a plugin that integrates Certbot with Apache, so that it’s possible to automate obtaining a certificate and configuring HTTPS 
# within your web server with a single command:
sudo apt install certbot python3-certbot-apache

# Obtaining an SSL Certificate
# Certbot provides a variety of ways to obtain SSL certificates through plugins. 
# The Apache plugin will take care of reconfiguring Apache and reloading the configuration whenever necessary:
sudo certbot --apache
