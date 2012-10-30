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

@end

@class AZTableViewCellBackground;

@interface AZTableViewCellBackgroundView : UIView

@end

@interface AZTableViewCellBackgroundLayer : CALayer

@property (nonatomic) AZTableViewCellSectionLocation sectionLocation;
@property (nonatomic) CGFloat topCornerRadius;
@property (nonatomic) CGFloat bottomCornerRadius;
@property (nonatomic, readonly) AZTableViewCell *cell;
@property (nonatomic, readonly) AZTableViewCellBackground *background;

@end

@interface AZTableViewCellBackground : UIView

@property (nonatomic, readonly, weak) AZTableViewCell *cell;
@property (nonatomic, readonly, getter = isSelected) BOOL selected;
@property (nonatomic, weak) AZTableViewCellBackgroundView *shadowView;

- (id) initWithCell:(AZTableViewCell *)cell selected:(BOOL)selected;

@end

@implementation AZTableViewCellBackgroundView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor clearColor];
		self.layer.contentsScale = [[UIScreen mainScreen] scale];
		self.layer.shouldRasterize = YES;
		self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
	}
	return self;
}

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

- (AZTableViewCell *)cell {
	return self.background.cell;
}

- (AZTableViewCellBackground *)background {
	return (id)[self.delegate superview];
}

- (void)drawInContext:(CGContextRef)ctx {
	if (!self.cell.tableViewIsGrouped)
		return;

	UIGraphicsPushContext(ctx);
	
	const CGFloat kShadowBlur = 3.0f;
	const CGSize kShadowOffset = CGSizeMake(0, 1);
	const CGFloat shadowMargin = kShadowBlur + MAX(ABS(kShadowOffset.width), ABS(kShadowOffset.height));
	
	CGRect rect = CGContextGetClipBoundingBox(ctx);
	CGRect clippingRect = rect;
	CGFloat topInset = 0, bottomInset = 0;
	switch (self.sectionLocation) {
        case AZTableViewCellSectionLocationTop:
			bottomInset = shadowMargin;
			break;
		case AZTableViewCellSectionLocationMiddle:
            topInset = shadowMargin;
            bottomInset = shadowMargin;
            break;
        case AZTableViewCellSectionLocationBottom:
            topInset = shadowMargin;
            break;
        default:
			break;
	}
	clippingRect.origin.y += topInset;
	clippingRect.size.height -= topInset + bottomInset;
    CGContextClipToRect(ctx, clippingRect);
    
    CGRect innerRect = CGRectInset(rect, shadowMargin, shadowMargin);    
    CGPathRef path = CGPathCreateByRoundingCornersInRect(innerRect, self.topCornerRadius, self.topCornerRadius, self.bottomCornerRadius, self.bottomCornerRadius);
    
    // stroke the primary shadow
    UIGraphicsContextPerformBlock(^(CGContextRef ctx) {
		if (!self.background.selected) [self.cell.shadow set];
        CGContextSetStrokeColorWithColor(ctx, self.cell.borderColor.CGColor);
        CGContextSetLineWidth(ctx, self.cell.shadow ? 0.5 : 1);
        CGContextAddPath(ctx, path);
        CGContextStrokePath(ctx);
    });
    
    // draw the cell background
    UIGraphicsContextPerformBlock(^(CGContextRef ctx) {
        CGContextAddPath(ctx, path);
        CGContextClip(ctx);
        
        CGPoint start = innerRect.origin;
        CGPoint end = CGPointMake(start.x, CGRectGetMaxY(innerRect));
        
        if (self.background.selected && self.cell.selectionStyle != UITableViewCellSelectionStyleNone && self.cell.selectionGradient) {
            CGContextDrawLinearGradient(ctx, self.cell.selectionGradient.gradient, start, end, 0);
        } else if (!self.cell.selected && self.cell.gradient) {
            CGContextDrawLinearGradient(ctx, self.cell.gradient.gradient, start, end, 0);
        } else {
            CGContextSetFillColorWithColor(ctx, self.cell.backgroundColor.CGColor);
            CGContextFillRect(ctx, innerRect);
        }
    });
    
    CGPathRelease(path);
    
    // draw the separator
    if (self.cell.separatorColor && !self.bottomCornerRadius)
        UIRectStrokeWithColor(innerRect, CGRectMaxYEdge, 1, self.cell.separatorColor);

	UIGraphicsPopContext();
}

@end

@implementation AZTableViewCellBackground

@synthesize cell = _cell, selected = _selected, shadowView = _shadowView;

- (id) initWithCell:(AZTableViewCell *)cell selected:(BOOL)selected
{
    if (self = [super initWithFrame: CGRectZero])
    {
        self.backgroundColor = [UIColor clearColor];
		_cell = cell;
		_selected = selected;
		
		AZTableViewCellBackgroundView *shadowView = [[AZTableViewCellBackgroundView alloc] initWithFrame: CGRectZero];
		[self addSubview: shadowView];
		self.shadowView = shadowView;
    }
    return self;
}

- (void)layoutSubviews {
	const CGFloat kShadowBlur = 3.0f;
	const CGSize kShadowOffset = CGSizeMake(0, 1);
	const CGFloat shadowMargin = kShadowBlur + MAX(ABS(kShadowOffset.width), ABS(kShadowOffset.height));
	self.shadowView.frame = CGRectInset(self.bounds, -shadowMargin, -shadowMargin);
}

- (void) setFrame: (CGRect) frame {
    [super setFrame: frame];
	[self setNeedsLayout];
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
	
	[UIView animateWithDuration: animated ? (1./3.) : 0 delay: 0.0 options: UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState animations: ^{
		shadow.sectionLocation = location;
		shadow.topCornerRadius = topRadius;
		shadow.bottomCornerRadius = bottomRadius;
	} completion: NULL];
}

@end

@implementation AZTableViewCell

@synthesize borderColor = _borderColor, separatorColor = _az_separatorColor, cornerRadius = _cornerRadius, selectionGradient = _selectionGradient, tableViewIsGrouped = _tableViewIsGrouped;

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
	[NSException raise: NSInvalidArgumentException format: @"%@ is unavailable on %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])];
}

- (void)setSelectedBackgroundView:(UIView *)selectedBackgroundView {
	[NSException raise: NSInvalidArgumentException format: @"%@ is unavailable on %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])];
}

#pragma mark - UITableViewCell

- (void) prepareForReuse
{
    [super prepareForReuse];
	[[super backgroundView] setNeedsDisplay];
	[[super selectedBackgroundView] setNeedsDisplay];
}

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
