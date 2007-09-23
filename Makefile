CC = /usr/local/arm-apple-darwin/bin/gcc
LD = $(CC)
LDFLAGS = -Wl,-syslibroot,$(HEAVENLY) -lobjc \
          -framework CoreFoundation -framework Foundation \
          -framework UIKit -framework LayerKit -framework CoreGraphics
CFLAGS = -fsigned-char -Wall -Werror

all:	Terminal

Terminal: main.o MobileTerminal.o ShellView.o ShellKeyboard.o SubProcess.o
	$(LD) $(LDFLAGS) -o $@ $^

%.o:	%.m
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

package: Terminal
	rm -fr Terminal.app
	mkdir -p Terminal.app
	cp Terminal Terminal.app/Terminal
	cp Info.plist Terminal.app/Info.plist
	cp Resources/icon.png Terminal.app/icon.png
	cp Resources/Default.png Terminal.app/Default.png
	cp Resources/vanish.png Terminal.app/vanish.png
	cp Resources/bar.png Terminal.app/bar.png

clean:	
	rm -fr *.o Terminal Terminal.app
