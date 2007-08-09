// MobileTerminal.m
#import "MobileTerminal.h"

#import <Foundation/Foundation.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIImage.h>
#import <UIKit/UIImageView.h>
#import <UIKit/UIView.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIView-Rendering.h>
#import <UIKit/UIWindow.h>
#import "Common.h"
#import "ShellKeyboard.h"
#import "ShellView.h"
#import "SubProcess.h"

#include <stdio.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>

@implementation MobileTerminal

// The heartbeatCallback is invoked by the UI occasionally. It does a
// non-blocking read of the background shell process, and also checks for
// input from the user. When it detects the user has pressed return, it
// sends the command to the background shell.
- (void)heartbeatCallback:(id)ignored
{
  char buf[255];
  int nread;

  int fd = [_shellProcess fileDescriptor];
  nread = read(fd, buf, 254);
  if (nread == -1) {
    if (errno == EAGAIN) {
      // No input was available, try reading again on next heartbeat
      return;
    }
    perror("read");
    return exit(1);
  } if (nread == 0) {
    NSLog(@"End of file from child process");
    return exit(1);
  }
  buf[nread] = '\0';
  NSString* out =
    [[NSString stringWithCString:buf
        encoding:[NSString defaultCStringEncoding]] retain];
#ifdef DEBUG
  if ([out length] == 1) {
    debug(@"length 1, char code %u", [out characterAtIndex:0]);
  } else {
    debug(@"length of %d", [out length]);
    int i;
    for (i = 0; i < [out length]; i++) {
      debug(@"char %d: code %u", i, [out characterAtIndex:i]);
    }
  }
#endif
  // TODO: Delete handling is broken; See bug in ShellView shouldDeleteDOMRange
  if ([out length] == 3 &&
      [out characterAtIndex:0] == 0x08 &&
      [out characterAtIndex:1] == 0x20 &&
      [out characterAtIndex:2] == 0x08) {
    // delete sequence, don't output
    NSLog(@"Ignored delete");
    return;
  }
  [_view insertText:out];
}

- (void) applicationDidFinishLaunching: (id) unused
{
  // Terminal size based on the font size below
  _shellProcess = [[SubProcess alloc] initWithRows:19 columns:41];

  UIWindow *window = [[UIWindow alloc] initWithContentRect: [UIHardware 
    fullScreenApplicationContentRect]];
  [window orderFront: self];
  [window makeKey: self];

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
  [view setFd:[_shellProcess fileDescriptor]];
  [view setText:@""];
  // Don't change the font size or style without updating the window size of the  // sub process above
  [view setTextSize:12];
  [view setTextFont:@"CourierNewBold"];
  //[view setBottomBufferHeight:(5.0f)];
  _view = view;
 
  ShellKeyboard* keyboard = [[ShellKeyboard alloc]
    initWithFrame: CGRectMake(0.0f, 240.0, 320.0f, 480.0f)];

  [view setKeyboard:keyboard];
  [keyboard setTapDelegate:view];

  struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
  rect.origin.x = rect.origin.y = 0.0f;

  UIView *mainView = [[UIView alloc] initWithFrame: rect];

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
