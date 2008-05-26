//
//  Tools.m
//  Terminal

#import "Tools.h"
#import "Log.h"

//_______________________________________________________________________________
//_______________________________________________________________________________

BOOL writeImageToPNG (CGImageRef image, NSString * filePath) 
{
  if (image == nil) { log(@"[ERROR] no image"); return NO; }
  CFURLRef cfurl = CFURLCreateFromFileSystemRepresentation (NULL, (const UInt8 *)[filePath cString], [filePath length], 0);
  CGImageDestinationRef imageDest = CGImageDestinationCreateWithURL(cfurl, (CFStringRef)@"public.png", 1, nil);
  if (imageDest==nil) { log(@"[ERROR] no image destination"); return NO; }  
  CGImageDestinationAddImage(imageDest, image, nil);
  if (!CGImageDestinationFinalize(imageDest)) { log(@"[ERROR] unable to write image"); return NO; }
  return YES;
}

//_______________________________________________________________________________

@implementation NSString (MobileTerminalExtensions)

- (int) indexOfSubstring:(NSString*)substring
{
  NSRange range = [self rangeOfString:substring];
  if (range.location == NSNotFound) return -1;
  return range.location;
}

- (BOOL) hasSubstring:(NSString*)substring
{
  return [self indexOfSubstring:substring] >= 0;
}

@end

//_______________________________________________________________________________

@implementation NSMutableString (MobileTerminalExtensions)

- (void) removeSubstring:(NSString*)substring
{
  [self replaceOccurrencesOfString:substring withString:@"" options:0 range:NSMakeRange(0, [self length])];
}

@end
