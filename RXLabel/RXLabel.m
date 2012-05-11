//
//  RXLabel.m
//  RXLabel
//
//  Created by Zachary Waldowski on 3/17/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "RXLabel.h"

@implementation RXLabel {
	CGGradientRef _gradient;
}

@synthesize shadowBlur = _rx_shadowBlur;

- (void)rx_resetGradient {
	if (_gradient) {
		CGGradientRelease(_gradient);
		_gradient = NULL;
	}
	
	NSUInteger colorCount = self.gradientColors.count;
	
	if (colorCount < 2)
		return;
	
	CGFloat *locations = calloc(sizeof(CGFloat), colorCount);
	if (self.gradientLocations.count == self.gradientColors.count && [self.gradientLocations.lastObject isKindOfClass:[NSNumber class]]) {
		[self.gradientLocations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			locations[idx] = [obj floatValue];
		}];
	} else {
		locations[0] = 0.0f;
		locations[colorCount-1] = 1.0f;
		CGFloat delta = 1.0f / (CGFloat)colorCount;
		for (int i = 1; i < colorCount-1; i++) {
			locations[i] = delta * i;
		}
	}
	
	NSMutableArray *colors = [NSMutableArray arrayWithCapacity: colorCount];
	if ([self.gradientColors.lastObject isKindOfClass:[UIColor class]]) {
		[self.gradientColors enumerateObjectsUsingBlock:^(UIColor *color, NSUInteger idx, BOOL *stop) {
			[colors addObject: (__bridge id)color.CGColor];
		}];
	}
	
	_gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);
	
	free(locations);
}

- (void)didChangeValueForKey:(NSString *)key {
	[super didChangeValueForKey:key];
	
	if ([key isEqualToString:@"shadowBlur"] ||
		[key isEqualToString:@"innerShadowOffset"] ||
		[key isEqualToString:@"innerShadowBlur"] ||
		[key isEqualToString:@"innerShadowColor"] ||
		[key isEqualToString:@"gradientDirection"]) {
		[self setNeedsDisplay];
	} else if ([key isEqualToString:@"gradientColors"] ||
			   [key isEqualToString:@"gradientLocations"]) {
		[self rx_resetGradient];
		[self setNeedsDisplay];
	}
}

- (void)drawTextInRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect innerRect = (CGRect){ CGPointZero, rect.size };
	BOOL needsMask = (self.innerShadowColor != nil || self.gradientColors.count > 1);
	
	CGImageRef alphaMask = NULL, invertedMask = NULL;
	
	if (needsMask) {
        CGContextSaveGState(context);
		
		[[UIColor blackColor] setFill];
		
        [self.text drawInRect:rect withFont:self.font lineBreakMode:self.lineBreakMode alignment:self.textAlignment];
        
        // Create an image mask from what we've drawn so far
        alphaMask = CGBitmapContextCreateImage(context);
		
        //clear the context
        CGContextClearRect(context, rect);
		
		if (self.innerShadowColor) {
			CGContextFillRect(context, innerRect);
			CGContextSetBlendMode(context, kCGBlendModeSourceOut);	//	R = S*(1 - Da)
			
			[[UIColor whiteColor] setFill];
			[self.text drawInRect:rect withFont:self.font lineBreakMode:self.lineBreakMode alignment:self.textAlignment];
			
			// Create an image mask from what we've drawn so far
			invertedMask = CGBitmapContextCreateImage(context);
			
			//clear the context
			CGContextClearRect(context, rect);
			
			CGContextRestoreGState(context);
		}
	}
	
	CGContextSaveGState(context);
	
	if (self.shadowColor) {
		CGFloat textAlpha = CGColorGetAlpha(self.textColor.CGColor);
        CGContextSetShadowWithColor(context, self.shadowOffset, self.shadowBlur, self.shadowColor.CGColor);
        [needsMask ? [self.shadowColor colorWithAlphaComponent:textAlpha] : self.textColor setFill];
	} else {
		[self.gradientColors.count ? [self.gradientColors objectAtIndex: 0] : self.textColor setFill];
		CGContextSetShadowWithColor(context, CGSizeZero, 0.0, NULL);
	}
	
	[self.text drawInRect:rect withFont:self.font lineBreakMode:self.lineBreakMode alignment:self.textAlignment];
	
	CGContextRestoreGState(context);
	
	if (needsMask) {
		CGContextSaveGState(context);
		CGContextTranslateCTM(context, 0, rect.size.height);
		CGContextScaleCTM(context, 1.0, -1.0);
		CGContextClipToMask(context, rect, alphaMask);
				
		if (self.gradientColors.count > 1) {
			if (!_gradient)
				[self rx_resetGradient];
			
			CGPoint startPoint = rect.origin;
			CGPoint endPoint = CGPointMake(CGRectGetMinX(rect), self.gradientDirection == RXLabelGradientDirectionHorizontal ? CGRectGetMaxX(rect) : CGRectGetMaxY(rect));
			CGContextDrawLinearGradient(context, _gradient, startPoint, endPoint, 0);
		}
		
		if (self.innerShadowColor) {
			CGContextSetShadowWithColor(context, self.innerShadowOffset, self.innerShadowBlur, self.innerShadowColor.CGColor);
			CGContextDrawImage(context, rect, invertedMask);
		}
		
		CGContextRestoreGState(context);
		CGImageRelease(invertedMask);
		CGImageRelease(alphaMask);
	}
}


@end
