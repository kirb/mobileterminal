// ShellView.m
#import "ShellView.h"

#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>
#import "Cleanup.h"
#import "Common.h"
#import "ShellKeyboard.h"

// TODO: Is the code for ignoring inserted text even needed? This should run
// in the same thread as the heartbeat callback.

// Forward declarations

@interface NSObject (HeartbeatDelegate)

- (void)heartbeatCallback:(id)ignored;

@end

// Disable the magnifying Glass effect for the shell view, since it can't be
// used effectively to change the cursor position (maybe later)

@interface UITextLoupe : UIView

- (void)drawRect:(struct CGRect)fp8;

@end

@implementation UITextLoupe (Black)

- (void)drawRect:(struct CGRect)fp8 { }

@end

// ShellView

@implementation ShellView : UITextView

- (id)initWithFrame:(struct CGRect)fp8
{
  debug(@"Created ShellView");
  id parent = [super initWithFrame:fp8];

  _nextCommand = [[NSMutableString stringWithCapacity:255] retain];
  _ignoreInsertText = NO;
  _controlKeyMode = NO;


  float backcomponents[4] = {0, 0, 0, 0};
#ifndef GREENTEXT
  float textcomponents[4] = {1, 1, 1, 1};
#else
  float textcomponents[4] = {.1, .9, .1, 1};
#endif // !GREENTEXT

  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  [self setTextColor: CGColorCreate( colorSpace, textcomponents)];
  [self setBackgroundColor: CGColorCreate( colorSpace, backcomponents)];

  [self setText:@""];
  [self setEditable:NO]; // don't mess up my pretty output
  [self setAllowsRubberBanding:YES];
  [self displayScrollerIndicators];
  [self setOpaque:NO];

  return parent;
}

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
    // Ignore mouse events that cause scrolling
  } else{
    // NSLog(@"MouseUp: not scrolling\n");
    [_keyboard toggle:self];
  }
  [super mouseUp:fp8];
}

- (BOOL)canBecomeFirstResponder
{
  return NO;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
//  debug(@"Request for selector: %@", NSStringFromSelector(aSelector));
  return [super respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
  debug(@"Called from UITextView %@",
        NSStringFromSelector([anInvocation selector]));
  [super forwardInvocation:anInvocation];
  return;
}

- (BOOL)webView:(id)fp8 shouldDeleteDOMRange:(id)fp12
{
  //debug(@"deleting  range: %i, %i", [fp12 startOffset], [fp12 endOffset]);

  // TODO: There is an annoying bug here.  This writes a ^H to the subprocess
  // then passes the delete on to the parent which removes it from the display.
  // The delete sent to the subprocess is echo'd back in heartbeatCallback
  // and we ignore it.  If we attempt to backspace over the start of a line,
  // then we end up causing a bell (^G) to get echo'd back to the terminal;
  // we don't backspace further and end up backspacing over the bells we are
  // creating.  Ghetto!

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
    if([character length] > 1) {
      debug(@"Unhandled multiple character insert!");
      return false;  //or just loop through
    }
 
    char cmd_char = [character characterAtIndex:0];
 
    if (!_controlKeyMode) {
      if ([character characterAtIndex:0] == 0x2022) {
        //debug(@"ctrl key mode");
        _controlKeyMode = YES;
        return NO;
      }
    } else {
      // was in ctrl key mode, got another key
      //debug(@"sending ctrl key");
      if (cmd_char < 0x60 && cmd_char > 0x40) {
        // Uppercase
        cmd_char -= 0x40;      
      } else if (cmd_char < 0x7B && cmd_char > 0x61) {
        // Lowercase
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

- (void)scrollToEnd
{
  NSRange aRange;
  aRange.location = 9999999; // horray for magic number
  aRange.length = 1;
  [self setSelectionRange:aRange];
  [self scrollToMakeCaretVisible:YES];
}

- (void)insertText:(NSString*)text
{
  // Insert at the end of the WebKit WebView
  [[[self _webView] webView] moveToEndOfDocument:self];

  _ignoreInsertText = YES;
  [[self _webView] insertText:text];
  _ignoreInsertText = NO;

  [self scrollToEnd];
}

@end
