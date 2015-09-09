# Introduction #

This document describes information that might be useful for people who want to fix bugs and add features to mobileterminal.  This may also be useful if you just want to compile mobileterminal from the source code.


# Source code #

See <a href='http://code.google.com/p/mobileterminal/source/checkout'>Source Checkout</a> for details about how to get the latest source code from the SVN repository.  If you are not familiar with SVN, you may want to <a href='http://www.google.com/search?q=svn+tutorial'>look for some tutorials</a>

There are multiple branches of mobileterminal, each with some historical cruft.

  * svn/
    * branches/
      * <b>applesdk</b> - The active branch.  This version was re-written to compile with a standard compiler/header setup.
      * <font color='gray'>menu - Last updated in May 2008</font>
      * <font color='gray'>multi - Last updated in October 2007</font>
      * <font color='gray'>unstable  - Last updated in April 2008</font>
    * <font color='gray'>trunk - The "old" version of MobileTerminal that worked on 3.x, last updated in 2009. Building this version requires a hacked up toolchain which I don't know how to configure.  This is the motivation for the applesdk branch.</font>

This document only covers the <b>applesdk</b> branch.  At some point the applesdk branch will be moved to the trunk and the old branches will be removed.

Open branches/applesdk/MobileTerminal/MobileTerminal.xcodeproj in XCode.

# Running in the Simulator #

MobileTerminal is primarily tested using the iPhone and iPad simulators that ship with XCode.  Running MobileTerminal in the simulator starts a local subprocess on your workstation, similar to how it would run on an actual device.

# Running on a Device #

Running MobileTerminal on the device from inside XCode copies it to <b>~/Applications/</b> which is a directory restricted by the sandbox.  Mobileterminal fails to run inside the sandbox because it uses the fork() and execve() to run the shell subprocess.  Therefore, MobileTermial can only run on jailbroken devices.

The simplest way to run MobileTerminal is to copy the build output (such as <b>build/Debug-iphoneos/Terminal.app</b>) directly to the <b>/Applications/</b>.  Typically you have to use scp or some other file transfer mechanishm.

TODO(allen): We need some instructions for building .deb packages.

# Adding Features / Fixing Bugs #

See [Roadmap](http://code.google.com/p/mobileterminal/wiki/Roadmap) for the latest proposed direction of the project.