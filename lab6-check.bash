#!/bin/bash

# ./lab6-check.bash

# Author:  Murray Saul
# Date:    June 27, 2016
# Edited by: Peter Callaghan
# Date: 18 Nov, 2021
# Edited by: Chris Johnson
# Date: July 22, 2021
# Edited by: Brian Gray for new Debian Labs
# Date: November 3, 2023

# Purpose: 

# Function to indicate OK (in green) if check is true; otherwise, indicate
# WARNING (in red) if check is false and end with false exit status
suser=${SUDO_USER:-$USER}
logfile=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)/Desktop/lab6_output.txt

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

cat <<+
ATTENTION:

In order to run this shell script, please
have the following information ready:

 - Your debhost and deb1, deb2, and deb3 VMs running.
   
 - Your deb1 username.
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


# Make certain user is logged in as root
if [ $(whoami) != "root" ]
then
  echo "Note: You are required to run this program as root."
  exit 1
fi

# System information gathering
echo "OPS245 Lab 6 Check Script" > $logfile
echo | tee -a $logfile
echo "SYSTEM INFORMATION:" | tee -a $logfile
#echo "------------------------------------" | tee -a $logfile
hostnamectl | tee -a $logfile
echo -n "              Date: "  | tee -a $logfile
date | tee -a $logfile
echo | tee -a $logfile

# Start checking lab6
echo "CHECKING YOUR LAB 6 WORK:" | tee -a $logfile
echo | tee -a $logfile

# Check if debhost can ping 192.168.245.1
echo -n "Checking pinging 192.168.245.1 (debhost): " | tee -a $logfile
check "ping 192.168.245.1 -c 1 > /dev/null 2>&1" "This program could not ping itself. Please make fixes, and re-run this checking shell script." | tee -a $logfile

# Check if debhost can ping 192.168.245.11
echo -n "Checking pinging 192.168.245.11 (deb1): " | tee -a $logfile
check "ping 192.168.245.11 -c 1 > /dev/null 2>&1" "This program could not ping deb1. Please make appropriate corrections, and re-run this checking script." | tee -a $logfile

# Check if debhost can ping 192.168.245.12
echo -n "Check pinging 192.168.245.12 (deb2): " | tee -a $logfile
check "ping 192.168.245.12 -c 1 > /dev/null 2>&1" "This program could not ping deb2. Please make appropriate corrections, and re-run this checking script." | tee -a $logfile

# Check if debhost can ping 192.168.245.13
echo -n "Check pinging 192.168.245.13 (deb3): " | tee -a $logfile
check "ping 192.168.245.13 -c 1 > /dev/null 2>&1" "This program could not ping deb3. Please make appropriate corrections, and re-run this checking script." | tee -a $logfile

# Check for persistent setting on deb1
#echo "Check for persistent setting on deb1: " | tee -a $logfile
#read -p "Enter your username for deb1: " deb1UserName
#check "ssh ${deb1UserName}@deb1 grep -isq 192.168.245.11 '/etc/NetworkManager/system-connections/Wired connection 1'" "This program could find a correct address in the network interface file. Please make fixes, and re-run this checking shell script." | tee -a $logfile

# Check for persistent setting on deb2
echo "Check for persistent setting on deb2: " | tee -a $logfile
check "ssh ${deb1UserName}@deb2 grep -isq 192.168.245.12 '/etc/network/interfaces'" "This program could find a correct address in the netwrok interface file. Please make fixes, and re-run this checking shell script." | tee -a $logfile

# Check for persistent setting on deb3
echo "Check for persistent setting on deb3 (use password: \"ops245\"): " | tee -a $logfile
check "ssh ops245@deb3 grep -isq 192.168.245.13 '/etc/network/interfaces'" "This program could not find a correct address in the network interface file. Please make fixes, and re-run this checking shell script." | tee -a $logfile

# Check if can ping debhost name
echo -n "Checking pinging debhost: " | tee -a $logfile
check "ping debhost -c 1 > /dev/null 2>&1" "This program could not ping itself. Please make fixes, and re-run this checking shell script." | tee -a $logfile

# Check if can ping deb1 host name
echo -n "Checking pinging deb1: " | tee -a $logfile
check " ping deb1 -c 1 > /dev/null 2>&1" "This program could not ping deb1. Please make appropriate corrections, and re-run this checking script." | tee -a $logfile

# Check if can ping deb2 host name
echo -n "Check pinging deb2: " | tee -a $logfile
check "ping deb2 -c 1 > /dev/null 2>&1" "This program could not ping deb2. Please make appropriate corrections, and re-run this checking script." | tee -a $logfile

# Check if can ping deb3 host name
echo -n "Check pinging deb3: " | tee -a $logfile
check "ping deb3 -c 1 > /dev/null 2>&1" "This program could not ping deb3. Please make appropriate corrections, and re-run this checking script." | tee -a $logfile

# Check existence of netconfig.py script
echo -n "Checking existence of \"/home/$suser/bin/pingtest.bash\" script: " | tee -a $logfile
check "test -f /home/$suser/bin/pingtest.bash" "This program could not detect the pathname: \"/home/$suser/bin/pingtest.bash\". Please review Investigation 3 and successfully code the script /home/$suser/bin/pingtest.bash." | tee -a $logfile

warningcount=`grep -c "WARNING" $logfile`

echo | tee -a $logfile
echo | tee -a $logfile
if [ $warningcount == 0 ]
then
  echo "Congratulations!" | tee -a $logfile
  echo | tee -a $logfile
  echo "You have successfully completed Lab 6." | tee -a $logfile
  echo "1. Submit a screenshot of your entire desktop (including this window) to your course professor." | tee -a $logfile
  echo "2. Also submit a screenshot your email message from the pingtest.bash script." | tee -a $logfile
  echo
else
  echo "Your Lab is not complete." | tee -a $logfile
  echo "Correct the warnings listed above, then run this script again." | tee -a $logfile
fi
