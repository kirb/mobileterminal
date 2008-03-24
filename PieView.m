#import "PieView.h"
#import "Log.h"

@implementation PieView

//_______________________________________________________________________________

+ (PieView*)sharedInstance
{
  static PieView* instance = nil;
  if (instance == nil) {
    CGRect frame = CGRectMake(56.0f,16.0f,208.0f,213.0f);
    instance = [[PieView alloc] initWithFrame:frame];
  }
  return instance;
}

//_______________________________________________________________________________

- (BOOL)ignoresMouseEvents {
  return YES;
}

//_______________________________________________________________________________

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  visibleFrame = frame;
  location = CGPointMake(frame.origin.x + (frame.size.width*0.5f),
                         frame.origin.y + (frame.size.height*0.5f));
  _visible = YES;

  NSBundle *bundle = [NSBundle mainBundle];
  NSString *pieImagePath = [bundle pathForResource: @"pie" ofType: @"png"];
  UIImage *pieImage = [[UIImage alloc] initWithContentsOfFile: pieImagePath];
  [self setImage: pieImage];
  [self setAlpha: 0.9f];

  anim = [[UIAnimator alloc] init];
	timer = nil;
	
  return self;
}

//_______________________________________________________________________________

- (void)showAtPoint:(CGPoint)p
{
	//log(@"showAtPoint %f %f", p.x, p.y);
	[self stopTimer];
  location.x = (int)(p.x - visibleFrame.size.width*0.5f);
  location.y = (int)(p.y - visibleFrame.size.height*0.5f);;
	timer = [NSTimer scheduledTimerWithTimeInterval:PIE_MENU_DELAY target:self selector:@selector(fadeIn) userInfo:nil repeats:NO];
}

//_______________________________________________________________________________

-(void) stopTimer
{
	if (timer != nil) {
		[timer invalidate];
		timer = nil;
	}
}

//_______________________________________________________________________________

- (void) fadeIn
{
	timer = NULL;
	
  if (_visible) {
    return;
  }
  _visible = YES;
  visibleFrame.origin.x = 0.0f;
  visibleFrame.origin.y = 0.0f;
  [self setTransform:CGAffineTransformMake(1,0,0,1,0,0)];
  [self setFrame: visibleFrame];
  [self setTransform:CGAffineTransformMake(0.01f,0,0,0.01f,0,480)];
  [self setAlpha: 0.0f];
  UITransformAnimation *scaleAnim = [[UITransformAnimation alloc] initWithTarget: self];
  [scaleAnim setStartTransform: CGAffineTransformMake(0.01f,0,0,0.01f,location.x,location.y)];
  [scaleAnim setEndTransform:   CGAffineTransformMake(1,0,0,1,location.x,location.y)];
  UIAlphaAnimation *alphaAnim = [[UIAlphaAnimation alloc] initWithTarget: self];
  [alphaAnim setStartAlpha: 0.0f];
  [alphaAnim setEndAlpha: 0.9f];
  
  [anim addAnimation:scaleAnim withDuration:PIE_MENU_FADE_IN_TIME start:YES]; 
  [anim addAnimation:alphaAnim withDuration:PIE_MENU_FADE_IN_TIME start:YES];
}

//_______________________________________________________________________________

- (void)hide {
  [self hideSlow:NO];
}

//_______________________________________________________________________________

- (void)hideSlow:(BOOL)slow
{ 
	[self stopTimer];
	
  if (!_visible) {
    return;
  }
  UITransformAnimation *scaleAnim =
    [[UITransformAnimation alloc] initWithTarget: self];
  [scaleAnim setStartTransform:
    CGAffineTransformMake(1,0,0,1,location.x,location.y)];
  [scaleAnim setEndTransform:
    CGAffineTransformMake(0.01f,0,0,0.01f,location.x,location.y)];
  UIAlphaAnimation *alphaAnim =
    [[UIAlphaAnimation alloc] initWithTarget: self];
  [alphaAnim setStartAlpha: 0.9f];
  [alphaAnim setEndAlpha: 0.0f];
  float duration = slow ? 1.0f : PIE_MENU_FADE_OUT_TIME;
 
	[anim removeAnimationsForTarget:self];
  if (!slow) [anim addAnimation:scaleAnim withDuration:duration start:YES]; 
  [anim addAnimation:alphaAnim withDuration:duration start:YES];
  _visible = NO;
}

@end
