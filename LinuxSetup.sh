####
#!/bin/bash
clear
while getopts "r" opt
do
 rm -f LinuxSetup.log
done

date | tr "\n" ":" | tee -a LinuxSetup.log
echo " Updating YUM" | tee -a LinuxSetup.log
echo "" | tee -a LinuxSetup.log
sleep 1

sudo yum -y update

echo "" | tee -a LinuxSetup.log
date | tr "\n" ":" | tee -a LinuxSetup.log
echo " YUM update complete." | tee -a LinuxSetup.log



echo "" | tee -a LinuxSetup.log
date | tr "\n" ":" | tee -a LinuxSetup.log
echo " Installing Vim." | tee -a LinuxSetup.log
sleep 1
sudo yum -y install vim
date | tr "\n" ":" | tee -a LinuxSetup.log


echo "" | tee -a LinuxSetup.log
date | tr "\n" ":" | tee -a LinuxSetup.log
echo " Installing epel-release." | tee -a LinuxSetup.log
sleep 1
sudo yum -y install epel-release
date | tr "\n" ":" | tee -a LinuxSetup.log


echo "" | tee -a LinuxSetup.log
date | tr "\n" ":" | tee -a LinuxSetup.log
echo " Installing Remi repository for CentOS 7." | tee -a LinuxSetup.log
sleep 1
sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
date | tr "\n" ":" | tee -a LinuxSetup.log

 sleep 1
 sudo yum-config-manager --enable remi-php74
  date | tr "\n" ":" | tee -a LinuxSetup.log
  

echo "" | tee -a LinuxSetup.log
date | tr "\n" ":" | tee -a LinuxSetup.log
echo " Installing PHP 7.4." | tee -a LinuxSetup.log
sleep 1
sudo yum -y install php php-mysqlnd php-fpm
date | tr "\n" ":" | tee -a LinuxSetup.log



echo "" | tee -a LinuxSetup.log
date | tr "\n" ":" | tee -a LinuxSetup.log
echo " Installing nginx." | tee -a LinuxSetup.log
sleep 1
sudo yum -y install nginx

date | tr "\n" ":" | tee -a LinuxSetup.log

 sleep 1
 sudo systemctl start nginx
 sudo systemctl enable nginx
 sudo systemctl status nginx
  date | tr "\n" ":" | tee -a LinuxSetup.log
 

echo "" | tee -a LinuxSetup.log
date | tr "\n" ":" | tee -a LinuxSetup.log
echo " Synchronizing time." | tee -a LinuxSetup.log
sudo ntpdate time.google.com
sudo timedatectl set-timezone "Asia/Ho_Chi_Minh"
date | tr "\n" ":" | tee -a LinuxSetup.log
echo " Synchronization complete." | tee -a LinuxSetup.log

date | tr "\n" ":" | tee -a LinuxSetup.log
echo " Performing cleanup." | tee -a LinuxSetup.log
sudo package-cleanup --problems
sudo package-cleanup --orphans
sudo yum autoremove
sudo yum clean all
echo ""
echo ""
echo "Linux setup script execution complete. Please run cat LinuxSetup.log command to see the complete log."
sleep 2

