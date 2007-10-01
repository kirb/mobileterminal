// ShellKeyboard.h
#include <UIKit/UIKit.h>
#include <UIKit/UITextView.h>

@class ShellView;

@protocol KeyboardInputProtocol
- (void)handleKeyPress:(unichar)c;
@end

@interface ShellKeyboard : UIKeyboard<KeyboardInputProtocol>
{
  id inputDelegate;
  UITextView* inputView;
}

- (id)initWithFrame:(CGRect)frame;
- (UITextView*)inputView;
- (void)setInputDelegate:(id)delegate;
- (void)handleKeyPress:(unichar)c;

@end
