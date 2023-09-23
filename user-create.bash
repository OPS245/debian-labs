#!/bin/bash

# /root/user-create.bash
# Author:  Murray Saul
# Purpose: To create a list of users
# USAGE: /root/user-create.bash

numberUsers=-1
until [ $numberUsers -gt 0 ]
do
  numberUsers=$(zenity --entry --text "how many users to create?")
done

for ((x=1; x <= $numberUsers; x++))
do
  userName=$(zenity --entry --text "Enter user Name #$x:")
  useradd -m $userName 2> /dev/null # throw away errors (already exists)
done

zenity --info --text "All users created!"
