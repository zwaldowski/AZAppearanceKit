//
//  RXLabel.m
//  RXLabel
//
//  Created by Zachary Waldowski on 3/17/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "RXLabel.h"

@interface RXLabel ()
{
	CGGradientRef _gradient;
}

- (UIBezierPath *) textPath;

- (void) rx_resetGradient;

@end

@implementation RXLabel

@synthesize gradientColors = _gradientColors;
@synthesize gradientDirection = _gradientDirection;
@synthesize gradientLocations = _gradientLocations;
@synthesize innerShadowBlur = _innerShadowBlur;
@synthesize innerShadowColor = _innerShadowColor;
@synthesize innerShadowOffset = _innerShadowOffset;
@synthesize shadowBlur = _rx_shadowBlur;

- (UIBezierPath *) textPath
{
	// Create path from text
    // See: http://www.codeproject.com/KB/iPhone/Glyph.aspx
    // License: The Code Project Open License (CPOL) 1.02 http://www.codeproject.com/info/cpol10.aspx
	
	// See: https://github.com/ole/Animated-Paths/blob/0347e90738cedf4f543c2cb9ab97d18780d461e2/Classes/AnimatedPathViewController.m#L86
	
	CGMutablePathRef letters = CGPathCreateMutable();
	
	CTFontRef font = CTFontCreateWithName((__bridge CFStringRef) self.font.fontName, self.font.pointSize, NULL);
	
	CTTextAlignment textAlignment;
	switch (self.textAlignment)
	{
		case UITextAlignmentLeft:
			textAlignment = kCTLeftTextAlignment;
			break;
			
		case UITextAlignmentCenter:
			textAlignment = kCTCenterTextAlignment;
			break;
		
		case UITextAlignmentRight:
			textAlignment = kCTRightTextAlignment;
			break;
		
		default:
			textAlignment = self.textAlignment;
			break;
	}
	
	CTLineBreakMode lineBreakMode;
	switch (self.lineBreakMode)
	{
		case UILineBreakModeWordWrap:
			lineBreakMode = kCTLineBreakByWordWrapping;
			break;
		
		case UILineBreakModeCharacterWrap:
			lineBreakMode = kCTLineBreakByCharWrapping;
			break;
		
		case UILineBreakModeClip:
			lineBreakMode = kCTLineBreakByClipping;
			break;
		
		case UILineBreakModeHeadTruncation:
			lineBreakMode = kCTLineBreakByTruncatingHead;
			break;
		
		case UILineBreakModeTailTruncation:
			lineBreakMode = kCTLineBreakByTruncatingTail;
			break;
		
		case UILineBreakModeMiddleTruncation:
			lineBreakMode = kCTLineBreakByTruncatingMiddle;
			break;
			
		default:
			lineBreakMode = self.lineBreakMode;
			break;
	}

	CTParagraphStyleSetting settings[] = {
		{ .spec = kCTParagraphStyleSpecifierAlignment,     .valueSize = sizeof(textAlignment), .value = &textAlignment },
		{ .spec = kCTParagraphStyleSpecifierLineBreakMode, .valueSize = sizeof(lineBreakMode), .value = &lineBreakMode }
	};
	CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 2);
	
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
								(__bridge_transfer id) font, kCTFontAttributeName,
								(__bridge_transfer id) paragraphStyle, kCTParagraphStyleAttributeName,
								nil];
	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString: self.text attributes: attributes];
	
	CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef) attributedString);
	
	CFArrayRef runArray = CTLineGetGlyphRuns(line);
	
	// For each RUN
	CFIndex runIndex, runCount = CFArrayGetCount(runArray);
	for (runIndex = 0; runIndex < runCount; ++runIndex)
	{
		// Get FONT for this run
		CTRunRef run = (CTRunRef) CFArrayGetValueAtIndex(runArray, runIndex);
		CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
		
		// For each GLYPH in run
		CFIndex runGlyphIndex, runGlyphCount = CTRunGetGlyphCount(run);
		for (runGlyphIndex = 0; runGlyphIndex < runGlyphCount; ++runGlyphIndex)
		{
			// Get GLYPH and GLYPH-DATA
			CFRange glyphRange = CFRangeMake(runGlyphIndex, 1);
			
			CGGlyph glyph;
			CTRunGetGlyphs(run, glyphRange, &glyph);
			
			CGPoint position;
			CTRunGetPositions(run, glyphRange, &position);
			
			// Get PATH of outline
			CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
			CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
			CGPathAddPath(letters, &t, letter);
			CGPathRelease(letter);
		}
	}
	
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint: CGPointZero];
	[path appendPath: [UIBezierPath bezierPathWithCGPath: letters]];
	[path closePath];
	
	CGPathRelease(letters);
	
	CGFloat xOffset = 0;
	switch (self.textAlignment)
	{
		case UITextAlignmentCenter:
			xOffset = 0.5 * (self.bounds.size.width - path.bounds.size.width);
			break;
			
		case UITextAlignmentRight:
			xOffset = self.bounds.size.width - path.bounds.size.width + path.bounds.origin.x;
			break;
			
		default:
			break;
	}
	
	[path applyTransform: CGAffineTransformMakeTranslation(xOffset, 0.5 * (self.bounds.size.height - path.bounds.size.height - MIN(path.bounds.origin.y, 0)))];
	
	return path;
}

- (void) drawTextInRect: (CGRect) rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextTranslateCTM(ctx, 0, rect.size.height);
	CGContextScaleCTM(ctx, 1, -1);

	UIBezierPath* textPath = [self textPath];
	CGContextSaveGState(ctx);
	{
		CGContextSetShadowWithColor(ctx, self.shadowOffset, self.shadowBlur, self.shadowColor.CGColor);
		CGContextBeginTransparencyLayer(ctx, NULL);
		{
			[textPath addClip];
			
			if (self.gradientColors.count)
			{
				if (!_gradient) [self rx_resetGradient];
				
				CGPoint startPoint = rect.origin;
				CGPoint endPoint = CGPointMake(CGRectGetMinX(rect), self.gradientDirection == RXLabelGradientDirectionHorizontal ? CGRectGetMaxX(rect) : CGRectGetMaxY(rect));
				CGContextDrawLinearGradient(ctx, _gradient, startPoint, endPoint, 0);
			}
			else
			{
				CGContextSetFillColorWithColor(ctx, self.textColor.CGColor);
				CGContextFillRect(ctx, textPath.bounds);
			}
		}
		CGContextEndTransparencyLayer(ctx);
		
		CGRect textBorderRect = CGRectInset([textPath bounds], -self.innerShadowBlur, -self.innerShadowBlur);
		textBorderRect = CGRectOffset(textBorderRect, -self.innerShadowOffset.width, -self.innerShadowOffset.height);
		textBorderRect = CGRectInset(CGRectUnion(textBorderRect, [textPath bounds]), -1, -1);
		
		UIBezierPath *textNegativePath = [UIBezierPath bezierPathWithRect: textBorderRect];
		[textNegativePath appendPath: textPath];
		textNegativePath.usesEvenOddFillRule = YES;
		
		CGContextSaveGState(ctx);
		{
			CGFloat xOffset = self.innerShadowOffset.width + round(textBorderRect.size.width);
			CGFloat yOffset = self.innerShadowOffset.height;
			CGContextSetShadowWithColor(ctx, CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)), self.innerShadowBlur, self.innerShadowColor.CGColor);
			
			[textPath addClip];
			
			CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(textBorderRect.size.width), 0);
			[textNegativePath applyTransform: transform];
			
			[[UIColor grayColor] setFill];
			[textNegativePath fill];
		}
		CGContextRestoreGState(ctx);
	}
	CGContextRestoreGState(ctx);
}
- (void) rx_resetGradient
{
	if (_gradient)
	{
		CGGradientRelease(_gradient), _gradient = NULL;
	}
	
	NSUInteger colorCount = self.gradientColors.count;
	
	if (colorCount < 2)
		return;
	
	CGFloat *locations = calloc(sizeof(CGFloat), colorCount);
	
	if (self.gradientLocations.count == self.gradientColors.count && [self.gradientLocations.lastObject isKindOfClass:[NSNumber class]])
	{
		[self.gradientLocations enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
			locations[idx] = [obj floatValue];
		}];
	}
	else
	{
		locations[0] = 0.0f;
		locations[colorCount - 1] = 1.0f;
		
		CGFloat delta = 1.0f / (CGFloat) colorCount;
		for (int i = 1; i < colorCount-1; i++) locations[i] = delta * i;
	}
	
	NSMutableArray *colors = [NSMutableArray arrayWithCapacity: colorCount];
	if ([self.gradientColors.lastObject isKindOfClass: [UIColor class]])
	{
		[self.gradientColors enumerateObjectsUsingBlock: ^(UIColor *color, NSUInteger idx, BOOL *stop) {
			[colors addObject: (__bridge id) color.CGColor];
		}];
	}
	
	_gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef) colors, locations);
	free(locations);
}
- (void) setGradientDirection: (RXLabelGradientDirection) gradientDirection
{
	_gradientDirection = gradientDirection;
	[self setNeedsDisplay];
}
- (void) setInnerShadowBlur: (CGFloat) innerShadowBlur
{
	_innerShadowBlur = innerShadowBlur;
	[self setNeedsDisplay];
}
- (void) setInnerShadowColor: (UIColor *) innerShadowColor
{
	_innerShadowColor = innerShadowColor;
	[self setNeedsDisplay];
}
- (void) setInnerShadowOffset: (CGSize) innerShadowOffset
{
	_innerShadowOffset = innerShadowOffset;
	[self setNeedsDisplay];
}
- (void) setShadowBlur: (CGFloat) shadowBlur
{
	_rx_shadowBlur = shadowBlur;
	[self setNeedsDisplay];
}
- (void) setGradientColors: (NSArray *) gradientColors
{
	_gradientColors = [gradientColors copy];
	[self rx_resetGradient];
	[self setNeedsDisplay];
}
- (void) setGradientLocations: (NSArray *) gradientLocations
{
	_gradientLocations = [gradientLocations copy];
	[self rx_resetGradient];
	[self setNeedsDisplay];
}

@end
