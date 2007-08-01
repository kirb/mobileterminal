#import "MobileTerminal.h"
#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIView.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UINavigationBar.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIView-Rendering.h>
#import <UIKit/UITextView.h>
#import <UIKit/UIKeyboard.h>

#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>
#include <util.h>
#include <pthread.h>
#include <stdlib.h>


int fd;
UITextView* view;
UITextView* input;

// This keyboard is currently just used to receive a heartbeat callback.
@interface ShellKeyboard : UIKeyboard {
}
@end
@implementation ShellKeyboard

// The heartbeatCallback is invoked by the UI occasionally.  It does a
// non-blocking read of the background shell process, and also checks for
// input from the user.  When it detects the user has pressed return, it
// sends the command to the background shell.
- (void)heartbeatCallback:(id)ignored
{
  // TODO: slow hack that removes suggestion bar.  fix?
  [self hideSuggestionBar];

  char buf[255];
  int nread;
  while (1) {
    nread = read(fd, buf, 254);
    if (nread == -1) {
      if (errno == EAGAIN) {
        break;
       }
       perror("read");
       exit(1);
    }
    buf[nread] = '\0';
    NSString* out = [[NSString stringWithCString:buf
        encoding:[NSString defaultCStringEncoding]] retain];
    //NSLog(out);
    NSString* text = [[[NSString alloc] initWithString:[view text]] retain];
    text = [[text stringByAppendingString: out] retain];
    [view setText:text];
  }

  NSString* cmd = [[input text] retain];
  //NSLog(cmd);
  unsigned int i;
  unsigned int newline = -1;
  for (i = 0; i < [cmd length]; ++i) {
	[self removeAutocorrectPrompt];		// slow hack. removes suggestion bar. fix?
    unichar c = [cmd characterAtIndex:i];
    if (c == '\n') {
      newline = i + 1;
      break;
    }
  }
  if (newline == -1) {
    // no newline, dont do anything yet
    //NSLog(@"no return");
  } else {
    //NSLog(@"got cmd:");
    //NSString* cmdpart = [cmd substringToIndex:newline];
    //NSLog(cmdpart);
    [input setText:@""];

    const char* cmd_cstr =
        [cmd cStringUsingEncoding:[NSString defaultCStringEncoding]];
    if (write(fd, cmd_cstr, newline) == -1) {
      perror("write");
      exit(1);
    }
  }
}

@end

@implementation MobileTerminal

- (void) applicationDidFinishLaunching: (id) unused
{
    UIWindow *window = [[UIWindow alloc] initWithContentRect: [UIHardware 
        fullScreenApplicationContentRect]];
    [window orderFront: self];
    [window makeKey: self];
    [window _setHidden: NO];
//make colors	
	float backcomponents[4] = {0, 0, 0, 0.0/0.0};
	float textcomponents[4] = {1, 1, 1, 1.0/1.0};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	

    view = [[UITextView alloc]
        initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 210.0f)];
    [view setText:@""];
    [view setTextSize:12];
	[view setTextColor:  CGColorCreate( colorSpace, textcomponents)];
    [view setTextFont:@"Courier"];
	[view setBackgroundColor: CGColorCreate( colorSpace, backcomponents)];
    [view setEditable:NO];  // don't mess up my pretty output
    [view displayScrollerIndicators];
// TODO: Black on gray?
//    [view setBackgroundColor:0xff];

    input = [[UITextView alloc]
        initWithFrame: CGRectMake(0.0f, 210.0f, 320.0f, 240.0f)];
    [input setText:@""];
    [input setTextSize:14];
    [input setTextColor:  CGColorCreate( colorSpace, textcomponents)];
    [input setTextFont:@"Courier"];
	[input setBackgroundColor: CGColorCreate( colorSpace, backcomponents)];
// TODO: Make it obvious this is an input box. TextField instead?
//    [input placeholderTextForFieldEditor:@"< shell command >"];
//    [input setDrawBorderText:@""];

    // Window size for font size 10 (determined with some manual testing)
    // This makes ls output line up and look nice.
    struct winsize win;
    win.ws_row = 19;
    win.ws_col = 50;
    win.ws_xpixel = 320;
    win.ws_ypixel = 210;

    pid_t pid = forkpty(&fd, NULL, NULL, &win);
    if (pid == -1) {
      perror("forkpty");
      exit(1);
    } else if (pid == 0) {
      if (execlp("/bin/sh", "sh", (void*)0) == -1) {
        perror("execlp");
      }
      fprintf(stderr, "program exited.\n");
      exit(1);
    }
    printf("Child process: %d\n", pid);
    printf("master fd: %d\n", fd);

    // Set non-blocking
    int flags;
    if ((flags = fcntl(fd, F_GETFL, 0)) == -1)
      flags = 0;
    if (fcntl(fd, F_SETFL, flags | O_NONBLOCK) == -1) {
      perror("fcntl");
      exit(1);
    }

    ShellKeyboard* keyboard = [[ShellKeyboard alloc]
        initWithFrame: CGRectMake(0.0f, 240.0, 320.0f, 480.0f)];
    [keyboard hideSuggestionBar];
    [keyboard setTapDelegate:input];
    [keyboard startHeartbeat:@selector(heartbeatCallback:) inRunLoopMode:nil];

	
    // TODO: Turn off auto caps?
	// DxQ: This code doesn't work. I think setAutoCapsType is going to be something crazy (not 1 or 0)
//	UITextTraits* textTraits = [[UITextTraits alloc] init];
//	[textTraits setCaretColor:CGColorCreate( colorSpace, textcomponents)];
//	[textTraits setAutoCapsType:0];
//	[input takeTraitsFrom:textTraits];

    struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
    rect.origin.x = rect.origin.y = 0.0f;
    UIView *mainView;
    mainView = [[UIView alloc] initWithFrame: rect];
    [mainView addSubview: view]; 
    [mainView addSubview: input]; 
    [mainView addSubview: keyboard];

    [input becomeFirstResponder];
	
    [window setContentView: mainView];
}

@end
