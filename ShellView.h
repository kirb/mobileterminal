#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UITextView.h>

@interface ShellView : UITextView {
  NSMutableString* _nextCommand;
  bool _ignoreInsertText;
  bool _controlKeyMode;
}

- (id)initWithFrame:(struct CGRect)fp8;
- (BOOL)canBecomeFirstResponder;
- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector;
- (void)forwardInvocation:(NSInvocation *)anInvocation;
- (void)stopCapture;
- (void)startCapture;
- (BOOL)respondsToSelector:(SEL)aSelector;
- (void)forwardInvocation:(NSInvocation *)anInvocation;
- (BOOL)webView:(id)fp8 shouldDeleteDOMRange:(id)fp12;
- (BOOL)webView:(id)fp8 shouldInsertText:(id)character
                       replacingDOMRange:(id)fp16 givenAction:(int)fp20;

@end
