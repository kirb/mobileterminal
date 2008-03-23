// MobileTerminal.h
#import <UIKit/UIKit.h>
#import <GraphicsServices/GraphicsServices.h>
#import "Constants.h"
#import "Log.h"

@class PTYTextView;
@class ShellKeyboard;
@class SubProcess;
@class VT100Screen;
@class VT100Terminal;
@class GestureView;
@class PieView;
@class MobileTerminal;

#define MAXTERMINALS 4

@interface UIView (Color)
+ (CGColorRef)colorWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
@end

//_______________________________________________________________________________

@interface MainWindow : UIWindow
{
	MobileTerminal * application;
}

@property(assign, readwrite) MobileTerminal * application;

- (void) _handleOrientationChange:(id)view;
- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

@end

//_______________________________________________________________________________

@interface MobileTerminal : UIApplication
{
  MainWindow				*	window;
	
	UITransitionView	* contentView;
  UIView						* mainView;
  PTYTextView				* textView;
  UIScroller				* textScroller;
  ShellKeyboard			* keyboardView;
  GestureView				* gestureView;
	UIView						* preferencesView;
	UIView            * activeView;
	
  NSMutableArray		* processes;
  NSMutableArray		* screens;
  NSMutableArray		* terminals;
  
  int numTerminals;
  int activeTerminal;	

  BOOL controlKeyMode;
  BOOL keyboardShown;
	BOOL landscape;
	int  degrees;
}

@property BOOL landscape;
@property int  degrees;

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void) applicationSuspend:(GSEvent *)event;
- (void) applicationResume:(GSEvent *)event;

- (void) handleStreamOutput:(const char*)c length:(unsigned int)len identifier:(int)tid;
- (void) handleKeyPress:(unichar)c;

- (void) updateFrames:(BOOL)needsRefresh;
- (void) setLandscape:(BOOL)landscape_ degrees:(int)degrees_;
- (CGPoint) viewPointForWindowPoint:(CGPoint)point;

-(SubProcess*) activeProcess;
-(VT100Screen*) activeScreen;
-(VT100Terminal*) activeTerminal;

- (void) showPreferences;

// Invoked by GestureMenu
- (void) hideMenu;
- (void) showMenu:(CGPoint)point;
- (void) handleInputFromMenu:(NSString*)input;
- (void) toggleKeyboard;

// Invoked by SwitcherMenu
- (void) prevTerminal;
- (void) nextTerminal;
- (void) setActiveTerminal:(int)active;

@end
