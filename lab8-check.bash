#!/bin/bash

# ./lab8-check.bash

# Author:  Murray Saul
# Date:    November 18, 2016
# Edited by: Peter Callaghan
# Date: Sept 26, 2021
# Edited by: Brian Gray for new Debian labs
# Date: Nov 20,2023
#
# Purpose: 

# Function to indicate OK (in green) if check is true; otherwise, indicate
# WARNING (in red) if check is false and end with false exit status

logfile=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)/Desktop/lab8_output.txt
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

 - Your debhost and your deb1 and deb3 VMs are running.
   
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
echo "OPS245 Lab 8 Check Script" > $logfile
echo | tee -a $logfile
echo "SYSTEM INFORMATION:" | tee -a $logfile
#echo "------------------------------------" | tee -a $logfile
hostnamectl | tee -a $logfile
echo -n "              Date: "  | tee -a $logfile
date | tee -a $logfile
echo | tee -a $logfile

# Start checking lab8
echo "CHECKING YOUR LAB 8 WORK:" | tee -a $logfile
echo | tee -a $logfile


# Check DHCPACK in journal on deb1
echo "Checking DHCP Client Lease for deb1 VM: " | tee -a $logfile
read -p "Enter your deb1 username: " deb1UserName
check "ssh $deb1UserName@192.168.245.42 sudo -S journalctl | grep -iqs 'DHCPACK'" "This program did not detect the value \"dhcp\" for the BOOTPROTO option in the network interface file on your deb1 VM. Another reason why this error occurred is that you didn't complete the last section to add a host for deb1 using the IPADDR \"192.168.245.42\". Please make corrections, reboot your deb3 VM, and re-run this checking shell script." | tee -a $logfile

# Check that dhcp server is running on deb3 VM
echo "Checking that isc-dhcp-server is currently running on your deb3 VM: " | tee -a $logfile
check "ssh $deb1USerName@deb3 sudo -S \"systemctl status isc-dhcp-server | grep -iqs active\"" "This program did not detect that the \"dhcp\" service is running (active). Please make corrections, and re-run this checking shell script." | tee -a $logfile

# Check DHCPDISCOVER, DHCPOFFER, DHCPREQUEST & DHCPACK for deb3 in journal
echo "Checking \" DHCPDISCOVER, DHCPOFFER, DHCPREQUEST & DHCPACK\" in" | tee -a $logfile
echo " journal on deb3 VM: " | tee -a $logfile
check "ssh $deb1UserName@deb3 \"sudo -S (journalctl | grep -iqs DHCPDISCOVER && journalctl | grep -iqs DHCPOFFER && journalctl | grep -iqs DHCPREQUEST && journalctl | grep -iqs DHCPACK )\"" "This program did not detect the messages containing \" DHCPDISCOVER or DHCPOFFER or DHCPREQUEST or DHCPACK\" relating to \"deb3\" for your deb3 VM. Please make corrections, and re-run this checking shell script." | tee -a $logfile

# Check for non-empty "/var/lib/dhcp/dhcpd.leases" file on deb3 VM
echo "Checking for non-empty \"/var/lib/dhcp/dhcpd.leases\" file on deb3 VM: " | tee -a $logfile
check "ssh $deb1UserName@deb3 test -s /var/lib/dhcp/dhcpd.leases " "This program did not detect the NON-EMPTY file called \"/var/lib/dhcpd/dhcpd.leases\" file in your deb3 VM. Please make corrections, and re-run this checking shell script." | tee -a $logfile

# Check that deb3 can ping deb1 host (IPADDR: 192.168.245.42)
echo "Checking that deb3 VM can ping deb1 host (IPADDR: \"192.168.245.42\"): " | tee -a $logfile
check "ssh $deb1UserName@deb3 ping -c1 192.168.245.42 > /dev/null 2> /dev/null" "This program did not detect that there was an ip address set for any network interface card (i.e. eth0) for the value: \"192.168.245.42\". Please make corrections, and re-run this checking shell script." | tee -a $logfile

# Check that "/var/lib/dhcp" directory is non-empty on deb1 VM
echo  "Checking that \"/var/lib/dhcp\" directory is non-empty on deb1 VM: " | tee -a $logfile
check "ssh $deb1UserName@192.168.245.42 ls /var/lib/dhcp | grep -sq ." "This program did not detect regular files contained in the \"/var/lib/dhclient\" directory - this indicates that the dhcp process did not correctly for your deb1 VM when you issued the command \"dhclient\". Please make corrections, and re-run this checking shell script." | tee -a $logfile

warningcount=`grep -c "WARNING" $logfile`

echo | tee -a $logfile
echo | tee -a $logfile
if [ $warningcount == 0 ]
then
  echo "Congratulations!" | tee -a $logfile
  echo | tee -a $logfile
  echo "You have successfully completed Lab 8." | tee -a $logfile
  echo "1. Submit a screenshot of this window to Blackboard as per your Professors instructions." | tee -a $logfile
  echo "2. A copy of this script output has been created at $logfile." | tee -a $logfile
  echo
else
  echo "Your Lab is not complete." | tee -a $logfile
  echo "Correct the warnings listed above, then run this script again." | tee -a $logfile
fi
