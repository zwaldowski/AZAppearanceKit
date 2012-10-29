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

@interface AZTableViewCellBackgroundLayer : CALayer

@property (nonatomic) CGFloat topCornerRadius;
@property (nonatomic) CGFloat bottomCornerRadius;

@end

@interface AZTableViewCellBackground : UIView

@property (nonatomic) AZTableViewCellSectionLocation sectionLocation;
- (void)setSectionLocation:(AZTableViewCellSectionLocation)sectionLocation animated:(BOOL)animated;

@property (nonatomic, readonly, weak) AZTableViewCell *cell;
@property (nonatomic, readonly, getter = isSelected) BOOL selected;

- (id) initWithCell:(AZTableViewCell *)cell selected:(BOOL)selected;

@end

@implementation AZTableViewCellBackgroundLayer

@dynamic topCornerRadius, bottomCornerRadius;

- (id<CAAction>)actionForKey:(NSString *)event {
	if ([event isEqualToString: @"topCornerRadius"] || [event isEqualToString: @"bottomCornerRadius"]) {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: event];
		animation.fromValue = [self.presentationLayer valueForKey: event];
		animation.fillMode = kCAFillModeForwards;
        return animation;
	}
	return [super actionForKey:event];
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
	if ([key isEqualToString: @"topCornerRadius"] || [key isEqualToString: @"bottomCornerRadius"]) return YES;
	return [super needsDisplayForKey:key];
}

- (AZTableViewCell *)cell {
	return [self.delegate cell];
}

- (void)layoutSublayers
{
	[super layoutSublayers];
	self.masksToBounds = NO;
	
	CGFloat topCornerRadius = self.topCornerRadius;
	CGFloat bottomCornerRadius = self.bottomCornerRadius;
    CGPathRef path = CGPathCreateByRoundingCornersInRect(self.bounds, topCornerRadius, topCornerRadius, bottomCornerRadius, bottomCornerRadius);
	self.shadowPath = path;
	CGPathRelease(path);
}

- (void)drawInContext:(CGContextRef)ctx {
	if (!self.cell.tableViewIsGrouped)
		return;

	UIGraphicsPushContext(ctx);

	const CGFloat kShadowBlur = 3.0f;
	const CGSize kShadowOffset = CGSizeMake(0, 1);
	const CGFloat shadowMargin = kShadowBlur + MAX(ABS(kShadowOffset.width), ABS(kShadowOffset.height));

	CGRect rect = CGContextGetClipBoundingBox(ctx);
	/*CGRect clippingRect = rect;
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
	 CGContextClipToRect(ctx, clippingRect);*/

    //CGRect innerRect = CGRectInset(rect, shadowMargin, shadowMargin);
	CGRect innerRect = rect;


	CGFloat topCornerRadius = self.topCornerRadius;
	CGFloat bottomCornerRadius = self.bottomCornerRadius;
    CGPathRef path = CGPathCreateByRoundingCornersInRect(innerRect, topCornerRadius, topCornerRadius, bottomCornerRadius, bottomCornerRadius);

    // stroke the primary shadow
    UIGraphicsContextPerformBlock(^(CGContextRef ctx) {
        //CGContextSetShadowWithColor(ctx, kShadowOffset, kShadowBlur, self.cell.shadowColor.CGColor);
        CGContextSetStrokeColorWithColor(ctx, self.cell.borderColor.CGColor);
        CGContextSetLineWidth(ctx, self.cell.shadowColor ? 0.5 : 1);
        CGContextAddPath(ctx, path);
        CGContextStrokePath(ctx);
    });

    // draw the cell background
    UIGraphicsContextPerformBlock(^(CGContextRef ctx) {
        CGContextAddPath(ctx, path);
        CGContextClip(ctx);

        CGPoint start = innerRect.origin;
        CGPoint end = CGPointMake(start.x, CGRectGetMaxY(innerRect));

        if ([self.delegate isSelected] && self.cell.selectionStyle != UITableViewCellSelectionStyleNone && self.cell.selectionGradient) {
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
    if (self.cell.separatorColor && !bottomCornerRadius)
        UIRectStrokeWithColor(innerRect, CGRectMaxYEdge, 1, self.cell.separatorColor);

	UIGraphicsPopContext();
}

@end

@implementation AZTableViewCellBackground {
	NSUInteger _az_animationCount;
}

+ (Class)layerClass {
	return [AZTableViewCellBackgroundLayer class];
}

- (BOOL)isAnimating {
	return !!self.layer.animationKeys;
}

- (id) initWithCell:(AZTableViewCell *)cell selected:(BOOL)selected
{
    if (self = [super initWithFrame: CGRectZero])
    {
        self.backgroundColor = [UIColor clearColor];
		self.layer.contentsScale = self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
		self.layer.shouldRasterize = YES;
//		self.layer.drawsAsynchronously = YES;
		_cell = cell;
		_selected = selected;
    }
    return self;
}

- (void)az_incrementAnimations {
	_az_animationCount++;
	self.opaque = NO;
	//self.backgroundColor = nil;
	[self layoutSubviews];
}

- (void)az_decrementAnimations {
	_az_animationCount--;
	if (!_az_animationCount) self.opaque = YES;
	[self layoutSubviews];
}

- (void)setFrame:(CGRect)frame {
	if (!CGRectEqualToRect(frame, [super frame])) {
		void(^anim)(void) = ^{
			[super setFrame: frame];
			[self setNeedsLayout];
		};

		if (self.isAnimating) {
			[self az_incrementAnimations];
			[UIView animateWithDuration: 0.33 delay: 0 options: UIViewAnimationOptionBeginFromCurrentState animations: anim
							 completion:^(BOOL finished) {
				[self az_decrementAnimations];
			}];
		} else {
			anim();
		}
	} else {
		[super setFrame: frame];
	}
}

- (CGFloat)az_pixelDisplayedImageHeight {
	switch (self.sectionLocation) {
        case AZTableViewCellSectionLocationMiddle:
			return 1.0;
            break;
        case AZTableViewCellSectionLocationAlone:
			return 2 * (self.cell.cornerRadius + 2);
			break;
        default:
			return (self.cell.cornerRadius + 2);
            break;
	}
}


- (CGRect)az_contentsCenter:(BOOL)animated {
	if (animated) {
		switch (self.sectionLocation) {
			case AZTableViewCellSectionLocationTop:
				return CGRectMake(0.5, 0.95, 0, 0); // center bottom
				break;
			case AZTableViewCellSectionLocationBottom:
				return CGRectMake(0.5, 0.05, 0, 0); // center top
				break;
			default:
				return CGRectMake(0.5, 0.5, 0, 0); // drag out the middle
				break;
		}
	}
	return CGRectMake(0, 0, 1, 1);
}

- (CGRect)az_contentsRect:(BOOL)animated {
	if (animated) {
		switch (self.sectionLocation) {
			case AZTableViewCellSectionLocationTop:
				return CGRectMake(0, 0, 1, 0.5); // top half
				break;
			case AZTableViewCellSectionLocationMiddle:
				return CGRectMake(0, 0.475, 1, 0.05); // middle bits
				break;
			case AZTableViewCellSectionLocationBottom:
				return CGRectMake(0, 0.5, 1, 0.5); // bottom half
				break;
			default: break;
		}
	}
	return CGRectMake(0, 0, 1, 1);
}

- (void)layoutSubviews {
	const CGFloat kShadowBlur = 3.0f;
	const CGSize kShadowOffset = CGSizeMake(0, 1);
	const CGFloat shadowMargin = (kShadowBlur * 2) + MAX(ABS(kShadowOffset.width), ABS(kShadowOffset.height));
	self.layer.contentsRect = [self az_contentsRect: (_az_animationCount > 0) ? YES : NO];
	self.layer.contentsCenter = [self az_contentsCenter: (_az_animationCount > 0) ? YES : NO];
	self.layer.shadowOffset = kShadowOffset;
	self.layer.shadowRadius = kShadowBlur;
	self.layer.shadowColor = self.cell.shadowColor.CGColor;
	self.layer.shadowOpacity = 1.0;
	[self.layer setNeedsDisplay];
	
	UIEdgeInsets insets = UIEdgeInsetsZero;
	
	switch (self.sectionLocation) {
		case AZTableViewCellSectionLocationTop:
			insets.top = insets.left = insets.right = -shadowMargin;
			break;
			
		case AZTableViewCellSectionLocationMiddle:
			insets.left = insets.right = -shadowMargin;
			break;
			
		case AZTableViewCellSectionLocationBottom:
			insets.left = insets.bottom = insets.right = -shadowMargin;
			break;
			
		case AZTableViewCellSectionLocationAlone:
			insets.top = insets.left = insets.right = insets.bottom = -shadowMargin;
			break;
			
		default:
			break;
	}
	
	CALayer *mask = [CALayer layer];
	mask.backgroundColor = [UIColor blackColor].CGColor;
	mask.frame = UIEdgeInsetsInsetRect(self.layer.bounds, insets);
	self.layer.mask = mask;
}

- (void)setSectionLocation:(AZTableViewCellSectionLocation)location
{
	[self setSectionLocation: location animated: NO];
}

- (void)setSectionLocation:(AZTableViewCellSectionLocation)location animated:(BOOL)animated
{
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
	
	//[UIView animateWithDuration: animated ? 0.33 : 0 delay: 0.0 options: UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState animations: ^{
		_sectionLocation = location;
		((AZTableViewCellBackgroundLayer *)self.layer).topCornerRadius = topRadius;
		((AZTableViewCellBackgroundLayer *)self.layer).bottomCornerRadius = bottomRadius;
	//} completion: NULL];
}

@end

@implementation AZTableViewCell

@synthesize shadowColor = _shadowColor, borderColor = _borderColor, separatorColor = _az_separatorColor, cornerRadius = _cornerRadius, selectionGradient = _selectionGradient, tableViewIsGrouped = _tableViewIsGrouped;

#pragma mark - Setup and teardown

- (void)az_sharedInit
{
    [super setBackgroundView: [[AZTableViewCellBackground alloc] initWithCell: self selected: NO]];
    [super setSelectedBackgroundView: [[AZTableViewCellBackground alloc] initWithCell: self selected:YES]];
    
    self.shadowColor = [UIColor colorWithWhite: 0.0 alpha: 0.7];
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
