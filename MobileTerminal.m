// MobileTerminal.m
#import "MobileTerminal.h"

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIImage.h>
#import <UIKit/UIImageView.h>
#import <UIKit/UIView.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIView-Rendering.h>
#import <UIKit/UIWindow.h>
#import "Common.h"
#import "Cleanup.h"
#import "ShellKeyboard.h"
#import "ShellView.h"

#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>
#include <util.h>
#include <sys/stat.h>

@implementation MobileTerminal

// The heartbeatCallback is invoked by the UI occasionally. It does a
// non-blocking read of the background shell process, and also checks for
// input from the user. When it detects the user has pressed return, it
// sends the command to the background shell.
- (void)heartbeatCallback:(id)ignored
{
  char buf[255];
  int nread;

  while (1) {
    nread = read(_fd, buf, 254);
    if (nread == -1) {
      if (errno == EAGAIN) {
        break;
      }
      perror("read");
      exit(1);
    }
    buf[nread] = '\0';
    NSString* out =
      [[NSString stringWithCString:buf
          encoding:[NSString defaultCStringEncoding]] retain];

    if ([out length] == 1) {
      debug(@"length 1, char code %u", [out characterAtIndex:0]);
    } else {
      debug(@"length of %d", [out length]);
      int i;
      for (i = 0; i < [out length]; i++) {
        debug(@"char %d: code %u", i, [out characterAtIndex:i]);
      }
    }

    // seems like if i read out a empty buffer with errno = EAGAIN it means exit
    if (![out length]) {
      //doesn't zoom out, is there a UIApplication method?
      exit(1);
    }
    if ([out length] == 3) {
      if ([out characterAtIndex:0] == 0x08 &&
          [out characterAtIndex:1] == 0x20 &&
          [out characterAtIndex:2] == 0x08) {
        // delete sequence, don't output
        //debug(@"delete");
        continue;
      }
    }

    [[[_view _webView] webView] moveToEndOfDocument:self];
    [_view stopCapture];
    [[_view _webView] insertText: out];
    [_view startCapture];
    NSRange aRange;
    aRange.location = 9999999; //horray for magic number
    aRange.length = 1;
    [_view setSelectionRange:aRange];
    [_view scrollToMakeCaretVisible:YES];
  }
}

// Handle signals from he child; just exit on any status change
static void signal_handler(int signal) {
  int status; 
  wait(&status);
  debug(@"Child status changed to %d", status);
  exit(1);
}

- (void) applicationDidFinishLaunching: (id) unused
{
  // Register a callback that is fired when the forked child process
  // status is changed; Should probably only happen when it actually exits;
  signal(SIGCHLD, &signal_handler);

  struct winsize win;
  win.ws_row = 15;
  win.ws_col = 41;
  win.ws_xpixel = 320;
  win.ws_ypixel = 210; 

  pid_t pid = forkpty(&_fd, NULL, NULL, &win);
  if (pid == -1) {
    perror("forkpty");
    exit(1);
  } else if (pid == 0) {
    // First try to use /bin/login since its a little nicer.  Fall back to
    // /bin/sh  if that is available.
    // We sleep for 5 seconds before exiting so that if someone doesn't have 
    // the correct binary, they will see an error messages printed on the
    // instead of the program exiting.
    struct stat st;
    if (stat("/bin/login", &st) == 0) {
      if (execlp("/bin/login", "login", "-f", "root", (void*)0) == -1) {
        perror("execlp: /bin/login");
        sleep(5);
      }
    } else if (stat("/bin/sh", &st) == 0) {
      if (execlp("/bin/sh", "sh", (void*)0) == -1) {
        perror("execlp: /bin/sh");
        sleep(5);
      }
    } else {
      printf("No shell available.  Please install /bin/login and /bin/sh");
      sleep(5);
    }
    exit(1);
    return;
  }
  NSLog(@"Child process: %d\n", pid);
  NSLog(@"master fd: %d\n", _fd);

  // Set non-blocking
  int flags;
  if ((flags = fcntl(_fd, F_GETFL, 0)) == -1)
    flags = 0;
  if (fcntl(_fd, F_SETFL, flags | O_NONBLOCK) == -1) {
    perror("fcntl");
    exit(1);
  }

  UIWindow *window = [[UIWindow alloc] initWithContentRect: [UIHardware 
    fullScreenApplicationContentRect]];
  [window orderFront: self];
  [window makeKey: self];
  float backcomponents[4] = {0, 0, 0, 0};
  #ifndef GREENTEXT
    float textcomponents[4] = {1, 1, 1, 1};
  #else
    float textcomponents[4] = {.1, .9, .1, 1};
  #endif // !GREENTEXT
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *defaultPath = [bundle pathForResource:@"Default" ofType:@"png"];
  NSString *barPath = [bundle pathForResource:@"bar" ofType:@"png"];

  UIImage *theDefault = [[UIImage alloc]initWithContentsOfFile:defaultPath];
  UIImage *bar = [[UIImage alloc]initWithContentsOfFile:barPath];
  UIImageView *barView = [[UIImageView alloc] initWithFrame: CGRectMake(0.0f, 405.0f, 320.0f, 480.0f)];
  UIImageView *workaround = [[UIImageView alloc] init];
  [workaround setImage:theDefault];
  [barView setImage:bar];
  [barView setAlpha:1.0];

  ShellView* view =
    [[ShellView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 240.0f)];
  [view setFd:_fd];
  [view setText:@""];
  // Don't change the font size or style without updating the window size below
  [view setTextSize:12];
  [view setTextFont:@"CourierNewBold"];
  [view setTextColor: CGColorCreate( colorSpace, textcomponents)];
  [view setBackgroundColor: CGColorCreate( colorSpace, backcomponents)];
  [view setEditable:YES]; // don't mess up my pretty output
  [view setAllowsRubberBanding:YES];
  [view displayScrollerIndicators];
  [view setOpaque:NO];
  [view setBottomBufferHeight:(5.0f)];
  _view = view;
 
  ShellKeyboard* keyboard = [[ShellKeyboard alloc]
    initWithFrame: CGRectMake(0.0f, 240.0, 320.0f, 480.0f)];

  [view setKeyboard:keyboard];

  [keyboard setTapDelegate:view];

  struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
  rect.origin.x = rect.origin.y = 0.0f;
  UIView *mainView;
  mainView = [[UIView alloc] initWithFrame: rect];

  [view setMainView:mainView];
  [keyboard show:view];

  [view setHeartbeatDelegate:self];

  [mainView addSubview: workaround];
  [mainView addSubview: view];
  [mainView addSubview: barView];
  [mainView addSubview: keyboard];
  
  [view becomeFirstResponder];
  [window setContentView: mainView];
}

@end
