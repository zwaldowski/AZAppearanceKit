//
//  UIImage+AZAppearanceKit.m
//  AZAppearanceKitDemo
//
//  Created by Zachary Waldowski on 11/9/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import "UIImage+AZAppearanceKit.h"

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED

@implementation UIImage (AZAppearanceKit)

+ (UIImage *)az_imageWithSize:(CGSize)size opaque:(BOOL)opaque usingBlock:(void(^)(void))drawingBlock {
	NSParameterAssert(drawingBlock);
	
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

	drawingBlock();

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

@end

#endif