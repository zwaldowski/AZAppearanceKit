//
//  AZTabBar.m
//  AZAppearanceKit
//
//  Created by Victor Pena Placer on 3/1/12.
//  Copyright (c) 2012 Victor Pena Placer. All rights reserved.
//  Copyright (c) 2012 Zachary Waldowski. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AZDrawingFunctions.h"
#import "AZGradient.h"
#import "AZTabBar.h"

@implementation AZTabBar

- (id) initWithCoder: (NSCoder *) aDecoder
{
    if ((self = [super initWithCoder: aDecoder]))
	{
		[self az_sharedInit];
    }
	
    return self;
}
- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame: frame]))
	{
		[self az_sharedInit];
    }
	
    return self;
}

- (void) az_sharedInit
{
    self.contentMode = UIViewContentModeRedraw;
	self.gradient = [[AZGradient alloc] initWithStartingColor: [UIColor colorWithWhite: 0.267 alpha: 1.0] endingColor: [UIColor colorWithWhite: 0.024 alpha: 1.0]];
	self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.separatorLineColor = [UIColor colorWithWhite: 0.4 alpha: 1.0];
    self.shadowOpacity = 0.5;
}
- (void) drawRect: (CGRect) rect
{
	[self.gradient drawInRect: rect direction: AZGradientDirectionVertical];
	UIRectStrokeWithColor(rect, CGRectMinYEdge, 2.5f, self.separatorLineColor);
}
- (void) layoutSubviews
{
	[super layoutSubviews];
	
    CGPathRef path = CGPathCreateWithRect(self.bounds, NULL);
	self.layer.shadowPath = path;
    CGPathRelease(path);
}
- (void) setShadowOpacity: (float) shadowOpacity
{
	_shadowOpacity = shadowOpacity;
	self.layer.shadowOpacity = shadowOpacity;
}

@end
