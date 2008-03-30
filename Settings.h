//
//  Settings.h
//  Terminal

#import <Foundation/Foundation.h>

//_______________________________________________________________________________

@interface TerminalConfig : NSObject
{
  int width;
	int fontSize;
	float fontWidth;
	BOOL autosize;
		
  NSString * font;
  NSString * args;	
}

- (NSString*) fontDescription;

@property BOOL autosize;
@property int width;
@property int fontSize;
@property float fontWidth;
@property (readwrite, copy) NSString * font;
@property (readwrite, copy) NSString * args;

@end

//_______________________________________________________________________________

@interface Settings : NSObject
{
	NSString * arguments;
	NSArray * terminalConfigs;
	NSArray * menuButtons;
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

- (NSArray*) terminalConfigs;
- (void) setArguments: (NSString*)arguments;
- (NSString*) arguments;
- (NSArray*) menuButtons;

//_______________________________________________________________________________

@end
