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

sudo yum update

echo "" | tee -a LinuxSetup.log
date | tr "\n" ":" | tee -a LinuxSetup.log
echo " YUM update complete." | tee -a LinuxSetup.log

echo "" | tee -a LinuxSetup.log
date | tr "\n" ":" | tee -a LinuxSetup.log
echo " Installing SSH." | tee -a LinuxSetup.log
sleep 1
sudo yum -y install openssh-server

date | tr "\n" ":" | tee -a LinuxSetup.log
if [ $? == 0 ]; then
 echo " SSH Installation successful." | tee -a LinuxSetup.log
 date | tr "\n" ":" | tee -a LinuxSetup.log
 echo " Starting and enabling SSHD." | tee -a LinuxSetup.log
 sleep 1
 sudo systemctl start sshd
 sudo systemctl enable sshd
 sudo systemctl status sshd
  date | tr "\n" ":" | tee -a LinuxSetup.log
  if [ $? == 0 ]; then
   echo " SSH starting and enablement successful." | tee -a LinuxSetup.log
  else
   echo " SSH starting and enablement unsuccessful." | tee -a LinuxSetup.log
  fi
else
 echo " SSH Installation unsuccessful." | tee -a LinuxSetup.log
fi

echo "" | tee -a LinuxSetup.log
date | tr "\n" ":" | tee -a LinuxSetup.log
echo " Installing Vim." | tee -a LinuxSetup.log
sleep 1
sudo yum -y install vim
date | tr "\n" ":" | tee -a LinuxSetup.log
if [ $? == 0 ]; then
  echo " Vim installation successful." | tee -a LinuxSetup.log
else
  echo " Vim installation unsuccessful." | tee -a LinuxSetup.log
fi

echo "" | tee -a LinuxSetup.log
date | tr "\n" ":" | tee -a LinuxSetup.log
echo " Synchronizing time." | tee -a LinuxSetup.log
sudo ntpdate time.google.com
sudo timedatectl set-timezone "[TIMEZONE]"
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

