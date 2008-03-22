// MobileTerminal.h
#define DEBUG_METHOD_TRACE    0

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

#import <UIKit/UIView-Geometry.h>

//_______________________________________________________________________________
//_______________________________________________________________________________

@implementation MainWindow

-(void) _handleOrientationChange:(id)notification
{
	int degrees = [[[notification userInfo] objectForKey:@"UIApplicationOrientationUserInfoKey"] intValue];	
	if (degrees == application.degrees) return;
	
	log(@"orientation changed: %d", degrees);
	
	BOOL landscape;
		
	struct CGAffineTransform transEnd;
	switch(degrees) 
	{
		case  90: transEnd = CGAffineTransformMake(0,  1, -1, 0, 0, 0); landscape = true;  break;
		case -90: transEnd = CGAffineTransformMake(0, -1,  1, 0, 0, 0); landscape = true;  break;
		case   0: transEnd = CGAffineTransformMake(1,  0,  0, 1, 0, 0); landscape = false; break;
		default:  return;
	}
		
	CGSize screenSize = [UIHardware mainScreenSize];
	CGRect contentBounds;

	if (landscape)
		contentBounds = CGRectMake(0, 0, screenSize.height, screenSize.width);
	else
		contentBounds = CGRectMake(0, 0, screenSize.width, screenSize.height);
		
	[UIView beginAnimations:@"rotation"];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
	[UIView setAnimationWillStartSelector: @selector(animationWillStart:context:)];
	[[self contentView] setTransform:transEnd];
	[[self contentView] setBounds:contentBounds];
	[UIView endAnimations];
	
	[application setLandscape:landscape degrees:degrees]; 
}

//_______________________________________________________________________________

- (void) setApplication:(MobileTerminal*)app { application = app; }
- (MobileTerminal*) application { return application; }

//_______________________________________________________________________________

- (void) animationWillStart:(NSString *)animationID context:(void *)context 
{
	//log(@"start %@ %@", animationID, context);
}

//_______________________________________________________________________________

- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	//log(@"stop %@ finished %@", animationID, finished);
	[application updateFrames];
}

@end

//_______________________________________________________________________________
//_______________________________________________________________________________

@implementation MobileTerminal

@synthesize landscape, degrees;

- (void) applicationDidFinishLaunching:(NSNotification*)unused
{
	log(@"applicationDidFinishLaunching");

  controlKeyMode = NO;

	CGSize screenSize = [UIHardware mainScreenSize];
  CGRect frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
	logRect(@"screen size", frame);

  keyboardShown = YES;

  terminal = [[VT100Terminal alloc] init];
  screen   = [[VT100Screen alloc] init];
  [screen setTerminal:terminal];
  [terminal setScreen:screen];

  textScroller = [[UIScroller alloc] init];
  textView = [[PTYTextView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 244.0f)
																				 source: screen
																			 scroller: textScroller];

  keyboardView = [[[ShellKeyboard alloc] initWithFrame:CGRectMake(0.0f, 244.0f, 320.0f, 460.0f-244.0f)] retain];
  [keyboardView setInputDelegate:self];

	CGRect gestureFrame = CGRectMake(0.0f, 0.0f, 240.0f, 250.0f);
  gestureView = [[GestureView alloc] initWithFrame:gestureFrame delegate:self];

  mainView = [[[UIView alloc] initWithFrame:frame] retain];
	
  [mainView addSubview:textScroller];
  [mainView addSubview:keyboardView];	
  [mainView addSubview:[keyboardView inputView]];
  [mainView addSubview:gestureView];
  [mainView addSubview:[PieView sharedInstance]];

	contentView = [[UIView alloc] initWithFrame: frame];
	[contentView addSubview:mainView];
	
	window = [[MainWindow alloc] initWithFrame: frame];
	window.application = self;
	[window setContentView: contentView]; 
	[window orderFront: self];
	[window makeKey: self];
	[window _setHidden: NO];
	[window retain];	
			
  // Shows momentarily and hides so the user knows its there
  [[PieView sharedInstance] hideSlow:YES];

  // Input focus
  [[keyboardView inputView] becomeFirstResponder];

	[self updateFrames];
	
	process  = [[SubProcess alloc] initWithDelegate:self];	
}

// Suspend/Resume: We have to hide then show again the keyboard view to get it
// to properly acheive focus on suspend and resume.

//_______________________________________________________________________________

- (void)applicationSuspend:(GSEvent *)event
{
  if (![process isRunning]) {
    exit(0);
  }

  [[keyboardView inputView] removeFromSuperview];
  [keyboardView removeFromSuperview];
}

//_______________________________________________________________________________

- (void)applicationResume:(GSEvent *)event
{
  [mainView addSubview:keyboardView];
  [mainView addSubview:[keyboardView inputView]];
  [[keyboardView inputView] becomeFirstResponder];
}

//_______________________________________________________________________________

- (void)applicationExited:(GSEvent *)event
{
  [process close];
}

//_______________________________________________________________________________

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

//_______________________________________________________________________________

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

//_______________________________________________________________________________

- (void)hideMenu
{
  [[PieView sharedInstance] hide];
}

- (void)showMenu:(CGPoint)point
{
  [[PieView sharedInstance] showAtPoint:point];
}

//_______________________________________________________________________________

- (void)handleInputFromMenu:(NSString*)input
{
  [process write:[input cString] length:[input length]];
}

//_______________________________________________________________________________

- (void)toggleKeyboard
{
	if (keyboardShown) 
	{
		keyboardShown = NO;
		[keyboardView removeFromSuperview];
	}
	else
	{
		keyboardShown = YES;
		[mainView addSubview:keyboardView];		
	}
		
	[self updateFrames];
}

//_______________________________________________________________________________

- (void) setLandscape:(BOOL)landscape_ degrees:(int)degrees_
{
	landscape = landscape_;
	degrees = degrees_;
	
	[self setStatusBarMode: [self statusBarMode]
						 orientation: degrees
								duration: 0.5 
								 fenceID: 0 
							 animation: 3];	
}

//_______________________________________________________________________________

- (void) updateFrames 
{
	CGRect contentRect;
	CGRect textFrame;
	CGRect gestureFrame;
	int width, height;

	struct CGSize size = [UIHardware mainScreenSize];
	CGSize keybSize = [UIKeyboard defaultSizeForOrientation:(landscape ? 90 : 0)];

	float statusBarHeight = [UIHardware statusBarHeight];
	
	if (landscape) contentRect = CGRectMake(0, statusBarHeight, size.height, size.width-statusBarHeight);
	else           contentRect = CGRectMake(0, statusBarHeight, size.width, size.height-statusBarHeight);

	logRect(@"---- contentRect", contentRect);
	//logRect(@"----- contentView.frame", contentView.frame);
	//logRect(@"----- contentView.bounds", contentView.bounds);
	
	//logRect(@"----- ---- mainView.frame", mainView.frame);
	//logRect(@"----- ---- mainView.bounds", mainView.bounds);

	[mainView setFrame:contentRect];
	
	//logRect(@"----- ---- mainView.frame", mainView.frame);
	//logRect(@"----- ---- mainView.bounds", mainView.bounds);
	
	if (keyboardShown) 
	{
		gestureFrame = CGRectMake(0.0f, 0.0f, mainView.bounds.size.width-40, mainView.bounds.size.height-keybSize.height);
		textFrame    = CGRectMake(0.0f, 0.0f, mainView.bounds.size.width, mainView.bounds.size.height-keybSize.height);
		width  = landscape ? 67 : 45;
		height = landscape ?  8 : 17;
		
		CGRect keybFrame = CGRectMake(0, mainView.bounds.size.height - keybSize.height, mainView.bounds.size.width, keybSize.height);
		
		[keyboardView setFrame:keybFrame];
	} 
	else 
	{
		gestureFrame = CGRectMake(0.0f, 0.0f, mainView.bounds.size.width-40, mainView.bounds.size.height);
		textFrame    = CGRectMake(0.0f, 0.0f, mainView.bounds.size.width, mainView.bounds.size.height);
		width  = landscape ? 67 : 45;
		height = landscape ? 23 : 32;
	}
	
	[textScroller setFrame:textFrame];
	[textView setFrame:textFrame];
	
	logRect(@"---- textFrame",  textFrame);
	logRect(@"---- textView.frame",  [textView frame]);
	logRect(@"---- textView.bounds",  [textView bounds]);
	
	[gestureView setFrame:gestureFrame];
	
	[process setWidth:width height:height];
	[screen resizeWidth:width height:height];
	
  [textView refresh];	
	[textView updateAndScrollToEnd];
	//[textView updateIfNecessary];
}

@end
