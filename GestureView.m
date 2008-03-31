//
//  GestureView.m
//  Terminal

#import "GestureView.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/CDStructures.h>
#import <GraphicsServices/GraphicsServices.h>
#import "MobileTerminal.h"
#import "Menu.h"
#import "Settings.h"
#include <math.h>

@implementation GestureView

//_______________________________________________________________________________

- (id)initWithFrame:(CGRect)rect delegate:(id)inputDelegate
{
  self = [super initWithFrame:rect];
  delegate = inputDelegate;
	[super setTapDelegate: self];

	[self setBackgroundColor:colorWithRGBA(0,0,0,0)];
	 
	toggleKeyboardTimer = NULL;
	gestureMode = NO;
	
  return self;
}

//_______________________________________________________________________________

-(BOOL) shouldTrack
{
	//log(@"should track"); // , [[Menu sharedInstance] visible]);
	return YES;
}

//_______________________________________________________________________________

- (BOOL) beginTrackingAt:(CGPoint)point withEvent:(id)event
{
	return YES;
}

//_______________________________________________________________________________

- (BOOL) continueTrackingAt:(CGPoint)point previous:(CGPoint)prev withEvent:(id)event
{
	Menu * menu = [Menu sharedInstance];
	
	int i;
	for (i = 0; i < [[menu subviews] count]; i++)
	{
		MenuButton * button = [[menu subviews] objectAtIndex:i];
		[button setSelected:CGRectContainsPoint([button frame], [menu convertPoint:point fromView:self])];
	}
	return YES;
}

//_______________________________________________________________________________

- (BOOL) endTrackingAt:(CGPoint)point previous:(CGPoint)prev withEvent:(id)event
{
	Menu * menu = [Menu sharedInstance];

	int i;
	for (i = 0; i < [[menu subviews] count]; i++)
	{
		MenuButton * button = [[menu subviews] objectAtIndex:i];
		if ([button isSelected])
		{
			//log(@"button activated %@", [button title]);
			if ([button chars])
				[delegate handleInputFromMenu:[button chars]];
			[button setSelected:NO];
			break;
		}
	}
	[menu hide];
	return YES;
}

//_______________________________________________________________________________

- (void)mouseDown:(GSEvent*)event
{
	//memcpy(&mouseDownEvent, event, sizeof(GSEventStruct));
	
	mouseDownPos = [delegate viewPointForWindowPoint:GSEventGetLocationInWindow(event)];
  [delegate showMenu:mouseDownPos];
	
	[super mouseDown:event];
}

//_______________________________________________________________________________

-(GSEventStruct*) mouseDownEvent
{
	return &mouseDownEvent;
}

//_______________________________________________________________________________

-(int) zoneForVector:(CGPoint)vector
{
  float theta = atan2(-vector.y, vector.x);
	return ((7-(lround(theta/M_PI_4)+4)%8)+7)%8;
}

//_______________________________________________________________________________

- (void)mouseUp:(GSEvent*)event
{
	//[delegate hideMenu];

	if (gestureMode) 
	{
		gestureMode = NO;
		
		//log(@"finger count %d", gestureFingers);
		
		CGPoint vector = CGPointMake(gestureEnd.x - gestureStart.x, gestureEnd.y - gestureStart.y);	
		float r = sqrtf(vector.x*vector.x + vector.y*vector.y);
		//log(@"vector %f %f length %f", vector.x, vector.y, r);
		if (r < 30) 
		{
			if (gestureFingers == 3)
				[[MobileTerminal application] toggleKeyboard];			
			return;
		}
		else if (r > 30)
		{
			int zone = [self zoneForVector:vector];
			//log(@"zone %d", zone);
			if (gestureFingers == 2)
			{
				switch (zone)
				{
					case ZONE_W: [[MobileTerminal application] nextTerminal]; break;
					case ZONE_E: [[MobileTerminal application] prevTerminal]; break;
					case ZONE_S: [[MobileTerminal application] handleKeyPress:0x0d]; break;
				}
			}
			else if (gestureFingers == 3)
			{
				switch (zone)
				{
					case ZONE_W: [[MobileTerminal application] togglePreferences]; break;
				}
			}
		}
		
		return;
		
	} // end if gestureMode
	
	if (![[Menu sharedInstance] visible])
	{
		CGPoint end = [delegate viewPointForWindowPoint:GSEventGetLocationInWindow(event)];
		CGPoint vector = CGPointMake(end.x - mouseDownPos.x, end.y - mouseDownPos.y);

		float r = sqrtf(vector.x*vector.x + vector.y*vector.y);

		int zone = [self zoneForVector:vector];
		if (r > 30.0f) 
		{
			NSString *characters = nil;
			
			switch (zone) 
			{
				case ZONE_W:  // Left
					if (r < 150.0f)
						characters = @"\x1B[D";
					else
						characters = @"\x1"; // ctrl-a
					break;
				case ZONE_S:  // Down
					characters = @"\x1B[B";
					break;
				case ZONE_E:  // Right
					if (r < 150.0f)
						characters = @"\x1B[C";
					else
						characters = @"\x5"; // ctrl-e
					break;
				case ZONE_N:  // Up
					characters = @"\x1B[A";
					break;
				case ZONE_NE:  // ^C
					characters = @"\x03";
					break;
				case ZONE_NW:  // ^[
					characters = @"\x1B";
					break;
				case ZONE_SW: // Tab
					characters = @"\x09";
					break;
				case ZONE_SE:  //^
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
	} // end if menu visible
	
	[super mouseUp:event];
}

//_______________________________________________________________________________

- (BOOL)canHandleGestures
{
  return YES;
}

//_______________________________________________________________________________

- (BOOL)canHandleSwipes
{
	return YES;
}

//_______________________________________________________________________________

-(CGPoint)gestureCenter:(GSEvent *)event
{
	float cx = 0, cy = 0;
	int i;
	for (i = 0; i < ((GSEventStruct*)event)->numPoints; i++)
	{
		//log(@"p %d %f %f", i, ((GSEventStruct*)event)->points[i].x, ((GSEventStruct*)event)->points[i].y);
		cx += ((GSEventStruct*)event)->points[i].x;
		cy += ((GSEventStruct*)event)->points[i].y;
	}		
	cx /= ((GSEventStruct*)event)->numPoints;
	cy /= ((GSEventStruct*)event)->numPoints;
	return CGPointMake(cx,cy);
}

//_______________________________________________________________________________

- (void)gestureStarted:(GSEvent *)event
{
	[delegate hideMenu];
	gestureMode = YES;
	gestureStart = [delegate viewPointForWindowPoint:[self gestureCenter:event]]; 
	
	//logPoint(@"start", gestureStart);
}

//_______________________________________________________________________________

- (void)gestureChanged:(GSEvent *)event
{
}

//_______________________________________________________________________________

- (void)gestureEnded:(GSEvent *)event
{
	[delegate hideMenu];
	gestureEnd = [delegate viewPointForWindowPoint:[self gestureCenter:event]];
	gestureFingers = ((GSEventStruct*)event)->numPoints;

	//logPoint(@"end", gestureEnd);
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

-(void) drawRect:(CGRect)frame
{
	CGRect rect = [self bounds];
	//rect.origin.x -= 1;
	//rect.origin.y -= 1;
	//rect.size.width += 1;
	rect.size.height -= 2;
	CGContextRef context = UICurrentContext();
	CGColorRef c = CGColorWithRGBAColor([[Settings sharedInstance] gestureFrameColor]);
	const float pattern[2] = {1,4};
	CGContextSetLineDash(context, 0, pattern, 2);
	CGContextSetStrokeColorWithColor(context, c);
	CGContextStrokeRectWithWidth(context, rect, 1);
	CGContextFlush(context);
}

//_______________________________________________________________________________

@end
