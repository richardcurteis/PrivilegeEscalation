#!/usr/bin/bash

mkdir privesc
cd privesc
cp /opt/LinEnum/LinEnum.sh .
cp /opt/linux-exploit-suggester/linux-exploit-suggester.sh .
cp /opt/linuxprivchecker/linuxprivchecker.py .
wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy32
cp /opt/privilege-escalation-awesome-scripts-suite/linPEAS/linpeas.sh .
cp /opt/linux-smart-enumeration/lse.sh .
