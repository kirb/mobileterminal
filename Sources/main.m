// main.m

#include <objc/runtime.h>

#import <UIKit/UIKit.h>

#import "MobileTerminal.h"
#import "Settings.h"

void UIApplicationUseLegacyEvents(BOOL use);

int main(int argc, char **argv)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    if (argc >= 2) {
        NSString *args = @"";
        for (int i = 1; i < argc; ++i) {
            if (i != 1)
                args = [args stringByAppendingString:@" "];
            args = [args stringByAppendingFormat:@"%s", argv[i]];
        }

        [[Settings sharedInstance] setArguments:args];
    }

    UIApplicationUseLegacyEvents(1);
    int ret = UIApplicationMain(argc, argv, @"MobileTerminal", @"MobileTerminal");

    [pool release];
    return ret;
}

/* vim: set syntax=objc sw=4 ts=4 sts=4 expandtab textwidth=80 ff=unix: */
