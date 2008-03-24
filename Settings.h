// Settings.h

#import <Foundation/Foundation.h>

// TODO: Listeners for when settings change
@interface Settings : NSObject
{
  int width;
  int height;
	int fontSize;
  NSString* font;
  NSString* args;
}

+ (Settings*)sharedInstance;

- (id)init;

- (int)width;
- (int)height;
- (int)fontSize;
- (NSString*)font;
- (NSString*)arguments;
- (NSString*)fontDescription;
- (void)setWidth:(int)width;
- (void)setHeight:(int)height;
- (void)setFont:(NSString*)terminalFont;
- (void)setFontSize:(int)fontSize;
- (void)setArguments:(NSString*)arguments;

@end
