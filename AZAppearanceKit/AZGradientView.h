//
//  AZGradientView.h
//  AZAppearanceKitDemo
//
//  Created by Zachary Waldowski on 6/29/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AZGradient.h"

typedef enum _AZGradientViewType {
	AZGradientViewTypeLinear,
	AZGradientViewTypeRadial
} AZGradientViewType;

@interface AZGradientView : UIView

- (id)initWithGradient:(AZGradient *)gradient;

@property (nonatomic, strong) AZGradient *gradient;
- (void)setGradient:(AZGradient *)gradient animated:(BOOL)animated;

@property (nonatomic) AZGradientViewType type;
- (void)setType:(AZGradientViewType)type animated:(BOOL)animated;

@property (nonatomic) CGFloat angle;
- (void)setAngle:(CGFloat)angle animated:(BOOL)animated;

@property (nonatomic) CGPoint relativeCenterPosition;
- (void)setRelativeCenterPosition:(CGPoint)relativeCenterPosition animated:(BOOL)animated;

@end
