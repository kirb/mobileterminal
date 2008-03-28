#import "GestureView.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GraphicsServices/GraphicsServices.h>
#import "MobileTerminal.h"
#import "Settings.h"

@implementation GestureView

//_______________________________________________________________________________

- (id)initWithFrame:(CGRect)rect delegate:(id)inputDelegate
{
  self = [super initWithFrame:rect];
  delegate = inputDelegate;
	[super setTapDelegate: self];
	
	[self setBackgroundColor:[Settings sharedInstance].gestureViewColor];
	 
	toggleKeyboardTimer = NULL;
	
  return self;
}

//_______________________________________________________________________________

- (void)mouseDown:(GSEvent *)event
{
	mouseDownPos = [delegate viewPointForWindowPoint:GSEventGetLocationInWindow(event)];
  [delegate showMenu:mouseDownPos];
}

//_______________________________________________________________________________

- (void)mouseUp:(GSEvent*)event
{
	[delegate hideMenu];
	
  CGPoint end = [delegate viewPointForWindowPoint:GSEventGetLocationInWindow(event)];
  CGPoint vector = CGPointMake(end.x - mouseDownPos.x, end.y - mouseDownPos.y);

  float absx = (vector.x > 0) ? vector.x : -vector.x;
  float absy = (vector.y > 0) ? vector.y : -vector.y;
  float r = (absx > absy) ? absx : absy;
  float theta = atan2(-vector.y, vector.x);
  int zone = (int)((theta / (2 * 3.1415f * 0.125f)) + 0.5f + 4.0f);
  if (r > 30.0f) 
	{
    NSString *characters = nil;
		
    switch (zone) 
		{
      case 0:
      case 8:  // Left
				if (r < 150.0f)
					characters = @"\x1B[D";
				else
					characters = @"\x1"; // ctrl-a
        break;
      case 2:  // Down
        characters = @"\x1B[B";
        break;
      case 4:  // Right
				if (r < 150.0f)
					characters = @"\x1B[C";
				else
					characters = @"\x5"; // ctrl-e
        break;
      case 6:  // Up
        characters = @"\x1B[A";
        break;
      case 5:  // ^C
        characters = @"\x03";
        break;
      case 7:  // ^[
        characters = @"\x1B";
        break;
      case 1: // Tab
        characters = @"\x09";
        break;
      case 3:  //^ // ^D
        //characters = @"\x04";
				if (![[MobileTerminal application] controlKeyMode])
					[[MobileTerminal application] setControlKeyMode:YES];
        break;
    }
    if (characters) 
		{
			//log(@"zone %d %f", zone, r);
			[self stopToggleKeyboardTimer];
			[delegate handleInputFromMenu:characters];
    }
  }
}

//_______________________________________________________________________________

- (BOOL)canHandleGestures
{
  return YES;
}

//_______________________________________________________________________________

- (void)gestureStarted:(GSEvent *)event
{
	//[super gestureStarted:event];
}

//_______________________________________________________________________________

-(void) stopToggleKeyboardTimer
{
	if (toggleKeyboardTimer != NULL) 
	{
		[toggleKeyboardTimer invalidate];
		toggleKeyboardTimer = NULL;
	}
}

//_______________________________________________________________________________

- (void)view:(UIView *)view handleTapWithCount:(int)count event:(GSEvent *)event fingerCount:(int)fingers
{
	/*
	if (fingers == 1 && count == 1) // REMOVE ME! (for debug purposes only)
	{
		[delegate togglePreferences];
	}*/
	
	if (fingers == 1 && count == 2)
	{
		[self stopToggleKeyboardTimer];
		toggleKeyboardTimer = [NSTimer scheduledTimerWithTimeInterval:TOGGLE_KEYBOARD_DELAY target:self selector:@selector(toggleKeyboard) userInfo:NULL repeats:NO];
	}
}

//_______________________________________________________________________________

-(void)toggleKeyboard
{	
	[self stopToggleKeyboardTimer];
	[delegate hideMenu];
	[delegate toggleKeyboard];	
}

//_______________________________________________________________________________

- (BOOL)canHandleSwipes
{
	return YES;
}

//_______________________________________________________________________________

- (int)swipe:(int)direction withEvent:(GSEvent *)event
{
	//log(@"swipeStarted %d %@", direction, event);
	return direction;
}

//_______________________________________________________________________________

- (BOOL)canBecomeFirstResponder
{
  return NO;
}

//_______________________________________________________________________________

- (BOOL)isOpaque
{
  return NO;
}

//_______________________________________________________________________________

/*
- (void)drawRect: (CGRect *)rect
{
}
*/
//_______________________________________________________________________________

@end
