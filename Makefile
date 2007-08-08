CC = arm-apple-darwin-cc
LD = $(CC)
LDFLAGS = -ObjC -framework CoreFoundation -framework Foundation \
          -framework UIKit -framework LayerKit -framework Coregraphics
CFLAGS = -Wall -Werror

all:	Terminal

Terminal: main.o MobileTerminal.o ShellView.o ShellKeyboard.o
	$(LD) $(LDFLAGS) -o $@ $^

%.o:	%.m
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

package: Terminal
	rm -fr Terminal.app
	mkdir -p Terminal.app
	cp Terminal Terminal.app/Terminal
	cp Info.plist Terminal.app/Info.plist
	cp icon.png Terminal.app/icon.png
	cp Default.png Terminal.app/Default.png
	cp vanish.png Terminal.app/vanish.png
	cp bar.png Terminal.app/bar.png

clean:	
	rm -fr *.o Terminal Terminal.app
