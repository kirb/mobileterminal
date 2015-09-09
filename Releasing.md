# Introduction #

This page is for developers who wish to build MobileTerminal and package it distribution.

# Details #

## Background ##

MobileTerminal binaries are released as .deb files.  The main reason we chose this installation method is because this is what is supported by [Cydia](http://cydia.saurik.com/), a popular package management system for iOS.

  * See the [Developers](http://code.google.com/p/mobileterminal/wiki/Developers) wiki for more details on how to obtain the source and build a MobileTerminal.
  * See [Deb (file format)](http://en.wikipedia.org/wiki/Deb_(file_format)) for more background.
  * See [How to Host a Cydia™ Repository](http://www.saurik.com/id/7) for details about Cydia packages and repositories.

The package is build using a shell script executed by XCode.  You must have a **deb-dpkg** binary to build debian packages, either by building it from source or using the binary compiled by Saurik (See the "How to Host a Cydia Repository" link above.)

## Packaging ##

Before building a MobileTerminal release, you should sync to the latest revision in the source tree.  It is also important that you do not have any open files in the release branch.

```
$ svn up
At revision 516.
$ svn status
```

  1. Open MobileTerminal.xcodeproj in XCode.
  1. Make sure the **Device** is selected (as opposed to Simulator)
  1. Make sure **Release** is selected (as opposed to Debug)
  1. From the **Build** menu select **Clean All Targets** to erase any previous intermediate files
  1. Make sure **deb** is selected as the **Active Target**
  1. From the **Build** menu select **Build**

This will place the output in the **build/Release-iphoneos** subdirectory.  (If you chose a different configuration such as Debug or Simulator the output files will be in a different directory)
Since **deb** has a direct dependency on the **MobileTerminal** project this has the side effect of also building the MobileTerminal binary:

```
$ ls -d build/Release-iphoneos/*.app
build/Release-iphoneos/Terminal.app
$ ls build/Release-iphoneos/*.deb
build/Release-iphoneos/MobileTerminal_516-1_iphoneos-arm.deb
```

Note that in the filename above:
  * The **516** refers to the current svn revision.  If you had changes in your local client, the version number would instead be "516M".  (We should probably just make the build script fail to build if you have uncommitted changes)
  * The **1** refers to the package version.  If you click **Build** again, it will create a second .deb with a 2 instead.

```
$ ls build/Release-iphoneos/*.deb
build/Release-iphoneos/MobileTerminal_516M-1_iphoneos-arm.deb
build/Release-iphoneos/MobileTerminal_516M-2_iphoneos-arm.deb
```

You can reset the package version back to one by cleaning all targets again.  We typically would not release a package version higher than 1 except in a rare circumstance.

## Distributing ##

Currently we only distribute binaries in the Downloads section of the googlecode site.  We might later need to update this page with instructions for how to distribute the binary via Cydia repositories.