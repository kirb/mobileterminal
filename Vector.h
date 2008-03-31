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

//A few 2D-Vectorbasics + my uniqe Transformeralgorithm. :-)

/* ============ */
/* = Vector2D = */
/* ============ */
@interface Vector2D : NSObject 
{
	@public
	float vx, vy;
}

- (Vector2D *) init;
- (Vector2D *) initWithvx: (float) _vx vy: (float) _vy;
- (Vector2D *) initWithAngle: (float) a length: (float) l;
- (Vector2D *) initWithNSSize:(NSSize) s;

- (Vector2D *) add: (Vector2D *) v;
- (Vector2D *) subtract: (Vector2D *) v;
- (Vector2D *) reverse;
- (Vector2D *) multiplyWith: (float) factor;
- (float) multiplyWithVector: (Vector2D *) vector;
- (Vector2D *) divideThrough: (float) divisor;
- (float) length;
- (Vector2D *) unityVector;
- (float) angleBetweenVector: (Vector2D *) v;
- (float) angle;
- (Vector2D *) turnLeft;
- (Vector2D *) turnRight;

- (NSSize) nsSize;
@end

/* =========== */
/* = Point2D = */
/* =========== */
@interface Point2D : NSObject 
{
	@public
	float x,y;
}
-(Point2D *)init;
-(Point2D *)initWithx: (float) _x y: (float) _y;
- (Point2D *) initWithNSPoint:(NSPoint) p;
- (void) setCoords:(Point2D *)p;


-(Vector2D *) to: (Point2D *) q;
-(Point2D *) add: (Vector2D *) v;
-(Point2D *) subtract: (Vector2D *) v;
-(BOOL) equals: (Point2D *) q withMaxDistance: (float) d;

-(NSPoint) nsPoint;
@end 

/* ============ */
/* = Gerade2D = */
/* ============ */
@interface Gerade2D : NSObject 
{
	@public
	Point2D *p;
	Vector2D *v;
}

- (Gerade2D *) init;
- (Gerade2D *) initWithPoint: (Point2D *) p andVector: (Vector2D *) v;
- (Gerade2D *) initWithPoint: (Point2D *) p andPoint: (Point2D *) q;

- (Point2D *) cutWithGerade: (Gerade2D *) h;

@end

/* ========== */
/* = Line2D = */
/* ========== */
@interface Line2D : NSObject 
{
	@public
	Point2D *p, *q;
}
- (Line2D *) init;
- (Line2D *) initWithPoint:(Point2D *) p andPoint: (Point2D *) q;
- (Line2D *) initWithPoint:(Point2D *) p andVector: (Vector2D *) v;
- (Line2D *) initWithpx: (float)px py: (float)py qx: (float)qx qy: (float)qy;

- (float) length;
- (Gerade2D *) toGerade;
- (Vector2D *) vector;
- (Point2D *) middle;

@end

/* ================= */
/* = Transformer2D = */
/* ================= */
@interface Transformer2D : NSObject 
{
	@public
	float t1, o1, t2, o2;
}

- (Transformer2D *) initWithLine: (Line2D *) rec1 andLine: (Line2D *) rec2;
- (Transformer2D *) initWithp1: (Point2D *) p1 q1: (Point2D *) q1 
									 p2: (Point2D *) p2 q2: (Point2D *) p2;

- (Line2D *) transformLine: (Line2D *) l;
@end

/* ============ */
/* = Matrix2D = */
/* ============ */
/*@interface Matrix2D : NSObject
	{
		m11, m12, m21, m22;
	}
	-(id) init;
	-(id) initWithRotation(float) r;
	-(id) initWithScale(float) s;
	-(id) initWithScale: (float) s andRotation: (float) r;
	
	-(id) combineWithMatrix: (Matrix2D *) n;
	-(Point2D *)mapPoint;
@end*/