#!/bin/bash

# ./lab3-check.bash

# Author:  Murray Saul
# Date:    June 7, 2016
# Edited by: Peter Callaghan
# Date: Sept 19, 2021
#
# Edited by: Brian Gray for new Debian Labs
# Date: Sept 18 2023
# Purpose: Check that students correctly archived and installed and
#          removed software on their VMs

# Function to indicate OK (in green) if check is true; otherwise, indicate
# WARNING (in red) if check is false and end with false exit status
suser=${SUDO_USER:-$USER}
logfile=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)/Desktop/lab3_output.txt

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

 - IPADDRESSES for only your deb3 VM.

 - Your regular username password for debhost and ALL VMs.
   You were instructed to have the IDENTICAL usernames
   and passwords for ALL of these Linux servers. If not
   login into each VM, switch to root, and use the commands:

   useradd -m -s /bin/bash -c "Full Name" [regular username]
   passwd [regular username]
   usermod -aG sudo [regular username]

   Before proceeding.

After reading the above steps, press ENTER to continue
+
read null
clear

# Start checking lab3
echo "OPS245 Lab 3 Check Script" > $logfile
echo | tee -a $logfile
echo "CHECKING YOUR LAB 3 WORK:" | tee -a $logfile
echo | tee -a $logfile

# Check creation of archive1.tar archive file (deb3)
echo "Checking creation of \"~/extract1/archive1.tar\" archive file (deb3): " | tee -a $logfile
read -p "Enter IP Address for your deb3 VM: " deb3_IPADDR
check "ssh $suser@$deb3_IPADDR test -f /home/$suser/extract1/archive1.tar" "This program found there is no file called: \"~/extract1/archive1.tar\" on your \"deb3\" VM. Please create this archive again (for the correct VM), and re-run this checking shell script." | tee -a $logfile

# Check creation of archive2.tar.gz zipped tarball (deb3)
echo "Checking creation of \"~/extract2/archive2.tar.gz\" archive file (deb3): " | tee -a $logfile
check "ssh $suser@$deb3_IPADDR test -f /home/$suser/extract2/archive2.tar.gz" "This program found there is no file called: \"~/extract2/archive2.tar.gz\" on your \"deb3\" VM. Please create this archive again (for the correct VM), and re-run this checking shell script." | tee -a $logfile

# Check for restored archive in extract1 directory (deb3)
echo "Checking archive1.tar restored to \"~/extract1\" directory (deb3): " | tee -a $logfile
check "ssh $suser@$deb3_IPADDR test -d /home/$suser/extract1" "This program found that the \"archive1.tar\" was not properly restored to directory \"~/extract1\" directory in your \"deb3\" VM. Please restore this archive again (for the correct VM), and re-run this checking shell script." | tee -a $logfile

# Check for restored archive in extract2 directory (deb3)
echo "Checking archive2.tar.gz restored to \"~/extract2\" directory (deb3): " | tee -a $logfile
check "ssh $suser@$deb3_IPADDR test -d /home/$suser/extract2" "This program found that the \"archive2.tar.gz\" was not properly restored to directory \"~/extract2\" directory in your \"deb3\" VM. Please restore this archive again (for the correct VM), and re-run this checking shell script." | tee -a $logfile

# Check for removal of elinks application (debhost)
echo "Checking for removal of \"elinks\" application: " | tee -a $logfile
check "! which elinks > /dev/null 2> /dev/null" "This program found that the \"elinks\" application was NOT removed on your \"debhost\" VM. Please re-do this task, and then re-run this checking shell script." | tee -a $logfile

# Check for install of xchat application (debhost)
echo -n "Checking for install of \"hexchat\" application: " | tee -a $logfile
check "which hexchat" "This program found that the \"hexchat\" application was NOT installed on your \"debhost\" VM. Please re-do this task, and then re-run this checking shell script." | tee -a $logfile

# Check for presence of lbreakout2  application (debhost)
echo -n "Checking for presence of \"lbreakout2\" application (debhost): " | tee -a $logfile
check "which lbreakout > /dev/null 2> /dev/null || which lbreakout2 > /dev/null 2> /dev/null || test -f /usr/bin/lbreakout2 || test -f /usr/local/bin/lbreakout2" "This program did NOT detect that the game called \"lbreakout2\" was installed on your \"debhost\" VM. Please follow the instructions to properly compile your downloaded source code (perhaps ask your instructor or lab assistant for help), and then re-run this checking shell script." | tee -a $logfile

# Check for presence of packageInfo.bash shell script
echo -n "Checking for presence of \"/home/$suser/bin/packageInfo.bash\" script: " | tee -a $logfile
check "test -f /home/$suser/bin/packageInfo.bash" "This program did NOT detect the presence of the file: \"/home/$suser/bin/packageInfo.bash\". Please create this shell script in the correct location, assign execute permissions, and run this shell script, and then re-run this checking shell script." | tee -a $logfile

warningcount=`grep -c "WARNING" $logfile`

echo | tee -a $logfile
echo | tee -a $logfile
if [ $warningcount == 0 ]
then
  echo "Congratulations!" | tee -a $logfile
  echo | tee -a $logfile
  echo "You have successfully completed Lab 3." | tee -a $logfile
  echo "1. Please follow the submission instructions of your Professor." | tee -a $logfile
  echo "2. A copy of this script output has been created at $logfile. Submit this file along with your screenshot." | tee -a $logfile
  echo "3. Also submit a copy of your packageInfo.bash script." | tee -a $logfile
  echo
else
  echo "Your Lab is not complete." | tee -a $logfile
  echo "Correct the warnings listed above, then run this script again." | tee -a $logfile
fi
