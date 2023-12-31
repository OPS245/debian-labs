#!/bin/bash

# ./lab4-check.bash

# Author:  Murray Saul
# Date:    June 7, 2016
# Edited by: Peter Callaghan
# Date: Sept 26, 2021
#
# Edited by: Brian Gray 
# For new debian labs Fall 2023
#
# Purpose: Check that students correctly managed user and group accounts
#          when performing this lab, check that students have properly
#          managed services, and created a shell script to work like
#          a Linux command to automate creation of multiple user
#          accounts (user data stored in a text-file).

# Function to indicate OK (in green) if check is true; otherwise, indicate
# WARNING (in red) if check is false and end with false exit status
suser=${SUDO_USER:-$USER}
logfile=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)/Desktop/lab4_output.txt

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
  echo "Note: You are required to run this program as root. Use sudo"
  exit 1
fi

cat <<+
ATTENTION:

In order to run this shell script, please
have the following information ready:

 - IPADDRESSES for only your deb1 VM.

 - Your regular username password for deb1 VM.
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


# Start checking lab4
echo "OPS245 Lab 4 Check Script" > $logfile
echo | tee -a $logfile
echo "CHECKING YOUR LAB 4 WORK:" | tee -a $logfile
echo | tee -a $logfile

# Check ops245_2 user created (deb1)
echo "Checking that ops245_2 user created (deb1): " | tee -a $logfile
read -p "Enter your deb1 username: " deb1UserName
read -p "Enter IP Address for your deb1 VMs eth0 device: " deb1_IPADDR
check "ssh $deb1UserName@$deb1_IPADDR \"grep -isq \"ops245_2\" /etc/passwd\"" "This program did NOT detect the user \"ops245_2\" in the \"/etc/passwd\" file. Please create this user, complete this lab, and re-run this checking script." | tee -a $logfile

# Check ops245_1 user removed (deb1)
#echo -n "Checking that ops245_1 user removed: "
#check "! ssh $deb1UserName@$deb1_IPADDR grep -isq \"ops245_2\" /etc/passwd" "This program detected the user \"ops245_1\" in the \"/etc/passwd\" file, when that user should have been removed. Please remove this user, complete this lab, and re-run this checking script."

# Check foobar.txt created in /etc/skel directory (deb1)
echo "Checking that \"/etc/skel\" directory contains the file called \"foobar.txt\" (deb1):" | tee -a $logfile
check "ssh $deb1UserName@$deb1_IPADDR ls /etc/skel | grep -isq \"foobar.txt\"" "This program did NOT detect the file called \"foobar.txt\" in the \"/etc/skel\" directory. Please create this file, remove the user ops245_2, and then create that user to see the \"foobar.txt\" file automatically created in that user's home directory upon the creation of this user. Complete this lab, and re-run this checking script." | tee -a $logfile

# Check group created with name "welcome" (deb1)
echo "Checking that a group name \"welcome\" is contained in the file \"/etc/group\": " | tee -a $logfile
check "ssh $deb1UserName@$deb1_IPADDR grep -isq \"welcome\" /etc/group" "This program did NOT detect the group name \"welcome\" in the \"/etc/group\" file. Please remove the group, and correctly add the group with the correct GID, complete the lab (with secondary users added), and re-run this checking script." | tee -a $logfile

# Check user noobie removed
echo "Checking that \"noobie\" user was removed: " | tee -a $logfile
check "ssh $deb1UserName@$deb1_IPADDR ! grep -isq \"noobie\" /etc/passwd" "This program did NOT detect the user name \"noobie\" was removed. Remove this user account, and re-run this checking script." | tee -a $logfile

# Check ssh service started and enabled (deb1)
echo "Checking that ssh service started and enabled (deb1): " | tee -a $logfile
check "ssh $deb1UserName@$deb1_IPADDR systemctl status ssh | grep -iqs \"active\" && ssh $deb1UserName@$deb1_IPADDR systemctl status ssh | grep -iqs \"enabled\"" "This program did NOT detect that the ssh service has \"started\" and/or is \"enabled\". Use systemctl to start and enable the ssh service, and re-run this checking script." | tee -a $logfile

# Check  runlevel 5 for deb1 VM
echo "Checking that that \"deb1\" VM is in target graphical.target: " | tee -a $logfile
check "ssh $deb1UserName@$deb1_IPADDR /usr/sbin/runlevel | grep -isq \"5$\"" "This program did NOT detect that your \"deb1\" VM is in graphical.target. Please make certain you set the default target to graphical, and re-run this checking script." | tee -a $logfile

# Check for file: ~/bin/createUsers.bash (debhost)
echo  "Checking that the script \"/home/$suser/bin/createUsers.bash\" exists: " | tee -a $logfile
check "test -f /home/$suser/bin/createUsers.bash" "This program did NOT detect the file \"/home/$suser/bin/createUSers.bash\" on your \"debhost\" machine. Complete the lab, and re-run this checking script." | tee -a $logfile

warningcount=`grep -c "WARNING" $logfile`

echo | tee -a $logfile
echo | tee -a $logfile
if [ $warningcount == 0 ]
then
  echo "Congratulations!" | tee -a $logfile
  echo | tee -a $logfile
  echo "You have successfully completed Lab 4." | tee -a $logfile
  echo "1. Please follow the submission instructions of your Professor." | tee -a $logfile
  echo "2. A copy of this script output has been created at $logfile. Submit this file along with your screenshot." | tee -a $logfile
  echo "3. Also submit a copy of your createUsers.bash script." | tee -a $logfile
  echo
else
  echo "Your Lab is not complete." | tee -a $logfile
  echo "Correct the warnings listed above, then run this script again." | tee -a $logfile
fi
