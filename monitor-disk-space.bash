#!/usr/bin/bash


# This script is based off of:
# Linux shell script to watch disk space (should work on other UNIX oses )
# SEE URL: http://www.cyberciti.biz/tips/shell-script-to-watch-the-disk-space.html
# 
# Re-written for OPS245 Debian labs: Brian Gray
# Date: 19 Oct 2023


# The local email account to send notifications to
admin="root"

# The percentage use at which notifications will be sent
alert=90

# Get the machine's hostname
hname=$(hostname)

# Get current timestamp
date=$(date)

# Gather %use of each monitored volume
diskusage=$(df -h | grep -vE '^Filesystem|tmpfs|^udev' | awk '{print $5 $1 }')

# Loop through each volume entry
for disk in $diskusage
do
    # Cut percentage use
    usage=$(echo $disk | cut -d'%' -f1)
    # Cut device/filesystem name
    volume=$(echo $disk | cut -d'%' -f2)
    # If %use of this volume is above the point at which we want to be notified...
    if [ $usage -ge $alert ]
    then
        # Send email notification
        echo "$hname is running out of space on the $volume device. As of $date  it is $usage% full." \
        | mail -s "Alert: $hname is almost out of disk space" $admin
    fi
