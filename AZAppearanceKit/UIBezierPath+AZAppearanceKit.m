//
//  UIBezierPath+AZAppearanceKit.m
//  AZAppearanceKitDemo
//
//  Created by Zachary Waldowski on 10/29/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED

#import "UIBezierPath+AZAppearanceKit.h"
#import "AZDrawingFunctions.h"

@implementation UIBezierPath (AZAppearanceKit)

+ (UIBezierPath *)bezierPathByRoundingCornersInRect:(CGRect)rect topLeft:(CGFloat)topLeftRadius topRight:(CGFloat)topRightRadius bottomLeft:(CGFloat)bottomLeftRadius bottomRight:(CGFloat)bottomRightRadius {
	const CGPoint topLeft = rect.origin;
    const CGPoint topRight = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
    const CGPoint bottomRight = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    const CGPoint bottomLeft = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
	UIBezierPath *ret = [UIBezierPath bezierPath];

	[ret moveToPoint: CGPointMake(topLeft.x + topLeftRadius, topLeft.y)];

	[ret addLineToPoint: CGPointMake(topRight.x - topRightRadius, topRight.y)];
	[ret addCurveToPoint: CGPointMake(topRight.x, topRight.y + topRightRadius) controlPoint1: CGPointMake(topRight.x, topRight.y) controlPoint2: CGPointMake(topRight.x, topRight.y + topRightRadius)];

	[ret addLineToPoint: CGPointMake(bottomRight.x, bottomRight.y - bottomRightRadius)];
	[ret addCurveToPoint: CGPointMake(bottomRight.x - bottomRightRadius, bottomRight.y) controlPoint1: CGPointMake(bottomRight.x, bottomRight.y) controlPoint2: CGPointMake(bottomRight.x - bottomRightRadius, bottomRight.y)];

	[ret addLineToPoint: CGPointMake(bottomLeft.x + bottomLeftRadius, bottomLeft.y)];
	[ret addCurveToPoint: CGPointMake(bottomLeft.x, bottomLeft.y - bottomLeftRadius) controlPoint1: CGPointMake(bottomLeft.x, bottomLeft.y) controlPoint2: CGPointMake(bottomLeft.x, bottomLeft.y - bottomLeftRadius)];

	[ret addLineToPoint: CGPointMake(topLeft.x, topLeft.y + topLeftRadius)];
	[ret addCurveToPoint: CGPointMake(topLeft.x + topLeftRadius, topLeft.y) controlPoint1: CGPointMake(topLeft.x, topLeft.y) controlPoint2: CGPointMake(topLeft.x + topLeftRadius, topLeft.y)];

	[ret closePath];

	return ret;
}

- (void)strokeEdge:(CGRectEdge)edge {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(ctx);

	[self addClip];

	CGContextSetLineWidth(ctx, self.lineWidth);
	CGContextSetLineJoin(ctx, self.lineJoinStyle);
	CGContextSetLineCap(ctx, self.lineCapStyle);
	CGContextSetMiterLimit(ctx, self.miterLimit);
	CGContextSetFlatness(ctx, self.flatness);

	NSInteger lineDashCount;
	CGFloat phase;
	[self getLineDash: nil count: &lineDashCount phase: &phase];
	if (lineDashCount) {
		CGFloat *lengths = calloc(sizeof(CGFloat), lineDashCount);
		CGContextSetLineDash(ctx, phase, lengths, lineDashCount);
		free(lengths);
	}

	CGContextStrokeRectEdge(ctx, self.bounds, edge);

	CGContextRestoreGState(ctx);
}

@end

#endif