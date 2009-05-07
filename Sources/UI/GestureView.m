//
// GestureView.m
// Terminal

#import "GestureView.h"

#include <math.h>

#import <GraphicsServices/GraphicsServices.h>
#import <UIKit/UIColor.h>
#import <UIKit/UIView.h>

#import "Menu.h"
#import "MobileTerminal.h"
#import "Settings.h"
#import "Tools.h"

@protocol UITouchCompatibility

- (CGPoint)locationInView:(UIView *)view;
- (CGPoint)previousLocationInView:(UIView *)view;

@end

//_______________________________________________________________________________
//_______________________________________________________________________________

@implementation GestureView

- (id)initWithFrame:(CGRect)rect delegate:(id)inputDelegate
{
    self = [super initWithFrame:rect];
    if (self) {
        delegate = inputDelegate;
        [super setTapDelegate: self];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setOpaque:NO];
    }
    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return NO;
}

- (BOOL)canHandleGestures
{
    return YES;
}

- (BOOL)canHandleSwipes
{
    return YES;
}

- (void)drawRect:(CGRect)frame
{
    CGRect rect = [self bounds];
    rect.size.height -= 2;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorRef c = [[[Settings sharedInstance] gestureFrameColor] CGColor];
    const float pattern[2] = {1,4};
    CGContextSetLineDash(context, 0, pattern, 2);
    CGContextSetStrokeColorWithColor(context, c);
    CGContextStrokeRectWithWidth(context, rect, 1);
    CGContextFlush(context);
}

#pragma mark Other

- (void)stopToggleKeyboardTimer
{
    if (toggleKeyboardTimer != nil) {
        [toggleKeyboardTimer invalidate];
        toggleKeyboardTimer = nil;
    }
}

- (void)toggleKeyboard
{
    [self stopToggleKeyboardTimer];
    [delegate hideMenu];
    [delegate toggleKeyboard];
}

# pragma mark UIView delegate methods

- (void)view:(UIView *)view handleTapWithCount:(int)count event:(GSEventRef)event fingerCount:(int)fingers
{
    if (fingers == 1) {
        if (count == 2) {
            [[MenuView sharedInstance] hide];
            [self stopToggleKeyboardTimer];
            toggleKeyboardTimer = [NSTimer scheduledTimerWithTimeInterval:TOGGLE_KEYBOARD_DELAY
                target:self selector:@selector(toggleKeyboard) userInfo:nil repeats:NO];
        }
    }
}

#pragma mark UIControl input tracking methods

- (BOOL)shouldTrack
{
    return ![[MenuView sharedInstance] visible];
}

- (BOOL)beginTrackingAt:(CGPoint)point withEvent:(id)event
{
    return YES;
}

- (BOOL)continueTrackingAt:(CGPoint)point previous:(CGPoint)prev withEvent:(id)event
{
    MenuView *menu = [MenuView sharedInstance];
    if (![menu visible]) {
        [menu stopTimer];
    } else {
        [menu handleTrackingAt:[menu convertPoint:point fromView:self]];
        return YES;
    }

    return NO;
}

- (BOOL)endTrackingAt:(CGPoint)point previous:(CGPoint)prev withEvent:(id)event
{
    if (!menuTapped)
        [delegate handleInputFromMenu:[[MenuView sharedInstance] handleTrackingEnd]];
    return YES;
}

- (BOOL)beginTrackingWithTouch:(id)touch withEvent:(id)event
{
    return [self beginTrackingAt:[touch locationInView:self] withEvent:event];
}

- (BOOL)continueTrackingWithTouch:(id)touch withEvent:(id)event
{
    return [self continueTrackingAt:[touch locationInView:self] previous:[touch previousLocationInView:self] withEvent:event];
}

- (void)endTrackingWithTouch:(id)touch withEvent:(id)event
{
    [self endTrackingAt:[touch locationInView:self] previous:[touch previousLocationInView:self] withEvent:event];
}

#pragma mark UIResponder touch input methods

- (void)mouseDown:(GSEventRef)event
{
    mouseDownPos = [delegate viewPointForWindowPoint:GSEventGetLocationInWindow(event).origin];
    [delegate showMenu:mouseDownPos];

    [super mouseDown:event];
}

static int zoneForVector(CGPoint vector)
{
    float theta = atan2(-vector.y, vector.x);
    return ((7 - (lround(theta / M_PI_4 ) + 4) % 8) + 7) % 8;
}

- (void)mouseUp:(GSEventRef)event
{
    if (gestureMode) {
        gestureMode = NO;

        CGPoint vector = CGPointMake(gestureEnd.x - gestureStart.x, gestureEnd.y - gestureStart.y);
        float r = sqrtf(vector.x *vector.x + vector.y *vector.y);

        if (r < 10) {
            if (gestureFingers == 2)
                [[MobileTerminal application] toggleKeyboard];
            return;
        } else if (r > 30) {
            int zone = zoneForVector(vector);

            if (gestureFingers >= 2) {
                NSString *zoneName = ZONE_KEYS[zone+16];
                NSString *characters = [[[Settings sharedInstance] swipeGestures] objectForKey:zoneName];

                if (characters) {
                    [delegate handleInputFromMenu:characters];
                }
            }
        }

        return;

    } // end if gestureMode

    if (![[MenuView sharedInstance] visible]) {
        CGPoint end = [delegate viewPointForWindowPoint:GSEventGetLocationInWindow(event).origin];
        CGPoint vector = CGPointMake(end.x - mouseDownPos.x, end.y - mouseDownPos.y);

        float r = sqrtf(vector.x *vector.x + vector.y *vector.y);

        int zone = zoneForVector(vector);
        if (r > 30.0f) {
            NSString *characters = nil;

            NSDictionary *swipeGestures = [[Settings sharedInstance] swipeGestures];
            NSString *zoneName = ZONE_KEYS[zone];

            if (r < 150.0f) {
                characters = [swipeGestures objectForKey:zoneName];
            } else {
                NSString *longZoneName = ZONE_KEYS[zone+8];
                characters = [swipeGestures objectForKey:longZoneName];
                if (![characters length]) {
                    characters = [swipeGestures objectForKey:zoneName];
                }
            }

            if (characters) {
                [self stopToggleKeyboardTimer];

                [delegate handleInputFromMenu:characters];
            }
        } else if (r < 10.0f) {
            mouseDownPos = [delegate viewPointForWindowPoint:GSEventGetLocationInWindow(event).origin];
            if ([[MenuView sharedInstance] visible]) {
                [[MenuView sharedInstance] hide];
            } else {
                [[MenuView sharedInstance] setDelegate:self];
                menuTapped = YES;
                [[MenuView sharedInstance] showAtPoint:mouseDownPos delay:MENU_TAP_DELAY];
            }
        }
    } // end if menu invisible
    else {
        [[MenuView sharedInstance] hide];
    }

    [super mouseUp:event];
}

#pragma mark UIResponder gesture input methods

static CGPoint gestureCenter(GSEventRef event)
{
    float cx = 0, cy = 0;
    int i;
    for (i = 0; i < ((GSEventStruct *)event)->numPoints; i++) {
        cx += ((GSEventStruct *)event)->points[i].x;
        cy += ((GSEventStruct *)event)->points[i].y;
    }
    cx /= ((GSEventStruct *)event)->numPoints;
    cy /= ((GSEventStruct *)event)->numPoints;
    return CGPointMake(cx,cy);
}

- (void)gestureStarted:(GSEventRef)event
{
    [delegate hideMenu];
    gestureMode = YES;
    gestureStart = [delegate viewPointForWindowPoint:gestureCenter(event)];
}

- (void)gestureChanged:(GSEventRef)event
{
}

- (void)gestureEnded:(GSEventRef)event
{
    [delegate hideMenu];
    gestureEnd = [delegate viewPointForWindowPoint:gestureCenter(event)];
    gestureFingers = ((GSEventStruct *)event)->numPoints;
}

#pragma mark MenuView delegate methods

- (void)menuFadedIn
{
    menuTapped = NO;
}

- (void)menuButtonPressed:(MenuButton *)button
{
    if (![button isMenuButton]) {
        BOOL keepMenu = NO;
        NSMutableString *command = [NSMutableString stringWithCapacity:16];
        [command setString:[button.item command]];

        if ([command hasSubstring:[[MobileTerminal menu] dotStringWithCommand:@"keepmenu"]]) {
            [command removeSubstring:[[MobileTerminal menu] dotStringWithCommand:@"keepmenu"]];
            [[MenuView sharedInstance] deselectButton:button];
            keepMenu = YES;
        }

        if ([command hasSubstring:[[MobileTerminal menu] dotStringWithCommand:@"back"]]) {
            [command removeSubstring:[[MobileTerminal menu] dotStringWithCommand:@"back"]];
            [[MenuView sharedInstance] popMenu];
            keepMenu = YES;
        }

        if (!keepMenu) {
            [[MenuView sharedInstance] setDelegate:nil];
            [[MenuView sharedInstance] hide];
        }

        [delegate handleInputFromMenu:command];
    }
}

@end

/* vim: set syntax=objc sw=4 ts=4 sts=4 expandtab textwidth=80 ff=unix: */
