// ShellKeyboard.m
//
// TODO: Should be able to cancel animations that have already started so they
// transition smoothly in the other direction
#import "ShellKeyboard.h"

#import <UIKit/CDStructures.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIAnimator.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIScroller.h>
#import <UIKit/UITransformAnimation.h>
#import <UIKit/UIView-Geometry.h>
#import "Common.h"

//
// Override settings of the default keyboard implementation
//

@interface UIKeyboardImpl : UIView
{

}
@end

@implementation UIKeyboardImpl (DisableFeatures)

- (BOOL)autoCapitalizationPreference
{
  return false;
}

- (BOOL)autoCorrectionPreference
{
  return false;
}

@end

//
// ShellKeyboard
//

@implementation ShellKeyboard

- (void) show:(ShellView*)shellView
{
  [shellView setBottomBufferHeight:(5.0f)];

  [shellView setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 245.0f)];
  [self setTransform:CGAffineTransformMake(1,0,0,1,0,0)];
  [self setFrame:CGRectMake(0.0f, 480.0, 320.0f, 480.0f)];

  struct CGAffineTransform trans = CGAffineTransformMakeTranslation(0, -240);
  UITransformAnimation *translate =
    [[UITransformAnimation alloc] initWithTarget: self];
  [translate setStartTransform: CGAffineTransformMake(1,0,0,1,0,0)];
  [translate setEndTransform: trans];
  [[[UIAnimator alloc] init] addAnimation:translate withDuration:.5 start:YES];

  _hidden = NO;
}

- (void) hide:(ShellView*)shellView
{
  [shellView setBottomBufferHeight:(70.0f)];

  struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
  rect.origin.x = rect.origin.y = 0.0f;
  [shellView setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
  [self setTransform:CGAffineTransformMake(1,0,0,1,0,0)];
  [self setFrame:CGRectMake(0.0f, 240.0, 320.0f, 480.0f)];

  struct CGAffineTransform trans = CGAffineTransformMakeTranslation(0, 240);
  UITransformAnimation *translate =
    [[UITransformAnimation alloc] initWithTarget: self];
  [translate setStartTransform: CGAffineTransformMake(1,0,0,1,0,0)];
  [translate setEndTransform: trans];
  [[[UIAnimator alloc] init] addAnimation:translate withDuration:.5 start:YES];
  _hidden = YES;
}

- (void) toggle:(ShellView*)shellView
{
  if (_hidden) {
    [self show:shellView];
  } else{
    [self hide:shellView];
  }
}

@end
