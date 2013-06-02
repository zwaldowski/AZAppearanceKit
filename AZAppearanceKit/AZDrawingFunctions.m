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

void CGContextPerformBlock(CGContextRef ctx, void (^block)(CGContextRef ctx)) {
	if (!block) return;
	CGContextSaveGState(ctx);
	block(ctx);
	CGContextRestoreGState(ctx);
}

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED

void UIGraphicsContextPerformBlock(void (^block)(CGContextRef)) {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextPerformBlock(ctx, block);
}
void UIRectStrokeWithColor(CGRect rect, CGRectEdge edge, CGFloat width, UIColor *color) {
    UIGraphicsContextPerformBlock(^(CGContextRef ctx) {
        CGContextSetStrokeColorWithColor(ctx, color.CGColor);
        CGContextSetLineWidth(ctx, width);
        CGContextStrokeRectEdge(ctx, rect, edge);
    });
}

static inline size_t aligned_size(size_t size, size_t alignment) {
	size_t r = size + --alignment + 2;
	return (r + 2 + alignment) & ~alignment;
}

UIImage *UIImageCreateUsingBlock(CGSize size, BOOL opaque, void(^drawingBlock)(CGContextRef ctx)) {
	BOOL isMain = [NSThread isMainThread];
	CGContextRef context = NULL;
	CGFloat scale;
	
	if (isMain) {
		UIGraphicsBeginImageContextWithOptions(size, opaque, 0.0);
		context = UIGraphicsGetCurrentContext();
	} else {
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		scale = [UIScreen mainScreen].scale;
		CGImageAlphaInfo alphaInfo = 0;
		if (opaque) {
			alphaInfo |= kCGImageAlphaNoneSkipFirst;
		} else {
			alphaInfo |= kCGImageAlphaPremultipliedFirst;
		}
		
		// RGB - 32 bpp - 8 bpc - available on both OS X and iOS
		const size_t bitsPerPixel = 32;
		const size_t bitsPerComponent = 8;
		const size_t widthPixels = size.width * scale;
		
		// Quartz 2D Programming Guide
		// "When you create a bitmap graphics context, you’ll get the best
		// performance if you make sure the data and bytesPerRow are 16-byte aligned."
		size_t bytesPerRow = widthPixels * bitsPerPixel;
		size_t alignedBytesPerRow = aligned_size(bytesPerRow, 16);
		
		context = CGBitmapContextCreate(NULL, widthPixels, size.height * scale, bitsPerComponent, alignedBytesPerRow, colorSpace, alphaInfo);
		CGColorSpaceRelease(colorSpace);
		CGContextScaleCTM(context, scale, -1 * scale);
		CGContextTranslateCTM(context, 0, -1 * size.height);
		CGContextClipToRect(context, (CGRect){ CGPointZero, size });
		UIGraphicsPushContext(context);
	}
	
	if (drawingBlock) drawingBlock(context);
	
    UIImage *retImage = nil;
	
	if (isMain) {
		retImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	} else {
		UIGraphicsPopContext();
		CGImageRef cgImage = CGBitmapContextCreateImage(context);
		retImage = [UIImage imageWithCGImage:cgImage scale:scale orientation:UIImageOrientationUp];
		CGImageRelease(cgImage);
		CGContextRelease(context);
	}
	
	return retImage;
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