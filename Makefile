CC=arm-apple-darwin-gcc
CFLAGS=-Wall -Werror -O7
LDFLAGS=-lobjc -framework CoreFoundation -framework Foundation \
        -framework UIKit -framework LayerKit -framework CoreGraphics \
        -framework GraphicsServices -lcurses

all:	Terminal

Terminal: main.o MobileTerminal.o  ShellKeyboard.o SubProcess.o \
	VT100Screen.o VT100Terminal.o PTYTextView.o  \
        ColorMap.o PTYTile.o Settings.o \
        GestureView.o PieView.o
	$(CC) $(LDFLAGS) -o $@ $^

%.o:	%.m
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

package: Terminal
	rm -fr Terminal.app
	mkdir -p Terminal.app
	cp Terminal Terminal.app/Terminal
	cp Info.plist Terminal.app/Info.plist
	cp Resources/icon.png Terminal.app/icon.png
	cp Resources/Default.png Terminal.app/Default.png
	cp Resources/pie.png Terminal.app/pie.png

dist: package
	zip -r Terminal.zip Terminal.app/

clean:	
	rm -fr *.o Terminal Terminal.app Terminal.zip
