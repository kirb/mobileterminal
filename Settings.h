// Settings.h

#import <Foundation/Foundation.h>

// TODO: Listeners for when settings change
@interface Settings : NSObject
{
  int width;
  int height;
  NSString* font;
	float fontSize;
  NSString* args;
}

+ (Settings*)sharedInstance;

- (id)init;

- (int)width;
- (int)height;
- (NSString*)font;
- (float)fontSize;
- (NSString*)arguments;
- (void)setWidth:(int)width;
- (void)setHeight:(int)height;
- (void)setFont:(NSString*)terminalFont;
- (void)setFontSize:(float)fontSize;
- (void)setArguments:(NSString*)arguments;

@end
