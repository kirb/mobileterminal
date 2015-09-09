# Introduction #

Many people have reported issues like "The command sudo wasn't found" and so on.
This guide helps you differ issues which are not related to MobileTerminal and therefore can't be fixed by the project members.
It's unnecessairy what version of MobileTerminal you have installed, but in order to gain full advantage of this tutorial, please install OpenSSH (cydia://package/openssh) too.

# Details #

First of all, any bash-related errors you may get are not MobileTerminal's fault. Those include:

  * Permission denied
  * Command not found
  * No such file or directory

The easiest way to prove if an error is related to MobileTerminal is to SSH into your iDevice (if you're using Terminal I assume you know how to) and do the exact same thing you did before. Watch your user and your directory! SSH-users tend to login as root while MobileTerminal usually starts up as mobile, the default user. Some "permission denied"-errors occur as mobile, but not as root. In order to check who you are, execute "whoami" (without quotes of course). To check where you are, execute "pwd" (print working directory).

## Example ##

User A reports:
```
Every time I'm trying to install something from the command line using apt-get, I get the error message "Unable to lock the administration directory (/var/lib/dpkg)/, are you root?".
When trying to use sudo apt-get, I get "sudo: command not found".
```

This is a typical case we find here quite often. Of course, it means "sudo" is not installed. You could login as root using su and install it manually or do the same using Cydia.

User B Reports:
```
I get a blank screen after executing nmap. Line-breaks aren't displayed correctly and I don't see my own imput anymore. MobileTerminal itself executes the input like usual, however.
```

This is a true error report, because when launching nmap via SSH on a PC (the execution still happens on the same device, the output is only on the pc!), it behaves completely normal. Therefore, there must be an issue with the screen output which prevents MobileTerminal from displaying it correctly. By the way, try it out with nmap, the issue has not been fixed yet.