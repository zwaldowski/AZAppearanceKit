//
//  AZDrawingFunctions.m
//  AZAppearanceKit
//
//  Created by Victor Pena Placer on 2/28/12.
//  Copyright (c) 2012 Victor Pena Placer. All rights reserver.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import "AZDrawingFunctions.h"

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

void UIGraphicsContextPerformBlock(void (^block)(CGContextRef)) {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(ctx);
	block(ctx);
	CGContextRestoreGState(ctx);
}

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED

void UIRectStrokeWithColor(CGRect rect, CGRectEdge edge, CGFloat width, UIColor *color) {
    UIGraphicsContextPerformBlock(^(CGContextRef ctx) {
        CGContextSetStrokeColorWithColor(ctx, color.CGColor);
        CGContextSetLineWidth(ctx, width);
        CGContextStrokeRectEdge(ctx, rect, edge);
    });
}

#endif