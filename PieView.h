#import <Foundation/Foundation.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIImageView.h>

@interface PieView : UIImageView {
    CGRect visibleFrame, hiddenFrame;
    CGPoint location;
    BOOL _visible;
}
-(void)showAtPoint:(CGPoint)p;
-(void)hide;
-(void)hideSlow:(BOOL)slow;
@end
