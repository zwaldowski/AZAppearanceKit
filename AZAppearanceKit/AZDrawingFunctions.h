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

extern CGPathRef CGPathCreateByRoundingCornersInRect(CGRect rect, CGFloat topLeftRadius, CGFloat topRightRadius, CGFloat bottomLeftRadius, CGFloat bottomRightRadius);

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED

@interface UIBezierPath (AZDrawingFunctions)

+ (UIBezierPath *)bezierPathByRoundingCornersInRect:(CGRect)rect topLeft:(CGFloat)topLeftRadius topRight:(CGFloat)topRightRadius bottomLeft:(CGFloat)bottomLeftRadius bottomRight:(CGFloat)bottomRightRadius;

- (void)strokeEdge:(CGRectEdge)edge;

@end

extern inline void UIGraphicsContextPerformBlock(void (^)(CGContextRef ctx));
extern void UIRectStrokeWithColor(CGRect rect, CGRectEdge edge, CGFloat width, UIColor *color);

#endif