//
//  Preferences.h
//  Terminal

#import <UIKit/UIKit.h>
#import <UIKit/UIFontChooser.h>
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UIPreferencesControlTableCell.h>
#import <UIKit/UIPreferencesTextTableCell.h>
#import <UIKit/UISwitchControl.h>
#import <UIKit/UINavigationController.h>

@class MobileTerminal;

//_______________________________________________________________________________

@interface PreferencesGroup : NSObject 
{
	UIPreferencesTableCell * title;
	NSMutableArray * cells;
	NSMutableArray * keys;
	float titleHeight;
	int tag;
}

+ (id) groupWithTitle: (NSString*) title icon: (UIImage*) icon;
- (id) initWithTitle: (NSString*) title icon: (UIImage*) icon;
- (void) addCell: (id) cell;
- (void) addSwitch: (NSString*) label;
- (void) addSwitch: (NSString*) label on: (BOOL) on;
- (void) addPageButton: (NSString*) label delegate: (id) delegate;
- (void) addValueField: (NSString*) label value:(NSString*)value;
- (void) addTextField: (NSString*) label;

- (int) rows;
- (BOOL) boolValueForRow: (int) row;
- (UIPreferencesTableCell*) row: (int) row;
- (NSString*) stringValueForRow: (int) row;

@property (readonly) float titleHeight;
@property (readonly) UIPreferencesTableCell * title;
@end

//_______________________________________________________________________________

@interface PreferencesGroups : NSObject 
{
	NSMutableArray * groups;
}

- (id) init;
- (void) addGroup: (PreferencesGroup*) group;
- (PreferencesGroup*) groupAtIndex: (int) index;
- (int) groups;

- (int) numberOfGroupsInPreferencesTable: (UIPreferencesTable*)table;
- (int) preferencesTable: (UIPreferencesTable*) table numberOfRowsInGroup: (int) group;
- (UIPreferencesTableCell*) preferencesTable: (UIPreferencesTable*)table cellForGroup: (int)group;
- (float) preferencesTable: (UIPreferencesTable*)table heightForRow: (int)row inGroup: (int)group withProposedHeight: (float)proposed;
- (UIPreferencesTableCell*) preferencesTable: (UIPreferencesTable*)table cellForRow: (int)row inGroup: (int)group;

@end

//_______________________________________________________________________________

@interface TestViewController : UIViewController
{
}

-(id) init;

@end

//_______________________________________________________________________________

@interface AboutViewController : UIViewController
{
}

-(id) init;

@end

//_______________________________________________________________________________

@interface PreferencesController : UIViewController 
{
	UINavigationController  * navController;
	AboutViewController			* aboutViewController;
	UINavigationBar					* navBar;
	UIPreferencesTable			*	table;
	UIFontChooser						* fontChooser;
	PreferencesGroups				* prefGroups;
	MobileTerminal					* application;
}

-(id) initWithApplication:(MobileTerminal*)app;

@end

