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

//_______________________________________________________________________________

+ (Menu*) sharedInstance
{
  static Menu * instance = nil;
  if (instance == nil) 
	{
    CGRect frame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
    instance = [[Menu alloc] initWithFrame:frame];
  }
  return instance;
}

//_______________________________________________________________________________

- (id) initWithFrame:(CGRect)frame
{
	//log(@"menu init");
  self = [super initWithFrame:frame];
  visibleFrame = frame;
  location = CGPointMake(frame.origin.x + (frame.size.width*0.5f),
                         frame.origin.y + (frame.size.height*0.5f));
  visible = YES;

  anim = [[UIAnimator alloc] init];
	timer = nil;

	[self setOpaque:NO];
	[self updateButtons];
	[self setBackgroundColor:colorWithRGBA(1.0f, 0.0f, 0.0f, 0.5f)];
		
  return self;
}

//_______________________________________________________________________________

- (void) updateButtons
{
	NSArray * buttons = [[Settings sharedInstance] menuButtons];
	
	int i;
	float x=0.0f, y=0.0f;
	
	CDAnonymousStruct4 buttonPieces = {
		.left = { .origin = { .x = 0.0f, .y = 0.0f }, .size = { .width = 14.0f, .height = 43.0f } },
		.middle = { .origin = { .x = 15.0f, .y = 0.0f }, .size = { .width = 2.0f, .height = 43.0f } },
		.right = { .origin = { .x = 17.0f, .y = 0.0f }, .size = { .width = 14.0f, .height = 43.0f } },
	};

	for (i = 0; i < [buttons count]; i++)
	{
		MenuButton * button = [[[MenuButton alloc] initWithFrame:CGRectMake(x, y, 60, 43)] autorelease];
				
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
			y += 45.0f;
		}
		else
		{
			x += 62.0f;
		}
		
		[self addSubview:button];
	}
}	

//_______________________________________________________________________________

- (void) showAtPoint:(CGPoint)p
{
	[self stopTimer];
  location.x = (int)(p.x - visibleFrame.size.width*0.5f);
  location.y = (int)(p.y - visibleFrame.size.height*0.5f);
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
	
  visible = YES;
  [self setTransform:CGAffineTransformMake(0.01f, 0, 0, 0.01f, location.x, location.y)];
  [self setAlpha: 0.0f];
		
	[UIView beginAnimations:@"fadeIn"];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
	[UIView setAnimationDuration:MENU_FADE_IN_TIME];
	[self setTransform:CGAffineTransformMake(1, 0, 0, 1, location.x, location.y)];
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
	
  UITransformAnimation *scaleAnim = [[UITransformAnimation alloc] initWithTarget:self];
  [scaleAnim setStartTransform: CGAffineTransformMake(1,0,0,1,location.x,location.y)];
  [scaleAnim setEndTransform:   CGAffineTransformMake(0.01f,0,0,0.01f,location.x,location.y)];
  UIAlphaAnimation *alphaAnim = [[UIAlphaAnimation alloc] initWithTarget:self];
  [alphaAnim setStartAlpha: 0.9f];
  [alphaAnim setEndAlpha: 0.0f];
  float duration = slow ? 1.0f : MENU_FADE_OUT_TIME;
 
	[anim removeAnimationsForTarget:self];
  if (!slow) [anim addAnimation:scaleAnim withDuration:duration start:YES]; 
  [anim addAnimation:alphaAnim withDuration:duration start:YES];
  visible = NO;
}

@end
