//
//  AZDrawingFunctions.h
//  AZAppearanceKit
//
//  Created by Victor Pena Placer on 2/28/12.
//  Copyright (c) 2012 Victor Pena Placer. All rights reserver.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import <UIKit/UIKit.h>

extern void CGContextStrokeRectEdge(CGContextRef ctx, CGRect rect, CGRectEdge edge);
extern void UIRectStrokeWithColor(CGRect rect, CGRectEdge edge, CGFloat width, UIColor *color);