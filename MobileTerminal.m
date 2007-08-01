#import "MobileTerminal.h"
#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIView.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UINavigationBar.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIHardware.h>
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

- (void)heartbeatCallback:(id)ignored
{
  NSLog(@"startcapture");
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
    NSString* text = [[[NSString alloc] initWithString:[view text]] retain];
    NSLog(@"A");
    text = [[text stringByAppendingString: out] retain];
    NSLog(@"B");
    NSLog(text);
    [view setText:text];
    NSLog(@"Set text=");
    NSLog([view text]);
  }

  NSLog(@"Checking input");
  NSString* cmd = [[input text] retain];
  NSLog(@"got cmd");
  NSLog(cmd);
  unsigned int i;
  unsigned int newline = -1;
  for (i = 0; i < [cmd length]; ++i) {
    unichar c = [cmd characterAtIndex:i];
    if (c == '\n') {
      newline = i + 1;
      break;
    }
  }
  NSLog(@"got range");
  if (newline == -1) {
    NSLog(@"no return");
  } else {
    NSLog(@"got cmd:");
    NSString* cmdpart = [cmd substringToIndex:newline];
    NSLog(cmdpart);
    [input setText:@""];

    const char* cmd_cstr = [cmd cStringUsingEncoding:[NSString defaultCStringEncoding]];
    if (write(fd, cmd_cstr, newline) == -1) {
      perror("write");
      exit(1);
    }
  }
  NSLog(@"endcap");
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
 
    view = [[UITextView alloc]
        initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 210.0f)];
    [view setText:@""];
    [view setTextSize:14];
    [view setEditable:NO];  // don't mess up my pretty output

    input = [[UITextView alloc]
        initWithFrame: CGRectMake(0.0f, 210.0f, 320.0f, 240.0f)];
    [input setTextSize:14];
    [input setText:@""];

    pid_t pid = forkpty(&fd, NULL, NULL, NULL);
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

    struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
    rect.origin.x = rect.origin.y = 0.0f;
    UIView *mainView;
    mainView = [[UIView alloc] initWithFrame: rect];
    [mainView addSubview: view]; 
    [mainView addSubview: input]; 
    [mainView addSubview: keyboard];

    [window setContentView: mainView];
}

@end
