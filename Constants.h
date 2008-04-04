//
//  Constants.h
//  Terminal

#import <UIKit/UIKit.h>
#import "svnversion.h"

#define MULTIPLE_TERMINALS      YES
#define MAXTERMINALS            4

#define TOGGLE_KEYBOARD_DELAY		0.35

#define MENU_DELAY							0.45 
#define MENU_FADE_IN_TIME				0.25
#define MENU_FADE_OUT_TIME			0.25
#define MENU_SLOW_FADE_OUT_TIME	1.50
#define MENU_BUTTON_HEIGHT      43.0f
#define MENU_BUTTON_WIDTH       60.0f
#define MENU_BUTTON_SPACE        2.0f
#define KEYBOARD_FADE_OUT_TIME   0.5f
#define KEYBOARD_FADE_IN_TIME    0.5f

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

extern NSString * ZONE_KEYS[];
extern NSString * DEFAULT_SWIPE_GESTURES[][2];
extern NSString * DEFAULT_MENU_BUTTONS[][4];
