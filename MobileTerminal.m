// MobileTerminal.h
#define DEBUG_METHOD_TRACE    0
#define RETURN_KEY_WORKAROUND

#import "MobileTerminal.h"
#import <Foundation/Foundation.h>
#import <GraphicsServices/GraphicsServices.h>
#import "ShellKeyboard.h"
#import "PTYTextView.h"
#import "SubProcess.h"
#import "VT100Terminal.h"
#import "VT100Screen.h"
#import "GestureView.h"
#import "PieView.h"

@implementation MobileTerminal

- (void) applicationDidFinishLaunching:(NSNotification*)unused
{
  controlKeyMode = NO;

  CGRect frame = [UIHardware fullScreenApplicationContentRect];
  frame.origin.y = 0;

  keyboardShown = YES;

  terminal = [[VT100Terminal alloc] init];
  screen = [[VT100Screen alloc] init];
  [screen setTerminal:terminal];
  [terminal setScreen:screen];

  window = [[UIWindow alloc] initWithContentRect:frame];

  CGRect textFrame = CGRectMake(0.0f, 0.0, 320.0f, 250.0f);
  textScroller = [[UIScroller alloc] initWithFrame:textFrame];
  textView = [[PTYTextView alloc] initWithFrame:textFrame
                                         source:screen
                                       scroller:textScroller];

  CGRect keyFrame = CGRectMake(0.0f, 245.0, 320.0f, 480.0f); 
  keyboardView = [[ShellKeyboard alloc] initWithFrame:keyFrame];
  [keyboardView setInputDelegate:self];

  mainView = [[UIView alloc] initWithFrame: frame];
  [mainView addSubview:[keyboardView inputView]];

  [window orderFront: self];
  [window makeKey: self];
  [window setContentView: mainView];
  [window _setHidden:NO];

  process = [[SubProcess alloc] initWithDelegate:self];

  CGRect gestureFrame = CGRectMake(0.0f, 0.0f, 240.0f, 250.0f);
  gestureView =
    [[GestureView alloc] initWithFrame:gestureFrame delegate:self];

  [mainView addSubview:textScroller];
  [mainView addSubview:keyboardView];
  [mainView addSubview:[keyboardView inputView]];
  [mainView addSubview:gestureView];
  [mainView addSubview:[PieView sharedInstance]];

  // Shows momentarily and hides so the user knows its there
  [[PieView sharedInstance] hideSlow:YES];

  // Input focus
  [[keyboardView inputView] becomeFirstResponder];
}

// Suspend/Resume: We have to hide then show again the keyboard view to get it
// to properly acheive focus on suspend and resume.

- (void)applicationSuspend:(GSEvent *)event
{
  if (![process isRunning]) {
    exit(0);
  }

  [[keyboardView inputView] removeFromSuperview];
  [keyboardView removeFromSuperview];
}

- (void)applicationResume:(GSEvent *)event
{
  [mainView addSubview:keyboardView];
  [mainView addSubview:[keyboardView inputView]];
  [[keyboardView inputView] becomeFirstResponder];
}

- (void)applicationExited:(GSEvent *)event
{
  [process close];
}

// Process output from the shell and pass it to the screen
- (void)handleStreamOutput:(const char*)c length:(unsigned int)len
{
#if DEBUG_METHOD_TRACE
  NSLog(@"%s: 0x%x (%d bytes)", __PRETTY_FUNCTION__, self, len);
#endif

  [terminal putStreamData:c length:len];

  // Now that we've got the raw data from the sub process, write it to the
  // terminal.  We get back tokens to display on the screen and pass the
  // update in the main thread.
  VT100TCC token;
  while((token = [terminal getNextToken]),
    token.type != VT100_WAIT && token.type != VT100CC_NULL) {
    // process token
    if (token.type != VT100_SKIP) {
      if (token.type == VT100_NOTSUPPORT) {
        NSLog(@"%s(%d):not support token", __FILE__ , __LINE__);
      } else {
        [screen putToken:token];
      }
    } else {
      NSLog(@"%s(%d):skip token", __FILE__ , __LINE__);
    }
  }
  [textView performSelectorOnMainThread:@selector(updateAndScrollToEnd)
                             withObject:nil
                          waitUntilDone:NO];
}

// Process input from the keyboard
- (void)handleKeyPress:(unichar)c
{
#if DEBUG_METHOD_TRACE
  NSLog(@"%s: 0x%x (c=0x%02x)", __PRETTY_FUNCTION__, self, c);
#endif

  if (!controlKeyMode) {
    if (c == 0x2022) {
      controlKeyMode = YES;
      return;
#ifdef RETURN_KEY_WORKAROUND
    } else if (c == '\n') {
	// The return key is generating LF instead of CR
	// Work around by mapping it back here
	c = '\r';
#endif
    }
  } else {
    // was in ctrl key mode, got another key
    if (c < 0x60 && c > 0x40) {
      // Uppercase
      c -= 0x40;
    } else if (c < 0x7B && c > 0x60) {
      // Lowercase
      c -= 0x60;
    }
    controlKeyMode = NO;
  }
  // Not sure if this actually matches anything.  Maybe support high bits later?
  if ((c & 0xff00) != 0) {
    NSLog(@"Unsupported unichar: %x", c);
    return;
  }
  char simple_char = (char)c;
  [process write:&simple_char length:1];
}

- (void)hideMenu
{
  [[PieView sharedInstance] hide];
}

- (void)showMenu:(CGPoint)point
{
  [[PieView sharedInstance] showAtPoint:point];
};

- (void)handleInputFromMenu:(NSString*)input
{
  [process write:[input cString] length:[input length]];
}

- (void)toggleKeyboard
{
  // TODO: Bring back keyboard hide/show animation
  CGRect textFrame;
  CGRect gestureFrame;
  int height;
  int width;
  if (keyboardShown) {
    gestureFrame = CGRectMake(0.0f, 0.0f, 240.0f, 460.0f);
    textFrame = CGRectMake(0.0f, 0.0, 320.0f, 460.0);
    keyboardShown = NO;
    width = 45;
    height = 32;
    [keyboardView removeFromSuperview];
  } else {
    gestureFrame = CGRectMake(0.0f, 0.0f, 240.0f, 250.0f);
    textFrame = CGRectMake(0.0f, 0.0, 320.0f, 250.0f);
    keyboardShown = YES;
    width = 45;
    height = 17;
    [mainView addSubview:keyboardView];
  }
  [textScroller setFrame:textFrame];
  [textView setFrame:textFrame];
  [gestureView setFrame:gestureFrame];
  [process setWidth:width height:height];
  [screen resizeWidth:width height:height];
}

@end
