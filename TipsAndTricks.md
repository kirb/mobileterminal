<font color='red'>OBSOLETE: This page is out of date and needs to be updated.  It does not reflect v426.</font>

# Introduction #

This page is a collection of tips and tricks that people have found useful. Please feel free to leave your own in the comments, but put feature requests in the Issues section.

# Tips #

## Hide the Keyboard ##

Tap twice quickly on the screen to hide the keyboard. Repeat to bring it back.

## Control Characters ##

You can send a control-C by pressing the "bullet" key (First press ".?123", then "#+=", then the circle on the middle right), then press the C key.  This can be useful when you want to escape out of a long running program such as ping. Control-C can also be accessed with a short Up-Right and Control is a short Down-Right swipe, after which the cursor will turn highlight red, from here press any character q, x, c, A to complete or the delete button to exit Control mode.

Escape is control-[ or a short Up-Left swip, which may come in handy with vi.
Tab is control-I or a short Down-Left swip (yay tab completion).

## Swipe Controls ##

| Swipe Type | Direction | Action |
|:-----------|:----------|:-------|
| Short      | Up-Right  | Control-C |
| Short      | Down-Right | Control-|
| Short      | Up-Left   | Esc    |
| Short      | Down-Left | Tab    |
| Short      | up/down/left/right | arrow keys (respectively)|
| Long       | Up        | None (functions as up-arrow) |
| Long       | Down      | Enter  |
| Long       | Left      | None   |
| Long       | Right     | None   |
| Two Finger | Up        | Config |
| Two Finger | Down      | Hide Keyboard |
| Two Finger | Left      | Page-Up/Next |
| Two Finger | Right     | Page-Down/PREV |

**None of the Two Finger Swipes seem to work right in 2.0 firmware**

## Multiple Terminals ##

Terminal comes with four terminal windows. Tap on the battery icon to go right, tap **directally** on the time to go left, and tap on the carrier name (AT&T or iPod) to crash Terminal (or do a really quick `killall Terminal` depending on how you look at it).

## Things to do with your terminal ##

While this is in no way a full how-to for UNIX systems, these are some of the commands that you may find useful for your Terminal.

### Copy ###
| Command | `cp` |
|:--------|:-----|
| Common Flags | `-r` |
Usage:
```
1. cp file /
2. cp -r folder /
3. cp folder /
4. cp -r /folder .
5. cp /file ..
```
  1. Copies file from the current directory to / the root directory
  1. Copies the folder "folder" and its subdirectories and files to the root
  1. Copies the folder "folder" to the root, without its subdirectories
  1. copies /folder to current directory ( . stands for current directory )
  1. copies /file to the directory above the current ( .. stands for the directory above this )

### Delete ###

| Command | `rm` |
|:--------|:-----|
| Common Flags | `-f -r` |
Usage:
```
1. rm file
2. rm -fr folder
3. rm -r non-empty-folder
4. rm -r empty-folder
```
  1. removes file completely (there is no trash, files deleted with rm are GONE)
  1. removes folder and its contents recursivly
  1. this will fail, if a folder has contents you must use -f
  1. this is fine, it will remove empty-folder

### Free Space ###

| Command | `df` |
|:--------|:-----|
| Common Flags | `-h` |
Usage:
```
1. df
2. df -h
```
  1. This will output ...
```
Filesystem           1K-blocks      Used Available Use% Mounted on
/dev/disk0s1           2048000    465184   1562336  23% /
devfs                       18        18         0 100% /dev
/dev/disk0s2          13811364   9972572   3838792  73% /private/var
```
  1. This will output ... (-h is for Human-Readable)
```
Filesystem            Size  Used Avail Use% Mounted on
/dev/disk0s1          2.0G  455M  1.5G  23% /
devfs                  18K   18K     0 100% /dev
/dev/disk0s2           14G  9.6G  3.7G  73% /private/var
```

### Make Folder ###

| Command | `mkdir` |
|:--------|:--------|
| Common Flags | none    |
Usage:
```
1. mkdir my-dir
2. mkdir my dir
3. mkdir my\ dir - or - mkdir "my dir"
4. mkdir /mydir
5. mkdir ~/myowndir
```
  1. makes the directory my-dir
  1. makes the directories my and dir
  1. makes the directory "my dir" with a space
  1. makes the directory mydir below the root
  1. makes the directory myowndir inside your home folder
(root home folder is /private/var/root, mobile is /private/var/mobile)

### Move About ###

| Command | `cd`|
|:--------|:----|
| Common Flags | none|
Usage:
```
1. cd
2. cd ~
3. cd /
4. cd ..
5. cd adir
6. cd /mydir
```
  1. goes to your home directory
  1. same as cd
  1. goes to the root
  1. goes up one directory
  1. goes to adir (if it exists)
  1. goes to /mydir

### Direct Output ###

| Command | `* >*.*` |
|:--------|:---------|
Usage:
```
1. ping yahoo.com >output.txt
2. df -h >freespace
3. echo "hello world" >hello_world.txt
4. ls -R / >/dev/null
```
  1. puts the output of the ping command into a txt file
  1. put the output of "df -h" into freespace
  1. puts "hello world" into hello\_world.txt
  1. runs the command "ls -R /" (careful thats a lot of output) but doesn't do anything with the output

### Background Processes ###

| Command | `* &` |
|:--------|:------|
Usage:
```
1. killall SpringBoard &
2. killall SpringBoard >/dev/null &
```
  1. runs the command in the background
  1. runs the command in the background and hides the output

## Common unix binaries ##

Get the latest iphone-binkit from http://iphone.natetrue.com which contains lots of useful unix binaries. Also there ssh, apache, python, ruby.  Join #iphone-shell on irc.osx86.hu for more discussion.

For some tips on setting up and using sshd and an ssh client see:

http://www.thebends.org/~allen/code/iphone-apps/binary/openssh-4.6p1/README

Binary packages:
http://www.thebends.org/~allen/code/iphone-apps/binary/openssh-4.6p1-iphone-binary.tar.gz
