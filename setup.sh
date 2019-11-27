#!/usr/bin/bash

usage()
{
	echo -e "\n#### PrivEsc Setup Script by 3therk1ll ####\n"
	echo -e "\n#### Run on attacker machine to update repos and copy binaries/files to project folder ####\n"
	echo "USAGE:"
	echo "-a	Target Architecture (Required). x86 or x64"
	echo "-l	Linux Target"
	echo "-w	Windows Target"
	echo "-p	Project Folder. Default is current folder"
}

updateLinRepos()
{
	scripts = (
				"LinEnum"
				"privilege-escalation-awesome-scripts-suite"
				"linux-smart-enumeration"
				"linux-exploit-suggester"
				"linuxprivchecker"
				"linux-exploit-suggester"
				"psspy32"
			)
	cd /opt
	
	for repo in "${repos[@]}"
	do
		cd $repo 
		git pull
		cd /opt
	done
}

linuxSetup()
{
	cd $projectFolder
	mkdir privesc
	cd privesc
	cp /opt/LinEnum/LinEnum.sh .
	cp /opt/linux-exploit-suggester/linux-exploit-suggester.sh .
	cp /opt/linuxprivchecker/linuxprivchecker.py .
	
	if [ $arch -eq "x86" ]; then
		wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy32
	else
		wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64
	fi
	
	cp /opt/privilege-escalation-awesome-scripts-suite/linPEAS/linpeas.sh .
	cp /opt/linux-smart-enumeration/lse.sh .
}

updateWinRepos()
{
	scripts = (
			"Powersploit"
			"privilege-escalation-awesome-scripts-suite"
		)
	cd /opt
	
	for repo in "${repos[@]}"
	do
		cd $repo
		git pull
		cd /opt
	done
}

windowsSetup()
{
	cd $projectFolder
	mkdir privesc
	cd privesc
	cp /opt/privilege-escalation-awesome-scripts-suite/winPEAS/winPEASbat/winPEAS.bat .
	cp /opt/PowerSploit/Privesc/PowerUp.ps1 .
	
	echo -e "\n[*] Automatically appending Invoke-AllChecks to PowerUp.ps1\n"
	echo "Invoke-AllChecks" >> PowerUp.ps1
	
	if [ $arch -eq "x86" ]; then
		wget https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite/blob/master/winPEAS/winPEASexe/winPEAS/bin/x86/Release/winPEAS.exe
	else
		wget https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite/blob/master/winPEAS/winPEASexe/winPEAS/bin/x64/Release/winPEAS.exe
	fi
}

run()
{
	if [ -z "$linux" ] || [ -z "$windows" ]; then
		echo -e "\n[!] Must Supply target OS. Linux/Windows.\n"; exit
	fi
	
	if [ -z "$arch" ]; then
		echo -e "\n[!] Must Supply target architecture for target\n"; exit
	fi
	
	if [ -z "$projectFolder" ]; then
		projectFolder=$(pwd)
		echo -e "\n[*] No Project Directory Specified. Defaulting to current: $projectFolder\n"
	fi
	
	if [ -d $projectFolder ]; then
		echo -e "\n[*] Project Directory Specified and OK: $projectFolder\n" 
	else
		echo -e "\n[*] Inavalid Directory: $projectFolder\n"; exit
	fi
	
	if [ ! -z "$windows" ]; then
		updateWinRepos
		windowsSetup
	else
		updateLinRepos
		linuxSetup
	fi
}

while getopts "a:l:w:p:h" option; do
 case "${option}" in
    	a) arch=${OPTARG};;
	l) linux=${OPTARG};;
	w) windows=${OPTARG};;
	p) projectFolder=${OPTARG};;
    	h) usage; exit;;
    	*) usage; exit;;
 esac
done

run
