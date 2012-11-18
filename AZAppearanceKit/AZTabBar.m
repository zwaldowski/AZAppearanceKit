//
//  AZTabBar.m
//  AZAppearanceKit
//
//  Created by Victor Pena Placer on 3/1/12.
//  Copyright (c) 2012 Victor Pena Placer. All rights reserved.
//  Copyright (c) 2012 Zachary Waldowski. All rights reserved.
//

#import "AZTabBar.h"
#import <QuartzCore/QuartzCore.h>
#import "AZGradient.h"
#import "UIBezierPath+AZAppearanceKit.h"

@implementation AZTabBar

@synthesize shadowOpacity = _shadowOpacity, gradient = _gradient, separatorLineColor = _separatorLineColor;

- (void) az_sharedInit 
{
    self.contentMode = UIViewContentModeRedraw;
	self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.shadowOpacity = 0.5;
    self.separatorLineColor = [UIColor colorWithWhite: 0.4 alpha: 1.0];
	self.gradient = [[AZGradient alloc] initWithStartingColor: [UIColor colorWithWhite: 0.267 alpha: 1.0] endingColor: [UIColor colorWithWhite: 0.024 alpha: 1.0]];
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

- (void)setShadowOpacity:(float)shadowOpacity {
	_shadowOpacity = shadowOpacity;
	self.layer.shadowOpacity = shadowOpacity;
}

- (void) layoutSubviews {
	[super layoutSubviews];
	self.layer.shadowPath = [[UIBezierPath bezierPathWithRect: self.bounds] CGPath];
}

- (void) drawRect:(CGRect)rect {
	[self.gradient drawInRect: rect direction: AZGradientDirectionVertical];

	UIBezierPath *path = [UIBezierPath bezierPathWithRect: rect];
	path.lineWidth = 2.5f;

	[self.separatorLineColor setStroke];
	[path strokeEdge: CGRectMinYEdge];
}

@end
