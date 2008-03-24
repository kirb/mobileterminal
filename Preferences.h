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
#import <UIKit/UIFontChooser.h>

@class MobileTerminal;

//_______________________________________________________________________________

@interface FontChooser : UIFontChooser {}
@end

//_______________________________________________________________________________

@interface PreferencesGroup : NSObject 
{
	UIPreferencesTableCell * title;
	NSMutableArray * cells;
	NSMutableArray * keys;
	float titleHeight;
	int tag;
}

+ (id) groupWithTitle:(NSString*) title icon:(UIImage*)icon;
- (id) initWithTitle:(NSString*) title icon:(UIImage*)icon;
- (void) addCell:(id)cell;
- (id) addSwitch:(NSString*)label;
- (id) addSwitch:(NSString*)label on:(BOOL)on;
- (id) addPageButton:(NSString*)label delegate:(id)delegate;
- (id) addPageButton:(NSString*)label value:(NSString*)value delegate:(id)delegate;
- (id) addValueField:(NSString*)label value:(NSString*)value;
- (id) addTextField:(NSString*)label;

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

@interface PreferencesController : UINavigationController 
{
	MobileTerminal	* application;
	
	UIView          * settingsView;
	UIView					* aboutView;
	UIView					* fontView;
	id								fontButton;
}

-(id) initWithApplication:(MobileTerminal*)app;

@end

