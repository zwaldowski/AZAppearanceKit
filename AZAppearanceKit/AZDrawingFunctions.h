//
//  AZDrawingFunctions.h
//  AZAppearanceKit
//
//  Created by Victor Pena Placer on 2/28/12.
//  Copyright (c) 2012 Victor Pena Placer. All rights reserver.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>

extern void CGContextStrokeRectEdge(CGContextRef ctx, CGRect rect, CGRectEdge edge);

extern CGPathRef CGPathCreateWithRoundedRect(CGRect rect, CGFloat cornerRadius);
extern CGPathRef CGPathCreateByRoundingCornersInRect(CGRect rect, CGFloat topLeftRadius, CGFloat topRightRadius, CGFloat bottomLeftRadius, CGFloat bottomRightRadius);

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED

extern void UIGraphicsContextPerformBlock(void (^)(CGContextRef ctx));
extern void UIRectStrokeWithColor(CGRect rect, CGRectEdge edge, CGFloat width, UIColor *color);
extern UIImage *UIGraphicsContextCreateImage(CGSize size, BOOL opaque, void (^contextBlock)(CGContextRef ctx));

#endif