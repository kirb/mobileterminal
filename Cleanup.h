// Cleanup.h
// 
// Cleanup of UIKit headers
#import <UIKit/UIKit.h>

@interface UITextView (CleanWarnings)
-(UIView*) webView;
@end

@interface UIView (CleanWarnings)
- (void) moveToEndOfDocument:(id)inVIew;
- (void) insertText: (id)ourText;
@end

