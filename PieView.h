#import "Constants.h"
#import <UIKit/UIKit.h>

@interface PieView : UIImageView {
	CGRect visibleFrame;
  CGPoint location;
  UIAnimator *anim;
	NSTimer *timer;
  BOOL _visible;
}

+ (PieView*)sharedInstance;

- (void)showAtPoint:(CGPoint)p;
- (void)hide;
- (void)stopTimer;
- (void)hideSlow:(BOOL)slow;

@end
