#!/bin/bash

# Script tu dong tai ban WordPress moi nhat va cai dat tao boi Luan Tran - https://hocvps.com/

while [ 1 ];do
clear
printf "=========================================================================\n"
printf "Chuan bi qua trinh tai ban cai dat WordPress... \n"
printf "=========================================================================\n"

printf "Ban hay dien thong tin nhu yeu cau: \n"
# DB Variables
echo -n "MySQL Host (localhost): "
read mysqlhost
if [ "$mysqlhost" = "" ]; then
	mysqlhost="localhost"
fi

echo -n "MySQL DB Name: "
read mysqldb

echo -n "MySQL DB User: "
read mysqluser

echo -n "MySQL Password: "
read mysqlpass

if [ "$mysqldb" != "" ] && [ "$mysqluser" != "" ] && [ "$mysqlpass" != "" ]; then
	break
fi
done

clear
printf "=========================================================================\n"
printf "Downloading... \n"
printf "=========================================================================\n"

# Download latest WordPress and uncompress
wget http://wordpress.org/latest.tar.gz
tar zxf latest.tar.gz
mv wordpress/* ./

# Grab Salt Keys
wget -O /tmp/wp.keys https://api.wordpress.org/secret-key/1.1/salt/

# Butcher our wp-config.php file
sed -e "s/localhost/"$mysqlhost"/" -e "s/database_name_here/"$mysqldb"/" -e "s/username_here/"$mysqluser"/" -e "s/password_here/"$mysqlpass"/" wp-config-sample.php > wp-config.php
sed -i '/#@-/r /tmp/wp.keys' wp-config.php
sed -i "/#@+/,/#@-/d" wp-config.php

# Tidy up
rmdir wordpress
rm latest.tar.gz
rm /tmp/wp.keys
rm wp

# Chown
if [ -f /etc/redhat-release ]; then #CentOS
 if ps ax | grep -v grep | grep 'httpd' > /dev/null; then #Apache
 chown -R apache:apache *
 elif ps ax | grep -v grep | grep 'nginx' > /dev/null; then #Nginx
 chown -R nginx:nginx *
 fi
elif [ -f /etc/lsb-release ]; then #Ubuntu
 chown -R www-data:www-data * #Both for Apache and Nginx
fi

clear
printf "=========================================================================\n"
printf "Xong, gio ban hay truy cap vao domain de cai dat WordPress! \n"
printf "Hoac truy cap https://hocvps.com \n"
printf "=========================================================================\n"
