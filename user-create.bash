#!/bin/bash

# user-create.bash
# Author:  Murray Saul
# Purpose: To create a list of users
# USAGE: sudo ./user-create.bash
# Test for sudo

user=$(whoami)
if [ $user != "root" ]
then
	echo "You must run this script with root privileges. Please use sudo" >&2
	exit 1
fi

numberUsers=-1
until [ $numberUsers -gt 0 ]
do
  numberUsers=$(zenity --entry --text "how many users to create?")
done

for ((x=1; x <= $numberUsers; x++))
do
  userName=$(zenity --entry --text "Enter user Name #$x:")
  fullName=$(zenity --entry --text "Enter full Name #$x:")
  useradd -m -c "$fullName" -s "/bin/bash" $userName 2> /dev/null # throw away errors (already exists)
done

zenity --info --text "All users created!"
