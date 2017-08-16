# [PowerPoll](https://github.com/Maarti/PowerPoll)
PowerShell poll program for my co-workers to decide where to eat each day :)

## Overview
![Program Overview](doc/overview.png)

## Getting started

* Open PowerShell (or PowerShell ISE)
* Move to the project folder `cd .\PowerPoll\`
* Run the script `.\poll.ps1`

## Disable Execution Policy
If you have this error :
> script1.ps1 cannot be loaded because running scripts is disabled on this system.

This error happens due to a security measure which won't let scripts be executed on your system without you having approved of it.

**Disable it for the current user :**
```bat
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force
```
**Or definitively on the computer :**
```bat
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
```

## Useful information
* [Effective Windows PowerShell ebook](https://rkeithhill.wordpress.com/2009/03/08/effective-windows-powershell-the-free-ebook/) from Keith 

## Author
[Bryan MARTINET](https://maarti.net)