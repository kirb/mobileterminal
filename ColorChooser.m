/*
Copyright 2007 Julian Asamer

This file is part of Fractalicious.

    Fractalicious is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Fractalicious is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Fractalicious.  If not, see <http://www.gnu.org/licenses/>.
*/
#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIView.h>
#import <UIKit/UISliderControl.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UIValueButton.h>
#import <UIKit/UIPlacardButton.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIView-Geometry.h>
#import <GraphicsServices/GraphicsServices.h>
#import "Log.h"
#import "Vector.h"
#import "ColorChooser.h"
#import "math.h"

//_______________________________________________________________________________

RGBAColor RGBAColorMake (float r, float g, float b, float a)
{
	RGBAColor c;
	c.r = r; c.g = g; c.b = b; c.a = a;
	return c;
}

//_______________________________________________________________________________

RGBAColor RGBAColorMakeWithArray(NSArray * array)
{
	return RGBAColorMake([[array objectAtIndex:0] floatValue], 
											 [[array objectAtIndex:1] floatValue],
											 [[array objectAtIndex:2] floatValue],
											 [[array objectAtIndex:3] floatValue]);
}

//_______________________________________________________________________________

NSArray * RGBAColorToArray(RGBAColor c)
{
	return [NSArray arrayWithObjects:	[NSNumber numberWithFloat:c.r],
																		[NSNumber numberWithFloat:c.g],
																		[NSNumber numberWithFloat:c.b],
																		[NSNumber numberWithFloat:c.a],
																		nil];
}

//_______________________________________________________________________________

CGColorRef colorWithRGBA(float red, float green, float blue, float alpha)
{
	float rgba[4] = {red, green, blue, alpha};
	CGColorSpaceRef rgbColorSpace = (CGColorSpaceRef)[(id)CGColorSpaceCreateDeviceRGB() autorelease];
	CGColorRef color = (CGColorRef)[(id)CGColorCreate(rgbColorSpace, rgba) autorelease];
	return color;	
}

//_______________________________________________________________________________

CGColorRef CGColorWithRGBAColor(RGBAColor c)
{
	return colorWithRGBA(c.r, c.g, c.b, c.a);
}

//_______________________________________________________________________________

@implementation ColorChooser

-(id)init {
	RGBAColor cold = {1,1,1,1};
	return [self initWithColor: cold];
}

-(id)initWithColor: (RGBAColor)cp {
	[super initWithFrame: CGRectMake(0,0,320,480)];
	color = cp;
	brightness = [ColorUtils HSBFromRGB: cp].b;
	alpha = cp.a;
	
	UITextLabel *brightnessLabel = [[UITextLabel alloc] initWithFrame: CGRectMake(10,10,300,20)];
	[brightnessLabel setText: @"Brightness:"];
	[brightnessLabel setBackgroundColor: [ColorUtils colorWithRed:0 green:0 blue:0 alpha:0]];
	[brightnessLabel setColor: [ColorUtils colorWithRed:1 green:1 blue:1 alpha: 1]];
	[brightnessLabel setCentersHorizontally: YES];
	
	brightnessControl = [[UISliderControl alloc] initWithFrame: CGRectMake(10,25-5,300,25+15)];
	[brightnessControl setBackgroundColor: [ColorUtils colorWithRed:0 green:0 blue:0 alpha:0]];
	[brightnessControl setOpaque: NO];
	[brightnessControl setMaxValue: 1];
	[brightnessControl setMinValue: 0];
	[brightnessControl setValue: brightness];
	[brightnessControl addTarget:self action:@selector(brightnessSliderUp:) forEvents:(1<<6)];
	[brightnessControl addTarget:self action:@selector(brightnessSliderDragged:) forEvents:(1<<2)];
	
	UITextLabel *alphaLabel = [[UITextLabel alloc] initWithFrame: CGRectMake(10,50,300,20)];
	[alphaLabel setText: @"Alpha:"];
	[alphaLabel setBackgroundColor: [ColorUtils colorWithRed:0 green:0 blue:0 alpha:0]];
	[alphaLabel setColor: [ColorUtils colorWithRed:1 green:1 blue:1 alpha: 1]];
	[alphaLabel setCentersHorizontally: YES];
	
	alphaControl = [[UISliderControl alloc] initWithFrame: CGRectMake(10,65-5,300,25+15)];
	[alphaControl setBackgroundColor: [ColorUtils colorWithRed:0 green:0 blue:0 alpha:0]];
	[alphaControl setOpaque: NO];
	[alphaControl setMaxValue: 1];
	[alphaControl setMinValue: 0];
	[alphaControl setValue: alpha];
	[alphaControl addTarget:self action:@selector(alphaSliderUp:) forEvents:(1<<6)];
	[alphaControl addTarget:self action:@selector(alphaSliderDragged:) forEvents:(1<<2)];
		
	center = [[Point2D alloc] initWithx: 160 y: 240];
	[self convertColorToCoords];
	
	colors = [UIImage applicationImageNamed:@"color_c.png"];
	pip = [[ColorPipette alloc] initWithFrame: CGRectMake(position->x - 18,position->y - 64,40, 86) RGBAColor: color];
	[self addSubview: brightnessLabel];
	[self addSubview: brightnessControl];
	[self addSubview: alphaLabel];
	[self addSubview: alphaControl];
	[self addSubview: pip];
	
	return self;
}

-(void)convertCoordsToColor {
	FHSBColor c = {
		[[[center to: position] turnRight] angle]/(M_PI*2)+0.5, //damn that... quite hard to simplify
		[[center to: position] length]/120,
		brightness,
		alpha
	};
	color = [ColorUtils RGBFromHSB: c];
}
-(void)convertColorToCoords {
	FHSBColor hsb = [ColorUtils HSBFromRGB: color];
	[position release];
	position = [center add: 
		[[[[Vector2D alloc] initWithAngle: hsb.h*2*M_PI length: hsb.s * 120] autorelease] turnRight]
	];
	[position retain];
}

-(void) setColor:(RGBAColor) c
{
	color = c;
	brightness = [ColorUtils HSBFromRGB: color].b;
	alpha = color.a;	
	
	[brightnessControl setValue: brightness];
	[alphaControl setValue: alpha];
	[pip setBrightness: brightness];
	[pip setAlpha: alpha];
	
	[self convertColorToCoords];
	[pip setFrame: CGRectMake(position->x - 18,position->y - 64,40, 86)];
	[pip setColor: color];
	[self setNeedsDisplay];
}

-(RGBAColor) color {
	return color;
}

-(void) drawRect:(struct CGRect)rect {
	CGContextRef context = UICurrentContext();
	CGContextClearRect(context, CGRectMake(0,0,320,320));
	
	float cintens = (((1-brightness-0.2)<=0) ? 0 : (1-brightness-0.2));
	CGContextSetFillColorWithColor(context, [ColorUtils colorWithRed: cintens green: cintens blue: cintens alpha: 1]);

	CGContextFillEllipseInRect(context, CGRectMake(16,96,288,288));
	CGContextDrawImage(context, CGRectMake(20,100,280,280), [colors imageRef]);
	CGContextSetFillColorWithColor(context, [ColorUtils colorWithRed: 0 green: 0 blue: 0 alpha: 1-brightness]);
	CGContextFillEllipseInRect(context, CGRectMake(19,99,282,282));
}

-(void)setBrightness:(float) b {
	brightness = b;
	[pip setBrightness: b];
	[self convertCoordsToColor];
	[pip setColor: color];
	[self setNeedsDisplay];
}
-(float)brightness {
	return brightness;
}
-(void)setAlpha:(float) a {
	alpha = a;
	[pip setAlpha: a];
	[self convertCoordsToColor];
	[pip setColor: color];
}
-(float)alpha {
	return alpha;
}

-(void)setDelegate:(id)d {
	delegate = d;
}
-(id)delegate {
	return delegate;
}

- (void) changed
{
	if ([self delegate] && [[self delegate] respondsToSelector:@selector(colorChanged:)])
	{
		NSArray * colorArray = RGBAColorToArray([pip color]);
		[[self delegate] performSelector:@selector(colorChanged:) withObject:colorArray];
	}
}

-(void)handleMouseEventWithPosition: (Point2D *)newpos {
	struct CGRect r = [self frame];
	newpos->x -= r.origin.x;
	newpos->y -= r.origin.y;
	if ([[newpos to: center] length] > 140) {
		newpos = [center add: [[[center to: newpos] unityVector] multiplyWith: 140]];
	}
	
	
	if (position!=newpos) {
		[position release];
		position = newpos;
		[position retain];
		
		[pip setOrigin: CGPointMake(position->x-[pip spot]->x, position->y-[pip spot]->y)];
		[self convertCoordsToColor];
		[pip setColor: color];
	}
}

-(void) mouseDown: (GSEvent *) event {
	if (GSEventGetLocationInWindow(event).y>100) {
		Point2D *newpos = [[[Point2D alloc] initWithx: GSEventGetLocationInWindow(event).x y: GSEventGetLocationInWindow(event).y] autorelease];
		struct CGRect r = [self frame];
		newpos->x -= r.origin.x;
		newpos->y -= r.origin.y;
		if ([[newpos to: center] length] > 140) {
			newpos = [center add: [[[center to: newpos] unityVector] multiplyWith: 140]];
		}
		
		if (position!=newpos) {
			[position release];
			position = newpos;
			[position retain];
			[UIView beginAnimations:nil];
			[UIView setAnimationDuration: 0.4];
			[pip setFrame: CGRectMake(position->x-[pip spot]->x, position->y-[pip spot]->y, [pip frame].size.width, [pip frame].size.height)];
			[UIView endAnimations];
			[pip setFrame: CGRectMake(position->x-[pip spot]->x, position->y-[pip spot]->y, [pip frame].size.width, [pip frame].size.height)];
			[self convertCoordsToColor];
			[pip setColor: color];
		}
	}
}

-(void) mouseUp: (GSEvent *) event {
	[pip minimize];
	[self changed];	
}

-(void) mouseDragged: (GSEvent *) event {
	if (![pip maximized])
		[pip maximize];
	
	[self handleMouseEventWithPosition: 
		[[[Point2D alloc] initWithx: GSEventGetLocationInWindow(event).x y:	GSEventGetLocationInWindow(event).y] autorelease]
	];
}

-(void)brightnessSliderDragged:(GSEvent *) event {
	if (brightness != [brightnessControl value]) {
		[self setBrightness: [brightnessControl value]];
		[self changed];		
	}
}
-(void)brightnessSliderUp:(GSEvent *) event {
	if (brightness != [brightnessControl value]) {
		[self setBrightness: [brightnessControl value]];
		[self changed];		
	}
}
-(void)alphaSliderDragged:(GSEvent *) event {
	if (alpha != [alphaControl value]) {
		[self setAlpha: [alphaControl value]];
		[self changed];
	}
}
-(void)alphaSliderUp:(GSEvent *) event {
	if (alpha != [alphaControl value]) {
		[self setAlpha: [alphaControl value]];
		[self changed];
	}
}

@end


//Circlemiddle @ 18,18; size: 39,40
//V: Circlemiddle + 11 = 29
//colorpt - 18,63 = upper left with finger
//colorpt - 18,18 = upper left without finger
@implementation ColorPipette
 
-(id)initWithFrame: (struct CGRect) f RGBAColor: (RGBAColor) c {
	[super initWithFrame: f];
	cv = [[ColorV alloc] initWithFrame: CGRectMake(0,27+36,[self frame].size.width, 10)];
	
	[self addSubview: cv];
	
	cc = [[ColorCircle alloc] init];
	[cc setColor: c];
	[self addSubview: cc];
	
	color = c;
	[self setOpaque: NO];
	[self setBrightness: [ColorUtils HSBFromRGB: c].b];
	
	maximized = NO;
	return self;
} 

-(void)minimize {
	maximized = NO;
	[UIView beginAnimations:nil];
	[UIView setAnimationDuration: 0.6];
	[cc setFrame: CGRectMake(0,46, 40, 40)];
	[cv setFrame: CGRectMake(0,27+36,[self frame].size.width, 10)];
	[UIView endAnimations];
	[cc setFrame: CGRectMake(0,46, 40, 40)];
	[cv setFrame: CGRectMake(0,27+36,[self frame].size.width, 10)];
}

-(void)maximize {
	maximized = YES;
	[UIView beginAnimations:nil];
	[UIView setAnimationDuration: 0.3];
	[cv setFrame: CGRectMake(0,27,[self frame].size.width, [self frame].size.height-27)];
	[cc setFrame: CGRectMake(0,0, 40, 40)];
	[UIView endAnimations];
	[cv setFrame: CGRectMake(0,27,[self frame].size.width, [self frame].size.height-27)];
	[cc setFrame: CGRectMake(0,0, 40, 40)];
	[cv setNeedsDisplay];
}

-(BOOL)maximized {
	return maximized;
}

-(void) setFrame:(struct CGRect) rect {
	[self needsDisplay];
	[super setFrame: rect];
}

-(Point2D*) spot {
	return [[[Point2D alloc] initWithx: 18 y: [self frame].size.height-22] autorelease];
}

-(void) setColor:(RGBAColor) c {
	color = c;
	[cc setColor: c];
}
-(RGBAColor) color {
	return color;
}
-(void)setBrightness:(float) b {
	[cc setBrightness: b];
	[cv setBlack: (b>0.5)];
}
-(float)brightness {
	return [cc brightness];
}
-(void)setAlpha:(float) a {
	[cc setAlpha: a];
}
-(float)alpha {
	return [cc alpha];
}

@end

@implementation ColorCircle

-(id)init {
	[super initWithFrame: CGRectMake(0,46,40,40)];
	[self setOpaque: NO];
	brightness = alpha = 1;
	return self;
}

-(void) drawRect:(struct CGRect)rect {
	CGContextRef context = UICurrentContext();
	CGContextClearRect(context, [self frame]);
	UIImage *lupeo;
	if (brightness>0.5) {
	 	lupeo = [UIImage applicationImageNamed:@"lupe5bo.png"];
	}
	else {
	 	lupeo = [UIImage applicationImageNamed:@"lupe5wo.png"];
	}	
		
	CGContextSetFillColorWithColor(context, [ColorUtils colorWithRed: 0 green: 0 blue: 0 alpha: 1]);
	CGContextFillEllipseInRect(context, CGRectMake(3,3, 30, 30));
	CGContextSetFillColorWithColor(context, [ColorUtils colorWithRed: 1 green: 1 blue: 1 alpha: 1]);
	CGContextMoveToPoint(context, 18, 18);
	CGContextAddArc(context, 18, 18, 15, M_PI/4, 7*M_PI/4, 1);
	CGContextFillPath(context);
	CGContextMoveToPoint(context, 18, 18);
	CGContextAddArc(context,  18, 18, 15, 5*M_PI/4, 3*M_PI/4, 1);
	CGContextFillPath(context);
	
	CGContextSetFillColorWithColor(context, [ColorUtils colorWithRGBAColor: color]);
	CGContextFillEllipseInRect(context, CGRectMake(3,3, 30, 30));
	CGContextDrawImage(context, CGRectMake(0, 0, 39, 40), [lupeo imageRef]);
}

-(void) setColor:(RGBAColor) c {
	color = c;
	[self setNeedsDisplay];
}
-(RGBAColor) color {
	return color;
}
-(void)setBrightness:(float) b {
	brightness = b;
	[self setNeedsDisplay];
}
-(float)brightness {
	return brightness;
}
-(void)setAlpha:(float) a {
	alpha = a;
}
-(float)alpha {
	return alpha;
}

@end

@implementation ColorV 

-(id)initWithFrame:(struct CGRect)rect {
	[super initWithFrame: rect];
	[self setOpaque: NO];
	black = YES;
	return self;
}

-(void) drawRect:(struct CGRect)rect {
	CGContextRef context = UICurrentContext();
	CGContextClearRect(context, [self frame]);
	if ([self frame].size.height!=40) {
		CGContextDrawImage(context, CGRectMake(4, 0, 29, [self frame].size.height-15), 
				[[UIImage applicationImageNamed: ((black) ? @"lupe5bv.png" : @"lupe5wv.png")] imageRef]);
	}
}

-(void) setBlack: (BOOL) y {
	black = y;
	[self setNeedsDisplay];
}
@end

//A few useful basic color utils.
@implementation ColorUtils
+ (CGColorRef)colorWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha {
	float rgba[4] = {red, green, blue, alpha};
	CGColorSpaceRef rgbColorSpace = (CGColorSpaceRef)[(id)CGColorSpaceCreateDeviceRGB() autorelease];
	CGColorRef color = (CGColorRef)[(id)CGColorCreate(rgbColorSpace, rgba) autorelease];
	return color;
}
+ (CGColorRef)colorWithRGBAColor:(RGBAColor) col {
	float rgba[4] = {col.r, col.g, col.b, col.a};
	CGColorSpaceRef rgbColorSpace = (CGColorSpaceRef)[(id)CGColorSpaceCreateDeviceRGB() autorelease];
	CGColorRef color = (CGColorRef)[(id)CGColorCreate(rgbColorSpace, rgba) autorelease];
	return color;
}
+ (CGColorRef)colorWithFHSBColor: (FHSBColor) col {
	return [ColorUtils colorWithRGBAColor: [ColorUtils RGBFromHSB: col]];
}

//I wonder why the hell those are not defaults.
/* Note: the color model conversion algorithms are taken from */
/* Rogers, Procedural Elements for Computer Graphics, pp. 401-403. */
//Note: ad note: that note is taken from ghostscript.com (http://svn.ghostscript.com/ghostscript/trunk/gs/src/gshsb.c) and the
//Algorithm is taken from their site (but not copied).
//I hope they don't have a problem with me copying two lines of comment...
+ (RGBAColor)RGBFromHSB: (FHSBColor) i {
	RGBAColor o;
	o.a = i.a;
	if (i.s == 0) {
		o.r = o.g = o.b = i.b;
	} else {
		float h6 = i.h * 6;
		int I = (int)h6;
		
		float M = i.b*(1-i.s);
		float N = i.b*(1-i.s*(h6-I));
		float K = M-N+i.b;
	
		switch (I) {
			default: 
			o.r = i.b;
			o.g = K;
			o.b = M;
			break;
			case 1:
			o.r = N;
			o.g = i.b;
			o.b = M;
			break;
			case 2:
			o.r = M;
			o.g = i.b;
			o.b = K;
			break;
			case 3:
			o.r = M;
			o.g = N;
			o.b = i.b;
			break;
			case 4:
			o.r = K;
			o.g = M;
			o.b = i.b;
			break;
			case 5:
			o.r = i.b;
			o.g = M;
			o.b = N;
			break;
		}
	}
	return o;
}
+ (FHSBColor)HSBFromRGB: (RGBAColor) i {
	FHSBColor o;
	if (i.g==i.b&&i.g==i.r) {
		o.h=0;
		o.s=0;
		o.b=i.r;
	} else {
		float V, Temp, diff, H;
		V = (i.r > i.g ? i.r : i.g);
		if (i.b > V) V=i.b;
		Temp = (i.r > i.g ? i.g : i.r);
		if (i.b < Temp) Temp = i.b;
		diff = V - Temp;
		
		if (V==i.r) H = (i.g-i.b)/diff;
		else if (V == i.g) H = (i.b-i.r)/diff + 2;
		else H = (i.r-i.g)/diff+4;
		if (H<0) H += 6;
		
		o.h = H/(6);
		o.s = diff / V;
		o.b = V;
		o.a = i.a;
	}
	return o;
}
@end



@implementation ColorPreviewer

-(id)initWithColor:(RGBAColor) c {
	[super initWithFrame: CGRectMake(20,20,280,80)];
	color = c;
	return self;
}

-(void)setColor:(RGBAColor) c {
	color = c;
	[self setNeedsDisplay];
}
-(RGBAColor)color {
	return color;
}

-(void) drawRect:(struct CGRect)rect {
	struct CGRect re = [self frame];
	CGContextRef context = UICurrentContext();
	
	struct CGRect colb = CGRectMake(0, 0, re.size.width, re.size.height);

	CGContextSetFillColorWithColor(context, [ColorUtils colorWithRed:0.f green: 0.f blue: 0.f alpha: 1.f]);
	CGContextFillRect(context, colb);
	
	CGContextSetFillColorWithColor(context, [ColorUtils colorWithRed:1.f green: 1.f blue: 1.f alpha: 1.f]);
	CGContextMoveToPoint(context, 0,colb.size.height);
	CGContextAddLineToPoint(context, colb.size.width, colb.size.height);
	CGContextAddLineToPoint(context, colb.size.width, 0);
	CGContextAddLineToPoint(context, 0,colb.size.height);
	CGContextFillPath(context);
	
	CGContextSetFillColorWithColor(context, [ColorUtils colorWithRGBAColor: color]);
	CGContextFillRect(context, colb);	
}
@end