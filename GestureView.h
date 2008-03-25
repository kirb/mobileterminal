#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SubProcess, PieView;

//_______________________________________________________________________________

@protocol GestureInputProtocol
- (void) showMenu:(CGPoint)point;
- (void) hideMenu;
- (void) handleInputFromMenu:(NSString*)input;
- (void) toggleKeyboard;
@end

//_______________________________________________________________________________

@interface GestureView : UIView 
{
	CGPoint mouseDownPos;

  id delegate;
	
	NSTimer *toggleKeyboardTimer;
}

- (id)initWithFrame:(CGRect)rect
           delegate:(id)inputDelegate;

-(void) stopToggleKeyboardTimer;

@end
