//
//  AZShadowedTableView.m
//  AZAppearanceKit
//
//  Created by Matt Gallagher on 8/21/09.
//  Copyright (c) 2009 Matt Gallagher. All rights reserved.
//  Copyright (c) 2011-2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import "AZDrawingFunctions.h"
#import "AZShadowedTableView.h"

@interface AZShadowedTableView ()

@property (nonatomic, weak) UIImageView *bottomShadow;
@property (nonatomic, weak) UIImageView *originShadow;
@property (nonatomic, weak) UIImageView *maximumShadow;
@property (nonatomic, weak) UIImageView *topShadow;

@end

@implementation AZShadowedTableView

+ (UIImage *)shadowImageWithSize:(CGSize)size top:(BOOL)top {
	CGRect rect = { CGPointZero, size };
	rect.size.height += 5;
	
	if (!top) rect.origin.y -= 5;
	
	return UIImageCreateUsingBlock(size, NO, ^(CGContextRef ctx){
		CGContextSetShadowWithColor(ctx, CGSizeZero, 20, [UIColor blackColor].CGColor);
		CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
		CGContextSetLineWidth(ctx, 5);
		CGContextStrokeRectEdge(ctx, rect, top ? CGRectMaxYEdge : CGRectMinYEdge);
	});
}

- (void) layoutSubviews
{
	[super layoutSubviews];
	
	static CGFloat const kShadowHeight = 25.0f;
	CGSize const kImageSize = CGSizeMake(self.frame.size.width, kShadowHeight);
	
	if (!self.tableFooterView)
	{
		UIView *v = [[UIView alloc] initWithFrame: CGRectZero];
		v.backgroundColor = [UIColor clearColor];
		self.tableFooterView = v;
	}
		
	if (!self.originShadow)
	{
		UIImageView *top = [[UIImageView alloc] initWithFrame: (CGRect){ self.contentOffset, kImageSize }];
		top.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		top.image = [[self class] shadowImageWithSize:kImageSize top:NO];
		
		if (self.backgroundView)
			[self insertSubview: top aboveSubview: self.backgroundView];
		else
			[self insertSubview: top atIndex: 0];
		
		self.originShadow = top;
	}
	else if (self.backgroundView)
	{
		[self insertSubview: self.originShadow aboveSubview: self.backgroundView];
	}
	else if ([self.subviews indexOfObjectIdenticalTo: self.originShadow] != 0)
	{
		[self insertSubview: self.originShadow atIndex: 0];
	}
	
	CGRect originShadowFrame = self.originShadow.frame;
	originShadowFrame.origin.y = self.contentOffset.y;
	self.originShadow.frame = originShadowFrame;
	
	NSArray *indexPathsForVisibleRows = self.indexPathsForVisibleRows;
	if (indexPathsForVisibleRows.count)
	{
		NSIndexPath *firstCell = indexPathsForVisibleRows[0];
		if (firstCell.section == 0 && firstCell.row == 0)
		{
			UIView *cell = [self cellForRowAtIndexPath: firstCell];
			
			if (!self.topShadow) {
				UIImageView *top = [[UIImageView alloc] initWithFrame: (CGRect){ CGPointZero, kImageSize }];
				top.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
				top.image = [[self class] shadowImageWithSize:kImageSize top:YES];
				
				[cell insertSubview: top atIndex: 0];
				
				self.topShadow = top;
			} else if ([cell.subviews indexOfObjectIdenticalTo: self.topShadow] != 0) {
				[cell insertSubview: self.topShadow atIndex: 0];
			}
			
			CGRect shadowFrame = self.topShadow.frame;
			shadowFrame.origin.y = -shadowFrame.size.height;
			shadowFrame.size.width = cell.bounds.size.width;
			self.topShadow.frame = shadowFrame;
		}
		else
		{
			[self.topShadow removeFromSuperview];
		}
		
		NSIndexPath *lastCell = [indexPathsForVisibleRows lastObject];
		if (lastCell.section == self.numberOfSections - 1 && lastCell.row == [self numberOfRowsInSection: lastCell.section] - 1) {
			UIView *cell = [self cellForRowAtIndexPath: lastCell];
			
			if (!self.bottomShadow)
			{
				UIImageView *bottom = [[UIImageView alloc] initWithFrame: (CGRect){ self.contentOffset, kImageSize }];
				bottom.image = [[self class] shadowImageWithSize:kImageSize top:NO];
				bottom.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
				
				[self insertSubview: bottom atIndex: 0];
				
				self.bottomShadow = bottom;
			}
			else if (self.backgroundView)
			{
				[self insertSubview: self.maximumShadow aboveSubview: self.backgroundView];
			}
			else if ([cell.subviews indexOfObjectIdenticalTo: self.bottomShadow] != 0)
			{
				[self insertSubview: self.bottomShadow atIndex: 0];
			}
			
			CGRect shadowFrame = self.bottomShadow.frame;
			shadowFrame.origin.y = CGRectGetMaxY(cell.frame);
			self.bottomShadow.frame = shadowFrame;
			
			if (!self.maximumShadow)
			{
				UIImageView *top = [[UIImageView alloc] initWithFrame:(CGRect){ self.contentOffset, kImageSize }];
				top.autoresizingMask = UIViewAutoresizingFlexibleWidth;
				top.image = [[self class] shadowImageWithSize:kImageSize top:YES];
				
				if (self.backgroundView)
					[self insertSubview: top aboveSubview: self.backgroundView];
				else
					[self insertSubview: top atIndex: 0];
				
				self.maximumShadow = top;
			}
			else if (self.backgroundView)
			{
				[self insertSubview: self.maximumShadow aboveSubview: self.backgroundView];
			}
			else if ([self.subviews indexOfObjectIdenticalTo: self.originShadow] != 0)
			{
				[self insertSubview: self.maximumShadow atIndex: 0];
			}
			
			CGRect maximumShadowFrame = self.maximumShadow.frame;
			maximumShadowFrame.origin.y = self.contentOffset.y + self.frame.size.height - maximumShadowFrame.size.height;
			self.maximumShadow.frame = maximumShadowFrame;
		}
		else
		{
			[self.bottomShadow removeFromSuperview];
			[self.maximumShadow removeFromSuperview];
		}
	}
	else
	{
		[self.topShadow removeFromSuperview];
		[self.bottomShadow removeFromSuperview];
	}

	self.topShadow.hidden = self.bottomShadow.hidden = self.originShadow.hidden = self.maximumShadow.hidden = self.hidesShadows;
	self.topShadow.alpha = self.bottomShadow.alpha = self.originShadow.alpha = self.maximumShadow.alpha = self.hidesShadows ? 0.0f : 1.0f;
}
- (void) setHidesShadows: (BOOL) hidesShadows
{
	[self setHidesShadows: hidesShadows animated: NO];
}
- (void) setHidesShadows: (BOOL) hidesShadows animated: (BOOL) animated
{
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
