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

// gesture pie zones

enum {
	ZONE_N,
	ZONE_NE,
	ZONE_E,
	ZONE_SE,
	ZONE_S,
	ZONE_SW,
	ZONE_W,
	ZONE_NW
};

/*
#define ZONE_N								0
#define ZONE_NE								1
#define ZONE_E								2
#define ZONE_SE								3
#define ZONE_S								4
#define ZONE_SW								5
#define ZONE_W								6
#define ZONE_NW								7
*/

//_______________________________________________________________________________

CGColorRef colorWithRGBA(float red, float green, float blue, float alpha);

//_______________________________________________________________________________

@interface UIView (Color)
+ (CGColorRef) colorWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
@end
