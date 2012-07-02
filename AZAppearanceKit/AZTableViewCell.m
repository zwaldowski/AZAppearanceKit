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

static void AZTableViewCellGetLayerValues(AZTableViewCellSectionLocation location, CGFloat radius, CGFloat *topRadius, CGFloat *bottomRadius, CGFloat *topInset, CGFloat *bottomInset) {
	CGFloat shadowMargin = kShadowMargin;
	CGFloat newTopRadius = 0, newBottomRadius = 0, newTopInset = 0, newBottomInset = 0;
	switch (location)
    {
        case AZTableViewCellSectionLocationAlone:
            newTopInset = shadowMargin;
            newBottomInset = 2 * shadowMargin;
			newTopRadius = radius;
			newBottomRadius = radius;
			break;
        case AZTableViewCellSectionLocationTop:
            newTopInset = shadowMargin;
            newBottomInset = shadowMargin;
			newTopRadius = radius;
            break;
        case AZTableViewCellSectionLocationBottom:
            newBottomInset = shadowMargin;
			newBottomRadius = radius;
            break;
        default:
            break;
    }
	*topRadius = newTopRadius;
	*bottomRadius = newBottomRadius;
	*topInset = newTopInset;
	*bottomInset = newBottomInset;
}

@interface AZTableViewCellBackgroundLayer : CALayer

@property (nonatomic) AZTableViewCellSectionLocation sectionLocation;
@property (nonatomic) CGFloat topCornerRadius;
@property (nonatomic) CGFloat bottomCornerRadius;
@property (nonatomic) CGFloat topShadowInset;
@property (nonatomic) CGFloat bottomShadowInset;

@end

@implementation AZTableViewCellBackgroundLayer

@dynamic sectionLocation;
@dynamic topCornerRadius;
@dynamic bottomCornerRadius;
@dynamic topShadowInset;
@dynamic bottomShadowInset;

+ (BOOL)needsDisplayForKey:(NSString *)key {
	if ([key isEqualToString: @"sectionLocation"] ||
		[key isEqualToString: @"topCornerRadius"] ||
		[key isEqualToString: @"bottomCornerRadius"] ||
		[key isEqualToString: @"topShadowInset"] ||
		[key isEqualToString: @"bottomShadowInset"])
		return YES;
	return [super needsDisplayForKey:key];
}

- (id<CAAction>)actionForKey:(NSString *)event {
	if ([event isEqualToString: @"sectionLocation"] ||
		[event isEqualToString: @"topCornerRadius"] ||
		[event isEqualToString: @"bottomCornerRadius"] ||
		[event isEqualToString: @"topShadowInset"] ||
		[event isEqualToString: @"bottomShadowInset"]) {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: event];
        animation.fromValue = [self.presentationLayer valueForKey: event];
        return animation;
	}
	return [super actionForKey:event];
}

@end

@interface AZTableViewCellBackground : UIView

@property (nonatomic, readonly, weak) AZTableViewCell *cell;
@property (nonatomic, readonly, getter = isSelected) BOOL selected;
@property (nonatomic, readonly) AZTableViewCellSectionLocation sectionLocation;

- (id) initWithCell:(AZTableViewCell *)cell selected:(BOOL)selected;

@end

@implementation AZTableViewCellBackground

@synthesize cell = _cell;
@synthesize selected = _selected;

+ (Class)layerClass {
	return [AZTableViewCellBackgroundLayer class];
}

- (id) initWithCell:(AZTableViewCell *)cell selected:(BOOL)selected
{
    if (self = [super initWithFrame: CGRectZero])
    {
        self.contentMode = UIViewContentModeRedraw;
        self.backgroundColor = [UIColor clearColor];
		_cell = cell;
		_selected = selected;
    }
    
    return self;
}

- (void)drawLayer:(AZTableViewCellBackgroundLayer *)layer inContext:(CGContextRef)ctx
{
	UIGraphicsPushContext(ctx);
	CGRect outerRect = CGContextGetClipBoundingBox(ctx);
	
	// Get an inner rect
	CGFloat topInset = layer.topShadowInset, bottomInset = layer.bottomShadowInset,
		    topRadius = layer.topCornerRadius,
	        bottomRadius = layer.bottomCornerRadius;
	
	UIBezierPath *(^roundedPath)(CGRect) = ^UIBezierPath *(CGRect rect){
		if (self.cell.tableViewIsGrouped) {
			CGPoint minPoint = rect.origin;
			CGPoint maxPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
			CGMutablePathRef path = CGPathCreateMutable();
			CGPathMoveToPoint(path, NULL, minPoint.x + topRadius, minPoint.y);
			CGPathAddArcToPoint(path, NULL, maxPoint.x, minPoint.y, maxPoint.x, minPoint.y + topRadius, topRadius);
			CGPathAddArcToPoint(path, NULL, maxPoint.x, maxPoint.y, maxPoint.x - bottomRadius, maxPoint.y, bottomRadius);
			CGPathAddArcToPoint(path, NULL, minPoint.x, maxPoint.y, minPoint.x, maxPoint.y - bottomRadius, bottomRadius);
			CGPathAddArcToPoint(path, NULL, minPoint.x, minPoint.y, minPoint.x + topRadius, minPoint.y, topRadius);
			CGPathCloseSubpath(path);
			UIBezierPath *ret = [UIBezierPath bezierPathWithCGPath: path];
			CGPathRelease(path);
			return ret;
		} else {
			return [UIBezierPath bezierPathWithRect: rect];
		}
	};
	
	CGRect rect = outerRect;
	if (self.cell.tableViewIsGrouped) {
		rect = CGRectInset(rect, kShadowMargin / 2, 0);
		rect = CGRectMake(rect.origin.x, rect.origin.y + topInset, rect.size.width, rect.size.height - bottomInset);
	}
    
	UIBezierPath *path = roundedPath(rect);
	
	CGRect innerRect = CGRectInset(rect, self.cell.shadowColor ? 0.5 : 0, self.cell.shadowColor ? 0.5 : 0);
	UIBezierPath *innerPath = roundedPath(innerRect);
    
	// Fix shadow
    if (self.cell.shadowColor && !layer.topCornerRadius)
		UIGraphicsContextPerform(^(CGContextRef ctx){
			CGContextSetShadowWithColor(ctx, CGSizeMake(0, -1), 3, self.cell.shadowColor.CGColor);
			CGContextSetStrokeColorWithColor(ctx, self.cell.borderColor.CGColor);
			CGContextSetLineWidth(ctx, 5);
			CGContextStrokeRectEdge(ctx, innerRect, CGRectMinYEdge);
		});
	
	// Draw border with shadow
	UIGraphicsContextPerform(^(CGContextRef ctx){
		if (self.cell.shadowColor) {
			CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 3, self.cell.shadowColor.CGColor);
		}
		CGContextSetStrokeColorWithColor(ctx, self.cell.borderColor.CGColor);
		CGContextSetLineWidth(ctx, self.cell.shadowColor ? 1.5 : 2);
		CGContextAddPath(ctx, innerPath.CGPath);
		CGContextStrokePath(ctx);
	});
	
	// Draw background
    if (self.selected && self.cell.selectionStyle != UITableViewCellSelectionStyleNone && self.cell.selectionGradient) {
		[self.cell.selectionGradient drawInBezierPath: path direction: AZGradientDirectionVertical];
    } else if (!self.selected && self.cell.gradient) {
		[self.cell.gradient drawInBezierPath: path direction: AZGradientDirectionVertical];
    } else {
		[self.cell.backgroundColor setFill];
		[path fill];
	}
    
	// Draw separator
    if (self.cell.separatorColor && !layer.bottomCornerRadius)
		UIRectStrokeWithColor(rect, CGRectMaxYEdge, 1, self.cell.separatorColor);
	
	UIGraphicsPopContext();
}

/* UIView uses the existence of -drawRect: to determine if it should allow
 its CALayer to call -drawLayer:inContext: being called. */
- (void) drawRect:(CGRect)outerRect {}

- (AZTableViewCellSectionLocation)sectionLocation {
	AZTableViewCellBackgroundLayer *layer = (id)self.layer;
	return layer.sectionLocation;
}

- (void)setSectionLocation:(AZTableViewCellSectionLocation)location
{
	[self setSectionLocation: location animated: NO];
}

- (void)setSectionLocation:(AZTableViewCellSectionLocation)location animated:(BOOL)animated
{
	AZTableViewCellBackgroundLayer *layer = (id)self.layer;
	CGFloat topRadius = 0, bottomRadius = 0, topInset = 0, bottomInset = 0;
	AZTableViewCellGetLayerValues(location, self.cell.cornerRadius, &topRadius, &bottomRadius, &topInset, &bottomInset);

	void (^animation)(void) = ^{
		layer.sectionLocation = location;
		layer.topCornerRadius = topRadius;
		layer.bottomCornerRadius = bottomRadius;
		layer.topShadowInset = topInset;
		layer.bottomShadowInset = bottomInset;
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

        [self.contentView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionOld context:nil];
		
		[super setBackgroundView: [[AZTableViewCellBackground alloc] initWithCell: self selected: NO]];
		[super setSelectedBackgroundView: [[AZTableViewCellBackground alloc] initWithCell: self selected:YES]];
		
		self.shadowColor = [UIColor colorWithWhite: 0.0 alpha: 0.7];
		self.borderColor = [UIColor colorWithRed: 0.737 green: 0.737 blue: 0.737 alpha: 1.0];
		self.separatorColor = [UIColor colorWithWhite: 0.804 alpha: 1.0];
		self.cornerRadius = 8.0f;
    }
    return self;
}

- (void) dealloc
{
    [self.contentView removeObserver:self forKeyPath:@"frame"];
}

#pragma mark - Private helpers

+ (CGFloat) tableView:(UITableView *)tableView neededHeightForIndexPath:(NSIndexPath *)indexPath
{
	
    if (tableView.style == UITableViewStylePlain)
        return 0;
	
	if ([tableView.dataSource tableView:tableView numberOfRowsInSection:indexPath.section] == 1) {
        return kShadowMargin * 2;
    } else if (indexPath.row == 0 || indexPath.row == [tableView.dataSource tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
        return kShadowMargin;
    } else {
		return 0;
	}
}

- (AZGradient *)selectionGradient {
	if (!_selectionGradient) {
		self.selectionGradient = [[AZGradient alloc]
								  initWithStartingColor: [UIColor colorWithRed: 0 green: 0.537 blue: 0.976 alpha: 1]
								  endingColor: [UIColor colorWithRed: 0 green: 0.329 blue: 0.918 alpha: 1]];
	}
	return _selectionGradient;
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
	
	AZTableViewCellBackground *backgroundView = (AZTableViewCellBackground *) [super backgroundView];
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
	}
	
	self.customView.frame = innerFrame;
	
	if (![self.customView.superview isEqual: self])
		[self addSubview:self.customView];
	
	if (!self.customView.layer.mask) {
		self.customView.layer.mask = [[CAShapeLayer alloc] init];
		self.customView.layer.masksToBounds = YES;
	}
	
	CGFloat radius = self.tableViewIsGrouped ? self.cornerRadius : 0;
	CGRect maskRect = (CGRect){ CGPointZero, innerFrame.size };
	UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: maskRect
												   byRoundingCorners: UIRectCornerForSectionLocation(location)
														 cornerRadii: CGSizeMake(radius, radius)];

	[(CAShapeLayer *)self.customView.layer.mask setPath: maskPath.CGPath];
	self.customView.layer.mask.frame = maskRect;
}

#pragma mark - Internal

// Avoids contentView's frame auto-updating. It calculates the best size, taking
// into account the cell's margin and so.
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"])
    {
		if (!self.superview || !self.tableViewIsGrouped)
			return;
		
        UIView *contentView = (UIView *) object;
        CGRect rect = contentView.frame;
		
        CGFloat shadowMargin = kShadowMargin;
        
        float y = 2.0f;
		AZTableViewCellBackground *backgroundView = (AZTableViewCellBackground *) [super backgroundView];
        switch (backgroundView.sectionLocation) {
            case AZTableViewCellSectionLocationTop:
            case AZTableViewCellSectionLocationAlone:
                y += shadowMargin;
                break;
            default:
                break;
        }
		y -= rect.origin.y;
        
        if (y)
        {
			contentView.frame = CGRectInset(rect, shadowMargin/2, y);
        }
		return;
    }
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
