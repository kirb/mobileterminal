#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>


@interface TermApplication : UIApplication {
    UIImageAndTextTableCell *pbCell;
    UITableCell *buttonCell;
}

@end