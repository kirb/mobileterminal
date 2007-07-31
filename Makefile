CC=arm-apple-darwin-cc
LD=$(CC)
LDFLAGS=-ObjC -framework CoreFoundation -framework Foundation -framework UIKit -framework LayerKit 
CFLAGS=-Wall

all:	mobileTerm

mobileTerm:		term.o TermApplication.o MyController.o PTYTask.o
	$(LD) $(LDFLAGS) -o $@ $^

%.o:	%.m
		$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

clean:	
		rm -f *.o mobileTerm
