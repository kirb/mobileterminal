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
	mkdir -p MobileTerminal.app
	cp MobileTerminal MobileTerminal.app/
	cp Info.plist MobileTerminal.app/
	cp icon.png MobileTerminal.app/icon.png

clean:	
	rm -fr *.o MobileTerminal MobileTerminal.app
