//
//  Preferences.m
//  Terminal

#import "Preferences.h"
#import "MobileTerminal.h"
#import "Settings.h"
#import "Constants.h"
#import "Log.h"

#import <UIKit/UISimpleTableCell.h> 

//_______________________________________________________________________________
//_______________________________________________________________________________

@implementation UIPickerTable (PickerTableExtensions)

//_______________________________________________________________________________

-(void) _selectRow:(int)row byExtendingSelection:(BOOL)extend withFade:(BOOL)fade scrollingToVisible:(BOOL)scroll withSelectionNotifications:(BOOL)notify 
{
	if (row >= 0)
	{
		[[[self selectedTableCell] iconImageView] setFrame:CGRectMake(0,0,0,0)];
		[super _selectRow:row byExtendingSelection:extend withFade:fade scrollingToVisible:scroll withSelectionNotifications:notify];		
		[[[self selectedTableCell] iconImageView] setFrame:CGRectMake(0,0,0,0)];
	}
}

@end

//_______________________________________________________________________________
//_______________________________________________________________________________

@implementation UIPickerView (PickerViewExtensions)

-(float) tableRowHeight { return 22.0f; }
-(id) delegate { return _delegate; }

//_______________________________________________________________________________

-(void) _sendSelectionChanged
{
	int c, r;
	
	for (c = 0; c < [self numberOfColumns]; c++)
	{
		UIPickerTable * table = [self tableForColumn:c];
		for (r = 0; r < [table numberOfRows]; r++)
		{
			[[[table cellAtRow:r column:0] iconImageView] setFrame:CGRectMake(0,0,0,0)]; 
		}
	}
	
	if ([self delegate])
	{
		if ([[self delegate] respondsToSelector:@selector(fontSelectionDidChange)])
		{
			[[self delegate] performSelector:@selector(fontSelectionDidChange)];
		}
	}
}

@end

//_______________________________________________________________________________
//_______________________________________________________________________________

@implementation FontChooser

//_______________________________________________________________________________

- (id) initWithFrame: (struct CGRect)rect
{
	self = [super initWithFrame:rect];
	[self createFontList];
	
	fontPicker = [[UIPickerView alloc] initWithFrame: [self bounds]];
	[fontPicker setDelegate: self];
	
	pickerTable = [fontPicker createTableWithFrame: [self bounds]];
	[pickerTable setAllowsMultipleSelection: FALSE];
	
	UITableColumn * fontColumn = [[UITableColumn alloc] initWithTitle: @"Font" identifier:@"font" width: rect.size.width];
	UITableColumn * sizeColumn = [[UITableColumn alloc] initWithTitle: @"Size" identifier:@"size" width: rect.size.width];
	
	[fontPicker columnForTable: fontColumn];
	[fontPicker columnForTable: sizeColumn];
	
	[self addSubview:fontPicker];

	return self;
}

//_______________________________________________________________________________

- (void) setDelegate:(id) aDelegate
{
	delegate = aDelegate;
}

//_______________________________________________________________________________

-(id) delegate
{
	return delegate;
}

//_______________________________________________________________________________

- (void) createFontList
{
	NSFileManager * fm = [NSFileManager defaultManager];

	fontNames = [[fm directoryContentsAtPath:@"/var/Fonts" matchingExtension:@"ttf" options:0 keepExtension:NO] retain];

	fontSizes = [	[NSArray arrayWithObjects: 
								[NSNumber numberWithInt: 7], [NSNumber numberWithInt: 8], 
								[NSNumber numberWithInt: 9], [NSNumber numberWithInt:10], 
								[NSNumber numberWithInt:11], [NSNumber numberWithInt:12], 
								[NSNumber numberWithInt:13], [NSNumber numberWithInt:14],
								[NSNumber numberWithInt:15], [NSNumber numberWithInt:16],
								[NSNumber numberWithInt:17], [NSNumber numberWithInt:18],
								[NSNumber numberWithInt:19], [NSNumber numberWithInt:20], nil] retain];
}

//_______________________________________________________________________________

- (int) numberOfColumnsInPickerView:(UIPickerView*)picker
{
	return 2;
}

//_______________________________________________________________________________

- (int) pickerView:(UIPickerView*)picker numberOfRowsInColumn:(int)col
{
	return (col == 0) ? [fontNames count] : [fontSizes count];
}

//_______________________________________________________________________________
- (UIPickerTableCell*) pickerView:(UIPickerView*)picker tableCellForRow:(int)row inColumn:(int)col
{
	UIPickerTableCell * cell = [[UIPickerTableCell alloc] init];
	
	if (col == 0)
	{
		[cell setTitle:[fontNames objectAtIndex:row]];
	}
	else
	{
		[cell setTitle:[[fontSizes objectAtIndex: row] stringValue]];
	}
	
	
	[[cell titleTextLabel] setFont:[UISimpleTableCell defaultFont]];
	[cell setSelectionStyle:0];
	[cell setShowSelection:YES];
	[[cell iconImageView] setFrame:CGRectMake(0,0,0,0)]; 
	
	return cell;
}

//_______________________________________________________________________________

-(float)pickerView:(UIPickerView*)picker tableWidthForColumn: (int)col
{
	if (col == 0) return [self bounds].size.width-80.0f;
	return 80.0f;
}

//_______________________________________________________________________________

- (int) rowForSize: (int)fontSize
{
	int i;
	for (i = 0; i < [fontSizes count]; i++)
	{
		if ([[fontSizes objectAtIndex:i] intValue] == fontSize)
		{
			return i;
		}
	}	
	return 0;
}

//_______________________________________________________________________________

- (int) rowForFont: (NSString*)fontName
{
	int i;
	for (i = 0; i < [fontNames count]; i++)
	{
		if ([[fontNames objectAtIndex:i] isEqualToString:fontName])
		{
			return i;
		}
	}	
	return 0;
}

//_______________________________________________________________________________

- (void) selectFont: (NSString*)fontName
{
	selectedFont = fontName;
	int row = [self rowForFont:fontName];
	[fontPicker selectRow:row inColumn:0 animated:YES];
	[[fontPicker tableForColumn:0] _selectRow:row byExtendingSelection:NO withFade:NO scrollingToVisible:YES withSelectionNotifications:YES];		
}

//_______________________________________________________________________________

- (void) selectSize: (int)fontSize
{
	selectedSize = fontSize;
	int row = [self rowForSize:fontSize];
	[fontPicker selectRow:row inColumn:1 animated:YES];
	[[fontPicker tableForColumn:1] _selectRow:row byExtendingSelection:NO withFade:NO scrollingToVisible:YES withSelectionNotifications:YES];		
}

//_______________________________________________________________________________

- (NSString*) selectedFont
{
	int row = [fontPicker selectedRowForColumn:0];
	return [fontNames objectAtIndex:row];
}

//_______________________________________________________________________________

- (int) selectedSize
{
	int row = [fontPicker selectedRowForColumn:1];
	log(@"row %d %d", row, [[fontSizes objectAtIndex:row] intValue]);
	return [[fontSizes objectAtIndex:row] intValue];
}

//_______________________________________________________________________________

-(void) fontSelectionDidChange
{
	log(@"font selection changed");
	if ([self delegate] && [[self delegate] respondsToSelector:@selector(selectedFont:size:)])
		[[self delegate] selectedFont:[self selectedFont] size:[self selectedSize]];
}

@end

//_______________________________________________________________________________
//_______________________________________________________________________________

@implementation PreferencesGroup

@synthesize title;
@synthesize titleHeight;

//_______________________________________________________________________________

+ (id) groupWithTitle: (NSString*) title icon: (UIImage*) icon 
{
	return [[PreferencesGroup alloc] initWithTitle: title icon: icon];
}

//_______________________________________________________________________________

- (id) initWithTitle: (NSString*) title_ icon: (UIImage*) icon 
{
	if ((self = [super init])) 
	{
		title = [[[UIPreferencesTableCell alloc] init] retain];
		[title setTitle: title_];
		if (icon)  [title setIcon: icon];			
		titleHeight = ([title_ length] > 0) ? 40.0f : 14.0f;		
		cells = [[NSMutableArray arrayWithCapacity:1] retain];
	}
	
	return self;
}

//_______________________________________________________________________________

- (void) addCell: (id) cell 
{
	[cells addObject: cell];
}

//_______________________________________________________________________________

- (id) addSwitch: (NSString*) label 
{
	return [self addSwitch: label on: NO];
}

//_______________________________________________________________________________

- (id) addSwitch: (NSString*) label on: (BOOL) on 
{
	UIPreferencesControlTableCell* cell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 48.0f)];
	[cell setTitle: label];
	[cell setShowSelection:NO];
	UISwitchControl * sw = [[UISwitchControl alloc] initWithFrame: CGRectMake(206.0f, 9.0f, 96.0f, 48.0f)];
	[sw setValue: on];
	[cell setControl:sw];	
	[cells addObject: cell];
	return cell;
}

//_______________________________________________________________________________

-(id) addPageButton: (NSString*) label delegate:(id)delegate
{
	return [self addPageButton:label value:nil delegate:delegate];
}

//_______________________________________________________________________________

-(id) addPageButton: (NSString*) label value:(NSString*)value delegate:(id)delegate
{
	UIPreferencesTextTableCell * cell = [[UIPreferencesTextTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 48.0f)];
	[cell setTitle: label];
	[cell setValue: value];
	[cell setShowDisclosure:YES];
	[cell setDisclosureClickable: NO];
	[cell setDisclosureStyle: 2];
	[[cell textField] setEnabled:NO];
	[cells addObject: cell];
	
	[[cell textField] setTapDelegate:delegate];
	[cell setTapDelegate:delegate];
	
	return cell;
}

//_______________________________________________________________________________

-(id) addValueField: (NSString*) label value:(NSString*)value
{
	UIPreferencesTextTableCell * cell = [[UIPreferencesTextTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 48.0f)];
	[cell setTitle: label];
	[cell setValue: value];
	[[cell textField] setEnabled:NO];
	[[cell textField] setHorizontallyCenterText:YES];
	[cells addObject: cell];	
	return cell;
}

//_______________________________________________________________________________

-(id) addTextField: (NSString*) label
{
	UIPreferencesTextTableCell * cell = [[UIPreferencesTextTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 48.0f)];
	[cell setValue: label];
	[[cell textField] setHorizontallyCenterText:YES];
	[[cell textField] setEnabled:NO];
	[cells addObject: cell];	
	return cell;
}

//_______________________________________________________________________________

- (int) rows 
{
	return [cells count];
}

//_______________________________________________________________________________

- (UIPreferencesTableCell*) row: (int) row 
{
	if (row == -1) 
	{
		return nil;
	} 
	else 
	{
		return [cells objectAtIndex:row];
	}
}

//_______________________________________________________________________________

- (NSString*) stringValueForRow: (int) row 
{
	UIPreferencesTextTableCell* cell = (UIPreferencesTextTableCell*)[self row: row];
	return [[cell textField] text];
}

//_______________________________________________________________________________

- (BOOL) boolValueForRow: (int) row 
{
	UIPreferencesControlTableCell * cell = (UIPreferencesControlTableCell*)[self row: row];
	UISwitchControl * sw = [cell control];
	return [sw value] == 1.0f;
}

@end

//_______________________________________________________________________________
//_______________________________________________________________________________

@implementation PreferencesController

//_______________________________________________________________________________

-(id) initWithApplication: (MobileTerminal*) app
{
	self = [super init];
	application = app;
	
	// ------------------------------------------------------------- navigation controller

	[self pushViewControllerWithView:[self settingsView] navigationTitle:@"Settings"];
	[[self navigationBar] setBarStyle:1];
	[[self navigationBar] showLeftButton:@"Done" withStyle: 5 rightButton:nil withStyle: 0];
	
	return self;
}

//_______________________________________________________________________________

-(id) settingsView
{
	if (!settingsView)
	{
		// ------------------------------------------------------------- pref groups

		PreferencesGroups * prefGroups = [[PreferencesGroups alloc] init];
		PreferencesGroup * group = [PreferencesGroup groupWithTitle:@"Terminals" icon:nil];
		[group addSwitch:@"Multiple Terminals"];
		fontButton = [group addPageButton:@"Font" value:[[Settings sharedInstance] fontDescription] delegate:self];
		[prefGroups addGroup:group];

		group = [PreferencesGroup groupWithTitle:@"" icon:nil];
		[group addPageButton:@"About" delegate:self];
		[prefGroups addGroup:group];

		// ------------------------------------------------------------- pref table

		UIPreferencesTable * table = [[UIPreferencesTable alloc] initWithFrame: [[self view] bounds]];
		[table setDataSource:prefGroups];
		[table reloadData];
		settingsView = table;
	}
	return settingsView;	
}

//_______________________________________________________________________________

- (void) navigationBar: (id)bar buttonClicked: (int)button 
{
	switch (button)
	{
		case 1:
			[application togglePreferences];
			break;
	}
}

//_______________________________________________________________________________

-(id) aboutView
{
	if (!aboutView)
	{
		PreferencesGroups * aboutGroups = [[[PreferencesGroups alloc] init] retain];
		PreferencesGroup * group;

		group = [PreferencesGroup groupWithTitle:@"MobileTerminal" icon:nil];
		[group addValueField:@"Version" value:@"1.0"];
		[aboutGroups addGroup:group];

		group = [PreferencesGroup groupWithTitle:@"Homepage" icon:nil];
		[group addPageButton:@"code.google.com/p/mobileterminal" delegate:self];
		[aboutGroups addGroup:group];

		group = [PreferencesGroup groupWithTitle:@"Contributors" icon:nil];
		[group addValueField:@"" value:@"allen.porter"];
		[group addValueField:@"" value:@"craigcbrunner"];
		[group addValueField:@"" value:@"vaumnou"]; 
		[group addValueField:@"" value:@"andrebragareis"];
		[group addValueField:@"" value:@"aaron.krill"];
		[group addValueField:@"" value:@"kai.cherry"];
		[group addValueField:@"" value:@"elliot.kroo"];
		[group addValueField:@"" value:@"validus"];
		[group addValueField:@"" value:@"DylanRoss"];
		[group addValueField:@"" value:@"lednerk"];
		[group addValueField:@"" value:@"tsangk"];
		[group addValueField:@"" value:@"joseph.jameson"];
		[group addValueField:@"" value:@"gabe.schine"];
		[group addValueField:@"" value:@"syngrease"];
		[group addValueField:@"" value:@"maball"];
		[group addValueField:@"" value:@"lennart"];
		[group addValueField:@"" value:@"monsterkodi"];	
		[aboutGroups addGroup:group];

		CGRect viewFrame = [[super view] bounds];
		UIPreferencesTable * table = [[UIPreferencesTable alloc] initWithFrame:viewFrame];
		[table setDataSource:aboutGroups];
		[table reloadData];

		aboutView = table;
	}
	return aboutView;
}

//_______________________________________________________________________________

-(id) fontView
{
	if (!fontView)
	{
		FontChooser * fontChooser = [[FontChooser alloc] initWithFrame:[[super view] bounds]];
		[fontChooser setDelegate:self]; 
		fontView = fontChooser;
	}
	
	return fontView;
}

//_______________________________________________________________________________

-(void)selectedFont:(id)font size:(int)size
{
	[[Settings sharedInstance] setFont:font];
	[[Settings sharedInstance] setFontSize:size];
}

//_______________________________________________________________________________

- (void) view: (UIView*) view handleTapWithCount: (int) count event: (id) event 
{
	NSString * title = [(UIPreferencesTextTableCell*)view title];
	if ([title isEqualToString:@"About"])
	{
		[self pushViewControllerWithView:[self aboutView] navigationTitle:@"About"];
	}
	else if ([title isEqualToString:@"code.google.com/p/mobileterminal"])
	{
		[[MobileTerminal application] openURL:[NSURL URLWithString:@"http://code.google.com/p/mobileterminal/"]];	
	}
	else if ([title isEqualToString:@"Font"])
	{
		[self pushViewControllerWithView:[self fontView] navigationTitle:@"Font"];
	}
}

//_______________________________________________________________________________

-(void) popViewController
{
	if ([[self topViewController] view] == fontView)
	{
		[fontButton setValue:[[Settings sharedInstance] fontDescription]];
		[[application textView] resetFont];
	}
	[super popViewController];
}

//_______________________________________________________________________________

-(void)_didFinishPoppingViewController
{
	[super _didFinishPoppingViewController];
	
	if ([[self topViewController] view] == settingsView)
	{
		[[self navigationBar] showLeftButton:@"Done" withStyle: 5 rightButton:nil withStyle: 0];
	}	
}

//_______________________________________________________________________________

-(void)_didFinishPushingViewController
{
	[super _didFinishPushingViewController];
	
	if ([[self topViewController] view] == fontView)
	{
		[fontView selectFont:[[Settings sharedInstance] font]];
		[fontView selectSize:[[Settings sharedInstance] fontSize]];
	}	
}

@end

//_______________________________________________________________________________
//_______________________________________________________________________________

@implementation PreferencesGroups

//_______________________________________________________________________________

- (id) init 
{
	if ((self = [super init])) 
	{
		groups = [[NSMutableArray arrayWithCapacity:1] retain];
	}
	
	return self;
}

//_______________________________________________________________________________

- (void) addGroup: (PreferencesGroup*) group 
{
	[groups addObject: group];
}

//_______________________________________________________________________________

- (PreferencesGroup*) groupAtIndex: (int) index 
{
	return [groups objectAtIndex: index];
}

//_______________________________________________________________________________

- (int) groups 
{
	return [groups count];
}

//_______________________________________________________________________________

- (int) numberOfGroupsInPreferencesTable: (UIPreferencesTable*)table 
{
	return [groups count];
}

//_______________________________________________________________________________

- (int) preferencesTable: (UIPreferencesTable*) table numberOfRowsInGroup: (int) group 
{
	return [[groups objectAtIndex: group] rows];
}

//_______________________________________________________________________________

- (UIPreferencesTableCell*) preferencesTable: (UIPreferencesTable*)table cellForGroup: (int)group  
{
	return [[groups objectAtIndex: group] title];
} 

//_______________________________________________________________________________

- (float) preferencesTable: (UIPreferencesTable*)table heightForRow: (int)row inGroup: (int)group withProposedHeight: (float)proposed  
{
	if (row == -1) 
	{
		return [[groups objectAtIndex: group] titleHeight];
	} 
	else 
	{
		return proposed;
	}
}

//_______________________________________________________________________________

- (UIPreferencesTableCell*) preferencesTable: (UIPreferencesTable*)table cellForRow: (int)row inGroup: (int)group 
{
	return [[groups objectAtIndex: group] row: row];
}

@end


