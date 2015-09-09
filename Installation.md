#Tutorial on how to install MobileTerminal
# Introduction #

## Easy Install (using Cydia auto-install) ##

We have submitted the latest version of mobileterminal to the bigboss repository, so that its easy to install through the default Cydia sources.

The older versions of MobileTerminal (less than v520) already on Cydia doesn't work on iOS 4.0 or greater.

### For Mac users: ###
  1. Download the latest `*`.deb file [here](http://mobileterminal.googlecode.com/files/MobileTerminal_520-1_iphoneos-arm.deb)
  1. Download and install on your Mac the latest version of [Cyberduck](http://cyberduck.ch/)
  1. Make sure your Mac and iDevice both have a Wi-Fi connection on the same network
  1. On your iDevice, open (for iOS 4.x) Settings: General: Wi-Fi or (for iOS 6.x) Settings: Wi-Fi, tap the right-arrow on your connected network, and note the IP Address
  1. Open Cyberduck on your Mac, select Open Connection, and select “SFTP (SSH File Transfer Protocol)”
  1. Enter the iDevice’s IP Address into “Server,” with Username “root” and your password (the default password is “alpine”), and press Connect {_NB: It will take some time to make the initial connection_}

••• If you have jailbroken your iDevice and NOT changed the default 'root' and 'mobile' passwords yet, you are asking to be hacked! •••

  1. Navigate to /private/var/root/Media/Cydia/AutoInstall {_NB: If the AutoInstall folder does not exist, create it, paying attention to the capital letters A and I_}
  1. Drag the MobileTerminal .deb file from your Mac into the AutoInstall folder
  1. Quit Cyberduck and reboot the iDevice

_NB: If, after rebooting, MobileTerminal does not appear on your Springboard, respring (not reboot) the iDevice_


### For Windows users: ###

  1. [Download the \*.deb file (r475)](http://www.mediafire.com/?x5b6vh1xz4tjllq)
  1. [Windows users should download iFunbox](http://www.i-funbox.com/)
  1. Extract the file you just downloaded using the method of your choice (the Windows built-in method is right-clicking and selecting "extract")
  1. Double-click on the extracted file iFunbox.exe icon, which should look like this: ![http://i54.tinypic.com/255jdcj.png](http://i54.tinypic.com/255jdcj.png)
  1. Connect your iPhone/iPod/iPad using your USB cable (the same one used for iTunes)
  1. Look on the left side of the iFunbox screen for ![http://i51.tinypic.com/21pbk.png](http://i51.tinypic.com/21pbk.png) and click on it
  1. Search the top bar of the iFunbox screen for ![http://i52.tinypic.com/2f0gd2s.png](http://i52.tinypic.com/2f0gd2s.png) and click it
  1. Select the `*`.deb file you downloaded in step one, which may have an icon looking like this on Windows 7: ![http://i51.tinypic.com/1zvfh1.png](http://i51.tinypic.com/1zvfh1.png)
  1. Start Cydia on your iDevice and MobileTerminal should automatically be installed

## Manual Install ##
This method assumes familiarity with using a command prompt/SSH.
This is an overview of the steps to installing the latest MobileTerminal from the `*`.zip on GoogleCode:
  1. Copy the contents of the `*`.zip archive on the downloads page to /Applications
  1. Change ownerships on /Applications/Terminal.app to root:admin
  1. Change permissions (recursively) on /Applications/Terminal.app to 644
  1. Change permissions on /Applications/Terminal.app/Terminal 755
  1. Change permissions on /Applications/Terminal.app 755
  1. Regenerate the SpringBoard icon cache (the `uicache` command has to be run as user mobile) or reboot
Mac and Linux users can use SCP over wireless, although Ubuntu Linux has built-in support for USB iDevice file transfer using usbmuxd.
Windows users have iFunbox, as mentioned above.