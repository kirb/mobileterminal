// PTYTextView.m
#define DEBUG_ALLOC           0 
#define DEBUG_METHOD_TRACE    0 

#import "PTYTextView.h"
#import <UIKit/NSString-UIStringDrawing.h>
#import "MobileTerminal.h"
#import "VT100Screen.h"
#import "ColorMap.h"
#import "PTYTile.h"
#import "Settings.h"
#import "Log.h"

#include <sys/time.h>
#include <math.h>

#define DEBUGLOG NO

@implementation PTYTextView

+ (Class)tileClass
{
  return [PTYTile class];
}

//_______________________________________________________________________________

- (id)initWithFrame:(CGRect)frame 
						 source:(VT100Screen*)screen
           scroller:(UIScroller*)scroller
				 identifier:(int)identifier
{	
	termid = identifier;
	
  self = [super initWithFrame:frame];
	
	[self setPositionsTilesFromOrigin:YES];
	[self setTileOrigin:CGPointMake(0,0)];

  CURSOR = YES;
  dataSource = screen;

  textScroller = scroller;
  [textScroller addSubview:self];
  [textScroller setAllowsRubberBanding:YES];
  [textScroller setBottomBufferHeight:0.0];
  [textScroller setBounces:YES];
  [textScroller setContentSize:frame.size];
  [textScroller setScrollerIndicatorStyle:2];
	[textScroller displayScrollerIndicators];
	[textScroller setAdjustForContentSizeChange:YES];

  [self refresh];

  // Create one tile per row
	_tileSize = CGSizeMake(480, lineHeight);
  _firstTileSize = _tileSize;

  [self setOpaque:YES];
  [self setTilingEnabled:YES];
  [self setTileDrawingEnabled:YES];
	
  return self;
}

//_______________________________________________________________________________

- (void) resetFont
{
	fontRef = nil;	
	[self refresh];
}

//_______________________________________________________________________________

- (void)dealloc
{
#if DEBUG_ALLOC
  NSLog(@"%s: 0x%x", __PRETTY_FUNCTION__, self);
#endif
  CFRelease(fontRef);
  [super dealloc];
	
#if DEBUG_ALLOC
  NSLog(@"%s: 0x%x, done", __PRETTY_FUNCTION__, self);
#endif
}

//_______________________________________________________________________________

-(void)setSource:(VT100Screen*)screen
{
	dataSource = screen;
	[self updateAll];
	[self updateAndScrollToEnd];
}

//_______________________________________________________________________________

- (void)updateAll
{
  [dataSource acquireLock];
  int height = [dataSource height];
  int lines = [dataSource numberOfLines];
	
  // Expand the height, and cause scroll
  int newHeight = lines * lineHeight;
  CGRect frame = [self frame];
  if (frame.size.height != newHeight) 
	{
    frame.size.height = newHeight;
    [self setFrame:frame];
    [textScroller setContentSize:frame.size];
  }
  int startIndex = 0;
  if (lines > height) 
	{
    startIndex = lines - height;
  }
	
  // Check for dirty on-screen rows; scroll back is not updated
  int row;
  for (row = 0; row < height; row++) 
	{
		CGRect rect = CGRectMake(0, (startIndex + row) * lineHeight,
														 [self frame].size.width, lineHeight);
		[self setNeedsDisplayInRect:rect];
  }
	
  [dataSource resetDirty];
  [dataSource releaseLock];
}

//_______________________________________________________________________________

- (void)refresh
{
  CGRect frame = [self frame];
	
	TerminalConfig * config = [[[Settings sharedInstance] terminalConfigs] objectAtIndex:termid];
	lineHeight = [config fontSize] + TERMINAL_LINE_SPACING;
	charWidth = [config fontSize]*[config fontWidth];
	
	//if (DEBUGLOG) log(@"size %d width %f", [config fontSize], [config fontWidth]);
	//if (DEBUGLOG) log(@"lineHeight %f charWidth %f frame.width %f", lineHeight, charWidth, frame.size.width);
	
	[self setFirstTileSize:CGSizeMake(frame.size.width, lineHeight)];
	[self setTileSize:CGSizeMake(frame.size.width, lineHeight)];
	[self setNeedsLayout];
	
	//if (DEBUGLOG) log(@"lineHeight %f frame.height %f", lineHeight, frame.size.height);
}

//_______________________________________________________________________________

- (void) updateAndScrollToEnd
{
  [self updateIfNecessary];
	
  [dataSource acquireLock];
	
  CGRect visibleRect = CGRectMake(0, [self frame].size.height, 0, 0);
	
	//logRect(@"visibleRect", visibleRect);
	
  [textScroller scrollRectToVisible:visibleRect animated:YES];
  [dataSource releaseLock];
}

//_______________________________________________________________________________

- (void) updateIfNecessary
{
  [dataSource acquireLock];
  int width  = [dataSource width];
  int height = [dataSource height];
  int lines  = [dataSource numberOfLines];

	CGRect frame = [self frame];
  float newHeight = lines * lineHeight;
	float oldHeight = frame.size.height;
	
  if (oldHeight != newHeight) // expand height -> refresh
	{
    frame.size.height = newHeight;
    [self setFrame:frame];
    [textScroller setContentSize:frame.size];
		
		[self removeAllTiles];
		[self setNeedsDisplay];
  }
	else if (lines >= 1000) // scrollback buffer full -> refresh
	{
		[self removeAllTiles];
		[self setNeedsDisplay];
	}
	else // redraw dirty lines
	{
		int row, column, startIndex = MAX(0, lines-height);
											
		for (row = 0; row < height; row++) 
		{
			const char * dirty = [dataSource dirty] + row * width;
			for (column = 0; column < width; column++)
			{
				if (dirty[column])
				{
					CGRect rect = CGRectMake(0, (startIndex + row) * lineHeight, [self frame].size.width, lineHeight);
					[self setNeedsDisplayInRect:rect];					
					break;
				}
			}		
		}
	}
	
  [dataSource resetDirty];
  [dataSource releaseLock];
}

//_______________________________________________________________________________

- (void) willSlideOut
{
	scrollOffset = [textScroller offset];
	//logPoint(@"scrollOffset", scrollOffset);
}

//_______________________________________________________________________________

- (void) willSlideIn
{
	[textScroller setOffset:scrollOffset];
	//logPoint(@"scrollOffset", scrollOffset);
}

//XXX: put me in a standard header somewhere
extern CGFontRef CGContextGetFont(CGContextRef);

//_______________________________________________________________________________

- (void)setupTextForContext:(CGContextRef)context
{
	if (!fontRef) 
	{		
		TerminalConfig * config = [[[Settings sharedInstance] terminalConfigs] objectAtIndex:termid];
		const char * font = [config.font cString];
    // First time through: cache the fontRef. This lookup is expensive.
		fontSize = config.fontSize;
    CGContextSelectFont(context, font, floor(lineHeight), kCGEncodingMacRoman);
    fontRef = (CGFontRef)CFRetain(CGContextGetFont(context));
  } 
	else 
	{
		CGContextSetFont(context, fontRef);
		CGContextSetFontSize(context, fontSize);
  }

  CGContextSetRGBFillColor(context, 1, 1, 1, 1);
  CGContextSetTextDrawingMode(context, kCGTextFill);

  // Flip text, for some reason it's written upside down by default
  CGAffineTransform translate = CGAffineTransformMake(1, 0, 0, -1, 0, 1.0);
  CGContextSetTextMatrix(context, translate);
}

//_______________________________________________________________________________

- (void)drawBox:(CGContextRef)context
          color:(CGColorRef)color
        boxRect:(CGRect)rect
{
  const float* components = CGColorGetComponents(color);
  CGContextSetRGBFillColor(context, components[0], components[1],
                                    components[2], components[3]);
  CGContextFillRect(context, rect);
}

//XXX: put me in a standard header somewhere
bool CGFontGetGlyphsForUnichars(CGFontRef, unichar[], CGGlyph[], size_t);

//_______________________________________________________________________________

- (void)drawChar:(CGContextRef)context
       character:(char)c
           color:(CGColorRef)color
           point:(CGPoint)point
{
  const float* components = CGColorGetComponents(color);
  CGContextSetRGBFillColor(context, components[0], components[1],
                                    components[2], components[3]);
  // TODO: Consider adjusting the text point based on the rotation above
  
  // Use CGContextShowGlyphsWithAdvances() and make up the advances. Actually
  // calculating advances is expensive and unnecessary for plotting one glyph.
  
  //Get the glyph
  CGGlyph glyphs[1] = { 0 };
  unichar chars[1];
  chars[0] = (unichar)c;
  CGFontGetGlyphsForUnichars(fontRef, chars, glyphs, 1);
  
  //one character, nothing to advance from, so this isn't really important.
  CGSize advances[1];
  advances[0] = CGSizeMake(0.0,0.0);
  
  //plot the one glyph
  CGContextSetTextPosition( context, floor(point.x), floor(point.y) );
  CGContextShowGlyphsWithAdvances(context,glyphs,advances,1);
}

//_______________________________________________________________________________

- (void)drawTileFrame:(CGRect)frame tileRect:(CGRect)rect
{
  // Each Tile is responsible for one row so determine the row that this
  // tile is responsible for based on its bounding rectangle.	
  int row = (int)((frame.origin.y - [self frame].origin.y) / lineHeight);
	
	//if (DEBUGLOG) logRect(@"frame", frame);
	
	if (row >= 0 && rect.size.height == lineHeight) [self drawRow:row tileRect:(CGRect)rect];
}

//_______________________________________________________________________________

- (void)drawRow:(unsigned int)row tileRect:(CGRect)rect
{
	//if (DEBUGLOG) log(@"row %d", row);
	
  CGContextRef context = UICurrentContext();

  [dataSource acquireLock];

  CGRect charRect = CGRectMake(rect.origin.x, rect.origin.y, charWidth, lineHeight);

  // Draw background for each column in the row
  int width = [dataSource width];
  int column;
		
  screen_char_t * theLine = [dataSource getLineAtIndex:row];
	
	// ---------- debug output
	/*
	if (DEBUGLOG) 
	{
		NSMutableString * line = [NSMutableString stringWithCapacity:width];
		for (column = 0; column < width; column++) 
		{
			char c = 0xff & theLine[column].ch;
			if (c == 0) c = ' ';
			[line appendFormat:@"%c", c];
		}
		logRect(@"   ", rect);		
		log(@"					    row %02d [%@]", row, line);
	}
	*/
	// ---------- debug output end

  // Avoid painting each black square individually. First paint the whole 
  // row with the background color  
	
  [self drawBox:context 
					color:[[ColorMap sharedInstance] colorForCode:DEFAULT_BG_COLOR_CODE]
				boxRect:CGRectMake(rect.origin.x, rect.origin.y, charWidth * width, lineHeight)];

  // now specially paint any exceptional backgrounds
  for (column = 0; column < width; column++) 
	{
    unsigned int bgcode = theLine[column].bg_color;
    if(bgcode != DEFAULT_BG_COLOR_CODE) 
		{
      CGColorRef bg = [[ColorMap sharedInstance] colorForCode:bgcode];
      [self drawBox:context color:bg boxRect:charRect];
    }
    charRect.origin.x += charWidth;
  }

  // Set font and mirror text; start one line lower to account for text flip
  [self setupTextForContext:context];
  // TODO: Text adjustment (3 px) should be font line height dependent.  Needs
  // some testing.
  charRect.origin.y += lineHeight - 3;

  // Draw foreground character for each column in the row
  charRect.origin.x = rect.origin.x;
  for (column = 0; column < width; column++) 
	{
    char c = 0xff & theLine[column].ch;
    if (c == 0) 
		{
      c = ' ';
    }
    unsigned int fgcode = theLine[column].fg_color;
    CGColorRef fg = [[ColorMap sharedInstance] colorForCode:fgcode];
    [self drawChar:context character:c color:fg point:charRect.origin];
    charRect.origin.x += charWidth;
  }

  // Fill a rectangle with the cursor. drawRow consideres scrollback buffer;
  // cursorY is relative to the non-scrollback screen.
  int cursorY = [dataSource cursorY];
  int height = [dataSource height];
  int lines = [dataSource numberOfLines];
  if (lines > height) {
    cursorY += (lines - height);
  }
	
  if (CURSOR && row == cursorY) 
	{
    int cursorX = [dataSource cursorX];
    CGRect cursorRect = CGRectMake(rect.origin.x, rect.origin.y,
                                   charWidth, lineHeight);
    cursorRect.origin.x += cursorX * charWidth;
    CGColorRef cursorColor = [[ColorMap sharedInstance] defaultCursorColor];
		if ([[MobileTerminal application] controlKeyMode])
		{
			cursorColor = [[ColorMap sharedInstance] colorForCode:1];
		}
    [self drawBox:context color:cursorColor boxRect:cursorRect];
  }

  [dataSource releaseLock];
}

//_______________________________________________________________________________

- (CGRect) rectForRow:(int)row
{
	return CGRectMake(0, row*lineHeight, self.frame.size.width, lineHeight);
}

//_______________________________________________________________________________

- (void) refreshCursorRow
{
	int row = [dataSource numberOfLines] - [dataSource height] + [dataSource cursorY];
	[self setNeedsDisplayInRect:CGRectMake(0, row*lineHeight, self.frame.size.width, lineHeight)];
}

@end
