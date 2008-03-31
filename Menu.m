//
//  Menu.m
//  Terminal

#import "Menu.h"
#import "MobileTerminal.h"
#import "GestureView.h"
#import "Settings.h"
#import "Log.h"
#import <UIKit/CDStructures.h>

//_______________________________________________________________________________
//_______________________________________________________________________________
/*
	button events:
	1 button down
	4 mouse move with focus
	8 mouse move without focus
	32 lost focus
	16 got focus
	64 button release
*/

@implementation MenuButton

//_______________________________________________________________________________

-(id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];

	chars = nil;
	return self;
}

//_______________________________________________________________________________

- (NSString*) chars { return chars; }
- (void) setChars:(NSString*)chars_ 
{
	[chars release];
	chars = [chars_ copy];
}

//_______________________________________________________________________________

@end

//_______________________________________________________________________________
//_______________________________________________________________________________

@implementation Menu

@synthesize visible;

//_______________________________________________________________________________

+ (Menu*) sharedInstance
{
  static Menu * instance = nil;
  if (instance == nil) 
	{		
    instance = [[Menu alloc] init];
  }
  return instance;
}

//_______________________________________________________________________________

- (id) init
{
  self = [super initWithFrame:CGRectMake(0, 0, 0, 0)];
	
	float lx = MAX(0, 160 - 1.5 * (MENU_BUTTON_WIDTH+MENU_BUTTON_SPACE));
	float ly = MAX(0, 100 - 1.5 * (MENU_BUTTON_HEIGHT+MENU_BUTTON_SPACE));

	[self setTransform:CGAffineTransformMake(1.0f, 0, 0, 1.0f, lx, ly)];
  location = CGPointMake(160, 100);
	
  visible = YES;

	timer = nil;

	[self setOpaque:NO];
	[self updateButtons];
	[self setBackgroundColor:colorWithRGBA(0.0f, 0.0f, 0.0f, 0.0f)];
		
  return self;
}

//_______________________________________________________________________________

- (void) updateButtons
{
	NSArray * buttons = [[Settings sharedInstance] menuButtons];
	
	int i;
	float x=0.0f, y=0.0f;
	
	CDAnonymousStruct4 buttonPieces = {
		.left = { .origin = { .x = 0.0f, .y = 0.0f }, .size = { .width = 14.0f, .height = MENU_BUTTON_HEIGHT } },
		.middle = { .origin = { .x = 15.0f, .y = 0.0f }, .size = { .width = 2.0f, .height = MENU_BUTTON_HEIGHT } },
		.right = { .origin = { .x = 17.0f, .y = 0.0f }, .size = { .width = 14.0f, .height = MENU_BUTTON_HEIGHT } },
	};

	for (i = 0; i < [buttons count]; i++)
	{
		MenuButton * button = [[[MenuButton alloc] initWithFrame:CGRectMake(x, y, MENU_BUTTON_WIDTH, MENU_BUTTON_HEIGHT)] autorelease];
				
		[button setAutosizesToFit:NO];
		[button setTitle:[[buttons objectAtIndex:i] objectForKey:@"title"]];
		if ([[buttons objectAtIndex:i] objectForKey:@"chars"])
				[button setChars:[[buttons objectAtIndex:i] objectForKey:@"chars"]];
		[button setPressedBackgroundImage: [UIImage imageNamed: @"menubuttonpressed.png"]];
		[button setBackground: [UIImage imageNamed: @"menubuttonpressed.png"] forState:4];
		[button setBackgroundImage: [UIImage imageNamed: @"menubutton.png"]];
		[button setDrawContentsCentered: YES];			
		[button setBackgroundSlices: buttonPieces];
		[button setEnabled: YES];		
				
		[button setTitleColor:colorWithRGBA(0,0,0,1) forState:0];
		[button setTitleColor:colorWithRGBA(1,1,1,1) forState:1]; // pressed
		[button setTitleColor:colorWithRGBA(1,1,1,1) forState:4]; // selected
		
		
		if (i % 3 == 2)
		{
			x = 0.0f;
			y += MENU_BUTTON_HEIGHT + MENU_BUTTON_SPACE;
		}
		else
		{
			x += MENU_BUTTON_WIDTH + MENU_BUTTON_SPACE;
		}
		
		[self addSubview:button];
	}
}	

//_______________________________________________________________________________

- (void) showAtPoint:(CGPoint)p
{
	[self stopTimer];
  location.x = p.x;
  location.y = p.y;
	timer = [NSTimer scheduledTimerWithTimeInterval:MENU_DELAY target:self selector:@selector(fadeIn) userInfo:nil repeats:NO];
}

//_______________________________________________________________________________

-(void) stopTimer
{
	if (timer != nil) 
	{
		[timer invalidate];
		timer = nil;
	}
}

//_______________________________________________________________________________

- (void) fadeIn
{
	[self stopTimer];
	
  if (visible) 
	{
    return;
  }
	
	CGRect frame = [[self superview] frame];
	//logRect(@"frame", frame);
	float lx = MIN(frame.size.width  - 3.0 * (MENU_BUTTON_WIDTH+MENU_BUTTON_SPACE),  MAX(0, location.x - 1.5 * (MENU_BUTTON_WIDTH+MENU_BUTTON_SPACE)));
	float ly = MIN(frame.size.height - 3.0 * (MENU_BUTTON_HEIGHT+MENU_BUTTON_SPACE), MAX(0, location.y - 1.5 * (MENU_BUTTON_HEIGHT+MENU_BUTTON_SPACE)));
	
  visible = YES;
  [self setTransform:CGAffineTransformMake(0.01f, 0, 0, 0.01f, location.x, location.y)];
  [self setAlpha: 0.0f];
		
	[UIView beginAnimations:@"fadeIn"];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
	[UIView setAnimationDuration:MENU_FADE_IN_TIME];
	[self setTransform:CGAffineTransformMake(1, 0, 0, 1, lx, ly)];
	[self setAlpha:1.0f];
	[UIView endAnimations];	
}

//_______________________________________________________________________________

- (void) animationDidStop:(NSString*)animID finished:(NSNumber*)finished context:(void*)context
{
	if ([finished boolValue] && [animID isEqualToString:@"fadeIn"])
	{
		//GSEventStruct * event = [[[MobileTerminal application] gestureView] mouseDownEvent];
		//log(@"mouseDownEvent %f %f", event->x, event->y);
	}
}

//_______________________________________________________________________________

- (void) hide 
{
  [self hideSlow:NO];
}

//_______________________________________________________________________________

- (void) hideSlow:(BOOL)slow
{ 
	[self stopTimer];
	
  if (!visible) 
	{
    return;
  }
		
	[UIView beginAnimations:@"fadeOut"];
	[UIView setAnimationDuration: slow ? MENU_SLOW_FADE_OUT_TIME : MENU_FADE_OUT_TIME];
	[self setTransform:CGAffineTransformMake(0.01f, 0, 0, 0.01f, location.x, location.y)];
	[self setAlpha:0.0f];
	[UIView endAnimations];	
	
  visible = NO;
}

@end
