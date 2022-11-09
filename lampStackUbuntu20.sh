#!/bin/bash

###################################################################
#         Author: Aamnah Akram
#           Link: http://github.com/aamnah/bash-scripts
#    Description: Installs an AMP stack and PHPMyAdmin plus tweaks. For Debian based systems.
#            Run: bash install_lamp_debian.sh
#          Notes: In case of any errors (e.g. MySQL) just re-run the script. 
#                 Nothing will be re-installed except for the packages with errors.
###################################################################

# Log file
while getopts "r" opt
do
 rm -f LinuxSetup.log
done

# Color Reset
Color_Off='\033[0m'       # Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

# GENERATE PASSOWRDS
# sudo apt -qy install openssl # openssl used for generating a truly random password
PASS_MYSQL_ROOT=`openssl rand -base64 12` # this you need to save 
PASS_PHPMYADMIN_APP=`openssl rand -base64 12` # can be random, won't be used again
PASS_PHPMYADMIN_ROOT="${PASS_MYSQL_ROOT}" # Your MySQL root pass

# Sync Viet Nam time
syncTime() {
  echo "" | tee -a LinuxSetup.log
  date | tr "\n" ":" | tee -a LinuxSetup.log
  echo " Synchronizing time." | tee -a LinuxSetup.log
  sudo ntpdate time.google.com
  sudo timedatectl set-timezone "Asia/Ho_Chi_Minh"
  date | tr "\n" ":" | tee -a LinuxSetup.log
  echo " Synchronization time complete." | tee -a LinuxSetup.log
}

update() {
	# Update system repos
	echo -e "\n ${Cyan} Updating package repositories.. ${Color_Off}"
	sudo apt -qy update 
}

installApache() {
	# Apache
	echo -e "\n ${Cyan} Installing Apache.. ${Color_Off}"
	sudo apt -qy install apache2 apache2-doc libexpat1 ssl-cert
	# check Apache configuration: apachectl configtest
}

installLetsEncryptCertbot() {
  # Let's Encrypt SSL 
  echo -e "\n ${Cyan} Installing Let's Encrypt SSL.. ${Color_Off}"

  sudo apt update # update repo sources
  sudo apt install -y software-properties-common # required in order to add a repo
  sudo add-apt-repository ppa:certbot/certbot -y # add Certbot repo
  sudo apt update # update repo sources
  sudo apt install -y python-certbot-apache # install Certbot
}


installPHP() {
	# PHP and Modules
	echo -e "\n ${Cyan} Installing PHP and common Modules.. ${Color_Off}"
  # PHP7 (latest)
	sudo apt -qy install php php-common libapache2-mod-php php-curl php-gd php-mbstring php-mysql php-xml php-zip php-json
}

installMySQL() {
	# MySQL
	echo -e "\n ${Cyan} Installing MySQL.. ${Color_Off}"
	
	# set password with `debconf-set-selections` so you don't have to enter it in prompt and the script continues
	sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password ${PASS_MYSQL_ROOT}" # new password for the MySQL root user
	sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${PASS_MYSQL_ROOT}" # repeat password for the MySQL root user
	
	# DEBIAN_FRONTEND=noninteractive # by setting this to non-interactive, no questions will be asked
	DEBIAN_FRONTEND=noninteractive sudo apt -qy install mysql-server mysql-client
}

secureMySQL() {
	# secure MySQL install
	echo -e "\n ${Cyan} Securing MySQL.. ${Color_Off}"
	
mysql --user=root --password=${PASS_MYSQL_ROOT} << EOFMYSQLSECURE
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
FLUSH PRIVILEGES;
EOFMYSQLSECURE

# NOTE: Skipped validate_password because it'll cause issues with the generated password in this script
}

installPHPMyAdmin() {
	# PHPMyAdmin
	echo -e "\n ${Cyan} Installing PHPMyAdmin.. ${Color_Off}"
	
	# set answers with `debconf-set-selections` so you don't have to enter it in prompt and the script continues
	sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" # Select Web Server
	sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true" # Configure database for phpmyadmin with dbconfig-common
	sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password ${PASS_PHPMYADMIN_APP}" # Set MySQL application password for phpmyadmin
	sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password ${PASS_PHPMYADMIN_APP}" # Confirm application password
	sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password ${PASS_MYSQL_ROOT}" # MySQL Root Password
	sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/internal/skip-preseed boolean true"

	DEBIAN_FRONTEND=noninteractive sudo apt -qy install phpmyadmin
  
  sudo mkdir /var/www/phpmyadmin                                        # create phpmyadmin folder
  sudo ln -s /usr/share/phpmyadmin /var/www/phpmyadmin/phpmyadmin       # link phpmyadmin folder
}


enableMods() {
	# Enable mod_rewrite, required for WordPress permalinks and .htaccess files
	echo -e "\n ${Cyan} Enabling Modules.. ${Color_Off}"
  sudo a2enmod rewrite
	
  # enable Apache and PHP to work with phpMyAdmin
	sudo phpenmod mbstring
}

setPermissions() {
	# Permissions
	echo -e "\n ${Cyan} Create the root web directory for your_domain & Setting Ownership for /var/www.. ${Color_Off}" | tee -a LinuxSetup.log
	#sudo chown -R $USER:$USER /var/www
	sudo mkdir /var/www/your_domain
	sudo chown -R www-data:www-data /var/www/your_domain
	date | tr "\n" ":" | tee -a LinuxSetup.log

restartApache() {
	# Restart Apache
	echo -e "\n ${Cyan} Restarting Apache.. ${Color_Off}"
	sudo service apache2 restart
}

# RUN
syncTime
update
installApache
installLetsEncryptCertbot
installPHP
installMySQL
secureMySQL
installPHPMyAdmin
enableMods
setPermissions
restartApache

echo -e "\n${Green} SUCCESS! MySQL password is: ${PASS_MYSQL_ROOT} ${Color_Off}"

# TODO
# - [x] Figure out why it is asking for MySQL password and not just taking it from the variable in heredoc (cz: to avoid redirection, programs don't let heredoc enter passwords)
# - [ ] Figure out a secure way for entering MySQL password (where it isn't shown on command prompt and saved in bash history as a result)
# - [ ] Prompt or indicate somehow that MySQL password won't be overwritten if already set
# - [ ] Email password (or add it to MOTD)

# LINKS
# https://www.howtogeek.com/howto/30184/10-ways-to-generate-a-random-password-from-the-command-line/
# https://serversforhackers.com/c/installing-mysql-with-debconf
# https://gist.github.com/Mins/4602864
# https://gercogandia.blogspot.com/2012/11/automatic-unattended-install-of.html
