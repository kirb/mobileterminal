// ShellView.m
#import "ShellView.h"

#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>
#import "ShellKeyboard.h"
#import "Common.h"

@interface NSObject (HeartbeatDelegate)

- (void)heartbeatCallback:(id)ignored;

@end

@interface UITextLoupe : UIView

- (void)drawRect:(struct CGRect)fp8;

@end

@implementation UITextLoupe (Black)

- (void)drawRect:(struct CGRect)fp8
{

}

@end


@implementation ShellView : UITextView

- (void)setKeyboard:(ShellKeyboard*) keyboard
{
  _keyboard=keyboard;
}

- (void)setMainView:(UIView *) mainView
{
  _mainView=mainView;
}

- (void)setFd:(int)fd
{
  _fd = fd;
}

- (void)mouseUp:(struct __GSEvent *)fp8
{
  if ([self isScrolling]) {
    //NSLog(@"MouseUp: scrolling\n");
  } else{
    //NSLog(@"MouseUp: not scrolling\n");
    [_keyboard toggle:self];
  }
  [super mouseUp:fp8];
}
- (id)initWithFrame:(struct CGRect)fp8
{
  debug(@"Created ShellView");
  _nextCommand = [[NSMutableString stringWithCapacity:255] retain];
  _ignoreInsertText = NO;
  _controlKeyMode = NO;
  return [super initWithFrame:fp8];
}

- (BOOL)canBecomeFirstResponder
{
  return NO;
}

- (void)stopCapture
{
  _ignoreInsertText = YES;
}

- (void)startCapture
{
  _ignoreInsertText = NO;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
  //debug(@"Request for selector: %@", NSStringFromSelector(aSelector));
  return [super respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
  debug(@"Called from UITextView %@", NSStringFromSelector([anInvocation selector]));
  [super forwardInvocation:anInvocation];
  return;
}

- (BOOL)webView:(id)fp8 shouldDeleteDOMRange:(id)fp12
{
//  debug(@"deleting range: %i, %i", [fp12 startOffset], [fp12 endOffset]);

  if(!_ignoreInsertText) {
    const char delete_cstr = 0x08;
    if (write(_fd, &delete_cstr, 1) == -1) {
     perror("write");
     exit(1);
    }
  }
  return [super webView:fp8 shouldDeleteDOMRange:fp12];
}

- (BOOL)webView:(id)fp8 shouldInsertText:(id)character replacingDOMRange:(id)fp16 givenAction:(int)fp20
{
  debug(@"inserting.. %#x", [character characterAtIndex:0]);
 
  if(!_ignoreInsertText) {
    if([character length] > 1) return false;  //or just loop through
 
    char cmd_char = [character characterAtIndex:0];
 
    if(!_controlKeyMode) {
      if([character characterAtIndex:0] == 0x2022) {
        //debug(@"ctrl key mode");
        _controlKeyMode = YES;
        return NO;
      }
    } else {
      // was in ctrl key mode, got another key
      //debug(@"sending ctrl key");
      if (cmd_char < 0x60 && cmd_char > 0x40) {
        //Uppercase
        cmd_char -= 0x40;      
      } else if (cmd_char < 0x7B && cmd_char > 0x61) {
        //Lowercase
        cmd_char -= 0x60;
      }
      _controlKeyMode = NO;
    }
 
    debug(@"writing char: %#x", cmd_char);
    if (write(_fd, &cmd_char, 1) == -1) {
     perror("write");
     exit(1);
    }
    return NO;
  }
  return [super webView:fp8 shouldInsertText:character
            replacingDOMRange:fp16 givenAction:fp20];
}

- (void)heartbeatCallback:(id)unused
{
  if (_heartbeatDelegate != nil) {
    if ([_heartbeatDelegate respondsToSelector:@selector(heartbeatCallback:)]) {
      [_heartbeatDelegate heartbeatCallback:self];
    } else {
      [NSException raise:NSInternalInconsistencyException
         format:@"Delegate doesn't respond to selector"];
    }
  }
}

- (void)setHeartbeatDelegate:(id)delegate
{
  _heartbeatDelegate = delegate;
  [self startHeartbeat:@selector(heartbeatCallback:) inRunLoopMode:nil];
}

@end
