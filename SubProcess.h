// SubProcess.h
#import <Foundation/Foundation.h>

@interface SubProcess : NSObject
{
  int _fd;
}

- (id)initWithRows:(int)rows columns:(int)cols;
- (int)fileDescriptor;
- (void)dealloc;

@end
