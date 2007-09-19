// MobileTermina.h
#import <UIKit/UIKit.h>

@class ShellView, SubProcess;

@interface MobileTerminal : UIApplication {
  SubProcess* _shellProcess;
  ShellView* _view;
}

@end
