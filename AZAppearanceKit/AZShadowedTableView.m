//
//  AZShadowedTableView.m
//  AZAppearanceKit
//
//  Created by Matt Gallagher on 8/21/09.
//  Copyright (c) 2009 Matt Gallagher. All rights reserved.
//  Copyright (c) 2011-2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import "AZShadowedTableView.h"

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
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 20, [UIColor colorWithWhite: 0.0 alpha: 1.0].CGColor);
    
    CGFloat position = _top ?  CGRectGetMaxY(rect) + 5 : CGRectGetMinY(rect) - 5;
    
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), position);
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), position);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(ctx, 5);
    
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);    
}

@end

@interface AZShadowedTableView ()

@property (nonatomic, weak) UIView *topShadow;
@property (nonatomic, weak) UIView *bottomShadow;

@end

@implementation AZShadowedTableView

@synthesize topShadow = _topShadow, bottomShadow = _bottomShadow;

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	NSArray *indexPathsForVisibleRows = self.indexPathsForVisibleRows;
	if (indexPathsForVisibleRows.count) {
		NSIndexPath *firstCell = [indexPathsForVisibleRows objectAtIndex:0];
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
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(context);
	
	CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 20, [UIColor colorWithWhite: 0.0 alpha: 1.0].CGColor);
    
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect) - 5);
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect) - 5);
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 5);
    
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect) + 5);
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect) + 5);
    
    CGContextStrokePath(context);
	
	CGContextRestoreGState(context);
}

@end
