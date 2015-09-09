# CHANGELOG #

## [r426](https://code.google.com/p/mobileterminal/source/detail?r=426) ##
  * complete rewrite
  * missing tons of features, but we can at least compile it now
  * runs on iPad

## [r296](https://code.google.com/p/mobileterminal/source/detail?r=296) ##

  * unstable branch merged into the trunk
  * code cleaned up and restructured

## [r286](https://code.google.com/p/mobileterminal/source/detail?r=286) ##

  * bug fix: color preference changes immediately visible

## [r284](https://code.google.com/p/mobileterminal/source/detail?r=284) ##

  * terminal color preferences added:
    * text foreground, background, bold
    * cursor foreground, background
  * cursor character displays now
  * ctrl-key mode indicated by cursor color invert

## [r282](https://code.google.com/p/mobileterminal/source/detail?r=282) ##

  * suspend/resume problems solved
    * resume after suspend with keyboard hidden works now
    * resume after suspend with preferences open works now
  * minor cosmetic changes

## [r278](https://code.google.com/p/mobileterminal/source/detail?r=278) ##

  * configurable gestures:
    * short single finger swipes
    * long single finger swipes
    * double finger swipes

  * special menu/gesture commands added:
    * `[CONF]` open the settings
    * `[PREV]` switch to previous terminal
    * `[NEXT]` switch to nex terminal
    * `[KEYB]` toggle keyboard
    * `[CTRL]` control key mode

  * minor bug fixes

## [r270](https://code.google.com/p/mobileterminal/source/detail?r=270) ##

  * configurable menu
    * two modes:
      * tap mode: single tap to open, single tap for item/submenu activation
      * swipe mode: hold to open, swipe to open submenu, release to activate item
    * special commands (prefixed with the dot symbol):
      * `*!` enter
      * `*<` cursor left
      * `*>` cursor right
      * `*esc` escape
      * `*del` delete
      * `*home` `*end` `*pgup` `*pgdown` `*up` `*down` dito
      * `*A` - `*Z` Ctrl-Keys
      * `*keepmenu` menu stays on screen when in tap mode
      * `*back` loads previous submenu after item activation

  * bug fix: setTerminalType reenabled (makes lynx and nano work again)

## [r265](https://code.google.com/p/mobileterminal/source/detail?r=265) ##

  * terminal arguments preferences added
  * command line arguments re-enabled:
    * when launched from the shell, additional arguments get executed in the first terminal
    * if arguments is a directory, the first shell cd's to that directory
    * still crashes if started from shell without arguments :-(
  * hopefully resolved the problems that made the app crash in multi-terminal mode on non-Cydia systems
  * svn version number is displayed in the about page
  * missing header files added


## [r257](https://code.google.com/p/mobileterminal/source/detail?r=257) ##

  * gesture commands and menu buttons are read from defaults file

  * bugfixes
    * should link against the original ncurses.dylib now (version 5.4)
    * fixed a problem with the gesture area after application resume
    * fixed a bug in the color chooser by replacing it with a much simpler solution :-)

  * application size reduced by removing unused images from the Resources

## [r250](https://code.google.com/p/mobileterminal/source/detail?r=250) ##

  * multiple terminals added (code merged from the multi branch)
> > this feature works best if the `Default_MobileTerminal?.png` and `FSO_MobileTerminal?.png` images are copied to `/System/CoreServices/SpringBoard.app`

  * landscape mode added

  * pie menu replaced with a button menu:
    * menu always within screen bounds
    * shows/hides with a delay

  * single finger swipe gestures:
    * short swipes:
      * up/down/left/right: cursor keys
      * down-left: tab
      * down-right: control key mode
      * up-right: ctrl-c
      * up-left: esc
    * long swipes:
      * left: start of line (ctrl-a)
      * right: end of line (ctrl-e)

  * double finger swipe gestures:
    * left/right: switch to next/previous terminal
    * down: return

  * preferences added:
    * multiple terminals:
      * terminal font, font size
      * terminal width
    * gesture view frame color
    * about page

  * gesture view:
    * bigger area
    * frame display added

  * keyboard:
    * toggles via 1-finger-double-tap
    * toggles with a delay
    * keyboard slides in and out

  * sensitive status bar:
    * left part: activates preferences
    * right part: next/previous terminal

  * scrollbar scroller display reactivated
  * control key mode indicates via cursor color
  * internally converts keyboard character LF to CR (makes nano and pico work)
  * various display bugs fixed
  * various code improvements
  * Makefile improved
  * XCode project added