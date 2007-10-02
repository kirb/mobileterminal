// Settings.h

#import <Foundation/Foundation.h>

// TODO: Listeners for when settings change
@interface Settings : NSObject
{
  int width;
  int height;
  NSString* font;
  NSString* args;
}

+ (Settings*)sharedInstance;

- (id)init;

- (int)width;
- (int)height;
- (NSString*)font;
- (NSString*)arguments;
- (void)setWidth:(int)width;
- (void)setHeight:(int)height;
- (void)setFont:(NSString*)terminalFont;
- (void)setArguments:(NSString*)arguments;

@end
