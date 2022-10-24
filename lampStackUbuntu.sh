#!/bin/bash

###################################################################
#    Description: Installs an LEMP stack and PHPMyAdmin plus tweaks. For Debian based systems.
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

# Sync time
echo "" | tee -a LinuxSetup.log
date | tr "\n" ":" | tee -a LinuxSetup.log
echo " Synchronizing time." | tee -a LinuxSetup.log
sudo ntpdate time.google.com
sudo timedatectl set-timezone "Asia/Ho_Chi_Minh"
date | tr "\n" ":" | tee -a LinuxSetup.log
echo " Synchronization complete." | tee -a LinuxSetup.log

#Tạo Swap
sudo su
sudo dd if=/dev/zero of=/swapfile bs=1024 count=2046k
mkswap /swapfile
swapon /swapfile
echo /swapfile none swap defaults 0 0 >> /etc/fstab
chown root:root /swapfile 
chmod 0600 /swapfile
sysctl vm.swappiness=10

# Để đảm bảo giữ nguyên thông số này mỗi khi khởi động lại VPS bạn cần điều chỉnh tham số vm.swappiness ở cuối file /etc/sysctl.conf 
# (nếu không có bạn hãy add thủ công vào)
# nano /etc/sysctl.conf
# Thêm dòng sau vào cuối nếu chưa có, nếu có rồi thì update lại giá trị:
# vm.swappiness = 10
# Nhấn Ctrl + o để lưu, Enter, và Ctrl + X để thoát nano.
# Khởi động lại VPS và kiểm tra lại kết quả:
# swapon -s
# cat /proc/sys/vm/swappiness

# GENERATE PASSOWRDS
# sudo apt -qy install openssl # openssl used for generating a truly random password
PASS_MYSQL_ROOT=`openssl rand -base64 12` # this you need to save 
PASS_PHPMYADMIN_APP=`openssl rand -base64 12` # can be random, won't be used again
PASS_PHPMYADMIN_ROOT="${PASS_MYSQL_ROOT}" # Your MySQL root pass


update() {
	# Update system repos
	echo -e "\n ${Cyan} Updating package repositories.. ${Color_Off}"
	sudo apt -y update 
	
	echo "" | tee -a LinuxSetup.log
	date | tr "\n" ":" | tee -a LinuxSetup.log
}

installNginx() {
	# Nginx
	echo -e "\n ${Cyan} Installing Nginx.. ${Color_Off}"
	sudo apt -y install nginx
	
	echo "" | tee -a LinuxSetup.log
	date | tr "\n" ":" | tee -a LinuxSetup.log
}

installLetsEncryptCertbot() {
  # Let's Encrypt SSL 
  echo -e "\n ${Cyan} Installing Let's Encrypt SSL.. ${Color_Off}"

  sudo apt -y install certbot
  
  	echo "" | tee -a LinuxSetup.log
	date | tr "\n" ":" | tee -a LinuxSetup.log
}


installPHP() {
	# PHP and Modules
	echo -e "\n ${Cyan} Installing PHP and common Modules.. ${Color_Off}"

	# PHP5 on Ubuntu 14.04 LTS
	# apt install php5 libapache2-mod-php5 php5-cli php5-common php5-curl php5-dev php5-gd php5-intl php5-mcrypt php5-mysql php5-recode php5-xml php5-pspell php5-ps php5-imagick php-pear php-gettext -y

	# PHP5 on Ubuntu 17.04 Zesty
	# Add repository and update local cache of available packages
	# sudo add-apt-repository ppa:ondrej/php
	# sudo apt update
	# apt install php5.6 libapache2-mod-php5.6 php5.6-cli php5.6-common php-curl php5.6-curl php5.6-dev php5.6-gd php5.6-intl php5.6-mcrypt php5.6-mbstring php5.6-mysql php5.6-recode php5.6-xml php5.6-pspell php5.6-ps php5.6-imagick php-pear php-gettext -y

	# PHP7 (latest)
	# sudo apt -qy install php php-common libapache2-mod-php php-curl php-dev php-gd php-gettext php-imagick php-intl php-mbstring php-mysql php-pear php-pspell php-recode php-xml php-zip
	
	sudo apt -qy install php-fpm php-mysql
	
	echo "" | tee -a LinuxSetup.log
	date | tr "\n" ":" | tee -a LinuxSetup.log
}

installMySQL() {
	# MySQL
	echo -e "\n ${Cyan} Installing MySQL.. ${Color_Off}"
	
	# set password with `debconf-set-selections` so you don't have to enter it in prompt and the script continues
	sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password ${PASS_MYSQL_ROOT}" # new password for the MySQL root user
	sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${PASS_MYSQL_ROOT}" # repeat password for the MySQL root user
	
	# DEBIAN_FRONTEND=noninteractive # by setting this to non-interactive, no questions will be asked
	DEBIAN_FRONTEND=noninteractive sudo apt -qy install mysql-server mysql-client
	
	echo "" | tee -a LinuxSetup.log
	date | tr "\n" ":" | tee -a LinuxSetup.log
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

	echo "" | tee -a LinuxSetup.log
	date | tr "\n" ":" | tee -a LinuxSetup.log

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
	
	echo "" | tee -a LinuxSetup.log
	date | tr "\n" ":" | tee -a LinuxSetup.log
}


#enableMods() {
	# Enable mod_rewrite, required for WordPress permalinks and .htaccess files
	#echo -e "\n ${Cyan} Enabling Modules.. ${Color_Off}"

	#sudo a2enmod rewrite
	# php5enmod mcrypt # PHP5 on Ubuntu 14.04 LTS
	# phpenmod -v 5.6 mcrypt mbstring # PHP5 on Ubuntu 17.04
	#sudo phpenmod mbstring # PHP7
#}

setPermissions() {
	# Permissions
	echo -e "\n ${Cyan} Create the root web directory for your_domain & Setting Ownership for /var/www.. ${Color_Off}" | tee -a LinuxSetup.log
	#sudo chown -R www-data:www-data /var/www
	sudo mkdir /var/www/your_domain
	sudo chown -R $USER:$USER /var/www/your_domain
	date | tr "\n" ":" | tee -a LinuxSetup.log
}

#restartApache() {
#	# Restart Apache
#	echo -e "\n ${Cyan} Restarting Apache.. ${Color_Off}"
#	sudo service apache2 restart
#}

# RUN
update
installNginx
installLetsEncryptCertbot
installPHP
installMySQL
secureMySQL
installPHPMyAdmin
#enableMods
setPermissions
#restartApache

echo -e "\n${Green} SUCCESS! MySQL password is: ${PASS_MYSQL_ROOT} ${Color_Off}"

date | tr "\n" ":" | tee -a LinuxSetup.log
echo " Performing cleanup." | tee -a LinuxSetup.log
sudo package-cleanup --problems
sudo package-cleanup --orphans
sudo apt autoremove
sudo apt clean all
echo ""
echo ""
echo "Linux setup script execution complete. Please run cat LinuxSetup.log command to see the complete log."
sleep 2

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
# http://github.com/aamnah/bash-scripts
# https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-on-ubuntu-20-04
# https://hocvps.com/bat-dau/
# https://arctris.com/2021/05/automating-your-linux-setup/
