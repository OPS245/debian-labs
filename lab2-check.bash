#!/bin/bash

# ./lab2-check.bash

# Author:    Murray Saul
# Date:      May 22, 2016
# Modified:  September 15, 2016
# Edited by: Peter Callaghan
# Date: 26 Sept, 2021
#
# Edited by: Brian Gray
# Date: Sep 11 2023
#
# Minor Update by: Chris Johnson
# Date: Feb 1 2024
# Revision notes: Echo's text file output's location.
#
# Rewritten for new Debian Labs
#
# Purpose: Check that students correctly installed deb1, deb2,
#          and deb3 VMs. Check that VMs installed correctly
#          (ext4 filesystem, sizes, AppArmor disabled).
#          Check that VMs were backed-up, and backup script created

# Function to indicate OK (in green) if check is true; otherwise, indicate
# WARNING (in red) if check is false and end with false exit status

suser=${SUDO_USER:-$USER}
logfile=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)/Desktop/lab2_output.txt

function check(){

  if eval $1
  then
     echo -e "\e[0;32mOK\e[m"
  else
     echo
     echo
     echo -e "\e[0;31mWARNING\e[m"
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

# Banner

cat <<+
ATTENTION:

In order to run this shell script, please
have the following information ready:

 - IPADDRESSES for your deb1 and deb2 VMs
   use the command: ip address

 - Your regular username password for debhost and ALL VMs.
   You were instructed to have the IDENTICAL usernames
   and passwords for ALL of these Linux hosts

After reading the above steps, press ENTER to continue
+
read null
clear

# Start checking lab2
echo "OPS245 Lab 2 Check Script" > $logfile
echo | tee -a $logfile
echo "CHECKING YOUR LAB 2 WORK:" | tee -a $logfile
echo | tee -a $logfile

read -p "Enter the username that you created for your debhost and ALL VMs: " UserName
# Insert various checks here

# Check if ~user/bin directory exists in debhost VM
echo -n "Checking for existence of \"/home/$UserName/bin\" directory in debhost: " | tee -a $logfile
check "test -d /home/$UserName/bin" "There is no bin directory contained in your home directory in your debhost VM. You need to issue command: \"mkdir /home/$UserName/bin\" and re-run this shell script." | tee -a $logfile

# Check if ~user/bin/lab2-check.bash path exists
echo -n "Checking for pathname \"/home/$UserName/bin/lab2-check.bash\"" | tee -a $logfile
check "test -f /home/$UserName/bin/lab2-check.bash" "The \"lab2-check.bash\" file should be contained in the \"/home/$UserName/bin\" directory where all shell scripts should be for your account. Please locate that file to the directory, and re-run this checking shell script." | tee -a $logfile

# Check that all 3 VMs have been created
echo -n "Checking that \"deb1\", \"deb2\", and \"deb3\" VMs have been created:" | tee -a $logfile
check "virsh list --all | grep -isq deb1 && virsh list --all | grep -isq deb2 && virsh list --all | grep -isq deb3" "This program detected that not ALL VMs have been created (i.e. deb1, deb2, deb3). Please create these VMs with the correct VM names, and re-run this checking shell script." | tee -a $logfile


# Check that all 3 VMs are running
echo -n "Checking that \"deb1\", \"deb2\", and \"deb3\" VMs are ALL running:" | tee -a $logfile
check "virsh list | grep -isq deb1 && virsh list | grep -isq deb2 && virsh list | grep -isq deb3" "This program detected that not ALL VMs (i.e. deb1, deb2, deb3) are running. Please make certain that ALL VMs are running, and re-run this checking shell script." | tee -a $logfile

# Check deb1 VM has \"ext4\" file-system types
echo "Checking that \"deb1\" has correct ext4 file-system type:" | tee -a $logfile
read -p "Enter IP Address for your deb1 VMs eth0 device: " deb1_IPADDR
check "ssh $UserName@$deb1_IPADDR \"lsblk -f | grep -i /$ | grep -iqs \"ext4\"\"" "This program detected that your deb1 VM does NOT have the correct filesystem type (ext4) for your / partition. Please remove and recreate the \"deb1\" VM, and re-run this checking shell script." | tee -a $logfile

# Check deb2 VM has \"ext4\" file-system types
echo "Checking that \"deb2\" has correct ext4 file-system types:" | tee -a $logfile
read -p "Enter IP Address for your deb2 VMs eth0 device: " deb2_IPADDR
check "ssh $UserName@$deb2_IPADDR \"lsblk -f | grep -iqs \"ext4\" && lsblk -f | grep -i /home$ | grep -iqs \"ext4\"\"" "This program detected that your deb2 VM does NOT have \"ext4\" file system types for / and/or /home partitions. Please remove and recreate the \"deb2\" VM, and re-run this checking shell script." | tee -a $logfile

# deb3 does not have to be checked since it was automatically setup...

# Check deb1 VM image file is in "images" directory
echo "Checking that \"/var/lib/libvirt/images/deb1.qcow2\" file exists:" | tee -a $logfile
check "test -f /var/lib/libvirt/images/deb1.qcow2" "This program detected that the file pathname \"/var/lib/libvirt/images/deb1.qcow2\" does NOT exist. Please remove, and recreate the deb1 VM, and then re-run this checking shell script." | tee -a $logfile

# Check deb2 VM image file is in "images" directory
echo -n "Checking that \"/var/lib/libvirt/images/deb2.qcow2\" file exists:" | tee -a $logfile
check "test -f /var/lib/libvirt/images/deb2.qcow2" "This program detected that the file pathname \"/var/lib/libvirt/images/deb2.qcow2\" does NOT exist. Please remove, and recreate the deb1 VM, and then re-run this checking shell script." | tee -a $logfile

# Check deb3 VM image file is in "images" directory
echo -n "Checking that \"/var/lib/libvirt/images/deb3.qcow2\" file exists:" | tee -a $logfile
check "test -f /var/lib/libvirt/images/deb3.qcow2" "This program detected that the file pathname \"/var/lib/libvirt/images/deb3.qcow2\" does NOT exist. Please remove, and recreate the deb3 VM, and then re-run this checking shell script." | tee -a $logfile

# Check that  backupVM.bash script was created in user's bin directory
echo -n "Checking that file pathname \"/home/$UserName/bin/backupVM.bash\" exists:" | tee -a $logfile
check "test -f /home/$UserName/bin/backupVM.bash" "This program detected that the file pathname \"/home/$UserName/bin/backupVM.bash\" does NOT exist. please make fixes to this script, and re-run this checking shell script." | tee -a $logfile

# Check deb1 VM backed up (qcow2)
echo -n "Checking that deb1 backed up in user's home directory:" | tee -a $logfile
check "test -f /home/$UserName/backups/deb1.qcow2.gz" "This program detected that the file pathname \"/home/$UserName/backups/deb1.qcow2.gz\" does NOT exist. Please properly backup the deb1 VM (using gzip) to your home directory, and then re-run this checking shell script." | tee -a $logfile

# Check deb2 VM backed up (qcow2)
echo -n "Checking that deb2 backed up in user's home directory:" | tee -a $logfile
check "test -f /home/$UserName/backups/deb2.qcow2.gz" "This program detected that the file pathname \"/home/$UserName/backups/deb2.qcow2.gz\" does NOT exist. Please properly backup the deb2 VM (using gzip) to your home directory, and then re-run this checking shell script." | tee -a $logfile

# Check deb3 VM backed up (qcow2)
echo "Checking that deb3 backed up in user's home directory:" | tee -a $logfile
check "test -f /home/$UserName/backups/deb3.qcow2.gz" "This program detected that the file pathname \"/home/$UserName/backups/deb3.qcow2.gz\" does NOT exist. Please properly backup the deb3 VM (using gzip) to your home directory, and then re-run this checking shell script." | tee -a $logfile

warningcount=`grep -c "WARNING" $logfile`

echo | tee -a $logfile
echo | tee -a $logfile
if [ $warningcount == 0 ]
then
  echo "Congratulations!" | tee -a $logfile
  echo | tee -a $logfile
  echo "You have successfully completed Lab 2." | tee -a $logfile
  echo "Follow the submission instructions of your Professor. " | tee -a $logfile
  echo "A text copy of this check script's results can be found at: $logfile"
  echo
else
  echo "Your Lab is not complete." | tee -a $logfile
  echo "Correct the warnings listed above, then run this script again." | tee -a $logfile
  echo "A text copy of this check script's results can be found at: $logfile"
fi
