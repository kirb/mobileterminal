#import "MobileTerminal.h"
#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIKeyboard.h>
#import <UIKit/UINavigationBar.h>
#import <UIKit/UISegmentedControl.h>
#import <UIKit/UIAnimator.h>
#import <UIKit/UITransformAnimation.h>
#import <UIKit/UITextView.h>
#import <UIKit/UIView.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIView-Rendering.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIImageView.h>
#import <UIKit/UIImage.h>
#import "ShellView.h"

#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>
#include <util.h>
#include <pthread.h>
#include <stdlib.h>
#include <signal.h>
#include <sys/stat.h>

@interface UITextView (CleanWarnings)

-(UIView*) webView;


@end


@interface UIView (CleanMoreWarnings)
- (void) moveToEndOfDocument:(id)inVIew;
- (void) insertText: (id)ourText;
@end


//#define DEBUG
#ifdef DEBUG
  #define debug(...) NSLog(__VA_ARGS__)
#else
  #define debug(...)
#endif

#define GREENTEXT
int fd;

@interface UIKeyboardImpl : UIView
{
}
@end

@implementation UIKeyboardImpl(disableAutoCaps)
 
- (BOOL)autoCapitalizationPreference
{
  return false;
}

- (BOOL)autoCorrectionPreference
{
  return false;
}

@end

@interface UITextLoupe : UIView

- (void)drawRect:(struct CGRect)fp8;

@end

@implementation UITextLoupe (black)

- (void)drawRect:(struct CGRect)fp8
{
  
}

@end

// This keyboard is currently just used to receive a heartbeat callback.
@interface ShellKeyboard : UIKeyboard {
  bool _kbOut;
}
@end


@implementation ShellView : UITextView 
- (void)setKeyboard:(id) keyboard
{
    _keyboard=keyboard;
}

- (void)setMainView:(UIView *) mainView
{
    _mainView=mainView;
}

- (void)mouseUp:(struct __GSEvent *)fp8
{
    if ([self isScrolling]) {
     //NSLog(@"MouseUp: scrolling\n");
    }else{
     //NSLog(@"MouseUp: not scrolling\n");
     [_keyboard toggle:_mainView shell:self];
    }
    [super mouseUp:fp8];
}
- (id)initWithFrame:(struct CGRect)fp8
{
  debug(@"Created ShellView");
  _nextCommand = [[NSMutableString stringWithCapacity:255] retain];
  _ignoreInsertText = NO;
  _controlKeyMode = NO;
  return [super initWithFrame:fp8];
}

- (BOOL)canBecomeFirstResponder 
{
  return NO;
}

- (void)stopCapture
{
  _ignoreInsertText = YES;
}

- (void)startCapture
{
  _ignoreInsertText = NO;
}

-(NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
  debug(@"Requested method for selector: %@", NSStringFromSelector(selector));
  return [super methodSignatureForSelector:selector];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
  //debug(@"Request for selector: %@", NSStringFromSelector(aSelector));
  return [super respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
  debug(@"Called from UITextView %@", NSStringFromSelector([anInvocation selector]));
  [super forwardInvocation:anInvocation];
  return;
}

- (BOOL)webView:(id)fp8 shouldDeleteDOMRange:(id)fp12
{
  debug(@"deleting range: %i, %i", [fp12 startOffset], [fp12 endOffset]);

  if(!_ignoreInsertText) {
    const char delete_cstr = 0x08;
    if (write(fd, &delete_cstr, 1) == -1) {
     perror("write");
     exit(1);
    }
  }
  return [super webView:fp8 shouldDeleteDOMRange:fp12];
}

- (BOOL)webView:(id)fp8 shouldInsertText:(id)character replacingDOMRange:(id)fp16 givenAction:(int)fp20
{
  //debug(@"range while inserting: %p, %x, %x", fp16, fp16->location, fp16->length);
  //debug(@"range class? %@", [fp16 class]);
  //debug(@"range: %i, %i", [fp16 startOffset], [fp16 endOffset]);
  debug(@"inserting.. %#x", [character characterAtIndex:0]);
  
  if(!_ignoreInsertText) {
    if([character length] > 1) return false;  //or just loop through
  
    char cmd_char = [character characterAtIndex:0];
  
    if(!_controlKeyMode) {
      if([character characterAtIndex:0] == 0x2022) {
        //debug(@"ctrl key mode");
        _controlKeyMode = YES;
        return NO;
      }
    } else {
      //was in ctrl key mode, got another key
      //debug(@"sending ctrl key");
      if(cmd_char < 0x60 && cmd_char > 0x40) {
        //Uppercase
        cmd_char -= 0x40;
      } else if(cmd_char < 0x7B && cmd_char > 0x61) {
        //Lowercase
        cmd_char -= 0x60;
      }
      _controlKeyMode = NO;
    }
    
    debug(@"writing char: %#x", cmd_char);
    if (write(fd, &cmd_char, 1) == -1) {
     perror("write");
     exit(1);
    }
    return NO;   
  }
  return [super webView:fp8 shouldInsertText:character replacingDOMRange:fp16 givenAction:fp20];
}
@end

ShellView* view;

@implementation ShellKeyboard

- (void) show:(id *)mainView shell:(id *)shellView
{
	[shellView setBottomBufferHeight:(5.0f)]; 

    //NSLog(@"keyboard show\n");

//    [mainView bringSubviewToFront:self];
    //[mainView sendSubviewToBack:self];
    [shellView setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 245.0f)];
    [self setTransform:CGAffineTransformMake(1,0,0,1,0,0)];
    [self setFrame:CGRectMake(0.0f, 480.0, 320.0f, 480.0f)];

 
    struct CGAffineTransform trans = CGAffineTransformMakeTranslation(0, -240);
    UITransformAnimation *translate = [[UITransformAnimation alloc] initWithTarget: self];
    [translate setStartTransform: CGAffineTransformMake(1,0,0,1,0,0)];
    [translate setEndTransform: trans];
    [[[UIAnimator alloc] init] addAnimation:translate withDuration:.5 start:YES];

    _kbOut=YES;
}
- (void) hide:(id *)mainView shell:(id *)shellView
{
 [shellView setBottomBufferHeight:(70.0f)]; 

 struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
 rect.origin.x = rect.origin.y = 0.0f;
 [shellView setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
 [self setTransform:CGAffineTransformMake(1,0,0,1,0,0)];
 [self setFrame:CGRectMake(0.0f, 240.0, 320.0f, 480.0f)];
 
 struct CGAffineTransform trans = CGAffineTransformMakeTranslation(0, 240);
 UITransformAnimation *translate = [[UITransformAnimation alloc] initWithTarget: self];
 [translate setStartTransform: CGAffineTransformMake(1,0,0,1,0,0)];
 [translate setEndTransform: trans];
 [[[UIAnimator alloc] init] addAnimation:translate withDuration:.5 start:YES];

    _kbOut=NO;
}

- (bool) toggle:(id *)mainView shell:(id *)shellView
{
    //NSLog(@"keyboard toggle\n");
    if (_kbOut) {
        [self hide:mainView shell:shellView];
    }else{
        [self show:mainView shell:shellView];
    }
    return _kbOut;
}

-(bool) kbOut
{
    return _kbOut;
}

// The heartbeatCallback is invoked by the UI occasionally. It does a
// non-blocking read of the background shell process, and also checks for
// input from the user. When it detects the user has pressed return, it
// sends the command to the background shell.
- (void)heartbeatCallback:(id)ignored
{  
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
  NSString* out = [[NSString stringWithCString:buf encoding:[NSString defaultCStringEncoding]] retain];
  //debug(out);
  //NSString* text = [[[NSString alloc] initWithString:[view text]] retain];
  //text = [[text stringByAppendingString: out] retain];
  //[view setEditable:YES];
  
  if([out length] == 1) {
    debug(@"length 1, char code %u", [out characterAtIndex:0]);   
  } else {
    debug(@"length of %d", [out length]);
    int i;
    for(i = 0; i < [out length]; i++) {
      debug(@"char %d: code %u", i, [out characterAtIndex:i]);  
    }
  }
  
  //seems like if i read out a empty buffer with errno = EAGAIN it means exit
  if(![out length]) {
    //doesn't zoom out, is there a UIApplication method?
    exit(1);
  }
  
  if([out length] == 3) {
    if([out characterAtIndex:0] == 0x08 && [out characterAtIndex:1] == 0x20 && [out characterAtIndex:2] == 0x08) {
      //delete sequence, don't output
      //debug(@"delete");
      continue;
    }
  }
  
  [[[view _webView] webView] moveToEndOfDocument:self];
  [view stopCapture];
  [[view _webView] insertText: out];
  [view startCapture];

  NSRange aRange;
  aRange.location = 9999999; //horray for magic number
  aRange.length = 1;
  [view setSelectionRange:aRange];
  [view scrollToMakeCaretVisible:YES];
 }
}

@end


@implementation MobileTerminal

// Handle signals from he child; just exit on any status change
void signal_handler(int signal) {
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
  NSLog(@"%@",theDefault);
  [barView setAlpha:1.0];

  view = [[ShellView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 240.0f)];
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
 
  struct winsize win;
  win.ws_row = 15;
  win.ws_col = 41;
  win.ws_xpixel = 320;
  win.ws_ypixel = 210; 

  pid_t pid = forkpty(&fd, NULL, NULL, &win);
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
  NSLog(@"master fd: %d\n", fd);

  // Set non-blocking
  int flags;
  if ((flags = fcntl(fd, F_GETFL, 0)) == -1)
   flags = 0;
  if (fcntl(fd, F_SETFL, flags | O_NONBLOCK) == -1) {
   perror("fcntl");
   exit(1);
  }

  //DelegateDebug* debugDelegate = [[DelegateDebug alloc] retain];
  //[debugDelegate doSomethingWeird];
  
  ShellKeyboard* keyboard = [[ShellKeyboard alloc]
    initWithFrame: CGRectMake(0.0f, 240.0, 320.0f, 480.0f)];

  [view setKeyboard:keyboard];

  [keyboard setTapDelegate:view];
  [keyboard startHeartbeat:@selector(heartbeatCallback:) inRunLoopMode:nil];

  struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
  rect.origin.x = rect.origin.y = 0.0f;
  UIView *mainView;
  mainView = [[UIView alloc] initWithFrame: rect];

  [view setMainView:mainView];
  [keyboard show:mainView shell:view];
  
  [mainView addSubview: workaround];
  [mainView addSubview: view];
  [mainView addSubview: barView];
  [mainView addSubview: keyboard];
  
 
  
  [view becomeFirstResponder];
  [window setContentView: mainView];
}

@end
