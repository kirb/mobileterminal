#import "GestureView.h"
#import <Foundation/Foundation.h>
#import <GraphicsServices/GraphicsServices.h>
#import <UIKit/UIKit.h>
#import "PieView.h"
#import "SubProcess.h"

// TODO: Switch to the GSEventGetLocationInWindow defined in the toolchain
// which returns a CGPoint.
@implementation GestureView

- (id)initWithProcess:(SubProcess *)aProcess
                Frame:(struct CGRect)rect
                  Pie:(PieView *)pie
{
  if ((self = [super initWithFrame: rect])) {
    _shellProcess = aProcess;
    _pie = pie;
  }
  return self;
}

#define ARROW_KEY_SLOP 75.0

CGPoint start;

- (void)mouseDown:(GSEvent *)event
{
  start = GSEventGetLocationInWindow(event);
  [_pie showAtPoint:start];
}

- (void)mouseDragged:(GSEvent*)event
{
}

- (void)mouseUp:(GSEvent*)event
{
  CGPoint endPoint= GSEventGetLocationInWindow(event);
  CGPoint vector;
  vector.x = endPoint.x - start.x;
  vector.y = endPoint.y - start.y;

  float theta, r, absx, absy;
  absx = (vector.x>0)?vector.x:-vector.x;
  absy = (vector.y>0)?vector.y:-vector.y;
  r = (absx>absy)?absx:absy;
  theta = atan2(-vector.y, vector.x);
  NSLog(@"%f,%f: %f,%f\n", vector.y, -vector.x, r, theta);
  int zone = (int)((theta / (2 * 3.1415f * 0.125f)) + 0.5f + 4.0f);
  NSLog(@"%d\n", zone);
  if (r > 30.0f) {
    NSString *characters = nil;
    switch (zone) {
      case 0:
      case 8:
        characters = @"\x1B[D";
        break;
      case 2:
        characters = @"\x1B[B";
        break;
      case 4:
        characters = @"\x1B[C";
        break;
      case 6:
        characters = @"\x1B[A";
        break;
      case 5:
        characters = @"\x03";
        break;
      case 7:
        characters = @"\x1B";
        break;
      case 1:
        characters = @"\x09";
        break;
      case 3:
        characters = @"\x04";
        break;
    }
    if (characters) {
      [_shellProcess write:[characters cStringUsingEncoding:NSASCIIStringEncoding] length:[characters lengthOfBytesUsingEncoding: NSASCIIStringEncoding]];
    }
  }
  [_pie hide];
}

- (BOOL)canBecomeFirstResponder
{
  return NO;
}

- (BOOL)isOpaque
{
  return NO;
}

- (void)drawRect: (CGRect *)rect
{
}

@end
