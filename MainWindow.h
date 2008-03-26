//
//  MainWindow.h
//  Terminal

#import <UIKit/UIKit.h>

@class MobileTerminal;

//_______________________________________________________________________________

@interface MainWindow : UIWindow
{
	MobileTerminal * application;
}

@property(assign, readwrite) MobileTerminal * application;

- (void) _handleOrientationChange:(id)view;
- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

@end
