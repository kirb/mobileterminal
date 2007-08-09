// ShellView.h
#import <UIKit/CDStructures.h>
#import <UIKit/UIKit.h>
#import <UIKit/UITextView.h>

@class ShellKeyboard;

@interface ShellView : UITextView {
  NSMutableString* _nextCommand;
  bool _ignoreInsertText;
  bool _controlKeyMode;
  ShellKeyboard* _keyboard;
  UIView *_mainView;
  int _fd;
  id _heartbeatDelegate;
  SEL _heartbeatSelector;
}

- (id)initWithFrame:(struct CGRect)fp8;
- (void)setFd:(int)fd;
- (void)setMainView:(UIView *) mainView;
- (void)setKeyboard:(ShellKeyboard*) keyboard;
- (BOOL)canBecomeFirstResponder;
- (BOOL)respondsToSelector:(SEL)aSelector;
- (void)forwardInvocation:(NSInvocation *)anInvocation;
- (BOOL)webView:(id)fp8 shouldDeleteDOMRange:(id)fp12;
- (BOOL)webView:(id)fp8 shouldInsertText:(id)character
      replacingDOMRange:(id)fp16 givenAction:(int)fp20;
- (void)setHeartbeatDelegate:(id)delegate;
- (void)scrollToEnd;
- (void)insertText:(NSString*)text;

@end
