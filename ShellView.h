
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import <UIKit/UIView.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UITextView.h>

@interface ShellView : UITextView {
	NSMutableString* _nextCommand;
	bool _ignoreInsertText;
	bool _controlKeyMode;
        id *_keyboard;
        UIView *_mainView;
}

- (void)setMainView:(UIView *) mainView;
- (void)setKeyboard:(id *) keyboard;
- (void)mouseDown:(struct __GSEvent *)fp8;
-(id)initWithFrame:(struct CGRect)fp8;
- (BOOL)canBecomeFirstResponder;
-(NSMethodSignature*)methodSignatureForSelector:(SEL)selector;
- (void)forwardInvocation:(NSInvocation *)anInvocation;
- (void)stopCapture;
- (void)startCapture;

- (BOOL)respondsToSelector:(SEL)aSelector;
- (void)forwardInvocation:(NSInvocation *)anInvocation;
- (BOOL)webView:(id)fp8 shouldDeleteDOMRange:(id)fp12;

  -(BOOL)webView:(id)fp8 shouldInsertText:(id)character replacingDOMRange:(id)fp16 givenAction:(int)fp20;

@end
