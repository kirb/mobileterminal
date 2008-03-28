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
#import "Settings.h"

#import <UIKit/UIView-Geometry.h>
#import <LayerKit/LKAnimation.h>
#import <CoreGraphics/CoreGraphics.h>

//_______________________________________________________________________________
//_______________________________________________________________________________

@implementation MobileTerminal

@synthesize landscape, degrees, controlKeyMode;

//_______________________________________________________________________________

- (void) applicationDidFinishLaunching:(NSNotification*)unused
{
	log(@"applicationDidFinishLaunching");
	
	settings = [[Settings sharedInstance] retain];
	[settings registerDefaults];
	[settings readUserDefaults];

	activeTerminal = 0;
  controlKeyMode = NO;
  keyboardShown = YES;

	CGSize screenSize = [UIHardware mainScreenSize];
  CGRect frame = CGRectMake(0, 0, screenSize.width, screenSize.height);

	processes = [[NSMutableArray arrayWithCapacity: MAXTERMINALS] retain];
  screens   = [[NSMutableArray arrayWithCapacity: MAXTERMINALS] retain];
  terminals = [[NSMutableArray arrayWithCapacity: MAXTERMINALS] retain];
	scrollers = [[NSMutableArray arrayWithCapacity: MAXTERMINALS] retain];
	textviews = [[NSMutableArray arrayWithCapacity: MAXTERMINALS] retain];
  	
	for (numTerminals = 0; numTerminals < ([settings multipleTerminals] ? MAXTERMINALS : 1); numTerminals++)
	{
		VT100Terminal * terminal = [[VT100Terminal alloc] init];
		VT100Screen   * screen   = [[VT100Screen alloc] initWithIdentifier: numTerminals];
		SubProcess    * process  = [[SubProcess alloc] initWithDelegate:self identifier: numTerminals];
		UIScroller    * scroller = [[UIScroller alloc] init];
		
		[screens   addObject: screen];
		[terminals addObject: terminal];
		[processes addObject: process];
		[scrollers addObject: scroller];
		
		[screen setTerminal:terminal];
		[terminal setScreen:screen];		
		
		PTYTextView * textview = [[PTYTextView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 244.0f)
																												 source: screen
																											 scroller: scroller
																										 identifier: numTerminals];		
		[textviews addObject:textview];
	}
	
  keyboardView = [[[ShellKeyboard alloc] initWithFrame:CGRectMake(0.0f, 244.0f, 320.0f, 460.0f-244.0f)] retain];
  [keyboardView setInputDelegate:self];

	CGRect gestureFrame = CGRectMake(0.0f, 0.0f, 240.0f, 250.0f);
  gestureView = [[GestureView alloc] initWithFrame:gestureFrame delegate:self];

  mainView = [[[UIView alloc] initWithFrame:frame] retain];
	[mainView setBackgroundColor:[UIView colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f]];
  [mainView addSubview:[scrollers objectAtIndex:0]];
  [mainView addSubview:gestureView];
  [mainView addSubview:keyboardView];	
  [mainView addSubview:[keyboardView inputView]];
  [mainView addSubview:[PieView sharedInstance]];
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

//_______________________________________________________________________________

-(MainWindow*) window { return window; }
-(UIView*) mainView { return mainView; }
-(UIView*) activeView { return activeView; }
-(PTYTextView*) textView { return [textviews objectAtIndex:activeTerminal]; }
-(UIScroller*) textScroller { return [scrollers objectAtIndex:activeTerminal]; }

// Suspend/Resume: We have to hide then show again the keyboard view to get it
// to properly acheive focus on suspend and resume.

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

- (void)applicationSuspend:(GSEvent *)event
{
	BOOL shouldQuit;
	int i;
	shouldQuit = YES;
	
	[settings writeUserDefaults];
	
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

- (void)applicationExited:(GSEvent *)event
{
	int i;
	
	[settings writeUserDefaults];
	
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
	
  if (tid == activeTerminal) 
	{
		[[self textView] performSelectorOnMainThread:@selector(updateAndScrollToEnd)
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

-(void) setControlKeyMode:(BOOL)mode
{
	log(@"setControlMode: %d", mode);
	controlKeyMode = mode;
	[[self textView] refreshCursorRow];
}

//_______________________________________________________________________________

- (void) statusBarMouseUp:(GSEvent*)event
{
	if (numTerminals > 1)
	{
		CGPoint pos = GSEventGetLocationInWindow(event);
		float width = landscape ? window.frame.size.height : window.frame.size.width;
		if (pos.x > width/2 && pos.x < width*3/4)
		{
			[self prevTerminal];
		}
		else if (pos.x > width*3/4)
		{
			[self nextTerminal];
		}
		else
		{
			if (activeView == mainView)
				[self togglePreferences];
		}
	}
	else
	{
		if (activeView == mainView)
			[self togglePreferences];
	}
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
							 animation: 0];	
}

//_______________________________________________________________________________

- (void) updateFrames:(BOOL)needsRefresh
{
	CGRect contentRect;
	CGRect textFrame;
	CGRect textScrollerFrame;
	CGRect gestureFrame;
	int columns, rows, i;
	
	//log(@"----------------- updateFrames needsRefresh %d", needsRefresh);

	struct CGSize size = [UIHardware mainScreenSize];
	CGSize keybSize = [UIKeyboard defaultSizeForOrientation:(landscape ? 90 : 0)];

	float statusBarHeight = [UIHardware statusBarHeight];
	
	if (landscape) contentRect = CGRectMake(0, statusBarHeight, size.height, size.width-statusBarHeight);
	else           contentRect = CGRectMake(0, statusBarHeight, size.width, size.height-statusBarHeight);

	[mainView setFrame:contentRect];
		
	TerminalConfig * config = [[[Settings sharedInstance] terminalConfigs] objectAtIndex:activeTerminal];

	float availableWidth = mainView.bounds.size.width;
	float availableHeight= mainView.bounds.size.height;
	
	if (keyboardShown) 
	{
		availableHeight -= keybSize.height;
		[keyboardView setFrame:CGRectMake(0, mainView.bounds.size.height - keybSize.height, availableWidth, keybSize.height)];
	}
			
	float lineHeight = [config fontSize] + TERMINAL_LINE_SPACING;
	float charWidth  = [config fontSize]*[config fontWidth];
	
	rows = availableHeight / lineHeight;
	
	if ([config autosize])
	{
		columns = availableWidth / charWidth;
	}
	else
	{
		columns = [config width];
	}

	textFrame				  = CGRectMake(0.0f, 0.0f, columns * charWidth, rows * lineHeight);
	gestureFrame			= CGRectMake(0.0f, 0.0f, availableWidth-40.0f, availableHeight-(columns * charWidth > availableWidth ? 40.0f : 0));
	textScrollerFrame = CGRectMake(0.0f, 0.0f, availableWidth, availableHeight);

	[[self textView]     setFrame:textFrame];
	[[self textScroller] setFrame:textScrollerFrame];
	[[self textScroller] setContentSize:textFrame.size];
	[gestureView         setFrame:gestureFrame];
	
	for (i = 0; i < numTerminals; i++)
	{
		[[processes objectAtIndex:i] setWidth:columns    height:rows];
		[[screens   objectAtIndex:i] resizeWidth:columns height:rows];
	}
	
	if (needsRefresh) 
	{
		[[self textView] refresh];	
		[[self textView] updateIfNecessary];
	}
}

//_______________________________________________________________________________

-(void) setActiveTerminal:(int)active
{
	[[self textScroller] removeFromSuperview];

	if (numTerminals > 1)
		[self removeStatusBarImageNamed:[NSString stringWithFormat:@"MobileTerminal%d", activeTerminal]];
	activeTerminal = active;
	if (numTerminals > 1)
		[self addStatusBarImageNamed:[NSString stringWithFormat:@"MobileTerminal%d", activeTerminal] removeOnAbnormalExit:YES];

	[mainView addSubview:[self textScroller]];
	[mainView bringSubviewToFront:gestureView];
	[mainView bringSubviewToFront:[PieView sharedInstance]];
	
	[self updateFrames:YES];
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

-(void) createTerminals
{
	for (numTerminals = 1; numTerminals < MAXTERMINALS; numTerminals++)
	{
		VT100Terminal * terminal = [[VT100Terminal alloc] init];
		VT100Screen   * screen   = [[VT100Screen alloc] init];
		SubProcess    * process  = [[SubProcess alloc] initWithDelegate:self identifier: numTerminals];
		UIScroller    * scroller = [[UIScroller alloc] init];
		
		[screens   addObject: screen];
		[terminals addObject: terminal];
		[processes addObject: process];
		[scrollers addObject: scroller];
		
		[screen setTerminal:terminal];
		[terminal setScreen:screen];		
		
		PTYTextView * textview = [[PTYTextView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 244.0f)
																												 source: screen
																											 scroller: scroller
																										 identifier: numTerminals];		
		[textviews addObject:textview];
	}	
	
	[self addStatusBarImageNamed:[NSString stringWithFormat:@"MobileTerminal0"] removeOnAbnormalExit:YES];
}

//_______________________________________________________________________________

-(void) destroyTerminals
{
	[self setActiveTerminal:0];
	
	[self removeStatusBarImageNamed:[NSString stringWithFormat:@"MobileTerminal0"]];
	
	for (numTerminals = MAXTERMINALS; numTerminals > 1; numTerminals--)
	{
		SubProcess * process = [processes lastObject];
		[process closeSession];
		[[textviews lastObject] removeFromSuperview];
		
		[screens   removeLastObject];
		[terminals removeLastObject];
		[processes removeLastObject];
		[scrollers removeLastObject];
		[textviews removeLastObject];
	}
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

-(NSArray *) textviews
{
	return textviews;
}

//_______________________________________________________________________________

- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	//log(@"animation did stop %@ finished %@", animationID, finished);
	[self updateFrames:YES];
}

//_______________________________________________________________________________

-(void) togglePreferences
{
	if (preferencesController == nil) 
	{
		preferencesController = [PreferencesController sharedInstance];
		[preferencesController initViewStack];
	}

	LKAnimation * animation = [LKTransition animation];
	// to make the compiler not complain
	//[animation setType: @"oglFlip"];
	//[animation setSubtype: (activeView == mainView) ? @"fromRight" : @"fromLeft"];
	//[animation setTransitionFlags: 3];
	[animation performSelector:@selector(setType:) withObject:@"oglFlip"];
	[animation performSelector:@selector(setSubtype:) withObject:(activeView == mainView) ? @"fromRight" : @"fromLeft"];
	[animation performSelector:@selector(setTransitionFlags:) withObject:[NSNumber numberWithInt:3]];
	[animation setTimingFunction: [LKTimingFunction functionWithName: @"easeInEaseOut"]];
	[animation setFillMode: @"extended"];
	[animation setSpeed: 0.25f];
	[contentView addAnimation:(id)animation forKey:@"flip"];	
	
	if (activeView == mainView)
	{
		[contentView transition:0 toView:[preferencesController view]];
		activeView = [preferencesController view];
	}
	else
	{
		[contentView transition:0 toView:mainView];
		activeView = mainView;
		
		[settings writeUserDefaults];
		
		if (numTerminals > 1 && ![settings multipleTerminals])
		{
			[self destroyTerminals];
		}
		else if (numTerminals == 1 && [settings multipleTerminals])
		{
			[self createTerminals];
		}
	}
}

@end
