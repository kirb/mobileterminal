**STATUS: This page has been marked deprecated since it is very likely to be out of date**

# Introduction #

This page is for developers who wish to build MobileTerminal and package it for binary distribution.  This page assumes that you have access to your iPhone and have a working [toolchain](http://code.google.com/p/iphone-dev).

See these pages for more info on how to get prepared:
  * http://code.google.com/p/iphone-dev/wiki/Building -- Instructions for building the latest toolchain.

# Details #

## Obtaining Source ##

First step is obtaining the source.  This step is the same for any project hosted on google code.

```
$ svn checkout http://mobileterminal.googlecode.com/svn/trunk/ mobileterminal
```

This will download the latest sources and put them in the mobileterminal directory.  If you already have the source, then you can obtain the latest version by running the following from the mobileterminal directory:

```
$ svn up
```

### Building ###

Execute the following command to build the program from source:

```
$ cd mobileterminal
$ make
...
```

This should build a "Terminal" binary in the current directory.  If you have problems building the source, feel free to [Open an Issue](http://code.google.com/p/mobileterminal/issues/list).

The default "Terminal" program can be run on the command line of your iPhone.  In order to run it from the main GUI menu, you build the package and place it in the /Applications folder of your phone.

```
$ make package
```

The above command creates a "Terminal.app" which should be copied to /Applcations on your iPhone.

See the Installation page for more details on how to install the Terminal.app on your phone.

#### Build Errors ####

If you run into any errors while building, you should make sure that you are using the latest toolchain headers.  These headers may change often so always make sure you're up to date.  Some MobileTerminal developers may be using headers from the iphone-binutils trunk, which is bleeding edge.

### Packaging ###

This section is for mobileterminal developers who want to package the latest binary release and put it in the Downloads section.

TODO

See BinaryVersioning

