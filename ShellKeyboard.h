// ShellKeyboard.h
#include <UIKit/UIKIt.h>

@class ShellView;

@interface ShellKeyboard : UIKeyboard
{
  bool _hidden;
}

// TODO: Init code that sets default values for _hidden

// TODO: Only show and toggle are called -- remove more dead code here
- (void)show:(ShellView*)shellView;
- (void)hide:(ShellView*)shellView;
- (void)toggle:(ShellView*)shellView;

@end
