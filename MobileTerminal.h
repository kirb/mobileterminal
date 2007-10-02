// MobileTermina.h
#import <UIKit/UIKit.h>
#import <GraphicsServices/GraphicsServices.h>

@class PTYTextView;
@class ShellKeyboard;
@class SubProcess;
@class VT100Screen;
@class VT100Terminal;
@class GestureView;
@class PieView;

@interface MobileTerminal : UIApplication
// TODO?
//<KeyboardInputProtocol, InputDelegateProtocol>
{
  UIWindow* window;
  UIView* mainView;
  PTYTextView* textView;
  UIScroller* textScroller;
  ShellKeyboard* keyboardView;
  GestureView* gestureView;
  PieView* pieView;

  SubProcess* process;
  VT100Screen* screen;
  VT100Terminal* terminal;

  BOOL controlKeyMode;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)applicationSuspend:(GSEvent *)event;
- (void)applicationResume:(GSEvent *)event;

- (void)handleStreamOutput:(const char*)c length:(unsigned int)len;
- (void)handleKeyPress:(unichar)c;

@end
