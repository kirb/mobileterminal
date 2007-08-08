// MobileTermina.h
#import <UIKit/UIApplication.h>

@class ShellView, SubProcess;

@interface MobileTerminal : UIApplication {
  SubProcess* _shellProcess;
  ShellView* _view;
}

@end
