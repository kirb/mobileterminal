//
//  Settings.h
//  Terminal

#import <Foundation/Foundation.h>
#import "ColorChooser.h"

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
	RGBAColor gestureFrameColor;
	BOOL multipleTerminals;
}

//_______________________________________________________________________________

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
- (RGBAColor) gestureFrameColor;
- (RGBAColorRef) gestureFrameColorRef;
- (void) setgestureFrameColor:(RGBAColor)color;

//_______________________________________________________________________________

@end
