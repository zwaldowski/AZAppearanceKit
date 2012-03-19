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
	BOOL needsMask = (self.innerShadowColor != nil && self.gradientColors.count > 1);
	
	// the original label, with colors
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, self.window.screen.scale);
	CGContextRef textContext = UIGraphicsGetCurrentContext();
	CGContextConcatCTM(textContext, (CGAffineTransform){ 1, 0, 0, -1, 0, CGRectGetHeight(rect) });
	[self.textColor setFill];
	[self.text drawInRect:innerRect withFont:self.font lineBreakMode:self.lineBreakMode alignment:self.textAlignment];
	CGImageRef textImage = UIGraphicsGetImageFromCurrentImageContext().CGImage;	//	With alpha channel
	UIGraphicsEndImageContext();
	
	if (self.shadowColor) {
		CGSize offset = self.shadowOffset;
		if (CGSizeEqualToSize(offset, CGSizeZero))
			offset = CGSizeMake(0, -1);
		
		CGContextSetShadowWithColor(context, offset, self.shadowBlur, self.shadowColor.CGColor);
	} else
		CGContextSetShadowWithColor(context, CGSizeZero, 0.0, NULL);
	
	CGContextDrawImage(context, rect, textImage);
	
	if (needsMask) {
		CGContextSaveGState(context);
		CGContextClipToMask(context, rect, textImage);
		
		if (self.gradientColors.count > 1) {
			if (!_gradient)
				[self rx_resetGradient];
			
			CGPoint startPoint = rect.origin;
			CGPoint endPoint = self.gradientDirection == RXLabelGradientDirectionHorizontal ? CGPointMake(CGRectGetMinX(rect), CGRectGetMaxX(rect)) : CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
			CGContextDrawLinearGradient(context, _gradient, startPoint, endPoint, 0);
		}
		
		if (self.innerShadowColor) {
			// inverted mask
			UIGraphicsBeginImageContextWithOptions(rect.size, NO, self.window.screen.scale);
			CGContextRef invertedTextContext = UIGraphicsGetCurrentContext();
			CGContextConcatCTM(invertedTextContext, (CGAffineTransform){ 1, 0, 0, -1, 0, CGRectGetHeight(rect) });
			CGContextSetFillColorWithColor(invertedTextContext, [UIColor blackColor].CGColor);
			CGContextFillRect(invertedTextContext, innerRect);
			CGContextSetBlendMode(invertedTextContext, kCGBlendModeSourceOut);	//	R = S*(1 - Da)
			[self.textColor setFill];
			[self.text drawInRect:innerRect withFont:self.font lineBreakMode:self.lineBreakMode alignment:self.textAlignment];
			CGImageRef invertedTextMask = UIGraphicsGetImageFromCurrentImageContext().CGImage;
			UIGraphicsEndImageContext();
			
			CGContextSetShadowWithColor(context, self.innerShadowOffset, self.innerShadowBlur, self.innerShadowColor.CGColor);
			CGContextDrawImage(context, rect, invertedTextMask);
		}
		CGContextRestoreGState(context);
	}
}


@end
