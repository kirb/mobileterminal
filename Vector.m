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


#import <Foundation/Foundation.h>
#import "Vector.h"
#import "math.h"

@implementation Vector2D 
	- (Vector2D *) init {
		[super init];
		vx = vy = 0;
		return self;
	}
	- (Vector2D *) initWithvx: (float) _vx vy: (float) _vy {
		[super init];
		vx = _vx; 
		vy = _vy;
		return self;
	}
	- (Vector2D *) initWithAngle: (float) a length: (float) l {
		[super init];
		vx = sin(a)*l;
		vy = cos(a)*l;
		return self;
	}
	- (Vector2D *) initWithNSSize:(NSSize) s {
		[super init];
		vx = s.width;
		vy = s.height;
		return self;
	}
	

	- (Vector2D *) add: (Vector2D *) v {	
		return [[[Vector2D alloc] initWithvx: vx + v->vx vy: vy + v->vy] autorelease];
	}
	- (Vector2D *) subtract: (Vector2D *) v {	
		return [[[Vector2D alloc] initWithvx: vx - v->vx vy: vy - v->vy] autorelease];
	}
	- (Vector2D *) reverse {
		return [[[Vector2D alloc] initWithvx: -vx vy: -vy] autorelease];
	}
	- (Vector2D *) multiplyWith: (float) factor {
		return [[[Vector2D alloc] initWithvx: vx*factor vy: vy*factor] autorelease];
	}
	- (float) multiplyWithVector: (Vector2D *) vector {
		return vx*vector->vx+vy*vector->vy;
	}
	- (Vector2D *) divideThrough: (float) divisor {
		return [[[Vector2D alloc] initWithvx: vx/divisor vy: vy/divisor] autorelease];
	}
	- (float) length {
		return sqrt(vx*vx+vy*vy);
	}
	- (Vector2D *) unityVector {
		return [self divideThrough: [self length]];
	}
	- (float) angleBetweenVector: (Vector2D *) v {
		float angle=[v angle] - [self angle];
		return (angle<0) ? angle+6.283185 : angle;
	}
	- (float) angle {
		return atan2(vx,vy);
	}
	- (Vector2D *) turnLeft {
		return [[[Vector2D alloc] initWithvx: -vy vy: vx] autorelease];
	}
	- (Vector2D *) turnRight {
		return [[[Vector2D alloc] initWithvx: vy vy: -vx] autorelease];
	}

	- (NSSize) nsSize {
		NSSize size;
		size.width = vx;
		size.height = vy;
		return size;
	}
@end

@implementation Point2D
	-(Point2D *)init {
		[super init];
		x=y=0;
		return self;
	}
	-(Point2D *)initWithx: (float) _x y: (float) _y {
		[super init];
		x=_x;
		y=_y;
		return self;
	}
	- (Point2D *) initWithNSPoint:(NSPoint) p {
		[super init];
		x = p.x;
		y = p.y;
		return self;
	}
	- (void) setCoords:(Point2D *)p {
		x = p->x;
		y = p->y;
	}
	
	- (Vector2D *) to: (Point2D *) q {
		return [[[Vector2D alloc] initWithvx: q->x-x vy: q->y-y] autorelease];
	}
	- (Point2D *) add: (Vector2D *) v {
		return [[[Point2D alloc] initWithx: x+v->vx y: y+v->vy] autorelease];
	}
	- (Point2D *) subtract: (Vector2D *) v {
		return [[[Point2D alloc] initWithx: x-v->vx y: y-v->vx] autorelease];
	}
	- (BOOL) equals: (Point2D *) q withMaxDistance: (float) d {
		return ([[self to: q] length]<=d);
	}
	
	-(NSPoint) nsPoint {
		NSPoint pt;
		pt.x = x;
		pt.y = y;
		return pt;
	}
@end	

@implementation Line2D 
- (Line2D *) init {
	[super init];
	p = [[Point2D alloc] init];
	q = [[Point2D alloc] init];
	return self;
}
- (Line2D *) initWithPoint:(Point2D *) _p andPoint: (Point2D *) _q {
	[super init];
	p = _p;
	[p retain];
	q = _q;
	[q retain];
	return self;
}
- (Line2D *) initWithPoint:(Point2D *) _p andVector: (Vector2D *) v {
	[super init];
	p = _p;
	[p retain];
	q = [_p add: v];
	[q retain];
	return self;
}
- (Line2D *) initWithpx: (float)px py: (float)py qx: (float)qx qy: (float)qy{
	[super init];
	p = [[Point2D alloc] initWithx: px y: py];
	q = [[Point2D alloc] initWithx: qx y: qy];
	return self;
}

- (float) length {
	return [[p to: q] length];
}
- (Gerade2D *) toGerade {
	return [[[Gerade2D alloc] initWithPoint: p andPoint: q] autorelease];
}
- (Vector2D *) vector {
	return [p to: q];
}
- (Point2D *) middle {
	return [[[Point2D alloc] initWithx: (p->x+q->x)/2 y: (p->y+q->y)/2] autorelease];
}

@end	
	
@implementation Gerade2D 
- (Gerade2D *) init {
	[super init];
	p = [[Point2D alloc] init];
	return self;
}
- (Gerade2D *) initWithPoint: (Point2D *) _p andVector: (Vector2D *) _v {
	[super init];
	p = _p;
	[p retain];
	v = _v;
	[v retain];
	return self;
}
- (Gerade2D *) initWithPoint: (Point2D *) _p andPoint: (Point2D *) q {
	[super init];
	p = _p;
	[p retain];
	v = [_p to: q];
	[v retain];
	return self;
}

- (Point2D *) cutWithGerade: (Gerade2D *) h {
	float lambda = (p->y * h->v->vx - h->p->y * h->v->vx - p->x * h->v->vy + h->p->x * h->v->vy) /
		(v->vx * h->v->vy - v->vy * h->v->vx);
	return [[[Point2D alloc] initWithx: (p->x + lambda * v->vx) 
		y: (p->y + lambda * v->vy)] autorelease];
}
@end

@implementation Transformer2D 
- (Transformer2D *) initWithLine: (Line2D *) rec1 andLine: (Line2D *) rec2 {
	return [self initWithp1: rec1->p q1: rec1->q p2: rec2->p q2: rec2->q];
}
- (Transformer2D *) initWithp1: (Point2D *) p1 q1: (Point2D *) q1 
									 p2: (Point2D *) p2 q2: (Point2D *) q2 {
	[super init];
	float olength = [[p1 to: q1] length];
	Point2D *s = [[[Gerade2D alloc] initWithPoint: p1 andPoint: q1] cutWithGerade: 
				[[Gerade2D alloc] initWithPoint: p2 andVector: [[p1 to: q1] turnLeft]]];

	t1 = [[p1 to: s] length] / olength;

	if (!
		[[p1 add: [[p1 to: q1] multiplyWith: t1]] equals: s withMaxDistance: 0.01f]
	) {
		t1 = -t1;
	}

	o1 = [[s to: p2] length] / olength;
     
	if (!
		[[s add: [[[p1 to: q1] multiplyWith: o1] turnLeft]] equals: p2 withMaxDistance: 0.01f]
	) {
		o1 = -o1;
	}
	
	//And the thing the second time...
	s = [[[Gerade2D alloc] initWithPoint: p1 andPoint: q1] cutWithGerade: 
		[[Gerade2D alloc] initWithPoint: q2 andVector: [[p1 to: q1] turnLeft]]];

	t2 = [[p1 to: s] length] / olength;
     
	if (!
		[[p1 add: [[p1 to: q1] multiplyWith: t2]] equals: s withMaxDistance: 0.01f]
	) {
		t2 = -t2;
	}
	o2 = [[s to: q2] length] / olength;
     
	if (!
		[[s add: [[[p1 to: q1] multiplyWith: o2] turnLeft]] equals: q2 withMaxDistance: 0.01f]
	) {
		o2 = -o2;
	}	
	
	return self;
}


- (Line2D *) transformLine: (Line2D *) l { 
	Vector2D * o = [l->p to: l->q];
	
	return [[[Line2D alloc] initWithPoint: 
		[l->p add: [[o multiplyWith: t1] add: [[o turnLeft] multiplyWith: o1]]]
		andPoint: 
		[l->p add: [[o multiplyWith: t2] add: [[o turnLeft] multiplyWith: o2]]]
	] autorelease];
}

@end