#!/bin/bash

# ./lab7-check.bash

# Author:  Murray Saul
# Date:    June 28, 2016
# Modified: November 27, 2020 (Chris Johnson)
# Edited by: Peter Callaghan
# Date: Sept 26, 2021
# Edited by Brian Gray for new Debian labs
# Date: Nov 13, 2023
#
# Purpose: 

# Function to indicate OK (in green) if check is true; otherwise, indicate
# WARNING (in red) if check is false and end with false exit status

logfile=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)/Desktop/lab7_output.txt
suser=${SUDO_USER:-$USER}
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

 - Your debhost and deb1, deb2 and deb3 VMs are running.

 - Your host computer is connected to Seneca's VPN
   
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
echo "OPS245 Lab 7 Check Script" > $logfile
echo | tee -a $logfile
echo "SYSTEM INFORMATION:" | tee -a $logfile
#echo "------------------------------------" | tee -a $logfile
hostnamectl | tee -a $logfile
echo -n "              Date: "  | tee -a $logfile
date | tee -a $logfile
echo | tee -a $logfile

# Start checking lab7
echo "CHECKING YOUR LAB 7 WORK:" | tee -a $logfile
echo | tee -a $logfile


# Check myfile.txt copied to user's Matrix home directory
echo "Checking file \"myfile.txt\" copied to user's Matrix home directory: " | tee -a $logfile
read -p "Enter your username for matrix: " matrixUserName
check "ssh $matrixUserName@matrix.senecacollege.ca ls /home/$matrixUserName/myfile.txt > /dev/null 2>/dev/null" "This program did not detect the file called \"myfile.txt\" in your Matrix account's home directory. Please make corrections, and re-run this checking shell script." | tee -a $logfile

# Check that the account "other" was created
echo "Checking that the user called \"other\" was created: " | tee -a $logfile
read -p "Enter your username for your deb1 VM: " deb1UserName
check "ssh $deb1UserName@deb1 grep -sq other /etc/passwd" "This program did not detect the user called \"other\" in your deb1 VM. Please make corrections, and re-run this checking shell script." | tee -a $logfile

# Check that PermitRootLogin in /etc/ssh/sshd_config file was set to no
echo "Checking \"PermitRootLogin\" set to \"no\" (sshd_config): " | tee -a $logfile
check "ssh $deb1UserName@deb1 grep -qsi PermitRootLogin.*no /etc/ssh/sshd_config" "This program did not detect the option \"PermitRootLogin\" was set to \"no\" in the \"/etc/ssh/sshd_config\" file in your deb1 VM. Please make corrections, and re-run this checking shell script." | tee -a $logfile

# Check that account called other is a member of the sudo group
echo "Checking user \"other\" added to \"sudo\" group: " | tee -a $logfile
check "ssh $deb1UserName@deb1 grep -sq sudo.*other.* /etc/group" "This program did not detect the \"other\" as a member of the \"sudo\" group in your deb1 VM. Please make corrections, and re-run this checking shell script." | tee -a $logfile

# Check that AllowGroups in sshd_config file includes sudo
echo "Checking group \"sudo\" added to \"AllowGroups\" option (sshd_config): " | tee -a $logfile
check "ssh $deb1UserName@deb1 grep -sq AllowGroups.*sudo.* /etc/ssh/sshd_config" "This program did not detect the option \"AllowGroups\" including the \"sudo\" group in the \"/etc/ssh/sshd_config\" file in your deb1 VM. Please make corrections, and re-run this checking shell script." | tee -a $logfile

# Check that public key created in deb2 VM
echo "Checking that public key created in \"deb2\" VM: " | tee -a $logfile
check "ssh $deb1UserName@deb2 ls /home/$deb1UserName/.ssh/id_rsa.pub > /dev/null" "This program did not detect the public key \"/home/$deb1UserName/.ssh/id_rsa.pub\" in the deb2 VM. Please make corrections, and re-run this checking shell script." | tee -a $logfile

# Check that public key copied to the deb3 VM
echo "Checking that public key copied to the \"deb3\" VM: " | tee -a $logfile
check "ssh $deb1UserName@deb3 ls /home/$deb1UserName/.ssh/authorized_keys > /dev/null" "This program did not detect the public key \"/home/$deb1UserName/.ssh/authorized_keys\" in the deb3 VM. Please make corrections, and re-run this checking shell script." | tee -a $logfile

# Have student run the command to remotely run gedit application
cat <<+
You will now be required to run the ssh command using tunnelling to
run the gedit application from deb1, but display in your debhost machine.
Type the command at the prompt below:

+
read -p "Enter ssh command here: " studentCommand
until [ "$studentCommand" = "ssh -X -C $deb1UserName@deb1 gedit" -o "$studentCommand" = "ssh -C -X $deb1UserName@deb1 gedit" -o "$studentCommand" = "ssh -XC $deb1UserName@deb1 gedit" -o "$studentCommand" = "ssh -CX $deb1UserName@deb1 gedit" ]
do
   echo "Error: Refer to lab7 to run gedit command remotely via ssh" | tee -a $logfile
   read -p "Enter correct ssh command with gedit argument here: " studentCommand
done

ssh -f -X -C $deb1UserName@deb1 gedit > /dev/null 2> /dev/null && echo -e "\e[0;32mOK\e[m" | tee -a $logfile

# check for iptables policy
echo -n "Checking /etc/iptables.rules for default iptables policy: " | tee -a $logfile
check "grep '^INPUT DROP' /etc/iptables.rules | head -1" "This program did not detect the default policy of the INPUT chain. Please make corrections, REBOOT your debhost machine, and re-run this checking shell script." | tee -a $logfile

# check for iptables RELATED/ESTABLISHED exception
echo -n "Checking /etc/iptables.rules for RELATED/ESTABLISHED traffic exception: " | tee -a $logfile
check "grep 'RELATED/ESTABLISHED.*ACCEPT' /etc/iptables.rules | head -1" "This program did not detect the rule to ACCEPT RELATED/ESTABLISHED traffic. Please make corrections, REBOOT your debhost machine, and re-run this checking shell script." | tee -a $logfile

# check for iptables icmp exception 
echo -n "Checking /etc/iptables.rules for icmp exception: " | tee -a $logfile
check "grep -sq 'icmp.*ACCEPT' /etc/iptables.rules | head -1" "This program did not detect the rule to ACCEPT icmp traffic. Please make corrections, REBOOT your debhost machine,  and re-run this checking shell script." | tee -a $logfile

# check for iptables exception for ssh from network1
echo -n "Checking /etc/iptables.rules for SSH exception: " | tee -a $logfile
check "grep -sq '192\.168\.245\.0/24.*--dport 22.*ACCEPT' /etc/iptables.rules | head -1" "This program did not detect the rule to ACCEPT ssh traffic from network1. Please make corrections, REBOOT your debhost machine, and re-run this checking shell script." | tee -a $logfile

# check for iptables exception for lo interface
echo -n "Checking /etc/iptables.rules for lo exception: " | tee -a $logfile
check "grep -sq '\-i lo.*ACCEPT' /etc/iptables.rules | head -1" "This program did not detect the rule to ACCEPT traffic to the lo interface. Please make corrections, REBOOT your debhost machine, and re-run this checking shell script." | tee -a $logfile

# check for making iptables rules persistent
echo -n "Checking for the script to restore /etc/iptables.rules at boot: " | tee -a $logfile
check "grep -sq 'iptables-restore' /etc/network/if-pre-up.d/iptables | head -1" "This program did not detect the /etc/network/if-pre-up.d/iptables script. Please make corrections, REBOOT your debhost machine, and re-run this checking shell script." | tee -a $logfile

warningcount=`grep -c "WARNING" $logfile`

echo | tee -a $logfile
echo | tee -a $logfile
if [ $warningcount == 0 ]
then
  echo "Congratulations!" | tee -a $logfile
  echo | tee -a $logfile
  echo "You have successfully completed Lab 7." | tee -a $logfile
  echo "1. Submit a screenshot of this window to Blackboard as per your Professor's instructions." | tee -a $logfile
  echo "2. A copy of this script output has been created at $logfile." | tee -a $logfile
  echo
else
  echo "Your Lab is not complete." | tee -a $logfile
  echo "Correct the warnings listed above, then run this script again." | tee -a $logfile
fi
