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
@property (nonatomic, readonly) UITableViewCellSeparatorStyle tableViewSeparatorStyle;

@end

@interface AZTableViewCellBackground : UIView

@property (nonatomic, readonly, weak) AZTableViewCell *cell;
@property (nonatomic, readonly, getter = isSelected) BOOL selected;
@property (nonatomic, weak) UIImageView *contentsView;

- (id) initWithCell:(AZTableViewCell *)cell selected:(BOOL)selected;

@property (nonatomic) AZTableViewCellSectionLocation sectionLocation;
- (void)setSectionLocation:(AZTableViewCellSectionLocation)sectionLocation animated:(BOOL)animated;

@end

@interface AZTableViewCellBackgroundContentsKey : NSObject <NSCopying>

@property (nonatomic) AZTableViewCellSectionLocation sectionLocation;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic, getter = isSelected) BOOL selected;
@property (nonatomic, strong) id <AZShadow> shadow;
@property (nonatomic, strong) id fill;
@property (nonatomic, strong) UIColor *borderColor;

@end

@implementation AZTableViewCellBackgroundContentsKey

- (id)copyWithZone:(NSZone *)zone {
	AZTableViewCellBackgroundContentsKey *copy = [[[self class] alloc] init];
	if (copy) {
		copy.sectionLocation = self.sectionLocation;
		copy.cornerRadius = self.cornerRadius;
		copy.shadow = self.shadow;
		copy.fill = self.fill;
		copy.borderColor = self.borderColor;
		copy.selected = self.selected;
	}
	return copy;
}

- (BOOL)isEqual:(AZTableViewCellBackgroundContentsKey *)object {
	if (![object isKindOfClass: [self class]]) return NO;
	if (object.sectionLocation != self.sectionLocation) return NO;
	if (object.cornerRadius != self.cornerRadius) return NO;
	if (object.selected != self.selected) return NO;
	if (![object.shadow isEqual: self.shadow]) return NO;
	if (![object.fill isEqual: self.fill]) return NO;
	if ([object.borderColor isEqual: self.borderColor]) return NO;
	return YES;
}

@end

@implementation AZTableViewCellBackground {
	NSUInteger _az_animationCount;
	UIView *_az_bottomSeparatorView;
	AZTableViewCellBackgroundContentsKey *_az_currentContentsKey;
}

static NSCache *_az_imageCache;

+ (void)az_flushCacheOnNotification:(NSNotification *)note {
	[_az_imageCache removeAllObjects];
}

+ (void)initialize {
	@autoreleasepool {
		if (self == [AZTableViewCellBackground class]) {
			_az_imageCache = [[NSCache alloc] init];
			_az_imageCache.countLimit = 15;
			[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(az_flushCacheOnNotification:) name: UIApplicationDidReceiveMemoryWarningNotification object: nil];
		}
	}
}

- (id) initWithCell:(AZTableViewCell *)cell selected:(BOOL)selected
{
    if (self = [super initWithFrame: CGRectZero])
    {
		_cell = cell;
		_selected = selected;
		self.clipsToBounds = NO;
		self.opaque = NO;

		UIImageView *contents = [[UIImageView alloc] initWithFrame: CGRectZero];
		contents.backgroundColor = [UIColor clearColor];
		contents.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview: contents];
		self.contentsView = contents;

		[cell addObserver: self forKeyPath: @"shadow" options: NSKeyValueObservingOptionNew context: NULL];
#warning TODO Also observe other key-affecting properties
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString: @"shadow"]) {
		CGSize shadowMargin = [self az_shadowMarginForShadow: change[NSKeyValueChangeNewKey]];
		self.contentsView.frame = CGRectInset(self.bounds, -shadowMargin.width, -shadowMargin.height);
		if (self.window) [self az_redrawablePropertyChange];
		return;
	}
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
	[super willMoveToWindow: newWindow];
	[self az_redrawablePropertyChange];
}

- (void)layoutSubviews {
	[self az_updateSeparatorViews];
}

- (void)setSectionLocation:(AZTableViewCellSectionLocation)location {
	[self setSectionLocation: location animated: NO];
}

- (void)setSectionLocation:(AZTableViewCellSectionLocation)location animated:(BOOL)animated
{
#warning TODO animation
	_sectionLocation = location;
	if (self.window) [self az_redrawablePropertyChange];
}

- (CGSize)az_shadowMarginForShadow:(id <AZShadow>)shadow {
	if (!shadow) return CGSizeZero;
	const CGFloat margin = shadow.shadowBlurRadius * 2;
	return CGSizeMake(margin + fabs(shadow.shadowOffset.width), margin + fabs(shadow.shadowOffset.height));
}

- (UIImage *)az_cachedImageForKey:(AZTableViewCellBackgroundContentsKey *)key {
#warning TODO Fix appearance of gradients, possibly draw elsewhere
	UIImage *ret = [_az_imageCache objectForKey: key];
	if (!ret) {
		BOOL isSelected = key.selected;
		id <AZShadow> shadow = key.shadow;
		id fill = key.fill;
		UIColor *borderColor = key.borderColor;
		CGSize shadowMargin = [self az_shadowMarginForShadow: shadow];
		AZTableViewCellSectionLocation location = key.sectionLocation;

		CGFloat topRadius = 0, bottomRadius = 0, radius = key.cornerRadius;

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

		UIEdgeInsets insets = UIEdgeInsetsZero;
		insets.top = shadowMargin.height + topRadius + 1;
		insets.bottom = shadowMargin.height + bottomRadius + 1;
		insets.left = shadowMargin.width + radius + 1;
		insets.right = shadowMargin.width + radius + 1;

		CGSize size = CGSizeMake(insets.left + insets.right + 1, insets.top + insets.bottom + 1);

		UIImage *image = UIGraphicsContextCreateImage(size, NO, ^(CGContextRef ctx) {
			CGRect rect = { CGPointZero, size };

			CGRect clippingRect = rect;
			CGFloat topInset = 0, bottomInset = 0;
			switch (location) {
				case AZTableViewCellSectionLocationTop:
					bottomInset = shadowMargin.height;
					break;
				case AZTableViewCellSectionLocationMiddle:
					topInset = shadowMargin.height;
					bottomInset = shadowMargin.height;
					break;
				case AZTableViewCellSectionLocationBottom:
					topInset = shadowMargin.height;
					break;
				default:
					break;
			}
			clippingRect.origin.y += topInset;
			clippingRect.size.height -= topInset + bottomInset;
			CGContextClipToRect(ctx, clippingRect);

			CGRect innerRect = CGRectInset(rect, shadowMargin.width, shadowMargin.height);
			CGPathRef path = CGPathCreateByRoundingCornersInRect(innerRect, topRadius, topRadius, bottomRadius, bottomRadius);
			CGPathRef shadowPath = path;

			if (shadow && !topRadius && (location == AZTableViewCellSectionLocationMiddle || location == AZTableViewCellSectionLocationBottom)) {
				CGRect shadowRect = innerRect;
				shadowRect.origin.y -= shadow.shadowBlurRadius;
				shadowRect.size.height += shadow.shadowBlurRadius;
				shadowPath = CGPathCreateByRoundingCornersInRect(shadowRect, topRadius, topRadius, bottomRadius, bottomRadius);
			}

			// stroke the primary shadow
			UIGraphicsContextPerformBlock(^(CGContextRef ctx) {
				if (!isSelected) [shadow set];
				CGContextSetStrokeColorWithColor(ctx, borderColor.CGColor);
				CGContextSetLineWidth(ctx, shadow ? 0.5 : 1);
				CGContextAddPath(ctx, shadowPath);
				CGContextStrokePath(ctx);
			});

			// draw the cell background
			UIGraphicsContextPerformBlock(^(CGContextRef ctx) {
				CGContextAddPath(ctx, path);
				CGContextClip(ctx);

				CGPoint start = innerRect.origin;
				CGPoint end = CGPointMake(start.x, CGRectGetMaxY(innerRect));

				if ([fill isKindOfClass: [AZGradient class]]) {
					CGContextDrawLinearGradient(ctx, [(AZGradient *)fill gradient], start, end, 0);
				} else if ([fill isKindOfClass: [UIColor class]]) {
					CGContextSetFillColorWithColor(ctx, [fill CGColor]);
					CGContextFillRect(ctx, innerRect);
				}
			});
		});

		ret = [image resizableImageWithCapInsets: insets resizingMode: UIImageResizingModeStretch];
		[_az_imageCache setObject: ret forKey: key];
	}
	return ret;
}

- (void)az_redrawablePropertyChange {
	AZTableViewCellBackgroundContentsKey *key = [AZTableViewCellBackgroundContentsKey new];
	key.sectionLocation = self.sectionLocation;
	key.cornerRadius = self.cell.cornerRadius;
	key.selected = self.selected;
	key.shadow = self.cell.shadow;
	if (self.selected) {
		key.fill = self.cell.selectionGradient;
	} else {
		key.fill = self.cell.gradient ?: self.cell.backgroundColor;
	}
	key.borderColor = self.cell.borderColor;
	self.contentsView.image = [self az_cachedImageForKey: key];
}

- (void)az_updateSeparatorViews {
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
		if (_az_bottomSeparatorView && !_az_animationCount) {
			[_az_bottomSeparatorView removeFromSuperview];
			_az_bottomSeparatorView = nil;
		}
	}
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
    self.separatorColor = [UIColor redColor];
    self.selectionGradient = [[AZGradient alloc] initWithStartingColor: [UIColor colorWithRed: 0 green: 0.537 blue: 0.976 alpha: 1] endingColor: [UIColor colorWithRed: 0 green: 0.329 blue: 0.918 alpha: 1]];
    self.cornerRadius = 10.0f;
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
		_tableViewIsGrouped = (((UITableView *)newSuperview).style == UITableViewStyleGrouped);
		_tableViewSeparatorStyle = ((UITableView *)newSuperview).separatorStyle;
	} else {
		_tableViewIsGrouped = NO;
		_tableViewSeparatorStyle = UITableViewCellSeparatorStyleNone;
	}
	
	[self setNeedsLayout];
}


@end
