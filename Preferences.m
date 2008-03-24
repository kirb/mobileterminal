//
//  Preferences.m
//  Terminal

#import "Preferences.h"
#import "MobileTerminal.h"
#import "Constants.h"
#import "Log.h"

//_______________________________________________________________________________
//_______________________________________________________________________________

UIPreferencesTableCell * MakeTitleCell (NSString* title, UIImage* img) 
{
	UIPreferencesTableCell* cell = [[[UIPreferencesTableCell alloc] init] retain];
	[cell setTitle: title];
	if (img)  [cell setIcon: img];	
	return cell;
}

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
		title = MakeTitleCell (title_, icon);
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

- (void) addSwitch: (NSString*) label 
{
	[self addSwitch: label on: NO];
}

//_______________________________________________________________________________

- (void) addSwitch: (NSString*) label on: (BOOL) on 
{
	UIPreferencesControlTableCell* cell = [[UIPreferencesControlTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 48.0f)];
	[cell setTitle: label];
	[cell setShowSelection:NO];
	UISwitchControl * sw = [[UISwitchControl alloc] initWithFrame: CGRectMake(206.0f, 9.0f, 96.0f, 48.0f)];
	[sw setValue: on];
	[cell setControl:sw];	
	[cells addObject: cell];
}

//_______________________________________________________________________________

-(void) addPageButton: (NSString*) label delegate:(id)delegate
{
	UIPreferencesTextTableCell * cell = [[UIPreferencesTextTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 48.0f)];
	[cell setTitle: label];
	[cell setShowDisclosure:YES];
	[cell setDisclosureClickable: NO];
	[cell setDisclosureStyle: 2];
	[[cell textField] setEnabled:NO];
	[cells addObject: cell];
	
	[[cell textField] setTapDelegate:delegate];
	[cell setTapDelegate:delegate];
}

//_______________________________________________________________________________

-(void) addValueField: (NSString*) label value:(NSString*)value
{
	UIPreferencesTextTableCell * cell = [[UIPreferencesTextTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 48.0f)];
	[cell setTitle: label];
	[cell setValue: value];
	[[cell textField] setEnabled:NO];
	[[cell textField] setHorizontallyCenterText:YES];
	[cells addObject: cell];	
}

//_______________________________________________________________________________

-(void) addTextField: (NSString*) label
{
	UIPreferencesTextTableCell * cell = [[UIPreferencesTextTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 48.0f)];
	[cell setValue: label];
	[[cell textField] setHorizontallyCenterText:YES];
	[[cell textField] setEnabled:NO];
	[cells addObject: cell];	
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

@implementation TestViewController

//_______________________________________________________________________________
	
-(id) init
{
	self = [super init];
	[[self view] setBackgroundColor:[UIView colorWithRed:1.0f green:0.1f blue:0.1f alpha:1.0f]];
	[self _setNavigationTitle:@"Test"];
	return self;
}		

@end

//_______________________________________________________________________________
//_______________________________________________________________________________

@implementation AboutViewController

//_______________________________________________________________________________

-(id) init
{	
	self = [super init];
	[self _setNavigationTitle:@"About"];
	return self;
}

//_______________________________________________________________________________

-(id) view
{
	PreferencesGroups * aboutGroups = [[[PreferencesGroups alloc] init] retain];
	PreferencesGroup * group;
	
	group = [PreferencesGroup groupWithTitle:@"" icon:nil];
	[group addValueField:@"Version" value:@"1.0"];
	[aboutGroups addGroup:group];

	group = [PreferencesGroup groupWithTitle:@"Test" icon:nil];
	[group addPageButton:@"test page" delegate:self];
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
	
	return table;
}

//_______________________________________________________________________________

- (void) view: (UIView*) view handleTapWithCount: (int) count event: (id) event 
{	
	if ([[(UIPreferencesTextTableCell*)view title] isEqualToString:@"code.google.com/p/mobileterminal"])
	{
		[[MobileTerminal application] openURL:[NSURL URLWithString:@"http://code.google.com/p/mobileterminal/"]];	
	}
	else
	{
		UIView * v = [[UIView alloc] init];
		[v  setBackgroundColor:[UIView colorWithRed:0.1f green:0.1f blue:1.0f alpha:1.0f]];
		[[self navigationController] pushViewControllerWithView:v navigationTitle:@"Testasd"];
	}
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
	
	// ------------------------------------------------------------- pref groups
	
	prefGroups = [[[PreferencesGroups alloc] init] retain];
	PreferencesGroup * group = [PreferencesGroup groupWithTitle:@"Terminals" icon:nil];
	[group addSwitch:@"Multiple Terminals"];
	[prefGroups addGroup:group];
	
	group = [PreferencesGroup groupWithTitle:@"" icon:nil];
	[group addPageButton:@"About" delegate:self];
	[prefGroups addGroup:group];
	
	// ------------------------------------------------------------- pref table
	
	table = [[UIPreferencesTable alloc] initWithFrame: [[self view] bounds]];
	[table setDataSource:prefGroups];
	[table reloadData];
	[[self view] addSubview:table];

	// ------------------------------------------------------------- navigation controller

	[self _setNavigationTitle:@"Settings"];

	navController = [[[UINavigationController alloc] initWithRootViewController:self] retain];
	navBar = [navController navigationBar];
	[navBar setBarStyle:1];
	//[navBar showLeftButton:@"Done" withStyle: 5 rightButton:nil withStyle: 0];
	//[navBar setDelegate:self];
	//[navController setDelegate:self];
	
	return self;
}

//_______________________________________________________________________________

-(UIView *) navigationView
{
	return [navController view];
}

//_______________________________________________________________________________

- (void) navigationBar: (id)bar buttonClicked: (int)button 
{
	log(@"button %d", button);
	if (bar == navBar) 
	{
		switch (button)
		{
			case 1:
				[application togglePreferences];
				break;
		}
	}
}

//_______________________________________________________________________________

- (void) view: (UIView*) view handleTapWithCount: (int) count event: (id) event 
{
	if ([[(UIPreferencesTextTableCell*)view title] isEqualToString:@"About"])
	{
		[navController pushViewController:[[AboutViewController alloc] init]];
	}
}

- (void) hideAds
{
	/*
	CGRect fontChooserFrame = CGRectMake(0, navBarHeight, width, 200);
	fontChooser = [UIFontChooser sharedFontChooser];
	[fontChooser initWithFrame:fontChooserFrame];
	[fontChooser setDelegate:self]; 	
	[table addSubview:fontChooser];
	
	return self;*/
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


