//
//  AZGradientView.m
//  AZAppearanceKitDemo
//
//  Created by Zachary Waldowski on 6/29/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import "AZGradientView.h"
#import <QuartzCore/QuartzCore.h>

@interface AZGradientLayer : CALayer

@property (nonatomic, strong) AZGradient *gradient;
@property (nonatomic) AZGradientViewType type;
@property (nonatomic) CGFloat angle;
@property (nonatomic) CGPoint relativeCenterPosition;

@end

@implementation AZGradientLayer

@dynamic gradient, type, angle, relativeCenterPosition;

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:@"gradient"] || [key isEqualToString:@"type"] || [key isEqualToString:@"angle"] || [key isEqualToString:@"relativeCenterPosition"]) {
		return YES;
	} else {
		return [super needsDisplayForKey:key];
	}
}

- (id < CAAction >)actionForKey:(NSString *)key
{
	if ([key isEqualToString:@"gradient"] || [key isEqualToString:@"type"]) {
		CATransition *transition = [CATransition animation];
		transition.fillMode = kCAFillModeForwards;
		return transition;
	} else if ([key isEqualToString:@"angle"] || [key isEqualToString:@"relativeCenterPosition"]) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: key];
        animation.fromValue = [self.presentationLayer valueForKey: key];
        return animation;
    } else {
        return [super actionForKey:key];
    }
}

- (void)drawInContext:(CGContextRef)context {
	[super drawInContext: context];
	
	UIGraphicsPushContext(context);
	
	if (self.type == AZGradientViewTypeLinear) {
		[self.gradient drawInRect: self.bounds angle: self.angle];
	} else {
		[self.gradient drawInRect: self.bounds relativeCenterPosition: self.relativeCenterPosition];
	}
	
	UIGraphicsPopContext();
}

@end

@implementation AZGradientView

+ (Class)layerClass {
	return [AZGradientLayer class];
}

- (void)az_sharedInit {
	self.layer.shouldRasterize = YES;
	self.layer.rasterizationScale = self.layer.contentsScale = [[UIScreen mainScreen] scale];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder: aDecoder])) {
		[self az_sharedInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self az_sharedInit];
    }
    return self;
}

- (id)initWithGradient:(AZGradient *)gradient {
	if ((self = [super initWithFrame: CGRectZero])) {
		self.gradient = gradient;
		[self az_sharedInit];
	}
	return self;
}

#pragma mark - Accessors

- (AZGradient *)gradient {
	AZGradientLayer *layer = (AZGradientLayer *)self.layer;
	return layer.gradient;
}

- (void)setGradient:(AZGradient *)gradient {
	[self setGradient: gradient animated: NO];
}

- (void)setGradient:(AZGradient *)gradient animated:(BOOL)animated {
	[CATransaction begin];
	[CATransaction setAnimationDuration: animated ? 0.33 : 0];
	[CATransaction setAnimationTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
	AZGradientLayer *layer = (AZGradientLayer *)self.layer;
	layer.gradient = gradient;
	[CATransaction commit];
}

- (AZGradientViewType)type {
	AZGradientLayer *layer = (AZGradientLayer *)self.layer;
	return layer.type;
}

- (void)setType:(AZGradientViewType)type {
	[self setType: type animated: NO];
}

- (void)setType:(AZGradientViewType)type animated:(BOOL)animated {
	[CATransaction begin];
	[CATransaction setAnimationDuration: animated ? 0.33 : 0];
	[CATransaction setAnimationTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
	AZGradientLayer *layer = (AZGradientLayer *)self.layer;
	layer.type = type;
	[CATransaction commit];
}

- (CGFloat)angle {
	AZGradientLayer *layer = (AZGradientLayer *)self.layer;
	return layer.angle;
}

- (void)setAngle:(CGFloat)angle {
	[self setAngle: angle animated: NO];
}

- (void)setAngle:(CGFloat)angle animated:(BOOL)animated {
	[CATransaction begin];
	[CATransaction setAnimationDuration: animated ? 0.33 : 0];
	[CATransaction setAnimationTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
	AZGradientLayer *layer = (AZGradientLayer *)self.layer;
	layer.angle = angle;
	[CATransaction commit];
}

- (CGPoint)relativeCenterPosition {
	AZGradientLayer *layer = (AZGradientLayer *)self.layer;
	return layer.relativeCenterPosition;
}

- (void)setRelativeCenterPosition:(CGPoint)relativeCenterPosition {
	[self setRelativeCenterPosition: relativeCenterPosition animated: NO];
}

- (void)setRelativeCenterPosition:(CGPoint)relativeCenterPosition animated:(BOOL)animated {
	[CATransaction begin];
	[CATransaction setAnimationDuration: animated ? 0.33 : 0];
	[CATransaction setAnimationTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
	AZGradientLayer *layer = (AZGradientLayer *)self.layer;
	layer.relativeCenterPosition = relativeCenterPosition;
	[CATransaction commit];
}

@end
