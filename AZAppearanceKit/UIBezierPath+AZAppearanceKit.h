//
//  UIBezierPath+AZAppearanceKit.h
//  AZAppearanceKitDemo
//
//  Created by Zachary Waldowski on 10/29/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED

#import <UIKit/UIKit.h>

@interface UIBezierPath (AZAppearanceKit)

+ (UIBezierPath *)bezierPathByRoundingCornersInRect:(CGRect)rect topLeft:(CGFloat)topLeftRadius topRight:(CGFloat)topRightRadius bottomLeft:(CGFloat)bottomLeftRadius bottomRight:(CGFloat)bottomRightRadius;

- (void)strokeEdge:(CGRectEdge)edge;

@end

#endif