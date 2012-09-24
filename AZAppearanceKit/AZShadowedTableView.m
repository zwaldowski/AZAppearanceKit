//
//  AZShadowedTableView.m
//  AZAppearanceKit
//
//  Created by Matt Gallagher on 8/21/09.
//  Copyright (c) 2009 Matt Gallagher. All rights reserved.
//  Copyright (c) 2011-2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import "AZShadowedTableView.h"
#import "AZDrawingFunctions.h"

@interface AZShadowedTableShadowView : UIView

@end

@implementation AZShadowedTableShadowView {
	BOOL _top;
}

- (id)initWithFrame:(CGRect)frame top:(BOOL)top {
    if ((self = [super initWithFrame:frame])) {
        self.contentMode = UIViewContentModeRedraw;
        self.backgroundColor = [UIColor clearColor];
		_top = top;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    rect.size.height += 5;
    if (!_top)
        rect.origin.y -= 5;
    
    UIGraphicsContextPerformBlock(^(CGContextRef ctx) {
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 20, [[UIColor colorWithWhite: 0.0 alpha: 1.0] CGColor]);
        CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
        CGContextSetLineWidth(ctx, 5);
        CGContextStrokeRectEdge(ctx, rect, _top ? CGRectMaxYEdge : CGRectMinYEdge);
    });
}

@end

@interface AZShadowedTableView ()

@property (nonatomic, weak) UIView *topShadow;
@property (nonatomic, weak) UIView *bottomShadow;
@property (nonatomic, weak) UIView *originShadow;
@property (nonatomic, weak) UIView *maximumShadow;

@end

@implementation AZShadowedTableView

@synthesize topShadow = _topShadow, bottomShadow = _bottomShadow, originShadow = _originShadow, maximumShadow = _maximumShadow;

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (!self.tableFooterView) {
		UIView *v = [[UIView alloc] initWithFrame: CGRectZero];
		v.backgroundColor = [UIColor clearColor];
		self.tableFooterView = v;
	}
		
	if (!self.originShadow) {
		AZShadowedTableShadowView *top = [[AZShadowedTableShadowView alloc] initWithFrame: CGRectMake(self.contentOffset.x, self.contentOffset.y, self.frame.size.width, 25) top: NO];
		top.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		if (self.backgroundView)
			[self insertSubview: top aboveSubview: self.backgroundView];
		else
			[self insertSubview: top atIndex: 0];
		self.originShadow = top;
	} else if (self.backgroundView) {
		[self insertSubview: self.originShadow aboveSubview: self.backgroundView];
	} else if ([self.subviews indexOfObjectIdenticalTo: self.originShadow] != 0) {
		[self insertSubview: self.originShadow atIndex: 0];
	}
	
	CGRect originShadowFrame = self.originShadow.frame;
	originShadowFrame.origin.y = self.contentOffset.y;
	self.originShadow.frame = originShadowFrame;
	
	if (!self.maximumShadow) {
		AZShadowedTableShadowView *top = [[AZShadowedTableShadowView alloc] initWithFrame: CGRectMake(self.contentOffset.x, self.contentOffset.y + self.frame.size.height - 25, self.frame.size.width, 25) top: YES];
		top.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		if (self.backgroundView)
			[self insertSubview: top aboveSubview: self.backgroundView];
		else
			[self insertSubview: top atIndex: 0];
		self.maximumShadow = top;
	} else if (self.backgroundView) {
		[self insertSubview: self.maximumShadow aboveSubview: self.backgroundView];
	} else if ([self.subviews indexOfObjectIdenticalTo: self.originShadow] != 0) {
		[self insertSubview: self.maximumShadow atIndex: 0];
	}
	
	CGRect maximumShadowFrame = self.maximumShadow.frame;
	maximumShadowFrame.origin.y = self.contentOffset.y + self.frame.size.height - maximumShadowFrame.size.height;
	self.maximumShadow.frame = maximumShadowFrame;
	
	NSArray *indexPathsForVisibleRows = self.indexPathsForVisibleRows;
	if (indexPathsForVisibleRows.count) {
		NSIndexPath *firstCell = indexPathsForVisibleRows[0];
		if (firstCell.section == 0 && firstCell.row == 0) {
			UIView *cell = [self cellForRowAtIndexPath: firstCell];
			
			if (!self.topShadow) {
				AZShadowedTableShadowView *top = [[AZShadowedTableShadowView alloc] initWithFrame: CGRectMake(0, 0, 0, 25) top: YES];
				top.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
				[cell insertSubview: top atIndex: 0];
				self.topShadow = top;
			} else if ([cell.subviews indexOfObjectIdenticalTo: self.topShadow] != 0) {
				[cell insertSubview: self.topShadow atIndex: 0];
			}
			
			CGRect shadowFrame = self.topShadow.frame;
			shadowFrame.origin.y = -shadowFrame.size.height;
			shadowFrame.size.width = cell.bounds.size.width;
			self.topShadow.frame = shadowFrame;
		} else {
			[self.topShadow removeFromSuperview];
		}
		
		NSIndexPath *lastCell = [indexPathsForVisibleRows lastObject];
		if (lastCell.section == self.numberOfSections - 1 && lastCell.row == [self numberOfRowsInSection: lastCell.section] - 1) {
			UIView *cell = [self cellForRowAtIndexPath: lastCell];
			
			if (!self.bottomShadow) {
				AZShadowedTableShadowView *bottom = [[AZShadowedTableShadowView alloc] initWithFrame: CGRectMake(0, 0, 0, 25) top: NO];
				bottom.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
				[cell insertSubview: bottom atIndex: 0];
				self.bottomShadow = bottom;
			} else if ([cell.subviews indexOfObjectIdenticalTo: self.bottomShadow] != 0) {
				[cell insertSubview: self.bottomShadow atIndex: 0];
			}
			
			CGRect shadowFrame = self.bottomShadow.frame;
			shadowFrame.origin.y = cell.bounds.size.height;
			shadowFrame.size.width = cell.bounds.size.width;
			self.bottomShadow.frame = shadowFrame;
		} else {
			[self.bottomShadow removeFromSuperview];
		}
	} else {
		[self.topShadow removeFromSuperview];
		[self.bottomShadow removeFromSuperview];
	}

	self.topShadow.hidden = self.bottomShadow.hidden = self.originShadow.hidden = self.maximumShadow.hidden = self.hidesShadows;
	self.topShadow.alpha = self.bottomShadow.alpha = self.originShadow.alpha = self.maximumShadow.alpha = self.hidesShadows ? 0.0f : 1.0f;

}

- (void)setHidesShadows:(BOOL)hidesShadows {
	[self setHidesShadows: hidesShadows animated: NO];
}

- (void)setHidesShadows:(BOOL)hidesShadows animated:(BOOL)animated {
	_hidesShadows = hidesShadows;

	self.topShadow.hidden = self.bottomShadow.hidden = self.originShadow.hidden = self.maximumShadow.hidden = !hidesShadows;
	self.topShadow.alpha = self.bottomShadow.alpha = self.originShadow.alpha = self.maximumShadow.alpha = hidesShadows ? 1.0f : 0.0f;

	[UIView animateWithDuration: (1./3.) delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowAnimatedContent animations: ^{
		self.topShadow.alpha = self.bottomShadow.alpha = self.originShadow.alpha = self.maximumShadow.alpha = hidesShadows ? 0.0f : 1.0f;
	} completion:^(BOOL finished) {
		self.topShadow.hidden = self.bottomShadow.hidden = self.originShadow.hidden = self.maximumShadow.hidden = hidesShadows;
		[self setNeedsLayout];
	}];
}

@end
