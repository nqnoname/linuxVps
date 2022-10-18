####
#!/bin/bash
clear
while getopts "r" opt
do
 rm -f LinuxSetup.log
done

date | tr "\n" ":" | tee -a LinuxSetup.log
echo " Updating apt" | tee -a LinuxSetup.log
echo "" | tee -a LinuxSetup.log
sleep 1
sudo apt -y update
echo "" | tee -a LinuxSetup.log
date | tr "\n" ":" | tee -a LinuxSetup.log
echo " apt update complete." | tee -a LinuxSetup.log

echo "" | tee -a LinuxSetup.log
date | tr "\n" ":" | tee -a LinuxSetup.log
echo " Synchronizing time." | tee -a LinuxSetup.log
sudo ntpdate time.google.com
sudo timedatectl set-timezone "Asia/Ho_Chi_Minh"
date | tr "\n" ":" | tee -a LinuxSetup.log
echo " Synchronization complete." | tee -a LinuxSetup.log

echo "" | tee -a LinuxSetup.log
date | tr "\n" ":" | tee -a LinuxSetup.log
echo " Installing nginx." | tee -a LinuxSetup.log
sudo apt -y install nginx
date | tr "\n" ":" | tee -a LinuxSetup.log

echo "" | tee -a LinuxSetup.log
date | tr "\n" ":" | tee -a LinuxSetup.log
echo " Installing MySQL." | tee -a LinuxSetup.log
sudo apt -y install mysql-server
date | tr "\n" ":" | tee -a LinuxSetup.log

echo "" | tee -a LinuxSetup.log
date | tr "\n" ":" | tee -a LinuxSetup.log
echo " Installing PHP." | tee -a LinuxSetup.log
sudo apt -y install php-fpm php-mysql
date | tr "\n" ":" | tee -a LinuxSetup.log

echo "" | tee -a LinuxSetup.log
date | tr "\n" ":" | tee -a LinuxSetup.log
echo " Create the root web directory for your_domain." | tee -a LinuxSetup.log
sudo mkdir /var/www/your_domain
sudo chown -R $USER:$USER /var/www/your_domain
date | tr "\n" ":" | tee -a LinuxSetup.log

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

