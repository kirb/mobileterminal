// MobileTermina.h
#import <UIKit/UIApplication.h>

@class ShellView;

@interface MobileTerminal : UIApplication {
  int _fd;
  ShellView* _view;
}

@end
