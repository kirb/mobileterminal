
#include <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>

#define logf(s,...)    [FileLog logFile:__FILE__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]
#define logfRect(s, r) [FileLog logFile:__FILE__ lineNumber:__LINE__ string:(s) rect:(r)] 
#define log(s,...)     [FileLog logFunc:__PRETTY_FUNCTION__ format:(s),##__VA_ARGS__]
#define logRect(s, r)  [FileLog logFunc:__PRETTY_FUNCTION__ string:(s) rect:(r)] 

@interface FileLog : NSObject {
}
+ (void)logFunc: (char*)func format:(NSString*)format, ...;
+ (void)logFunc: (char*)func string:(NSString*)s rect:(CGRect)r;
+ (void)logFile: (char*)sourceFile lineNumber: (int)lineNumber format:(NSString*)format, ...;
+ (void)logFile: (char*)sourceFile lineNumber: (int)lineNumber string:(NSString*)s rect:(CGRect)r;

@end
