#!/bin/bash
#
# createUsers.bash
# Purpose: Generates a batch of user accounts from a text file
#
# Usage: sudo ./createUsers.bash [-i {input-path}]
#
# Author: *** INSERT YOUR NAME ***
# Date: *** CURRENT DATE ***

# Test for sudo
user=$(whoami)
if [ $user != "root" ]
then
	echo "you must run this script with root privileges. Please use sudo"
	exit 1
fi

# Test for argument
if [ "$#" -eq 0 ] # if no arguments
then
	echo "You must enter an argument" >&2
	echo "Usage: $0 [-i {input-path}]" >&2
	exit 2
fi

# Parse arguments
outputFlag="n"
while getopts i: name
do
	case $name in
		i) inputFile=$OPTARG ;;
		:) echo "Error: You need text after options requiring text"
			exit 3 ;;
		\?) echo "Error: Incorrect option"
			exit 3 ;;
	esac
done

# Test for inputFile
if [ ! -f $inputFile ]
then
	echo "The file pathname \"$inputFile\" is empty or does not extist" >&2
	exit 4
fi

# Temporarily convert spaces to + for storing lines as positional parameters
set $(sed 's/ /+/g' $inputFile) 

for x
do
	userPassWd=$(date | md5sum | cut -d" " -f1)
	useradd -m \
		-c "$(echo $x | cut -d":" -f2 | sed 's/+/ /g')" \
	        -s "/bin/bash" \
		-p $userPassWd \
		$(echo $x | cut -d":" -f1)
	cat <<+
	Server Account Information
	Here is your server account information:
	servername : myserver.senecacollege.ca
	username: $(echo $x | cut -d":" -f1)
	password: $userPassWd
	email: $(echo $x | cut -d":" -f3) 

+
done

echo -e "\n\nAccounts have been created\n\n"
exit 0


