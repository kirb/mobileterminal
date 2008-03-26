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
	if (degrees == application.degrees || application.activeView != application.mainView) return;
	
	BOOL landscape;
	
	struct CGAffineTransform transEnd;
	switch(degrees) 
	{
		case  90: transEnd = CGAffineTransformMake(0,  1, -1, 0, 0, 0); landscape = true;  break;
		case -90: transEnd = CGAffineTransformMake(0, -1,  1, 0, 0, 0); landscape = true;  break;
		case   0: transEnd = CGAffineTransformMake(1,  0,  0, 1, 0, 0); landscape = false; break;
		default:  return;
	}
	
	CGSize screenSize = [UIHardware mainScreenSize];
	CGRect contentBounds;
	
	if (landscape)
		contentBounds = CGRectMake(0, 0, screenSize.height, screenSize.width);
	else
		contentBounds = CGRectMake(0, 0, screenSize.width, screenSize.height);
	
	[UIView beginAnimations:@"rotation"];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
	[(UIView*)[self contentView] setTransform:transEnd];
	[[self contentView] setBounds:contentBounds];
	[UIView endAnimations];
	
	[application setLandscape:landscape degrees:degrees]; 
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
