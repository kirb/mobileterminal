#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SubProcess, PieView;

@interface GestureView : UIView {
    SubProcess *_shellProcess;
    PieView *_pie;
    BOOL _isGesture;
}

- (id)initWithProcess:(SubProcess *)aProcess
                Frame:(CGRect)rect
                  Pie:(PieView *)pie;

@end
