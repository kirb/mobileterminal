//
//  Settings.h
//  Terminal

#import <Foundation/Foundation.h>

//_______________________________________________________________________________

@interface TerminalConfig : NSObject
{
  int width;
  int height;
	int fontSize;
		
  NSString * font;
  NSString * args;	
}

- (NSString*) fontDescription;

@property int width;
@property int height;
@property int fontSize;
@property (readwrite, copy) NSString * font;
@property (readwrite, copy) NSString * args;

@end

//_______________________________________________________________________________

@interface Settings : NSObject
{
	NSString * arguments;
	NSArray * terminalConfigs;
	CGColorRef gestureViewColor;
	BOOL multipleTerminals;
}

//_______________________________________________________________________________

@property CGColorRef gestureViewColor;
@property BOOL multipleTerminals;

+ (Settings*) sharedInstance;

- (id) init;

- (void) registerDefaults;
- (void) readUserDefaults;
- (void) writeUserDefaults;

- (NSArray *) terminalConfigs;
- (void) setArguments: (NSString*)arguments;
- (NSString*) arguments;

//_______________________________________________________________________________

@end
