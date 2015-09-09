Status: <font color='green'>CURRENT</font>  as of 2010-08-28

# Introduction #

This document is a proposal for current plans for MobileTerminal development, to provide some visibility into what people are working on.   This document should be updated occasionally with the current state of the project, with some short term milestones.  File a feature request in the Issues section if you'd like to see some features that aren't on this list.  Feel free to email the google group if you would like to discuss the current status of a particular feature, or work on it yourself.

# Apple SDK #

MobileTerminal was started before apple released an official SDK, and therefore uses a lot of undocumented headers.  The effort required to build the project is too much for almost everyone, except for a handful of developers who are all very busy and have a lot on their plate.  To address this issue, an effort has been started to port mobile terminal to the official SDK, which should allow anyone interested to hack on it.  This is taking place in the =applesdk= branch.

It is against the apple terms of service to use the SDK to release jail broken applications, and it is not likely that MobileTerminal would ever be accepted into the App-Store since it does things not allowed on the phone such as forking sub-processes.  That said, someone out there can still probably build it with their own toolchain, and having the code compatible with the offical SDK will make it easier to share the code with other projects such as an SSH client.

## Porting Goals ##

When porting code to the new SDK, keep in mind the following goals:

  * Break code into independentmodules and reduce dependencies
  * Write unit tests when possible
  * Improve usability

## Porting Steps ##

  * `[Done]` Forked SubProcess routines, simplified I/O routines
  * `[In Progress]` VT100 subsystem
    * `[Done]` Simple VT100 text view control
    * `[Not Started]` Improve efficiency of text view drawing (its pretty dumb, slower than trunk)
    * `[Not Started]` Fix bugs in the VT100Screen/VT100Terminal emulation
    * `[Not Started]` Scrolling support
  * `[In Progress]` Preferences
    * `[Done]` Persistence layer.  Not compatible with old format.
    * `[Done]` Main preferences page
    * `[Done]` Menu preferences
    * `[Done]` Gesture preferences
    * `[Not Started]` Control characters in menu prefs
    * `[In Progress]` Terminal settings preferences (and simplify the font settings)
    * `[Not Started]` About page (names of contributors, link to website, etc)
  * `[In Progress]` Gestures
    * `[Done]` Keyboard show/hide
    * `[Done]` Landscape mode/rotation
    * `[Done]` Directional gestures
    * `[Done]` Copy and Paste (though could probably use some improvement)
    * `[Done]` Configurable gestures "actions"
    * `[In Progress]` More gesture actions (key presses, menu shortcuts, etc)
  * `[In Progress]` Shortcut Menu
    * `[Done]` Basic UITableView menu as a proof of concept
    * `[Not Started]` Better UI for the menu (possibly hiding the keyboard and using more space)



