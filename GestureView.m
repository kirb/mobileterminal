#import "GestureView.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GraphicsServices/GraphicsServices.h>

@implementation GestureView

- (id)initWithFrame:(CGRect)rect
           delegate:(id)inputDelegate
{
  self = [super initWithFrame:rect];
  delegate = inputDelegate;
  return self;
}

CGPoint start;
BOOL gesture;

- (void)mouseDown:(GSEvent *)event
{
  gesture = NO;
  start = GSEventGetLocationInWindow(event);
  [delegate showMenu:start];
}

- (void)mouseUp:(GSEvent*)event
{
  if (gesture) {
    return;
  }

  CGPoint end = GSEventGetLocationInWindow(event);
  CGPoint vector = CGPointMake(end.x - start.x, end.y - start.y);

  float absx = (vector.x > 0) ? vector.x : -vector.x;
  float absy = (vector.y > 0) ? vector.y : -vector.y;
  float r = (absx > absy) ? absx : absy;
  float theta = atan2(-vector.y, vector.x);
  int zone = (int)((theta / (2 * 3.1415f * 0.125f)) + 0.5f + 4.0f);
  if (r > 30.0f) {
    NSString *characters = nil;
    switch (zone) {
      case 0:
      case 8:  // Left
        characters = @"\x1B[D";
        break;
      case 2:  // Down
        characters = @"\x1B[B";
        break;
      case 4:  // Right
        characters = @"\x1B[C";
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
      case 3:  // ^D
        characters = @"\x04";
        break;
    }
    if (characters) {
      [delegate handleInputFromMenu:characters];
    }
  }
  [delegate hideMenu];
}

- (void)gestureStarted:(GSEvent *)event
{
  gesture = YES;
  [delegate hideMenu];
  [delegate toggleKeyboard];
}

- (BOOL)canBecomeFirstResponder
{
  return NO;
}

- (BOOL)canHandleGestures
{
  return YES;
}

- (BOOL)isOpaque
{
  return NO;
}

- (void)drawRect: (CGRect *)rect
{
}

@end
