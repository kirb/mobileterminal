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
  id delegate;
  MenuButton * activeButton;
  
  CGPoint location;
	NSTimer * timer;
  BOOL visible;
}

@property BOOL visible;

+ (Menu*)	sharedInstance;

- (void) updateButtons;
- (void) showAtPoint:(CGPoint)p;
- (void) hide;
- (void) stopTimer;
- (void) hideSlow:(BOOL)slow;
- (id)   delegate;
- (void) setDelegate:(id)delegate;

@end
