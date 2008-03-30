//
//  Menu.h
//  Terminal

#import <UIKit/UIKit.h>
#import <UIKit/UIPopup.h> 
#import "Constants.h"

//_______________________________________________________________________________

@interface MenuButton : UIThreePartButton
{
	NSString * chars;
}

- (NSString*) chars;
- (void) setChars:(NSString *)chars;
- (id) initWithFrame:(CGRect)frame;

@end

//_______________________________________________________________________________

@interface Menu : UIView
{
	CGRect visibleFrame;
  CGPoint location;
  UIAnimator * anim;
	NSTimer * timer;
  BOOL visible;
}

//_______________________________________________________________________________

+ (Menu*)	sharedInstance;

- (void) updateButtons;
- (void) showAtPoint:(CGPoint)p;
- (void) hide;
- (void) stopTimer;
- (void) hideSlow:(BOOL)slow;

@end
