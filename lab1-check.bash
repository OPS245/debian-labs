#!/bin/bash

# ./lab1-check.bash

# Author:  Murray Saul
# Date:    May 22, 2016
# Edited by: Peter Callaghan
# Date: Sept 26, 2021
#
# Modified by: Brian Gray
# Rewritten for Fall 2023 switch to Debian

# Purpose: Check that students correctly installed the debhost VM
#          and properly performed common Linux commands. Script will
#          exit if errors, but provide feedback to correct the problem.

# Function to indicate OK (in green) if check is true; otherwise, indicate
# WARNING (in red) if check is false and end with false exit status

suser=${SUDO_USER:-$USER}
logfile=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)/Desktop/lab1_output.txt

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

# Make certain suser is logged in as root
if [ $(whoami) != "root" ]
then
  echo "Note: You are required to run this program as root."
  exit 1
fi

# System information gathering
echo "OPS245 Lab 1 Check Script" > $logfile
echo | tee -a $logfile
echo "SYSTEM INFORMATION:" | tee -a $logfile
#echo "------------------------------------" | tee -a $logfile
hostnamectl | tee -a $logfile
echo -n "              Date: "  | tee -a $logfile
date | tee -a $logfile

# Start checking lab1
echo | tee -a $logfile
echo "CHECKING YOUR LAB 1 WORK:" | tee -a $logfile
#echo | tee -a $logfile

# Check version of Linux distribution
echo -n "Checking Correct Linux Distribution: " | tee -a $logfile
check "grep -iqs \"VERSION=.*12\" /etc/os-release && grep -iqs \"debian\" /etc/os-release" " Your version of Debian is not 12. You are required to use Debian 12 in order to perform these labs. Install the correct version of Debian and re-run this shell script." | tee -a $logfile

# Checking for correct partitions created
echo -n "Checking that root partition was created: " | tee -a $logfile
check "lsblk -f | grep  /$ | grep -isq ext4" "You needed to create a root partition (file system type: ext4). Please reinstall debhost and re-run this shell script." | tee -a $logfile

echo -n "Checking that \"/home\" partition was created: " | tee -a $logfile
check "lsblk -f | grep  /home$ | grep -isq ext4" "You needed to create a \"/home\" partition (file system type: ext4). Please reinstall debhost and re-run this shell script." | tee -a $logfile

echo -n "Checking that \"/var/lib/libvirt/images\" partition was created: " | tee -a $logfile
check "lsblk -f | grep  /var/lib/libvirt/images$ | grep -isq ext4" "You needed to create a \"/var/lib/libvirt/images\" partition (file system type: ext4 with correct absolute pathname correctly spelled). Please reinstall debhost and re-run this shell script." | tee -a $logfile

# Checking for correct sizes for the partitions created
echo -n "Checking that the root partition is at least 30GB: " | tee -a $logfile
check "test `df | grep /$ | awk '{print $2;}'` -ge 28000000" "The size of the root partition must be at least 30GB. Please reinstall debhost and re-run this shell script." | tee -a $logfile

echo -n "Checking that the /home partition is at least 40GB: " | tee -a $logfile
check "test `df | grep /home$ | awk '{print $2;}'` -ge 38000000" "The /home partition must be at least 40GB. Please reinstall debhost and re-run this shell script." | tee -a $logfile

echo -n "Checking that the \"/var/lib/libvirt/images\" partition is at least 100GB: " | tee -a $logfile
check  "test `df | grep /var/lib/libvirt/images$ | awk '{print $2;}'` -ge 95000000" "The \"/var/lib/libvirt/images\" partition must be at least 100GB. Please reinstall debhost and re-run this shell script." | tee -a $logfile

# Checking for network connectivity
echo -n "Checking for network connectivity: " | tee -a $logfile
check "wget -qO- http://google.ca &> /dev/null" "Your internet connection doesn't seem to work. Check the interface is configured for DHCP" | tee -a $logfile

# Check if AppArmor is disabled
echo -n "Checking that AppArmor is disabled: " | tee -a $logfile
check "systemctl status apparmor | grep -isq disabled" "AppArmor is not disabled. Please make corrections and re-run this shell script." | tee -a $logfile

# Check if /home/suser/bin directory was created
echo -n "Checking that \"/home/$suser/bin\" directory was created:" | tee -a $logfile
check "test -d \"/home/$suser/bin\"" "This program did NOT detect that the \"/$suser/bin\" directory was created. Please create this directory, and re-run this shell script." | tee -a $logfile

# Check for existence of /home/suser/bin/report.txt
echo -n "Checking that \"/home/$suser/bin/report.txt\"  exists:" | tee -a $logfile
check "test -f \"/home/$suser/bin/report.txt\"" "This program did NOT detect the output from the manual system report \"/home/$suser/bin/report.txt\". Please create your manual system report and re-run this shell script." | tee -a $logfile

# Check for existence of /home/suser/bin/myreport.bash script
echo -n "Checking that \"/home/$suser/bin/myreport.bash\" script exists:" | tee -a $logfile
check "test -f \"/home/$suser/bin/myreport.bash\"" "This program did NOT detect the file pathname \"/home/$suser/bin/myreport.bash\". Please create this script at that pathname and re-run this shell script." | tee -a $logfile

# Check that myreport.bash script was run
echo -n "Checking that \"/home/$suser/bin/myreport.bash\" script was run:" | tee -a $logfile
check "test -f \"/home/$suser/bin/sysreport.txt\"" "This program did NOT detect the existence of the file \"/home/$suser/bin/sysreport.txt\" and may indicate that the shell script was NOT run. Please run the shell script correctly and re-run this shell script." | tee -a $logfile

warningcount=`grep -c "WARNING" $logfile`

echo | tee -a $logfile
echo | tee -a $logfile
if [ $warningcount == 0 ]
then
  echo "Congratulations!" | tee -a $logfile
  echo | tee -a $logfile
  echo "You have successfully completed Lab 1." | tee -a $logfile
  echo "1. Submit a screenshot of your entire desktop (including this window) to your course professor." | tee -a $logfile
  echo "2. A copy of this script output has been created at $logfile. Submit this file along with your screenshot." | tee -a $logfile
  echo "3. Also submit a copy of your myreport.bash script." | tee -a $logfile
  echo
else
  echo "Your Lab is not complete." | tee -a $logfile
  echo "Correct the warnings listed above, then run this script again." | tee -a $logfile
fi
