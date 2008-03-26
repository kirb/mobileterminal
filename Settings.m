//
//  Settings.m
//  Terminal

#import "Settings.h"
#import "Constants.h"
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
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary * d = [NSMutableDictionary dictionaryWithCapacity:10];
	[d setObject:[NSNumber numberWithBool:YES] forKey:@"multipleTerminals"];
	[defaults registerDefaults:d];
}

//_______________________________________________________________________________

-(void) readUserDefaults
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];

	multipleTerminals = [defaults boolForKey:@"multipleTerminals"];
}

//_______________________________________________________________________________

-(void) writeUserDefaults
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	
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
