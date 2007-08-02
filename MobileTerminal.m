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

//#import "DelegateDebug.h"

#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>
#include <util.h>
#include <pthread.h>
#include <stdlib.h>

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

@interface ShellView : UITextView {
	NSMutableString* _nextCommand;
	bool _ignoreInsertText;
}
- (id)initWithFrame:(struct CGRect)fp8;
- (BOOL)canBecomeFirstResponder;
-(NSMethodSignature*)methodSignatureForSelector:(SEL)selector;
- (void)forwardInvocation:(NSInvocation *)anInvocation;
- (void)stopCapture;
- (void)startCapture;

@end

@implementation ShellView : UITextView 
- (id)initWithFrame:(struct CGRect)fp8
{
	NSLog(@"Created ShellView");
	_nextCommand = [[NSMutableString stringWithCapacity:255] retain];
	_ignoreInsertText = NO;
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
	NSLog(@"Requested method for selector: %@", NSStringFromSelector(selector));
	return [super methodSignatureForSelector:selector];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	//NSLog(@"Request for selector: %@", NSStringFromSelector(aSelector));
	return [super respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	NSLog(@"Called from UITextView %@", NSStringFromSelector([anInvocation selector]));
	[super forwardInvocation:anInvocation];
	return;
}

- (BOOL)webView:(id)fp8 shouldDeleteDOMRange:(id)fp12
{
	//NSLog(@"deleting range: %i, %i", [fp12 startOffset], [fp12 endOffset]);

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
	//NSLog(@"range while inserting: %p, %x, %x", fp16, fp16->location, fp16->length);
	//NSLog(@"range class? %@", [fp16 class]);
	//NSLog(@"range: %i, %i", [fp16 startOffset], [fp16 endOffset]);
	//NSLog(@"inserting.. %@", character);
	if(!_ignoreInsertText) {
		const char* cmd_cstr = [character cStringUsingEncoding:[NSString defaultCStringEncoding]];
	    if (write(fd, cmd_cstr, [character length]) == -1) {
	      perror("write");
	      exit(1);
	    }
		return NO;
	}
	return [super webView:fp8 shouldInsertText:character replacingDOMRange:fp16 givenAction:fp20];
}
@end

ShellView* view;

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
    //NSLog(out);
    //NSString* text = [[[NSString alloc] initWithString:[view text]] retain];
    //text = [[text stringByAppendingString: out] retain];
	//[view setEditable:YES];
	
	/*
	if([out length] == 1) {
		NSLog(@"length 1, char code %u", [out characterAtIndex:0]);		
	} else {
		NSLog(@"length of %d", [out length]);
		int i;
		for(i = 0; i < [out length]; i++) {
			NSLog(@"char %d: code %u", i, [out characterAtIndex:i]);	
		}
	}
	*/
	
	if([out length] == 3) {
		if([out characterAtIndex:0] == 0x08 && [out characterAtIndex:1] == 0x20 && [out characterAtIndex:2] == 0x08) {
			//delete sequence, don't output
			//NSLog(@"delete");
			continue;
		}
	}
	
	[[[view _webView] webView] moveToEndOfDocument:self];
	[view stopCapture];
	[[view _webView] insertText: out];
	[view startCapture];

	NSRange aRange;
	aRange.location = 9999999;	//horray for magic number
	aRange.length = 1;
	[view setSelectionRange:aRange];
	[view scrollToMakeCaretVisible:YES];
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
	float backcomponents[4] = {0, 0, 0, 1};
	float textcomponents[4] = {1, 1, 1, 1};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	

    view = [[ShellView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 240.0f)];
    [view setText:@"Welcome!\n"];
    [view setTextSize:12];
	[view setTextColor:  CGColorCreate( colorSpace, textcomponents)];
    [view setTextFont:@"Courier"];
	[view setBackgroundColor: CGColorCreate( colorSpace, backcomponents)];
    [view setEditable:YES];  // don't mess up my pretty output
	[view setAllowsRubberBanding:YES];
    [view displayScrollerIndicators];

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

	//DelegateDebug* debugDelegate = [[DelegateDebug alloc] retain];
	//[debugDelegate doSomethingWeird];
	
    ShellKeyboard* keyboard = [[ShellKeyboard alloc]
        initWithFrame: CGRectMake(0.0f, 240.0, 320.0f, 480.0f)];

    [keyboard setTapDelegate:view];
    [keyboard startHeartbeat:@selector(heartbeatCallback:) inRunLoopMode:nil];

    struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
    rect.origin.x = rect.origin.y = 0.0f;
    UIView *mainView;
    mainView = [[UIView alloc] initWithFrame: rect];

    [mainView addSubview: view]; 
    [mainView addSubview: keyboard];

    [view becomeFirstResponder];
	
    [window setContentView: mainView];
}

@end
