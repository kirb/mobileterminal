// main.m
#import <UIKit/UIKit.h>
#import "MobileTerminal.h"
#import "Settings.h"

int main(int argc, char **argv)
{
  [[NSAutoreleasePool alloc] init];
  if (argc >= 2) {
    NSString* args = @"";
    int i ;
    for (i = 1; i < argc; i++) {
      if (i != 1) {
        args = [args stringByAppendingString:@" "];
      }
      args = [args stringByAppendingFormat:@"%s", argv[i]];
    }
    [[Settings sharedInstance] setArguments:args];
  }

  return UIApplicationMain(argc, argv, [MobileTerminal class]);
}
