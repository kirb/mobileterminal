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
#import "Preferences.h"

#import <UIKit/UIView-Geometry.h>
#import <LayerKit/LKAnimation.h>
#import <CoreGraphics/CoreGraphics.h>

//_______________________________________________________________________________
//_______________________________________________________________________________

@implementation MainWindow

-(void) _handleOrientationChange:(id)notification
{
	int degrees = [[[notification userInfo] objectForKey:@"UIApplicationOrientationUserInfoKey"] intValue];	
	//log(@"orientation changed: %d", degrees);
	if (degrees == application.degrees || application.activeView != application.mainView) return;
	
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
	[(UIView*)[self contentView] setTransform:transEnd];
	[[self contentView] setBounds:contentBounds];
	[UIView endAnimations];
	
	[application setLandscape:landscape degrees:degrees]; 
}

//_______________________________________________________________________________

- (void) setApplication:(MobileTerminal*)app { application = app; }
- (MobileTerminal*) application { return application; }

//_______________________________________________________________________________

- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	//log(@"stop %@ finished %@", animationID, finished);
	[application updateFrames:YES];
}

@end

//_______________________________________________________________________________
//_______________________________________________________________________________

@implementation MobileTerminal

@synthesize landscape, degrees;

//_______________________________________________________________________________

- (void) applicationDidFinishLaunching:(NSNotification*)unused
{
	log(@"applicationDidFinishLaunching");

	activeTerminal = 0;
  controlKeyMode = NO;
  keyboardShown = YES;

	CGSize screenSize = [UIHardware mainScreenSize];
  CGRect frame = CGRectMake(0, 0, screenSize.width, screenSize.height);

	processes = [[NSMutableArray arrayWithCapacity: MAXTERMINALS] retain];
  screens   = [[NSMutableArray arrayWithCapacity: MAXTERMINALS] retain];
  terminals = [[NSMutableArray arrayWithCapacity: MAXTERMINALS] retain];
  
	for (numTerminals = 0; numTerminals < MAXTERMINALS; numTerminals++)
	{
		VT100Terminal * terminal = [[VT100Terminal alloc] init];
		VT100Screen   * screen   = [[VT100Screen alloc] init];
		SubProcess    * process  = [[SubProcess alloc] initWithDelegate:self identifier: numTerminals];  
		
		[screens   addObject: screen];
		[terminals addObject: terminal];
		[processes addObject: process];

		[screen setTerminal:terminal];
		[terminal setScreen:screen];		
	}
	
  textScroller = [[UIScroller alloc] init];
  textView = [[PTYTextView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 244.0f)
																				 source: [self activeScreen]
																			 scroller: textScroller];

  keyboardView = [[[ShellKeyboard alloc] initWithFrame:CGRectMake(0.0f, 244.0f, 320.0f, 460.0f-244.0f)] retain];
  [keyboardView setInputDelegate:self];

	CGRect gestureFrame = CGRectMake(0.0f, 0.0f, 240.0f, 250.0f);
  gestureView = [[GestureView alloc] initWithFrame:gestureFrame delegate:self];

  mainView = [[[UIView alloc] initWithFrame:frame] retain];
  [mainView addSubview:textScroller];
  [mainView addSubview:gestureView];
  [mainView addSubview:keyboardView];	
  [mainView addSubview:[keyboardView inputView]];
  [mainView addSubview:[PieView sharedInstance]];
	[mainView setBackgroundColor:[UIView colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]];
	activeView = mainView;

	contentView = [[UITransitionView alloc] initWithFrame: frame];
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
			
	[self updateFrames:YES];
	
	[self setActiveTerminal:0];
}

//_______________________________________________________________________________

+ (MobileTerminal*) application
{
	return [[UIWindow keyWindow] application];
}

// Suspend/Resume: We have to hide then show again the keyboard view to get it
// to properly acheive focus on suspend and resume.

//_______________________________________________________________________________

- (void)applicationSuspend:(GSEvent *)event
{
	BOOL shouldQuit;
	int i;
	shouldQuit = YES;
	
	for (i = 0; i < [processes count]; i++) {
		if ([ [processes objectAtIndex: i] isRunning]) {
			shouldQuit = NO;
			break;
		}
	}
	
  if (shouldQuit) {		
    exit(0);
  }

  [[keyboardView inputView] removeFromSuperview];
  [keyboardView removeFromSuperview];
	
	for (i = 0; i < MAXTERMINALS; i++)
		[self removeStatusBarImageNamed:[NSString stringWithFormat:@"MobileTerminal%d", i]];
}

//_______________________________________________________________________________

-(MainWindow*) window { return window; }
-(UIView*) mainView { return mainView; }
-(UIView*) activeView { return activeView; }

//_______________________________________________________________________________

- (void)applicationResume:(GSEvent *)event
{
	if (keyboardShown)
	{
		[mainView addSubview:keyboardView];
	}
	
	[mainView addSubview:[keyboardView inputView]];
	[[keyboardView inputView] becomeFirstResponder];
	
	[self setActiveTerminal:0];
	[self setLandscape: landscape degrees: degrees];
}

//_______________________________________________________________________________

- (void)applicationExited:(GSEvent *)event
{
	int i;
	for (i = 0; i < [processes count]; i++) {
		[[processes objectAtIndex: i] close];
	}	

	for (i = 0; i < MAXTERMINALS; i++)
		[self removeStatusBarImageNamed:[NSString stringWithFormat:@"MobileTerminal%d", i]];
}

//_______________________________________________________________________________

// Process output from the shell and pass it to the screen
- (void)handleStreamOutput:(const char*)c length:(unsigned int)len identifier:(int)tid
{
	if (tid < 0 || tid >= [terminals count]) {
		return;
  }
	
  VT100Terminal* terminal = [terminals objectAtIndex: tid];
  VT100Screen* screen = [screens objectAtIndex: tid];
  	
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
	
  if (tid == activeTerminal) {
		[textView performSelectorOnMainThread:@selector(updateAndScrollToEnd)
															 withObject:nil
														waitUntilDone:NO];
	}	
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
	
  [[self activeProcess] write:&simple_char length:1];
}

//_______________________________________________________________________________

- (void) deviceOrientationChanged: (GSEvent*)event 
{
	// keep me!
}

//_______________________________________________________________________________

-(CGPoint) viewPointForWindowPoint:(CGPoint)point
{
	return [mainView convertPoint:point fromView:window];
}

//_______________________________________________________________________________

- (void)hideMenu
{
  [[PieView sharedInstance] hide];
}

//_______________________________________________________________________________

- (void)showMenu:(CGPoint)point
{
  [[PieView sharedInstance] showAtPoint:point];
}

//_______________________________________________________________________________

- (void)handleInputFromMenu:(NSString*)input
{
  [[self activeProcess] write:[input cString] length:[input length]];
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
		
	[self updateFrames:NO];
}

//_______________________________________________________________________________

- (void) statusBarMouseDown:(GSEvent*)event
{
	CGPoint pos = GSEventGetLocationInWindow(event);
	float width = landscape ? window.frame.size.height : window.frame.size.width;
	if (pos.x > width/2 && pos.x < width*3/4)
		[self prevTerminal];
	else if (pos.x > width*3/4)
		[self nextTerminal];
	else
		[self togglePreferences];
}	

//_______________________________________________________________________________

- (void) setLandscape:(BOOL)landscape_ degrees:(int)degrees_
{
	landscape = landscape_;
	degrees = degrees_;
	
	//log(@"setLandscape %d", degrees);
	
	[self setStatusBarMode: [self statusBarMode]
						 orientation: degrees
								duration: 0.5 
								 fenceID: 0 
							 animation: 0];	
}

//_______________________________________________________________________________

- (void) updateFrames:(BOOL)needsRefresh
{
	CGRect contentRect;
	CGRect textFrame;
	CGRect textScrollerFrame;
	CGRect gestureFrame;
	int width, height, i;

	struct CGSize size = [UIHardware mainScreenSize];
	CGSize keybSize = [UIKeyboard defaultSizeForOrientation:(landscape ? 90 : 0)];

	float statusBarHeight = [UIHardware statusBarHeight];
	
	if (landscape) contentRect = CGRectMake(0, statusBarHeight, size.height, size.width-statusBarHeight);
	else           contentRect = CGRectMake(0, statusBarHeight, size.width, size.height-statusBarHeight);

	[mainView setFrame:contentRect];
		
	if (keyboardShown) 
	{
		gestureFrame			= CGRectMake(0.0f, 0.0f, mainView.bounds.size.width-40.0f, mainView.bounds.size.height-keybSize.height);
		textScrollerFrame = CGRectMake(0.0f, 0.0f, mainView.bounds.size.width, mainView.bounds.size.height-keybSize.height);
		textFrame					= CGRectMake(0.0f, 0.0f, mainView.bounds.size.width, mainView.bounds.size.height-keybSize.height);
		
		width  = landscape ? 67 : 45;
		height = landscape ?  8 : 17;
		
		CGRect keybFrame = CGRectMake(0, mainView.bounds.size.height - keybSize.height, mainView.bounds.size.width, keybSize.height);
		
		[keyboardView setFrame:keybFrame];
	} 
	else 
	{
		gestureFrame			= CGRectMake(0.0f, 0.0f, mainView.bounds.size.width-40.0f, mainView.bounds.size.height);
		textScrollerFrame = CGRectMake(0.0f, 0.0f, mainView.bounds.size.width, mainView.bounds.size.height);
		textFrame					= CGRectMake(0.0f, 0.0f, mainView.bounds.size.width, mainView.bounds.size.height);
		
		width  = landscape ? 67 : 45;
		height = landscape ? 23 : 32;
	}
	
	[textView setFrame:textFrame];
	[textScroller setFrame:textScrollerFrame];
	[textScroller setContentSize:textFrame.size];
	[gestureView setFrame:gestureFrame];
	
	for (i = 0; i < MAXTERMINALS; i++)
	{
		[[processes objectAtIndex:i] setWidth:width    height:height];
		[[screens   objectAtIndex:i] resizeWidth:width height:height];
	}
	
	if (needsRefresh) 
	{
		[textView refresh];	
		[textView updateIfNecessary];
	}
}

//_______________________________________________________________________________

-(void) setActiveTerminal:(int)active
{
	[self removeStatusBarImageNamed:[NSString stringWithFormat:@"MobileTerminal%d", activeTerminal]];
	activeTerminal = active;
	[self addStatusBarImageNamed:[NSString stringWithFormat:@"MobileTerminal%d", activeTerminal] removeOnAbnormalExit:YES];
	
	[textView setSource: [self activeScreen]];
	
	//[self setStatusBarCustomText:[NSString stringWithFormat:@"Terminal %d", activeTerminal+1]];
}

//_______________________________________________________________________________

-(void) prevTerminal
{
	int active = activeTerminal - 1;
	if (active < 0) active = numTerminals-1;
	[self setActiveTerminal:active];
}

//_______________________________________________________________________________

-(void) nextTerminal
{
	int active = activeTerminal + 1;
	if (active >= numTerminals) active = 0;
	[self setActiveTerminal:active];
}

//_______________________________________________________________________________

-(SubProcess*) activeProcess
{
	return [processes objectAtIndex: activeTerminal];
}

-(VT100Screen*) activeScreen
{
	return [screens objectAtIndex: activeTerminal];
}

-(VT100Terminal*) activeTerminal
{
	return [terminals objectAtIndex: activeTerminal];
}

//_______________________________________________________________________________

- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	//log(@"animation did stop %@ finished %@", animationID, finished);
	[self updateFrames:YES];
}

//_______________________________________________________________________________
-(void) initPreferences
{
	preferencesController = [[[PreferencesController alloc] initWithApplication:self] retain];
}

//_______________________________________________________________________________

-(void) togglePreferences
{
	if (preferencesController == NULL) [self initPreferences];
	LKAnimation *animation = [LKTransition animation];
	[animation setType: @"oglFlip"];
	[animation setTimingFunction: [LKTimingFunction functionWithName: @"easeInEaseOut"]];
	[animation setFillMode: @"extended"];
	[animation setSubtype: (activeView == mainView) ? @"fromRight" : @"fromLeft"];
	[animation setTransitionFlags: 3];
	[animation setSpeed: 0.25f];
	[contentView addAnimation: animation forKey: 0];	
	if (activeView == mainView)
	{
		[contentView transition:0 toView:[preferencesController navigationView]];
		activeView = [preferencesController navigationView];
	}
	else
	{
		[contentView transition:0 toView:mainView];
		activeView = mainView;
	}
}

@end
