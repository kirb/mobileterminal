CC = arm-apple-darwin-cc
LD = $(CC)
LDFLAGS = -ObjC -framework CoreFoundation -framework Foundation \
          -framework UIKit -framework LayerKit -framework Coregraphics
CFLAGS = -Wall

all:	Terminal

Terminal:	main.o MobileTerminal.o
	$(LD) $(LDFLAGS) -o $@ $^

%.o:	%.m
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

package: Terminal
	rm -fr Terminal.app
	mkdir -p Terminal.app
	cp Terminal Terminal.app/Terminal
	cp Info.plist Terminal.app/Info.plist
	cp icon.png Terminal.app/icon.png

clean:	
	rm -fr *.o MobileTerminal Terminal.app
