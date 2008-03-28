//
//  Constants.h
//  Terminal

#import <UIKit/UIKit.h>

#define TOGGLE_KEYBOARD_DELAY		0.35
#define PIE_MENU_DELAY					0.45 
#define PIE_MENU_FADE_IN_TIME		0.25
#define PIE_MENU_FADE_OUT_TIME	0.25

#define DEFAULT_TERMINAL_WIDTH	80
#define DEFAULT_TERMINAL_HEIGHT	25

#define TERMINAL_LINE_SPACING   3.0f

//_______________________________________________________________________________

CGColorRef colorWithRGBA(float red, float green, float blue, float alpha);

//_______________________________________________________________________________

@interface UIView (Color)
+ (CGColorRef) colorWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
@end
