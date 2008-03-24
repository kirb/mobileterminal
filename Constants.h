//
//  Constants.h
//  Terminal

#import <UIKit/UIKit.h>

#define TOGGLE_KEYBOARD_DELAY  0.35
#define PIE_MENU_DELAY         0.45 
#define PIE_MENU_FADE_IN_TIME  0.25
#define PIE_MENU_FADE_OUT_TIME 0.25

//_______________________________________________________________________________

@interface UIView (Color)
+ (CGColorRef) colorWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
@end
