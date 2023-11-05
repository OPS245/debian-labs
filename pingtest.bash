#!/bin/bash

# ./pingtest.sh
# Script to test ping to all hosts on local network

while read line
do
	if echo $line | grep "^192.168.245" >> /dev/null 
	then 
		addr=$(echo $line | cut -f1 -d' ')
		host=$(echo $line | cut -f2 -d' ')
		if ping -c1 $addr > /dev/null
		then
			echo "$host online"
		else
			echo "$host offline"
		fi
	fi

done < /etc/hosts

