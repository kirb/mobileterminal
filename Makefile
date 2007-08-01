CC = arm-apple-darwin-cc
LD = $(CC)
LDFLAGS = -ObjC -framework CoreFoundation -framework Foundation \
          -framework UIKit -framework LayerKit 
CFLAGS = -Wall

all:	MobileTerminal

MobileTerminal:	term.o TermApplication.o
	$(LD) $(LDFLAGS) -o $@ $^

%.o:	%.m
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

clean:	
	rm -f *.o mobileTerm
