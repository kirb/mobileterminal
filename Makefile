CC = arm-apple-darwin-cc
LD = $(CC)
LDFLAGS = -ObjC -framework CoreFoundation -framework Foundation \
          -framework UIKit -framework LayerKit 
CFLAGS = -Wall

all:	MobileTerminal

MobileTerminal:	main.o MobileTerminal.o
	$(LD) $(LDFLAGS) -o $@ $^

%.o:	%.m
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

package: MobileTerminal
	rm -fr Terminal.app
	mkdir -p Terminal.app
	cp MobileTerminal Terminal.app/Terminal
	cp Info.plist Terminal.app/
	cp icon.png Terminal.app/icon.png

clean:	
	rm -fr *.o MobileTerminal Terminal.app
