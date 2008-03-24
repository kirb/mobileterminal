//
//  Constants.m
//  Terminal

#import "Constants.h"

//_______________________________________________________________________________
//_______________________________________________________________________________

@implementation UIView (Color)

+ (CGColorRef)colorWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
{
	float rgba[4] = {red, green, blue, alpha};
	CGColorSpaceRef rgbColorSpace = (CGColorSpaceRef)[(id)CGColorSpaceCreateDeviceRGB() autorelease];
	CGColorRef color = (CGColorRef)[(id)CGColorCreate(rgbColorSpace, rgba) autorelease];
	return color;
}

@end