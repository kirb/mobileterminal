//
//  Settings.m
//  Terminal

#import "Settings.h"
#import "Constants.h"
#import "MobileTerminal.h"
#import <Foundation/NSUserDefaults.h>

//_______________________________________________________________________________
//_______________________________________________________________________________

@implementation TerminalConfig

//_______________________________________________________________________________

- (id)init
{
  self = [super init];
	
  width = 45;
  height = 17;
	fontSize = 12;
	fontWidth = 0.6f;
  font = @"CourierNewBold";
  args = nil;
	
  return self;
}

//_______________________________________________________________________________

- (NSString*)fontDescription
{
	return [NSString stringWithFormat:@"%@ %d", font, fontSize];
}

//_______________________________________________________________________________

- (NSString*) font { return font; }
- (void) setFont: (NSString*)str
{
	if (font != str)
	{
		[font release];
		font = [str copy];
	}
}

//_______________________________________________________________________________

- (NSString*) args { return args; }
- (void) setArgs: (NSString*)str
{
	if (args != str)
	{
		[args release];
		args = [str copy];
	}
}

//_______________________________________________________________________________

@synthesize width;
@synthesize height;
@synthesize fontSize;
@synthesize fontWidth;
@dynamic font;
@dynamic args;

@end

//_______________________________________________________________________________
//_______________________________________________________________________________


@implementation Settings

//_______________________________________________________________________________

+ (Settings*) sharedInstance
{
  static Settings * instance = nil;
  if (instance == nil) {
    instance = [[Settings alloc] init];
  }
  return instance;
}

//_______________________________________________________________________________

- (id)init
{
  self = [super init];

	terminalConfigs = [NSArray arrayWithObjects:
										 [[TerminalConfig alloc] init],
										 [[TerminalConfig alloc] init],
										 [[TerminalConfig alloc] init],
										 [[TerminalConfig alloc] init], nil];
	
	gestureViewColor = colorWithRGBA(1.0f, 1.0f, 1.0f, 0.005f);
	multipleTerminals = YES;
	
  return self;
}

//_______________________________________________________________________________

@synthesize gestureViewColor;
@synthesize multipleTerminals;

//_______________________________________________________________________________

-(void) registerDefaults
{
	int i;
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary * d = [NSMutableDictionary dictionaryWithCapacity:2];
	[d setObject:[NSNumber numberWithBool:YES] forKey:@"multipleTerminals"];
	NSMutableArray * tcs = [NSMutableArray arrayWithCapacity:MAXTERMINALS];
	for (i = 0; i < MAXTERMINALS; i++)
	{
		NSMutableDictionary * tc = [NSMutableDictionary dictionaryWithCapacity:10];		
		[tc setObject:[NSNumber numberWithInt:45] forKey:@"width"];
		[tc setObject:[NSNumber numberWithInt:17] forKey:@"height"];
		[tc setObject:[NSNumber numberWithInt:12] forKey:@"fontSize"];
		[tc setObject:[NSNumber numberWithFloat:0.6f] forKey:@"fontWidth"];
		[tc setObject:@"CourierNewBold" forKey:@"font"];
		[tc setObject:@"" forKey:@"args"];
		[tcs addObject:tc];
	}
	[d setObject:tcs forKey:@"terminals"];
	[defaults registerDefaults:d];
}

//_______________________________________________________________________________

-(void) readUserDefaults
{
	int i;
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSArray * tcs = [defaults arrayForKey:@"terminals"];
	for (i = 0; i < MAXTERMINALS; i++)
	{
		TerminalConfig * config = [terminalConfigs objectAtIndex:i];
		NSDictionary * tc = [tcs objectAtIndex:i];
		config.width = [[tc objectForKey:@"width"] intValue];
		config.height = [[tc objectForKey:@"height"] intValue];
		config.fontSize = [[tc objectForKey:@"fontSize"] intValue];
		config.fontWidth = [[tc objectForKey:@"fontWidth"] floatValue];
		config.font = [tc objectForKey:@"font"];
		config.args = [tc objectForKey:@"args"];
	}

	multipleTerminals = [defaults boolForKey:@"multipleTerminals"];
}

//_______________________________________________________________________________

-(void) writeUserDefaults
{
	int i;
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray * tcs = [NSMutableArray arrayWithCapacity:MAXTERMINALS];
	for (i = 0; i < MAXTERMINALS; i++)
	{
		TerminalConfig * config = [terminalConfigs objectAtIndex:i];
		NSMutableDictionary * tc = [NSMutableDictionary dictionaryWithCapacity:10];		
		[tc setObject:[NSNumber numberWithInt:config.width] forKey:@"width"];
		[tc setObject:[NSNumber numberWithInt:config.height] forKey:@"height"];
		[tc setObject:[NSNumber numberWithInt:config.fontSize] forKey:@"fontSize"];
		[tc setObject:[NSNumber numberWithFloat:config.fontWidth] forKey:@"fontWidth"];
		[tc setObject:config.font forKey:@"font"];
		[tc setObject:config.args ? config.args : @"" forKey:@"args"];
		[tcs addObject:tc];
	}
	[defaults setObject:tcs forKey:@"terminals"];
	[defaults setBool:multipleTerminals forKey:@"multipleTerminals"];
	[defaults synchronize];
}

//_______________________________________________________________________________

-(NSArray *) terminalConfigs { return terminalConfigs; }

//_______________________________________________________________________________

- (NSString*) arguments { return arguments; }
- (void) setArguments: (NSString*)str
{
	if (arguments != str)
	{
		[arguments release];
		arguments = [str copy];
	}
}

@end
