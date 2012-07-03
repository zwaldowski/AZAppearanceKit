//
//  AZTableViewCell.m
//  AZAppearanceKit
//
//  Created by Victor Pena Placer on 2/28/12.
//  Copyright (c) 2012 Victor Pena Placer. All rights reserver.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import "AZTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "AZGradient.h"
#import "AZDrawingFunctions.h"

static const CGFloat kShadowMargin = 4.0f;

typedef enum {
    AZTableViewCellSectionLocationNone = 0,
    AZTableViewCellSectionLocationMiddle = 1,
	AZTableViewCellSectionLocationTop = 2,
    AZTableViewCellSectionLocationBottom = 3,
    AZTableViewCellSectionLocationAlone = 4
} AZTableViewCellSectionLocation;

static inline UIRectCorner UIRectCornerForSectionLocation(AZTableViewCellSectionLocation pos) {
	UIRectCorner corners = 0;
	
	switch (pos) {
		case AZTableViewCellSectionLocationTop:
			corners = UIRectCornerTopLeft | UIRectCornerTopRight;
			break;
		case AZTableViewCellSectionLocationAlone:
			corners = UIRectCornerAllCorners;
			break;
		case AZTableViewCellSectionLocationBottom:
			corners = UIRectCornerBottomLeft | UIRectCornerBottomRight;
			break;
		default:break;
	}
	
	return corners;
}

@interface AZTableViewCell ()

@property (nonatomic, readonly) BOOL tableViewIsGrouped;

@end

@class AZTableViewCellBackground;

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
@property (nonatomic, weak) AZTableViewCellBackgroundLayer *shadow;

- (id) initWithCell:(AZTableViewCell *)cell selected:(BOOL)selected;

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
	return self.delegate ?: self.superlayer.delegate;
}

- (void)drawInContext:(CGContextRef)ctx {
	[super drawInContext:ctx];
	
	if (!self.cell.tableViewIsGrouped)
		return;
	
	UIGraphicsPushContext(ctx);
	
	const CGFloat kShadowBlur = 3.0f;
	const CGSize kShadowOffset = CGSizeMake(0, 1);
	const CGFloat shadowMargin = kShadowBlur + MAX(ABS(kShadowOffset.width), ABS(kShadowOffset.height));
	
	CGRect rect = CGContextGetClipBoundingBox(ctx);
	CGRect innerRect = CGRectInset(rect, shadowMargin, shadowMargin);

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
	
	CGFloat topRadius = self.topCornerRadius, bottomRadius = self.bottomCornerRadius;
	
	CGContextSaveGState(ctx);

	CGContextClipToRect(ctx, clippingRect);
	
	CGPathRef(^roundedPath)(CGRect) = ^CGPathRef(CGRect rect){
		CGPoint minPoint = rect.origin;
		CGPoint maxPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathMoveToPoint(path, NULL, minPoint.x + topRadius, minPoint.y);
		CGPathAddArcToPoint(path, NULL, maxPoint.x, minPoint.y, maxPoint.x, minPoint.y + topRadius, topRadius);
		CGPathAddArcToPoint(path, NULL, maxPoint.x, maxPoint.y, maxPoint.x - bottomRadius, maxPoint.y, bottomRadius);
		CGPathAddArcToPoint(path, NULL, minPoint.x, maxPoint.y, minPoint.x, maxPoint.y - bottomRadius, bottomRadius);
		CGPathAddArcToPoint(path, NULL, minPoint.x, minPoint.y, minPoint.x + topRadius, minPoint.y, topRadius);
		CGPathCloseSubpath(path);
		return path;
	};
	
	CGPathRef cgPath = roundedPath(innerRect);
	
	// stroke the primary shadow
	UIGraphicsContextPerform(^(CGContextRef ctx) {
		if (self.cell.shadowColor) {
			CGContextSetShadowWithColor(ctx, kShadowOffset, kShadowBlur, self.cell.shadowColor.CGColor);
		}
		CGContextSetStrokeColorWithColor(ctx, self.cell.borderColor.CGColor);
		CGContextSetLineWidth(ctx, self.cell.shadowColor ? 0.5 : 1);
		CGContextAddPath(ctx, cgPath);
		CGContextStrokePath(ctx);

	});
	
	// draw the cell background
	UIBezierPath *path = [UIBezierPath bezierPathWithCGPath: cgPath];
	
	if (self.background.selected && self.cell.selectionStyle != UITableViewCellSelectionStyleNone && self.cell.selectionGradient) {
		[self.cell.selectionGradient drawInBezierPath: path direction: AZGradientDirectionVertical];
    } else if (!self.cell.selected && self.cell.gradient) {
		[self.cell.gradient drawInBezierPath: path direction: AZGradientDirectionVertical];
    } else {
		[self.cell.backgroundColor setFill];
		[path fill];
	}
	
	CGPathRelease(cgPath);
	
	// draw the separator
	if (self.cell.separatorColor && !self.bottomCornerRadius)
		UIRectStrokeWithColor(innerRect, CGRectMaxYEdge, 1, self.cell.separatorColor);
	
	CGContextRestoreGState(ctx);
	
	UIGraphicsPopContext();
}

@end

@implementation AZTableViewCellBackground

@synthesize cell = _cell;
@synthesize selected = _selected;
@synthesize shadow = _shadow;

- (id) initWithCell:(AZTableViewCell *)cell selected:(BOOL)selected
{
    if (self = [super initWithFrame: CGRectZero])
    {
        self.backgroundColor = [UIColor clearColor];
		_cell = cell;
		_selected = selected;
		
		AZTableViewCellBackgroundLayer *shadow = [AZTableViewCellBackgroundLayer layer];
		shadow.contentsScale = [[UIScreen mainScreen] scale];
		self.shadow = shadow;
		[self.layer addSublayer: shadow];
		
    }
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
	self.shadow.frame = CGRectInset(layer.bounds, -kShadowMargin, -kShadowMargin);
}

- (void)setSectionLocation:(AZTableViewCellSectionLocation)location
{
	[self setSectionLocation: location animated: NO];
}

- (void)setSectionLocation:(AZTableViewCellSectionLocation)location animated:(BOOL)animated
{
	AZTableViewCellBackgroundLayer *shadow = self.shadow;
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

	void (^animation)(void) = ^{
		shadow.sectionLocation = location;
		shadow.topCornerRadius = topRadius;
		shadow.bottomCornerRadius = bottomRadius;
	};
	
	if (animated) {
		[UIView animateWithDuration: 0.33 delay: 0.0 options: UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState animations: animation completion: NULL];
	} else {
		[CATransaction begin];
		[CATransaction setDisableActions: YES];
		animation();
		[CATransaction commit];
	}
}

@end

@implementation AZTableViewCell

@synthesize shadowColor = _shadowColor;
@synthesize borderColor = _borderColor;
@synthesize separatorColor = _az_separatorColor;
@synthesize cornerRadius = _cornerRadius;
@synthesize selectionGradient = _selectionGradient;
@synthesize tableViewIsGrouped = _tableViewIsGrouped;

#pragma mark - Setup and teardown

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {		
		[super setBackgroundView: [[AZTableViewCellBackground alloc] initWithCell: self selected: NO]];
		[super setSelectedBackgroundView: [[AZTableViewCellBackground alloc] initWithCell: self selected:YES]];
		
		self.shadowColor = [UIColor colorWithWhite: 0.0 alpha: 0.7];
		self.borderColor = [UIColor colorWithRed: 0.737 green: 0.737 blue: 0.737 alpha: 1.0];
		self.separatorColor = [UIColor colorWithWhite: 0.804 alpha: 1.0];
		self.selectionGradient = [[AZGradient alloc] initWithStartingColor: [UIColor colorWithRed: 0 green: 0.537 blue: 0.976 alpha: 1] endingColor: [UIColor colorWithRed: 0 green: 0.329 blue: 0.918 alpha: 1]];
		self.cornerRadius = 8.0f;
    }
    return self;
}

#pragma mark - Properties

- (UITableViewCellSelectionStyle)selectionStyle
{
	return self.customView ? UITableViewCellSelectionStyleNone : [super selectionStyle];
}

- (void) setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
	if (self.customView)
		self.customView.backgroundColor = backgroundColor;
}

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

- (void)layoutSubviews {
	[super layoutSubviews];
	
    if (!self.customView)
		return;
	
	/*AZTableViewCellBackground *backgroundView = (AZTableViewCellBackground *) [super backgroundView];
	AZTableViewCellSectionLocation location = backgroundView.sectionLocation;
	CGRect innerFrame = backgroundView.frame;
	
	if (self.tableViewIsGrouped) {
		CGFloat shadowMargin = kShadowMargin;
		CGFloat topMargin = 0, bottomMargin = 0;
		
		switch (location) {
			case AZTableViewCellSectionLocationTop:
				topMargin = shadowMargin;
			case AZTableViewCellSectionLocationMiddle:
				bottomMargin = self.tableViewIsGrouped ? 1 : 0;
				break;
			case AZTableViewCellSectionLocationAlone:
				topMargin = shadowMargin;
				bottomMargin = shadowMargin;
				break;
			case AZTableViewCellSectionLocationBottom:
				bottomMargin = shadowMargin;
				break;
			default:
				break;
		}
		
		innerFrame = CGRectInset(innerFrame, shadowMargin/2, 0);
		innerFrame.origin.y += topMargin;
		innerFrame.size.height -= topMargin + bottomMargin;
	}*/
	
	/*self.customView.frame = self.contentView.bounds;
	
	if (![self.customView.superview isEqual: self])
		[self.contentView addSubview:self.customView];*/
	
	/*if (!self.customView.layer.mask) {
		self.customView.layer.mask = [[CAShapeLayer alloc] init];
		self.customView.layer.masksToBounds = YES;
	}
	
	CGFloat radius = self.tableViewIsGrouped ? self.cornerRadius : 0;
	CGRect maskRect = (CGRect){ CGPointZero, innerFrame.size };
	UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: maskRect
												   byRoundingCorners: UIRectCornerForSectionLocation(location)
														 cornerRadii: CGSizeMake(radius, radius)];

	[(CAShapeLayer *)self.customView.layer.mask setPath: maskPath.CGPath];
	self.customView.layer.mask.frame = maskRect;*/
}

@end
