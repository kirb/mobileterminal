#import "MyController.h"
#import "TermApplication.h"
#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>


@implementation MyController
- (IBAction)EnterKey:(id)sender
{
	const unichar myCharacters[] = {13};
	NSString *entString = [NSString stringWithCharacters: myCharacters
						  length: sizeof myCharacters / sizeof *myCharacters];
	
	[self writeTask: [entString dataUsingEncoding: NSUTF8StringEncoding]];
}
- (IBAction)CrtlKey:(id)sender
{
}
- (IBAction)EscKey:(id)sender
{
	const unichar myCharacters[] = {0x00, 0x1B};
	NSString *escString = [NSString stringWithCharacters: myCharacters
						  length: sizeof myCharacters / sizeof *myCharacters];
	
	[self writeTask: [escString dataUsingEncoding: NSUTF8StringEncoding]];
}
- (int)runBash
{
	 taskRunning = 0;
	 if(!taskRunning)
	 {
		
		SHELL = [[PTYTask alloc] init];
		[SHELL setDelegate:self];
		[SHELL retain];
		taskRunning = 0;
		//NSMutableArray *argumentList = [NSMutableArray arrayWithArray:[[inputBox stringValue] componentsSeparatedByString:@" "]];
		NSString *path = @"/usr/bin/ls";
		//[argumentList removeObjectAtIndex:0];
		NSLog(@"Trying to run: %@", path);
		[SHELL launchWithPath:path
			   arguments:nil
			   environment:[NSDictionary dictionary]
			   width:120
			   height:200];
		taskRunning = 1;
		
		[self writeTask:[@"ls -lax" dataUsingEncoding: NSUTF8StringEncoding]];
		[self EnterKey:nil];
	}
	else
	{
		[self writeTask:[[inputBox stringValue] dataUsingEncoding: NSUTF8StringEncoding]];
		[self EnterKey:nil];
	}

}

- (void)awakeFromNib
{
	SHELL = [[PTYTask alloc] init];
	[SHELL setDelegate:self];
	[SHELL retain];
	taskRunning = 0;
}

- (void)writeTask:(NSData *)data
{
	if(taskRunning)
	{
		[SHELL writeTask: data];
	}
}

- (void) dealloc
{
	[SHELL release];
	[super dealloc];
}
//PTYTask Delegats
- (void)readTask:(char *)buf length:(int)length
{
	NSLog(@"Anything here?");
	if (buf == NULL || !taskRunning)
        return;
	else
	{
		NSString* taskText = [NSString stringWithFormat:@"%s", buf];
		NSLog(@"taskText= %@", taskText);
		[[TermApplication getOutputBox] setText: taskText];
	}
	return;
	
}
- (void)brokenPipe
{
	NSLog(@"Hmmm broken pipe, Guess it is time to end this thread ");
	taskRunning = 0;
}
@end
