//
//  AZDrawingFunctions.m
//  AZAppearanceKit
//
//  Created by Victor Pena Placer on 2/28/12.
//  Copyright (c) 2012 Victor Pena Placer. All rights reserver.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import "AZDrawingFunctions.h"

CGPathRef CGPathCreateWithRoundedRect(CGRect rect, CGFloat cornerRadius) {
    return CGPathCreateByRoundingCornersInRect(rect, cornerRadius, cornerRadius, cornerRadius, cornerRadius);
}
CGPathRef CGPathCreateByRoundingCornersInRect(CGRect rect, CGFloat topLeftRadius, CGFloat topRightRadius, CGFloat bottomLeftRadius, CGFloat bottomRightRadius) {
	const CGPoint topLeft = rect.origin;
    const CGPoint topRight = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
    const CGPoint bottomRight = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    const CGPoint bottomLeft = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGMutablePathRef path = CGPathCreateMutable();
	
	CGPathMoveToPoint(path, NULL, topLeft.x + topLeftRadius, topLeft.y);
	
	CGPathAddLineToPoint(path, NULL, topRight.x - topRightRadius, topRight.y);
	CGPathAddCurveToPoint(path, NULL, topRight.x, topRight.y, topRight.x, topRight.y + topRightRadius, topRight.x, topRight.y + topRightRadius);
	
	CGPathAddLineToPoint(path, NULL, bottomRight.x, bottomRight.y - bottomRightRadius);
	CGPathAddCurveToPoint(path, NULL, bottomRight.x, bottomRight.y, bottomRight.x - bottomRightRadius, bottomRight.y, bottomRight.x - bottomRightRadius, bottomRight.y);
	
	CGPathAddLineToPoint(path, NULL, bottomLeft.x + bottomLeftRadius, bottomLeft.y);
	CGPathAddCurveToPoint(path, NULL, bottomLeft.x, bottomLeft.y, bottomLeft.x, bottomLeft.y - bottomLeftRadius, bottomLeft.x, bottomLeft.y - bottomLeftRadius);
	
	CGPathAddLineToPoint(path, NULL, topLeft.x, topLeft.y + topLeftRadius);
	CGPathAddCurveToPoint(path, NULL, topLeft.x, topLeft.y, topLeft.x + topLeftRadius, topLeft.y, topLeft.x + topLeftRadius, topLeft.y);
	
    CGPathCloseSubpath(path);
	
    return path;
}

void CGContextStrokeRectEdge(CGContextRef ctx, CGRect rect, CGRectEdge edge) {
	CGFloat minX, maxX, minY, maxY;
	switch (edge) {
		case CGRectMinXEdge:
			minX = CGRectGetMinX(rect);
			minY = CGRectGetMinY(rect);
			maxX = CGRectGetMinX(rect);
			maxY = CGRectGetMaxY(rect);
			break;
		case CGRectMinYEdge:
			minX = CGRectGetMinX(rect);
			minY = CGRectGetMinY(rect);
			maxX = CGRectGetMaxX(rect);
			maxY = CGRectGetMinY(rect);
			break;
		case CGRectMaxXEdge:
			minX = CGRectGetMaxX(rect);
			minY = CGRectGetMinY(rect);
			maxX = CGRectGetMaxX(rect);
			maxY = CGRectGetMaxY(rect);
			break;
		case CGRectMaxYEdge:
			minX = CGRectGetMinX(rect);
			minY = CGRectGetMaxY(rect);
			maxX = CGRectGetMaxX(rect);
			maxY = CGRectGetMaxY(rect);
			break;
	}
	
    CGContextMoveToPoint(ctx, minX, minY);
    CGContextAddLineToPoint(ctx, maxX, maxY);
	CGContextStrokePath(ctx);
}

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED

void UIGraphicsContextPerformBlock(void (^block)(CGContextRef)) {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(ctx);
	block(ctx);
	CGContextRestoreGState(ctx);
}
void UIRectStrokeWithColor(CGRect rect, CGRectEdge edge, CGFloat width, UIColor *color) {
    UIGraphicsContextPerformBlock(^(CGContextRef ctx) {
        CGContextSetStrokeColorWithColor(ctx, color.CGColor);
        CGContextSetLineWidth(ctx, width);
        CGContextStrokeRectEdge(ctx, rect, edge);
    });
}
UIImage *UIGraphicsContextCreateImage(CGSize size, void (^block)(CGContextRef)) {
	UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
	UIGraphicsContextPerformBlock(block);
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

#else

void NSGraphicsContextPerformBlock(void (^block)(CGContextRef ctx))
{
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState(ctx);
	block(ctx);
	CGContextRestoreGState(ctx);
}
void NSRectStrokeWithColor(CGRect rect, CGRectEdge edge, CGFloat width, NSColor *color)
{
	NSGraphicsContextPerformBlock(^(CGContextRef ctx) {
		CGContextSetStrokeColorWithColor(ctx, color.CGColor);
		CGContextSetLineWidth(ctx, width);
		CGContextStrokeRectEdge(ctx, rect, edge);
	});
}

#endif