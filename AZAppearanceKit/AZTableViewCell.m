//
//  AZTableViewCell.m
//  AZAppearanceKit
//
//  Created by Victor Pena Placer on 2/28/12.
//  Copyright (c) 2012 Victor Pena Placer. All rights reserved.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import "AZTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "AZGradient.h"
#import "AZDrawingFunctions.h"

typedef NS_ENUM(NSUInteger, AZTableViewCellSectionLocation)  {
    AZTableViewCellSectionLocationNone,
    AZTableViewCellSectionLocationMiddle,
	AZTableViewCellSectionLocationTop,
    AZTableViewCellSectionLocationBottom,
    AZTableViewCellSectionLocationAlone
};

#pragma mark - Background hackery

@interface AZTableViewCell ()

@property (nonatomic, readonly) BOOL tableViewIsGrouped;
@property (nonatomic, readonly, getter = az_shadowMargin) CGSize shadowMargin;

@end

@class AZTableViewCellBackground;

@interface AZTableViewCellBackgroundView : UIView

@end

@interface AZTableViewCellBackgroundLayer : CALayer

@property (nonatomic) AZTableViewCellSectionLocation sectionLocation;
@property (nonatomic) CGFloat topCornerRadius;
@property (nonatomic) CGFloat bottomCornerRadius;

@end

@interface AZTableViewCellBackground : UIView

@property (nonatomic, readonly, weak) AZTableViewCell *cell;
@property (nonatomic, readonly, getter = isSelected) BOOL selected;
@property (nonatomic, weak) AZTableViewCellBackgroundView *shadowView;

- (id) initWithCell:(AZTableViewCell *)cell selected:(BOOL)selected;

@end

@implementation AZTableViewCellBackgroundView

+ (Class)layerClass {
	return [AZTableViewCellBackgroundLayer class];
}

@end

@implementation AZTableViewCellBackgroundLayer

@dynamic sectionLocation;
@dynamic topCornerRadius;
@dynamic bottomCornerRadius;

+ (BOOL)needsDisplayForKey:(NSString *)key {
	if ([key isEqualToString: @"sectionLocation"] ||
		[key isEqualToString: @"topCornerRadius"] ||
		[key isEqualToString: @"bottomCornerRadius"])
		return YES;
	return [super needsDisplayForKey:key];
}

- (id<CAAction>)actionForKey:(NSString *)event {
	if ([event isEqualToString: @"sectionLocation"] ||
		[event isEqualToString: @"topCornerRadius"] ||
		[event isEqualToString: @"bottomCornerRadius"]) {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: event];
        animation.fromValue = [self.presentationLayer valueForKey: event];
        return animation;
	}
	return [super actionForKey:event];
}

- (void)drawInContext:(CGContextRef)ctx {
	AZTableViewCellBackground *background = (id)[(id)self.delegate superview];
	AZTableViewCell *cell = background.cell;

	if (!cell.tableViewIsGrouped)
		return;

	UIGraphicsPushContext(ctx);
	
	const CGSize margin = cell.shadowMargin;
	const AZTableViewCellSectionLocation location = self.sectionLocation;
	CGFloat topRadii = self.topCornerRadius, bottomRadii = self.bottomCornerRadius;
	
	CGRect rect = CGContextGetClipBoundingBox(ctx);
	CGRect clippingRect = rect;
	CGFloat topInset = 0, bottomInset = 0;
	switch (location) {
        case AZTableViewCellSectionLocationTop:
			bottomInset = margin.height;
			break;
		case AZTableViewCellSectionLocationMiddle:
            topInset = margin.height;
            bottomInset = margin.height;
            break;
        case AZTableViewCellSectionLocationBottom:
            topInset = margin.height;
            break;
        default:
			break;
	}
	clippingRect.origin.y += topInset;
	clippingRect.size.height -= topInset + bottomInset;
    CGContextClipToRect(ctx, clippingRect);
    
    CGRect innerRect = CGRectInset(rect, margin.width, margin.height);
    CGPathRef path = CGPathCreateByRoundingCornersInRect(innerRect, topRadii, topRadii, bottomRadii, bottomRadii);
	CGPathRef shadowPath = path;

	if (cell.shadow && !topRadii && (location == AZTableViewCellSectionLocationMiddle || location == AZTableViewCellSectionLocationBottom)) {
		CGRect shadowRect = innerRect;
		shadowRect.origin.y -= cell.shadow.shadowBlurRadius;
		shadowRect.size.height += cell.shadow.shadowBlurRadius;
		shadowPath = CGPathCreateByRoundingCornersInRect(shadowRect, topRadii, topRadii, bottomRadii, bottomRadii);
	}

    // stroke the primary shadow
    UIGraphicsContextPerformBlock(^(CGContextRef ctx) {
		if (!background.selected) [cell.shadow set];
        CGContextSetStrokeColorWithColor(ctx, cell.borderColor.CGColor);
        CGContextSetLineWidth(ctx, cell.shadow ? 0.5 : 1);
        CGContextAddPath(ctx, shadowPath);
        CGContextStrokePath(ctx);
    });
    
    // draw the cell background
    UIGraphicsContextPerformBlock(^(CGContextRef ctx) {
        CGContextAddPath(ctx, path);
        CGContextClip(ctx);
        
        CGPoint start = innerRect.origin;
        CGPoint end = CGPointMake(start.x, CGRectGetMaxY(innerRect));
        
        if (background.selected && cell.selectionStyle != UITableViewCellSelectionStyleNone && cell.selectionGradient) {
            CGContextDrawLinearGradient(ctx, cell.selectionGradient.gradient, start, end, 0);
        } else if (!background.selected && cell.gradient) {
            CGContextDrawLinearGradient(ctx, cell.gradient.gradient, start, end, 0);
        } else {
            CGContextSetFillColorWithColor(ctx, cell.backgroundColor.CGColor);
            CGContextFillRect(ctx, innerRect);
        }
    });
    
    CGPathRelease(path);
    
    // draw the separator
    if (cell.separatorColor && !bottomRadii)
        UIRectStrokeWithColor(innerRect, CGRectMaxYEdge, 1, cell.separatorColor);

	UIGraphicsPopContext();
}

@end

@implementation AZTableViewCellBackground

- (id) initWithCell:(AZTableViewCell *)cell selected:(BOOL)selected
{
    if (self = [super initWithFrame: CGRectZero])
    {
		_cell = cell;
		_selected = selected;
		
		AZTableViewCellBackgroundView *shadowView = [[AZTableViewCellBackgroundView alloc] initWithFrame: CGRectZero];
		shadowView.backgroundColor = [UIColor clearColor];
		shadowView.layer.contentsScale = [[UIScreen mainScreen] scale];
		shadowView.layer.shouldRasterize = YES;
		shadowView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
		[self addSubview: shadowView];
		self.shadowView = shadowView;
    }
    return self;
}

- (void)layoutSubviews {
	CGSize margin = self.cell.shadowMargin;
	self.shadowView.frame = CGRectInset(self.bounds, -margin.width, -margin.height);
}

- (void)setSectionLocation:(AZTableViewCellSectionLocation)location
{
	[self setSectionLocation: location animated: NO];
}

- (void)setSectionLocation:(AZTableViewCellSectionLocation)location animated:(BOOL)animated
{
	AZTableViewCellBackgroundLayer *shadow = (id)self.shadowView.layer;
	
	CGFloat topRadius = 0, bottomRadius = 0, radius = self.cell.cornerRadius;
	
	switch (location)
    {
        case AZTableViewCellSectionLocationTop:
			topRadius = radius;
            break;
        case AZTableViewCellSectionLocationAlone:
			topRadius = radius;
			bottomRadius = radius;
			break;
        case AZTableViewCellSectionLocationBottom:
			bottomRadius = radius;
            break;
        default:
            break;
    }

	[CATransaction begin];
	[CATransaction setAnimationDuration: animated ? (1./3.) : 0];
	[CATransaction setAnimationTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
	shadow.sectionLocation = location;
	shadow.topCornerRadius = topRadius;
	shadow.bottomCornerRadius = bottomRadius;
	[self setNeedsLayout];
	[CATransaction commit];
}

@end

@implementation AZTableViewCell

@synthesize separatorColor = _az_separatorColor;

#pragma mark - Setup and teardown

- (void)az_sharedInit
{
    [super setBackgroundView: [[AZTableViewCellBackground alloc] initWithCell: self selected: NO]];
    [super setSelectedBackgroundView: [[AZTableViewCellBackground alloc] initWithCell: self selected:YES]];
    
	self.shadow = [AZShadow shadowWithOffset: CGSizeMake(0, 1) blurRadius: 3.0f color: [UIColor colorWithWhite: 0 alpha: 0.7]];
    self.borderColor = [UIColor colorWithRed: 0.737 green: 0.737 blue: 0.737 alpha: 1.0];
    self.separatorColor = [UIColor colorWithWhite: 0.804 alpha: 1.0];
    self.selectionGradient = [[AZGradient alloc] initWithStartingColor: [UIColor colorWithRed: 0 green: 0.537 blue: 0.976 alpha: 1] endingColor: [UIColor colorWithRed: 0 green: 0.329 blue: 0.918 alpha: 1]];
    self.cornerRadius = 8.0f;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        [self az_sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder: aDecoder])) {
		[self az_sharedInit];
    }
    return self;
}

#pragma mark - Properties

- (void)setBackgroundView:(UIView *)backgroundView {
	[self doesNotRecognizeSelector: _cmd];
}

- (void)setSelectedBackgroundView:(UIView *)selectedBackgroundView {
	[self doesNotRecognizeSelector: _cmd];
}

- (CGSize)az_shadowMargin {
	if (!self.shadow) return CGSizeZero;
	const CGFloat margin = self.shadow.shadowBlurRadius * 2;
	return CGSizeMake(margin + fabs(self.shadow.shadowOffset.width), margin + fabs(self.shadow.shadowOffset.height));
}

#pragma mark - UITableViewCell

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];
	
	if (newSuperview) {
		_tableViewIsGrouped = (((UITableView *)newSuperview).style == UITableViewStyleGrouped);
	} else {
		_tableViewIsGrouped = NO;
	}
	
	[self setNeedsLayout];
}


@end
