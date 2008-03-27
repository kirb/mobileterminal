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
#import <UIKit/UIPickerView.h>
#import <UIKit/UIPickerTable.h>
#import <UIKit/UIPickerTableCell.h>

@class MobileTerminal;
@class TerminalConfig;

//_______________________________________________________________________________

@interface UIPickerTable (PickerTableExtensions)
@end

@interface UIPickerView (PickerViewExtensions)
@end

//_______________________________________________________________________________

@interface FontChooser : UIView
{
	id delegate;
	
	NSArray * fontNames;
	
	UIPickerView * fontPicker;
	UIPickerTable * pickerTable;
	
	NSString * selectedFont;
}

- (id) initWithFrame: (struct CGRect)rect;
- (void) selectFont: (NSString*)font;
- (void) createFontList;
- (void) setDelegate:(id)delegate;

@end

//_______________________________________________________________________________

@interface FontView : UIPreferencesTable
{
	FontChooser * fontChooser;
	UISliderControl * sizeSlider;
	UISliderControl * widthSlider;
}

-(FontChooser*) fontChooser;
-(id) initWithFrame:(CGRect)frame;
-(void) selectFont:(NSString*)font size:(int)size width:(float)width;
-(void) sizeSelected:(UISliderControl*)control;
-(void) widthSelected:(UISliderControl*)control;

@end

//_______________________________________________________________________________

@interface TerminalView : UIPreferencesTable
{
	id							 fontButton;
	
	TerminalConfig * config;
	int							 terminalIndex;
}

-(void) fontChanged;
-(id) initWithFrame:(CGRect)frame;
-(void) setTerminalIndex:(int)terminal;

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
- (void) removeCell:(id)cell;
- (id) addSwitch:(NSString*)label;
- (id) addSwitch:(NSString*)label target:(id)target action:(SEL)action;
- (id) addSwitch:(NSString*)label on:(BOOL)on;
- (id) addSwitch:(NSString*)label on:(BOOL)on target:(id)target action:(SEL)action;
- (id) addIntValueSlider:(NSString*)label range:(NSRange)range target:(id)target action:(SEL)action;
- (id) addFloatValueSlider: (NSString*)label minValue:(float)minValue maxValue:(float)maxValue target:(id)target action:(SEL)action;
- (id) addPageButton:(NSString*)label;
- (id) addPageButton:(NSString*)label value:(NSString*)value;
- (id) addValueField:(NSString*)label value:(NSString*)value;
- (id) addTextField:(NSString*)label;

- (int) rows;
- (BOOL) boolValueForRow: (int) row;
- (UIPreferencesTableCell*) row: (int) row;
- (NSString*) stringValueForRow: (int) row;

@property (readwrite) float titleHeight;
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
	MobileTerminal			* application;
	
	UIPreferencesTable	* settingsView;
	UIView							* aboutView;
	FontView						* fontView;
	TerminalView				* terminalView;

	UIPreferencesTextTableCell * terminalButton1;
	UIPreferencesTextTableCell * terminalButton2;
	UIPreferencesTextTableCell * terminalButton3;
	UIPreferencesTextTableCell * terminalButton4;
	
	PreferencesGroup * terminalGroup;
	
	int               terminalIndex;
}

+(PreferencesController*) sharedInstance;
-(id) init;
-(void) initViewStack;
-(TerminalView*) terminalView;
-(UIPreferencesTable*) settingsView;

-(FontView*) fontView;
-(void)setFontSize:(int)size;
-(void)setFontWidth:(float)width;
-(void)setFont:(NSString*)font;

-(id) aboutView;

@end

