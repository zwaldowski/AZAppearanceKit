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

@interface AZTableViewCellBackground : UIView

@property (nonatomic, readonly, weak) AZTableViewCell *cell;
@property (nonatomic, readonly, getter = isSelected) BOOL selected;
@property (nonatomic, readonly) AZTableViewCellSectionLocation sectionLocation;

- (id) initWithCell:(AZTableViewCell *)cell selected:(BOOL)selected;

@end

@implementation AZTableViewCellBackground

@synthesize cell = _cell;
@synthesize selected = _selected;
@synthesize sectionLocation = _sectionLocation;

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

- (void) drawRect:(CGRect)rect
{
	CGFloat shadowMargin = self.cell.tableViewIsGrouped ? kShadowMargin : 0;
	CGFloat radius = self.cell.tableViewIsGrouped ? self.cell.cornerRadius : 0;
	
	rect = CGRectInset(rect, shadowMargin, 0);
	rect.origin.y += (self.sectionLocation == AZTableViewCellSectionLocationAlone ||
					  self.sectionLocation == AZTableViewCellSectionLocationTop) ? shadowMargin : 0;
	rect.size.height -= (self.sectionLocation == AZTableViewCellSectionLocationMiddle) ? 0 : (self.sectionLocation == AZTableViewCellSectionLocationAlone ? 2 * shadowMargin : shadowMargin);
	
	UIBezierPath *(^roundedPath)(CGRect) = ^UIBezierPath *(CGRect rect){
		return [UIBezierPath bezierPathWithRoundedRect: rect
									 byRoundingCorners: UIRectCornerForSectionLocation(self.sectionLocation)
										   cornerRadii: CGSizeMake(radius, radius)];
	};
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	UIBezierPath *path = roundedPath(rect);
	
	void (^drawBorder)(void) = ^{
		UIBezierPath *path = roundedPath(CGRectInset(rect, 0.5, 0.5));
		path.lineWidth = 1.5f;
		[self.cell.borderColor setStroke];
		[path stroke];
	};
	
    if (self.cell.tableViewIsGrouped && self.cell.shadowColor) {
		CGContextSaveGState(ctx);
		CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 3, self.cell.shadowColor.CGColor);
        drawBorder();
		CGContextRestoreGState(ctx);
	}
	
    if (self.selected && self.cell.selectionStyle != UITableViewCellSelectionStyleNone) {
		[self.cell.selectionGradient drawInBezierPath: path direction: AZGradientDirectionVertical];
    } else if (self.cell.gradient) {
		[self.cell.gradient drawInBezierPath: path direction: AZGradientDirectionVertical];
    } else {
		[self.cell.backgroundColor setFill];
		[path fill];
	}
    
    if (self.cell.separatorColor && (self.sectionLocation == AZTableViewCellSectionLocationTop || self.sectionLocation == AZTableViewCellSectionLocationMiddle))
		UIRectStrokeWithColor(self.cell.shadowColor && self.cell.tableViewIsGrouped ? rect : CGRectInset(rect, 0.5, 0), CGRectMaxYEdge, 1.0f, self.cell.separatorColor);
	
    if (!self.cell.shadowColor && self.cell.tableViewIsGrouped)
        drawBorder();
}

- (void)setSectionLocation:(AZTableViewCellSectionLocation)location
{
	[self setSectionLocation: location animated: NO];
}

- (void)setSectionLocation:(AZTableViewCellSectionLocation)location animated:(BOOL)animated
{
	void (^block)(void) = ^{
		_sectionLocation = location;
		[self setNeedsDisplay];
	};
	
	if (animated) {
		[UIView transitionWithView: self duration: 0.3 options: UIViewAnimationOptionTransitionCrossDissolve animations: block completion: NULL];
	} else {
		block();
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
		self.borderColor = [UIColor colorWithWhite: 0.737 alpha: 1.0];
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
		
		innerFrame = CGRectInset(innerFrame, shadowMargin, 0);
		innerFrame.origin.y += topMargin;
		innerFrame.size.height -= topMargin + bottomMargin;
	}
	
	self.customView.frame = innerFrame;
	
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
	
	if (![self.customView.superview isEqual: self])
		[self addSubview:self.customView];
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
			contentView.frame = CGRectInset(rect, shadowMargin, y);
        }
		return;
    }
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
