//
//  MainWindow.m
//  Terminal

#import "MainWindow.h"
#import "MobileTerminal.h"

//_______________________________________________________________________________
//_______________________________________________________________________________

@implementation MainWindow

-(void) _handleOrientationChange:(id)notification
{
	int degrees = [[[notification userInfo] objectForKey:@"UIApplicationOrientationUserInfoKey"] intValue];	
	//log(@"orientation changed: %d", degrees);
	[application setOrientation:degrees];
}

//_______________________________________________________________________________

- (void) setApplication:(MobileTerminal*)app { application = app; }
- (MobileTerminal*) application { return application; }

//_______________________________________________________________________________

- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	//log(@"stop %@ finished %@", animationID, finished);
	[application updateFrames:YES];
}

@end
