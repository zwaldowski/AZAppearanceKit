//
//  AZTableViewCell.m
//  AZAppearanceKit
//
//  Created by Victor Pena Placer on 2/28/12.
//  Copyright (c) 2012 Victor Pena Placer. All rights reserved.
//  Copyright (c) 2012-2013 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import "AZTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "AZGradient.h"
#import "AZGradientView.h"
#import "AZDrawingFunctions.h"

#pragma mark - Shared definitions

static char regularPropertyObservationContextKey;
static char frameAffectingPropertyObservationContextKey;

typedef NS_ENUM(NSUInteger, AZTableViewCellSectionLocation)  {
	AZTableViewCellSectionLocationNone,
	AZTableViewCellSectionLocationMiddle,
	AZTableViewCellSectionLocationTop,
	AZTableViewCellSectionLocationBottom,
	AZTableViewCellSectionLocationAlone
};

static NSString *NSStringFromTableViewCellSectionLocation(AZTableViewCellSectionLocation location) {
	switch (location) {
		case AZTableViewCellSectionLocationMiddle: return @"Middle";
		case AZTableViewCellSectionLocationTop: return @"Top";
		case AZTableViewCellSectionLocationBottom: return @"Bottom";
		case AZTableViewCellSectionLocationAlone: return @"Alone";
		default: return @"None";
	}
}

@interface AZTableViewCell ()

@property (nonatomic) BOOL tableViewIsGrouped;
@property (nonatomic) UITableViewCellSeparatorStyle tableViewSeparatorStyle;

@end

@interface AZTableViewCellBackgroundContentsKey : NSObject <NSCopying>

@property (nonatomic) AZTableViewCellSectionLocation sectionLocation;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic, getter = isSelected) BOOL selected;
@property (nonatomic, strong) id <AZShadow> shadow;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *borderColor;

@property (nonatomic, readonly, getter = isEmpty) BOOL empty;

@end

#pragma mark - Shared drawing functions

static CGSize AZTableViewCellShadowMargin(id <AZShadow> shadow) {
	if (!shadow) return CGSizeZero;
	const CGFloat margin = shadow.shadowBlurRadius * 2;
	return CGSizeMake(margin + fabs(shadow.shadowOffset.width), margin + fabs(shadow.shadowOffset.height));
}

static void AZTableViewCellGetMetrics(AZTableViewCellBackgroundContentsKey *key, CGSize shadowMargin, CGSize *outImageSize, UIEdgeInsets *outImageEdgeInsets, CGRect *outOuterDrawingRect, CGRect *outInnerDrawingRect) {
	const AZTableViewCellSectionLocation location = key.sectionLocation;
	const CGFloat radius = key.cornerRadius;

	UIEdgeInsets insets = UIEdgeInsetsZero;
	CGSize minimumDrawSize = CGSizeZero, imageSize = CGSizeZero;

	insets.left = insets.right = shadowMargin.width + radius + 1;
	minimumDrawSize.width = imageSize.width = insets.left + insets.right + 1;

	const CGFloat shadowAndRadius = shadowMargin.height + radius;
	switch (location)
	{
		case AZTableViewCellSectionLocationTop:
			insets.top = imageSize.height = shadowAndRadius;
			insets.bottom = 0;
			minimumDrawSize.height = (shadowMargin.height * 2) + radius;
			break;
		case AZTableViewCellSectionLocationAlone:
			insets.top = insets.bottom = shadowAndRadius;
			minimumDrawSize.height = imageSize.height = fmaxf(1, shadowAndRadius * 2);
			break;
		case AZTableViewCellSectionLocationMiddle:
			insets.top = insets.bottom = shadowMargin.height;
			minimumDrawSize.height = (shadowMargin.height * 2) + 1;
			imageSize.height = 1;
			break;
		case AZTableViewCellSectionLocationBottom:
			insets.top = 0;
			insets.bottom = imageSize.height = shadowAndRadius;
			minimumDrawSize.height = (shadowMargin.height * 2) + radius;
			break;
		default: break;
	}

	BOOL outsetsOriginY = (location == AZTableViewCellSectionLocationMiddle || location == AZTableViewCellSectionLocationBottom);

	CGRect outerRect = {{ 0, outsetsOriginY ? -shadowMargin.height : 0 }, minimumDrawSize };
	__block CGRect rect = CGRectInset(outerRect, shadowMargin.width, shadowMargin.height);
	rect.size.height = fmaxf(1, rect.size.height);

	if (outImageSize) *outImageSize = imageSize;
	if (outImageEdgeInsets) *outImageEdgeInsets = insets;
	if (outOuterDrawingRect) *outOuterDrawingRect = outerRect;
	if (outInnerDrawingRect) *outInnerDrawingRect = rect;
}

static void AZTableViewCellDrawInContext(CGContextRef ctx, CGRect outerRect, CGRect innerRect, AZTableViewCellBackgroundContentsKey *key) {
	const BOOL isSelected = key.selected;
	const id <AZShadow> shadow = key.shadow;
	const UIColor *outerColor = key.backgroundColor;
	const UIColor *fillColor = key.fillColor;
	const UIColor *borderColor = key.borderColor;
	const AZTableViewCellSectionLocation location = key.sectionLocation;
	const CGFloat radius = key.cornerRadius;

	CGFloat topRadius = 0, bottomRadius = 0;
	switch (location)
	{
		case AZTableViewCellSectionLocationTop:
			topRadius = radius;
			break;
		case AZTableViewCellSectionLocationAlone:
			topRadius = bottomRadius = radius;
			break;
		case AZTableViewCellSectionLocationBottom:
			bottomRadius = radius;
			break;
		default: break;
	}

	BOOL offsetsShadow = (shadow && (location == AZTableViewCellSectionLocationMiddle || location == AZTableViewCellSectionLocationBottom));

	if (location == AZTableViewCellSectionLocationTop && topRadius == 0) {
		innerRect = CGRectInset(innerRect, 0, -1);
	}

	if (shadow && outerColor) {
		CGContextSetFillColorWithColor(ctx, outerColor.CGColor);
		CGContextFillRect(ctx, outerRect);
	}

	CGPathRef path = CGPathCreateByRoundingCornersInRect(innerRect, topRadius, topRadius, bottomRadius, bottomRadius);
	CGPathRef shadowPath = path;

	if (offsetsShadow) {
		CGRect shadowRect = innerRect;
		shadowRect.origin.y -= shadow.shadowBlurRadius;
		shadowRect.size.height += shadow.shadowBlurRadius;
		shadowPath = CGPathCreateByRoundingCornersInRect(shadowRect, topRadius, topRadius, bottomRadius, bottomRadius);
	}

	// stroke the primary shadow
	CGContextPerformBlock(ctx, ^(CGContextRef ctx) {
		if (!isSelected) [shadow setInContext:ctx];
		CGContextSetStrokeColorWithColor(ctx, borderColor.CGColor);
		CGContextAddPath(ctx, shadowPath);
		CGContextSetLineWidth(ctx, shadow ? 0.5 : 1);
		CGContextStrokePath(ctx);
	});

	// draw the cell background
	CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
	CGContextAddPath(ctx, path);
	CGContextFillPath(ctx);

	if (shadowPath != path) {
		CGPathRelease(shadowPath);
	}
	CGPathRelease(path);
}

#pragma mark - Internal subclasses

@interface AZTableViewCellBackgroundFillView : AZGradientView

@end

@interface AZTableViewCellBackground : UIView

@property (nonatomic, readonly, weak) AZTableViewCell *cell;
@property (nonatomic, readonly, getter = isSelected) BOOL selected;
@property (nonatomic, weak) UIImageView *contentsView;
@property (nonatomic, weak) AZTableViewCellBackgroundFillView *fillView;

@property (nonatomic) CGSize shadowMargin;

@property (nonatomic) AZTableViewCellSectionLocation sectionLocation;
- (void)setSectionLocation:(AZTableViewCellSectionLocation)sectionLocation animated:(BOOL)animated;

@end

#pragma -

@implementation AZTableViewCellBackgroundContentsKey

- (id)copyWithZone:(NSZone *)zone {
	AZTableViewCellBackgroundContentsKey *copy = [[[self class] alloc] init];
	if (copy) {
		copy.sectionLocation = self.sectionLocation;
		copy.cornerRadius = self.cornerRadius;
		copy.shadow = self.shadow;
		copy.backgroundColor = self.backgroundColor;
		copy.fillColor = self.fillColor;
		copy.borderColor = self.borderColor;
		copy.selected = self.selected;
	}
	return copy;
}

- (BOOL)isEmpty {
	return !self.sectionLocation && !self.cornerRadius && !self.shadow && !self.backgroundColor && !self.fillColor && !self.borderColor;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: {Location: %i, Corner Radius: %f, Shadow: %@, Background: %@, Fill: %@, Border: %@, Selected: %i}>", NSStringFromClass(self.class), self.sectionLocation, self.cornerRadius, self.shadow, self.backgroundColor, self.fillColor, self.borderColor, self.selected];
}

- (BOOL)isEqual:(AZTableViewCellBackgroundContentsKey *)object {
	if (![object isKindOfClass: [self class]]) return NO;
	if (object.sectionLocation != self.sectionLocation) return NO;
	if (object.cornerRadius != self.cornerRadius) return NO;
	if (object.selected != self.selected) return NO;
	if (![object.shadow isEqual: self.shadow]) return NO;
	if (![object.backgroundColor isEqual: self.backgroundColor]) return NO;
	if (![object.fillColor isEqual: self.fillColor]) return NO;
	if (![object.borderColor isEqual: self.borderColor]) return NO;
	return YES;
}

@end

@implementation AZTableViewCellBackgroundFillView

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
	UIGraphicsPushContext(ctx);

	AZTableViewCellBackground *background = (id)[self superview];
	AZTableViewCell *cell = background.cell;

	CGFloat topRadius = 0, bottomRadius = 0, radius = cell.cornerRadius;

	switch (background.sectionLocation)
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

	CGRect rect = CGContextGetClipBoundingBox(ctx);
	CGPathRef path = CGPathCreateByRoundingCornersInRect(rect, topRadius, topRadius, bottomRadius, bottomRadius);
	CGContextAddPath(ctx, path);
	CGContextClip(ctx);
	CGPathRelease(path);

	[super drawLayer:layer inContext:ctx];

	UIGraphicsPopContext();
}

@end

@implementation AZTableViewCellBackground {
	UIView *_az_bottomSeparatorView;
	AZTableViewCellBackgroundContentsKey *_az_currentContentsKey;
}

static NSCache *_az_imageCache;

+ (void)initialize {
	@autoreleasepool {
		if (self == [AZTableViewCellBackground class]) {
			_az_imageCache = [[NSCache alloc] init];
			_az_imageCache.countLimit = 15;
		}
	}
}

- (id)init {
	if (self = [super initWithFrame: CGRectZero]) {
		UIImageView *contents = [[UIImageView alloc] initWithFrame: CGRectZero];
		contents.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview: contents];
		self.contentsView = contents;

		AZTableViewCellBackgroundFillView *fill = [[AZTableViewCellBackgroundFillView alloc] initWithFrame: CGRectZero];
		fill.type = AZGradientViewTypeLinear;
		fill.angle = 90.0f;
		fill.backgroundColor = [UIColor clearColor];
		fill.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		fill.contentMode = UIViewContentModeRedraw;
		[self addSubview: fill];
		self.fillView = fill;
	}
	return self;
}

- (void)dealloc {
	[self removeObservers];
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	BOOL isFrame = (context == &frameAffectingPropertyObservationContextKey);
	BOOL isShadow = [keyPath isEqualToString: @"shadow"];
	BOOL isOther = (context == &regularPropertyObservationContextKey);

	if (isFrame || isShadow || isOther) {
		if (isShadow) {
			self.shadowMargin = AZTableViewCellShadowMargin(self.cell.shadow);
		}

		if (self.window) {
			[self redrawablePropertyChange];
		}

		if (isShadow) {
			[self setNeedsLayout];
		}

		return;
	}
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[self removeObservers];
	[super willMoveToSuperview:newSuperview];

	_cell = (id)newSuperview;
	if (_cell) {
		[_cell addObserver: self forKeyPath: @"shadow" options: 0 context: &frameAffectingPropertyObservationContextKey];
		[_cell addObserver: self forKeyPath: @"cornerRadius" options: 0 context: &regularPropertyObservationContextKey];
		[_cell addObserver: self forKeyPath: @"backgroundColor" options: 0 context: &regularPropertyObservationContextKey];
		[_cell addObserver: self forKeyPath: @"tableViewBackgroundColor" options: 0 context: &regularPropertyObservationContextKey];
		[_cell addObserver: self forKeyPath: @"borderColor" options: 0 context: &regularPropertyObservationContextKey];
		[_cell addObserver: self forKeyPath: @"tableViewIsGrouped" options: 0 context: &frameAffectingPropertyObservationContextKey];
		[_cell addObserver: self forKeyPath: @"tableViewSeparatorStyle" options: 0 context: &regularPropertyObservationContextKey];
		_selected = ![[(UITableViewCell *)newSuperview backgroundView] isEqual: self];
		if (_selected) {
			[_cell addObserver: self forKeyPath: @"selectionGradient" options: 0 context: NULL];
			self.fillView.gradient = self.cell.selectionGradient;
		} else {
			[_cell addObserver: self forKeyPath: @"gradient" options: 0 context: NULL];
			self.fillView.gradient = self.cell.gradient;
		}

		[self redrawablePropertyChange];
	}
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
	[super willMoveToWindow: newWindow];
	if (newWindow) {
		[self redrawablePropertyChange];
	}
}

- (void)layoutSubviews {
	[self updateSeparatorViews];

	CGSize shadowMargin = self.shadowMargin;
	CGRect outsetBounds = CGRectInset(self.bounds, -shadowMargin.width, -shadowMargin.height);
	switch (self.sectionLocation) {
		case AZTableViewCellSectionLocationTop:
			outsetBounds.size.height -= shadowMargin.height;
			break;
		case AZTableViewCellSectionLocationMiddle:
			outsetBounds.origin.y += shadowMargin.height;
			outsetBounds.size.height -= 2 * shadowMargin.height;
			break;
		case AZTableViewCellSectionLocationBottom:
			outsetBounds.origin.y += shadowMargin.height;
			outsetBounds.size.height -= shadowMargin.height;
			break;
		default: break;
	}
	self.contentsView.frame = outsetBounds;
}

#pragma mark -

- (void)setSectionLocation:(AZTableViewCellSectionLocation)location {
	[self setSectionLocation: location animated: NO];
}

- (void)setSectionLocation:(AZTableViewCellSectionLocation)location animated:(BOOL)animated
{
	_sectionLocation = location;

	if (self.window) {
		if (animated) {
			UIViewAnimationOptions opts = UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve;
			[UIView transitionWithView: self duration: animated ? 0.33 : 0 options:opts animations:^{
				[self redrawablePropertyChange];
			} completion: NULL];
		} else {
			BOOL animationsWereEnabled = [UIView areAnimationsEnabled];
			[UIView setAnimationsEnabled:NO];
			[self redrawablePropertyChange];
			[self setNeedsLayout];
			[UIView setAnimationsEnabled:animationsWereEnabled];
		}
	}
}

#pragma mark -

- (void)redrawablePropertyChange {
	if (self.cell) {
		AZTableViewCellBackgroundContentsKey *key = [AZTableViewCellBackgroundContentsKey new];
		key.cornerRadius = self.cell.cornerRadius;
		key.shadow = self.cell.shadow;
		key.backgroundColor = self.cell.tableViewBackgroundColor;
		key.sectionLocation = self.sectionLocation;
		key.selected = self.selected;
		key.fillColor = self.cell.backgroundColor;
		key.borderColor = self.cell.borderColor;

		self.fillView.gradient = self.selected ? self.cell.selectionGradient : self.cell.gradient;

		UIImage *image = nil;
		if (!key.isEmpty) {
			image = [_az_imageCache objectForKey: key];
			if (!image) {
				CGSize imageSize; UIEdgeInsets insets; CGRect outerRect, rect;
				AZTableViewCellGetMetrics(key, self.shadowMargin, &imageSize, &insets, &outerRect, &rect);

				BOOL opaque = self.cell.tableViewIsGrouped ?(key.shadow ? (key.backgroundColor != nil) : NO) : YES;

				UIImage *unstretched = UIImageCreateUsingBlock(imageSize, opaque, ^(CGContextRef ctx) {
					AZTableViewCellDrawInContext(ctx, outerRect, rect, key);
				});

				image = [unstretched resizableImageWithCapInsets: insets resizingMode: UIImageResizingModeStretch];
				[_az_imageCache setObject: image forKey: key];
			}
		}
		self.contentsView.image = image;
	} else {
		self.contentsView.image = nil;
	}
}

- (void)updateSeparatorViews {
	BOOL shouldHaveBottomSeparator = (_sectionLocation == AZTableViewCellSectionLocationMiddle || _sectionLocation == AZTableViewCellSectionLocationTop);

	if (shouldHaveBottomSeparator) {
		if (!_az_bottomSeparatorView && self.cell.tableViewSeparatorStyle != UITableViewCellSeparatorStyleNone) {
			BOOL hasAnimations = [UIView areAnimationsEnabled];
			[UIView setAnimationsEnabled: NO];
			CGRect bounds = self.bounds;
			_az_bottomSeparatorView = [[UIView alloc] initWithFrame: CGRectMake(0, CGRectGetMaxY(bounds) - 1, CGRectGetWidth(bounds), 1)];
			[self addSubview: _az_bottomSeparatorView];
			_az_bottomSeparatorView.opaque = YES;
			_az_bottomSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
			[UIView setAnimationsEnabled: hasAnimations];
		}
		_az_bottomSeparatorView.backgroundColor = self.cell.separatorColor;
		[self bringSubviewToFront: _az_bottomSeparatorView];
	} else {
		if (_az_bottomSeparatorView) {
			[_az_bottomSeparatorView removeFromSuperview];
			_az_bottomSeparatorView = nil;
		}
	}
}

- (void)removeObservers {
	if (_cell) {
		[_cell removeObserver: self forKeyPath: @"shadow"];
		[_cell removeObserver: self forKeyPath: @"cornerRadius"];
		[_cell removeObserver: self forKeyPath: @"backgroundColor"];
		[_cell removeObserver: self forKeyPath: @"tableViewBackgroundColor"];
		[_cell removeObserver: self forKeyPath: @"borderColor"];
		[_cell removeObserver: self forKeyPath: @"tableViewIsGrouped"];
		[_cell removeObserver: self forKeyPath: @"tableViewSeparatorStyle"];
		if (_selected)
			[_cell removeObserver: self forKeyPath: @"selectionGradient"];
		else
			[_cell removeObserver: self forKeyPath: @"gradient"];
	}
}

@end

#pragma mark - Primary cell implementation

@implementation AZTableViewCell

@synthesize separatorColor = _az_separatorColor;

#pragma mark - Setup and teardown

- (void)az_sharedInit
{
	[super setBackgroundView: [AZTableViewCellBackground new]];
	[super setSelectedBackgroundView: [AZTableViewCellBackground new]];

	self.shadow = [AZShadow shadowWithOffset: CGSizeMake(0, 1) blurRadius: 3.0f color: [UIColor colorWithWhite: 0 alpha: 0.7]];
	self.borderColor = [UIColor colorWithRed: 0.737 green: 0.737 blue: 0.737 alpha: 1.0];
	self.separatorColor = [UIColor redColor];
	self.selectionGradient = [[AZGradient alloc] initWithStartingColor: [UIColor colorWithRed: 0 green: 0.537 blue: 0.976 alpha: 1] endingColor: [UIColor colorWithRed: 0 green: 0.329 blue: 0.918 alpha: 1]];
	self.cornerRadius = 10;
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

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];

	if (newSuperview) {
		self.tableViewIsGrouped = (((UITableView *)newSuperview).style == UITableViewStyleGrouped);
		self.tableViewSeparatorStyle = ((UITableView *)newSuperview).separatorStyle;
	} else {
		self.tableViewIsGrouped = NO;
		self.tableViewSeparatorStyle = UITableViewCellSeparatorStyleNone;
	}

	AZTableViewCellBackground *bg = self.selected ? (id)[super selectedBackgroundView] : (id)[super backgroundView];
	[bg redrawablePropertyChange];
}


@end
