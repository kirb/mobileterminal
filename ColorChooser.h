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
#import <UIKit/UIView.h>
#import <UIKit/UIPushButton.h>
#import <GraphicsServices/GraphicsServices.h>

@class Point2D;
@class UISliderControl;
@class NSMutableArray;
@class ColorPreviewer;
@class ColorCircle;
@class ColorV;
@class ColorPipette;
@class UIImage;

//A simple struct to save color values due to the lack of NSColor
typedef struct {
	float r, g, b, a;
} RGBAColor;

typedef struct {
	float h, s, b, a;
} FHSBColor;

typedef RGBAColor * RGBAColorRef;

//_______________________________________________________________________________

CGColorRef colorWithRGBA(float red, float green, float blue, float alpha);
CGColorRef CGColorWithRGBAColor(RGBAColor c);
RGBAColor RGBAColorMake (float r, float g, float b, float a);
RGBAColor RGBAColorMakeWithArray (NSArray * array);
NSArray * RGBAColorToArray (RGBAColor c);

//A fullscreen colorpicker, similar to OS X's default one. 
//Create it, set it's delegate, and blend over with some effect and wait for (void)colorChosen:(CGColorRef)c to be called.
//the first parameter handed over to colorChosen: tapedOk: will be the latest selected color; if cancel was pressed tapedOk is NO.
// Then remove the view the way you like.
//initWithColor is missing due to internal problems with converting RGB<->HSB (I'm currently to lazy to implement that stuff).
@interface ColorChooser : UIView 
{
	id delegate;
	
	Point2D *position, *center;
	RGBAColor color;
	UISliderControl *brightnessControl;
	UISliderControl *alphaControl;
	float brightness, alpha;
	ColorPreviewer *colorPreview;
	UIImage *colors;
	ColorPipette *pip;
}

-(id)init;
-(id)initWithColor: (RGBAColor)cp;

-(void)convertCoordsToColor;
-(void)convertColorToCoords;

-(void) drawRect:(struct CGRect)rect;

-(void)setDelegate:(id)d;
-(id)delegate;
-(RGBAColor) color;
-(void) setColor:(RGBAColor) c;
-(void)setBrightness:(float) b;
-(float)brightness;
-(void)setAlpha:(float)alpha;
-(float)alpha;
-(void) mouseDragged: (GSEvent *) event;
-(void) mouseDown: (GSEvent *) event;
-(void) mouseUp: (GSEvent *) event;
-(void)handleMouseEventWithPosition: (Point2D *)newpos;
@end

@interface ColorPipette : UIView 
{
	RGBAColor color;
	float alpha, brightness;
	ColorCircle *cc;
	ColorV *cv;
	BOOL maximized;
}
-initWithFrame:(struct CGRect) f RGBAColor: (RGBAColor) c;

-(void)maximize;
-(void)minimize;
-(BOOL)maximized;

-(void) setColor:(RGBAColor) c;
-(RGBAColor) color;
-(void)setBrightness:(float) b;
-(float)brightness;
-(void)setAlpha:(float)alpha;
-(float)alpha;

-(Point2D*) spot;
@end

@interface ColorCircle : UIView
{
	RGBAColor color;
	float alpha, brightness;
}
-(id)init;

-(void) drawRect:(struct CGRect)rect;

-(void) setColor:(RGBAColor) c;
-(RGBAColor) color;
-(void)setBrightness:(float) b;
-(float)brightness;
-(void)setAlpha:(float)alpha;
-(float)alpha;

@end

@interface ColorV : UIView 
{
	BOOL black;
}
-(void) setBlack: (BOOL) y;
-(void) drawRect:(struct CGRect)rect;
@end
//A few useful color utils.
@interface ColorUtils : NSObject 
+ (CGColorRef)colorWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
+ (CGColorRef)colorWithRGBAColor: (RGBAColor) color;

//I wonder why the hell those are not defaults.
+ (RGBAColor)RGBFromHSB: (FHSBColor) color;
+ (FHSBColor)HSBFromRGB: (RGBAColor) color;
@end

//The ColorManager will be a static class which handles color presets.
@interface ColorManager : NSObject 
{
	NSMutableArray *presetColors;
}

@end

//Colorpreviewer is the class which shows the color + it's alpha in that rectangle.
//A rather simple class as it's output only.
@interface ColorPreviewer : UIPushButton 
{
	RGBAColor color;
}

-(id)initWithColor:(RGBAColor) c;
-(void)setColor:(RGBAColor) c;
-(RGBAColor)color;
-(void) drawRect:(CGRect)rect;
@end