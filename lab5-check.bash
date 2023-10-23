#!/bin/bash

# ./lab5-check.bash

# Author:  Murray Saul
# Date:    June 7, 2016
# Edited by: Peter Callaghan
# Date: Sept 26, 2021
#
# Edited by: Brian Gray for Debian labs
# Date: Oct 23, 2023
# Purpose: Check that students have correctly managed file system sizes with LVM
#          and other disk management utlities. Also check that crontab was correctly
#          set-up by the student

# Function to indicate OK (in green) if check is true; otherwise, indicate
# WARNING (in red) if check is false and end with false exit status
suser=${SUDO_USER:-$USER}
logfile=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)/Desktop/lab5_output.txt

function check(){

  if eval $1
  then
     echo -e "\e[0;32mOK\e[m"
  else
     echo
     echo
     echo -e "\e[0;31mWARNING\e[m"
     echo
     echo
     echo $2
     echo
     exit 1
  fi

} # end of check() function

clear  # Clear the screen

# Make certain user is logged in as root
if [ $(whoami) != "root" ]
then
  echo "Note: You are required to run this program as root."
  exit 1
fi

cat <<+
ATTENTION:

In order to run this shell script, please
have the following information ready:

 - IPADDRESSES for only your deb2 VM.

 - Your regular username password for deb2 VM.
   You were instructed to have the IDENTICAL usernames
   and passwords for ALL of these Linux servers. If not
   login into each VM, switch to root, and use the commands:

   useradd -m [regular username]
   passwd [regular username]

   Before proceeding.

After reading the above steps, press ENTER to continue
+
read null
clear

# System information gathering
echo "OPS245 Lab 5 Check Script" > $logfile
echo | tee -a $logfile
echo "SYSTEM INFORMATION:" | tee -a $logfile
#echo "------------------------------------" | tee -a $logfile
hostnamectl | tee -a $logfile
echo -n "              Date: "  | tee -a $logfile
date | tee -a $logfile
echo | tee -a $logfile

# Start checking lab5
echo "CHECKING YOUR LAB 5 WORK:" | tee -a $logfile
echo | tee -a $logfile

# Check for file pathname /home/$USER/bin/monitor-disk-space.bash (debhost)
echo -n "Checking that \"/home/$USER/bin/monitor-disk-space.bash\" file exists (debhost): " | tee -a $logfile
check "test -f \"/home/$USER/bin/monitor-disk-space.bash\"" "This program found there is no file called: \"//home/$USER/bin/monitor-disk-space.bash\" on your \"debhost\" VM. Please create this archive again (for the correct VM), and re-run this checking shell script." | tee -a $logfile

# Check crontab file (debhost)
echo -n "Checking for crontab file (debhost): " | tee -a $logfile
check "crontab -l -u $USER | grep -iqs \"/home/$USER/bin/monitor-disk-space.bash\"" "This program found there was no crontab entry to run the monitor-disk-space.bash shell script. Please properly create this crontab entry as ${USER}, and re-run this checking shell script." | tee -a $logfile

# Check /dev/vdb1 partition created (deb2)
echo "Checking that /dev/vdb1 partition created (deb2): " | tee -a $logfile
read -p "Enter your deb2 username: " deb2UserName
read -p "Enter IP Address for your deb2 VMs eth0 device: " deb2_IPADDR
check "ssh ${deb2UserName}@$deb2_IPADDR ls /dev/vdb1 > /dev/null || ls /dev/sda3 > /dev/null" "This program did NOT detect the partition called: \"/dev/vdb1\" was created. Please create this partition, and re-run this checking script." | tee -a $logfile

# Check archive LV was mounted under /archive directory (deb2)
echo "Checking that the \"archive LV\" was mounted under \"/archive\" directory (deb2): " | tee -a $logfile
check "ssh ${deb2UserName}@$deb2_IPADDR mount | grep -isq \"/archive\"" "This program did NOT detect that the \"archive LV\" was mounted under the \"/archive\" directory. Please make appropriate corrections, and re-run this checking script." | tee -a $logfile

# Check archive LV was formatted for ext4 file-system (deb2)
echo "Checking that the \"archive LV\" was formatted with ext4 file-system: " | tee -a $logfile
check "ssh ${deb2UserName}@$deb2_IPADDR mount | grep /archive | grep -isq ext4" "This program did NOT detect that the \"archive LV\" partition was formatted for the ext4 file-system. Please format this partition, and re-run this checking script." | tee -a $logfile

# Check /archive logical volume is 1.5G (deb2)
echo "Checking that \"/archive\" logical volume has size: 1.5G (deb2): " | tee -a $logfile
check "ssh ${deb2UserName}@$deb2_IPADDR lsblk | grep archive | grep -isq 1.5G" "This program did NOT detect that the size of the \"archive\" logical volume is set to: \"1.5G\". Please set the correct size for this partition, and re-run this checking script." | tee -a $logfile

# Check new virtual hard disk /dev/vdb created (deb2)
echo "Checking that new virtual hard disk \"/dev/vdb\" was created (deb2): " | tee -a $logfile
check "ssh $deb2UserName@$deb2_IPADDR  ls /dev/[sv]db* >/dev/null" "This program did NOT detect the device called: \"/dev/vdb\" or \"/dev/sdb\". Create this partition, and re-run this checking script." | tee -a $logfile

# Check \"home\" file-system size increased
echo -n "Checking that that the \"home\" file system increased to 12.3G (deb2): " | tee -a $logfile
check "ssh $deb2UserName@$deb2_IPADDR lsblk | grep home | grep -isq 12.3G" "This program did NOT detect that the \"home\" file-system was increased to 12.3G. Please change the size of your home partition to 12.3G, and re-run this checking script." | tee -a $logfile

# Check automatic boot of archive in /etc/fstab (deb2)
echo -n "Checking that entry of \"/archive\" mount in /etc/fstab(deb2): " | tee -a $logfile
check "ssh $deb2UserName@$deb2_IPADDR grep -sq /archive /etc/fstab" "This program did NOT detect  that the \"/etc/fstab\" file contains the entry to mount the \"archive LV\" under the \"/archive\" directory. Please make corrections to this file, and re-run this checking script." | tee -a $logfile

warningcount=`grep -c "WARNING" $logfile`

echo | tee -a $logfile
echo | tee -a $logfile
if [ $warningcount == 0 ]
then
  echo "Congratulations!" | tee -a $logfile
  echo | tee -a $logfile
  echo "You have successfully completed Lab 5." | tee -a $logfile
  echo "1. Please follow the submission instructions of your course Professor." | tee -a $logfile
  echo "2. A copy of this script output has been created at $logfile." | tee -a $logfile
  echo
else
  echo "Your Lab 5 is not complete." | tee -a $logfile
  echo "Correct the warnings listed above, then run this script again." | tee -a $logfile
fi
