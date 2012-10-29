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

- (id)init {
	if ((self = [super init])) {
		CALayer *mask = [CALayer layer];
		CABasicAnimation *boundsAnim = [CABasicAnimation animationWithKeyPath: @"bounds"];
		boundsAnim.fillMode = kCAFillModeForwards;
		mask.actions = @{ @"bounds" : boundsAnim};
		mask.backgroundColor = [UIColor blackColor].CGColor;
		self.mask = mask;
		self.masksToBounds = NO;
		self.shadowOffset = CGSizeMake(0, 1);
		self.shadowRadius = 3.0f;
	}
	return self;
}

- (id<CAAction>)actionForKey:(NSString *)event {
	if ([event isEqualToString: @"topCornerRadius"] || [event isEqualToString: @"bottomCornerRadius"] || [event isEqualToString: @"shadowPath"]) {
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

	CGFloat topRadius = self.topCornerRadius;
	CGFloat bottomRadius = self.bottomCornerRadius;
	CGRect rect = self.bounds;
	const CGFloat shadowMargin = (2*self.shadowRadius);
	CGFloat topInset = 0, bottomInset = 0;
	switch ([self.delegate sectionLocation]) {
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
		default: break;
	}
	rect.origin.y -= topInset;
	rect.size.height += topInset + bottomInset;
	
	CGPathRef path = CGPathCreateByRoundingCornersInRect(rect, topRadius, topRadius, bottomRadius, bottomRadius);
	self.shadowPath = path;
	CGPathRelease(path);
}

- (void)drawInContext:(CGContextRef)ctx {
	if (!self.cell.tableViewIsGrouped)
		return;

	UIGraphicsPushContext(ctx);

	CGRect rect = CGContextGetClipBoundingBox(ctx);
	CGFloat topRadius = self.topCornerRadius;
	CGFloat bottomRadius = self.bottomCornerRadius;
	
	UIBezierPath *path = [UIBezierPath bezierPathByRoundingCornersInRect: rect topLeft: topRadius topRight: topRadius bottomLeft: bottomRadius bottomRight: bottomRadius];
	
	[self.cell.backgroundColor setFill];
	[self.cell.borderColor setStroke];

    // stroke the primary shadow
	path.lineWidth = self.shadowColor ? 0.5 : 1;
	[path stroke];

    // draw the cell background
	if ([self.delegate isSelected] && self.cell.selectionStyle != UITableViewCellSelectionStyleNone && self.cell.selectionGradient) {
		[self.cell.selectionGradient drawInBezierPath: path direction: AZGradientDirectionVertical];
	} else if (!self.cell.selected && self.cell.gradient) {
		[self.cell.gradient drawInBezierPath: path direction: AZGradientDirectionVertical];
	} else {
		[path addClip];
		[path fill];
	}

    // draw the separator
    if (self.cell.separatorColor && !bottomRadius) {
		[self.cell.separatorColor setStroke];
		path.lineWidth = 1;
		[path strokeEdge: CGRectMaxYEdge];
	}

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
	return [[UIView valueForKey:@"_isInAnimationBlock"] boolValue];
}

- (id) initWithCell:(AZTableViewCell *)cell selected:(BOOL)selected
{
    if (self = [super initWithFrame: CGRectZero])
    {
        self.backgroundColor = [UIColor clearColor];
		self.layer.contentsScale = self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
		self.layer.shouldRasterize = YES;
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
	}
}

- (CGRect)az_contentsCenter:(BOOL)animated {
	if (animated) {
		switch (self.sectionLocation) {
			case AZTableViewCellSectionLocationTop:
				return CGRectMake(0.5, 0.95, 0.01, 0); // center bottom
				break;
			case AZTableViewCellSectionLocationBottom:
				return CGRectMake(0.5, 0.05, 0.01, 0); // center top
				break;
			default:
				return CGRectMake(0.5, 0.5, 0.01, 0); // drag out the middle
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
	self.layer.contentsCenter = [self az_contentsCenter: (_az_animationCount > 0 ? YES : NO)];
	if (!self.selected) {
		self.layer.shadowColor = self.cell.shadowColor.CGColor;
		self.layer.shadowOpacity = CGColorGetAlpha(self.layer.shadowColor);

	}
	[self.layer setNeedsDisplay];

	const CGFloat shadowMargin = (self.layer.shadowRadius * 2) + MAX(ABS(self.layer.shadowOffset.width), ABS(self.layer.shadowOffset.height));
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
		default: break;
	}
	self.layer.mask.frame = UIEdgeInsetsInsetRect(self.layer.bounds, insets);
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
	[self doesNotRecognizeSelector: _cmd];
}

- (void)setSelectedBackgroundView:(UIView *)selectedBackgroundView {
	[self doesNotRecognizeSelector: _cmd];
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
