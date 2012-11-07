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

UIImage *AZGraphicsCreateImageUsingBlock(CGSize size, BOOL opaque, void (^contextBlock)(void)) {
	BOOL isMain = (dispatch_get_current_queue() == dispatch_get_main_queue());
	CGContextRef context = NULL;
	CGColorSpaceRef colorSpace = NULL;

	if (isMain) {
		UIGraphicsBeginImageContextWithOptions(size, opaque, 0.0);
		context = UIGraphicsGetCurrentContext();
	} else {
		colorSpace = CGColorSpaceCreateDeviceRGB();
		CGFloat scale = [UIScreen mainScreen].scale;
		context = CGBitmapContextCreate(NULL, size.width * scale, size.height * scale, 8, size.width * scale, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Host);
		UIGraphicsPushContext(context);
	}

	contextBlock();

    UIImage *retImage = nil;

	if (isMain) {
		retImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	} else {
		UIGraphicsPopContext();
		CGImageRef cgImage = CGBitmapContextCreateImage(context);
		retImage = [UIImage imageWithCGImage:cgImage];
		CGImageRelease(cgImage);
		CGContextRelease(context);
		CGColorSpaceRelease(colorSpace);
	}

	return retImage;
}

#endif