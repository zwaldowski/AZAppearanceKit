//
//  AZLabel.m
//  AZAppearanceKit
//
//  Created by Zachary Waldowski on 3/17/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//
//  Includes code by Ole Begemann. Licensed under MIT.
//  Copyright 2010. All rights reserved.
//
//  Includes code by Sam King. Licensed under CPOL 1.02.
//  Copyright 2010. All rights reserved.
//

#import <CoreText/CoreText.h>

#import "AZDrawingFunctions.h"
#import "AZGradient.h"
#import "AZLabel.h"

static inline CTLineBreakMode CTLineBreakModeForUILineBreakMode(UILineBreakMode lineBreak)
{
	switch (lineBreak)
	{
		case UILineBreakModeWordWrap:
			return kCTLineBreakByWordWrapping;
		case UILineBreakModeCharacterWrap:
			return kCTLineBreakByCharWrapping;
		case UILineBreakModeClip:
			return kCTLineBreakByClipping;
		case UILineBreakModeHeadTruncation:
			return kCTLineBreakByTruncatingHead;
		case UILineBreakModeTailTruncation:
			return kCTLineBreakByTruncatingTail;
		case UILineBreakModeMiddleTruncation:
			return kCTLineBreakByTruncatingMiddle;
	}
}

static inline CTTextAlignment CTTextAlignmentForUIContentHorizontalAlignment(UIControlContentHorizontalAlignment align)
{
	switch (align)
	{
		case UIControlContentHorizontalAlignmentLeft:
			return kCTLeftTextAlignment;
		case UIControlContentHorizontalAlignmentCenter:
			return kCTCenterTextAlignment;
		case UIControlContentHorizontalAlignmentRight:
			return kCTRightTextAlignment;
		case UIControlContentHorizontalAlignmentFill:
			return kCTJustifiedTextAlignment;
	}
}

static inline UIControlContentHorizontalAlignment UIControlContentHorizontalAlignmentForUITextAlignment(UITextAlignment align)
{
	switch (align)
	{
		case UITextAlignmentLeft:
			return UIControlContentHorizontalAlignmentLeft;
		case UITextAlignmentCenter:
			return UIControlContentHorizontalAlignmentCenter;
		case UITextAlignmentRight:
			return UIControlContentHorizontalAlignmentRight;
		default:
			return UIControlContentHorizontalAlignmentFill;
	}
}

@interface AZLabel ()

- (id) az_valueForAppearanceKeyForCurrentState: (NSString *) key;
- (id) az_valueForAppearanceKey: (NSString *) key forState: (UIControlState) state;

+ (UIFont *) az_defaultFont;

- (void) az_sharedInit;
- (void) az_setValue: (id) value forAppearanceKey: (NSString *) key forState: (UIControlState) state;

@property (nonatomic, readonly, getter = az_gradientDirectionForCurrentState) AZGradientDirection gradientDirectionForCurrentState;
@property (nonatomic, readonly, getter = az_gradientForCurrentState) AZGradient *gradientForCurrentState;
@property (nonatomic, readonly, getter = az_innerShadowForCurrentState) id <AZShadow> innerShadowForCurrentState;
@property (nonatomic, readonly, getter = az_shadowForCurrentState) id <AZShadow> shadowForCurrentState;
@property (nonatomic, readonly, getter = az_shouldUseGradientForCurrentState) BOOL shouldUseGradientForCurrentState;
@property (nonatomic, readonly, getter = az_textColorForCurrentState) UIColor *textColorForCurrentState;
@property (nonatomic, strong) NSMutableDictionary *appearanceStorage;
@property (nonatomic, strong) NSMutableDictionary *gradientDict;
@property (nonatomic, strong) NSMutableDictionary *innerShadowDict;
@property (nonatomic, strong) NSMutableDictionary *shadowDict;
@property (nonatomic, strong, readwrite) UIBezierPath *textPath;

@end

@implementation AZLabel

- (CGSize) sizeThatFits: (CGSize) size
{
	size = [self.text sizeWithFont: self.font];
	size.height += fabs(self.shadowForCurrentState.shadowOffset.height);
	size.width += fabs(self.shadowForCurrentState.shadowOffset.width);
	return size;
}

- (id) init
{
	if ((self = [super init]))
	{
		[self az_sharedInit];
	}
	
	return self;
}
- (id) initWithCoder: (NSCoder *) aDecoder
{
	if ((self = [super initWithCoder: aDecoder]))
	{
		self.text = [aDecoder decodeObjectForKey: @"UIText"];
		self.font = [aDecoder decodeObjectForKey: @"UIFont"] ?: [[self class] az_defaultFont];
		[self setTextColor: [aDecoder decodeObjectForKey: @"UITextColor"] ?: [UIColor blackColor] forState: UIControlStateNormal];
		[self setTextColor: [aDecoder decodeObjectForKey: @"UIHighlightedColor"] forState: UIControlStateHighlighted];
		
		if ([aDecoder containsValueForKey: @"UIShadowOffset"] || [aDecoder containsValueForKey: @"UIShadowColor"])
		{
			id <AZShadow> shadow = [[AZShadow alloc] init];
			
			if ([aDecoder containsValueForKey: @"UIShadowOffset"])
				shadow.shadowOffset = [aDecoder decodeCGSizeForKey: @"UIShadowOffset"];
			if ([aDecoder containsValueForKey: @"UIShadowColor"])
				shadow.shadowColor = [aDecoder decodeObjectForKey: @"UIShadowColor"];
			
			self.shadow = shadow;
		}
		
		if ([aDecoder containsValueForKey: @"UILineBreakMode"])
			self.lineBreakMode = [aDecoder decodeIntegerForKey: @"UILineBreakMode"];
		if ([aDecoder containsValueForKey: @"UITextAlignment"])
			self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentForUITextAlignment([aDecoder decodeIntegerForKey: @"UITextAlignment"]);
		if ([aDecoder containsValueForKey: @"UIEnabled"])
			self.enabled = [aDecoder decodeBoolForKey: @"UIEnabled"];
/*
		 if ([aDecoder containsValueForKey: @"UINumberOfLines"])
			self.numberOfLines = [aDecoder decodeIntegerForKey: @"UINumberOfLines"];
		 if ([aDecoder containsValueForKey: @"UIBaselineAdjustment"])
			self.baselineAdjustment = [aDecoder decodeIntegerForKey: @"UIBaselineAdjustment"];
		 if ([aDecoder containsValueForKey: @"UIAdjustsFontSizeToFit"])
			self.adjustsFontSizeToFitWidth = [aDecoder decodeBoolForKey: @"UIAdjustsFontSizeToFit"];
		 if ([aDecoder containsValueForKey: @"UIMinimumFontSize"])
			self.minimumFontSize = [aDecoder decodeFloatForKey: @"UIMinimumFontSize"];
*/
	}
	
	return self;
}
- (id) initWithFrame: (CGRect) frame
{
	if ((self = [super initWithFrame: frame]))
	{
		[self az_sharedInit];
	}
	
	return self;
}

+ (UIFont *) az_defaultFont
{
	return [UIFont systemFontOfSize: 17];
}

- (void) az_recalculateTextPath
{
	if (!self.font || !self.text)
		return;
	
	CGRect rect = self.bounds;
	
	CGMutablePathRef letters = CGPathCreateMutable();
	
	CTFontRef font = CTFontCreateWithName((__bridge CFStringRef) self.font.fontName, self.font.pointSize, NULL);
	
	CTTextAlignment textAlignment = CTTextAlignmentForUIContentHorizontalAlignment(self.contentHorizontalAlignment);
	CTLineBreakMode lineBreakMode = CTLineBreakModeForUILineBreakMode(self.lineBreakMode);
	
	CTParagraphStyleSetting settings[] = {
		{ .spec = kCTParagraphStyleSpecifierAlignment,     .valueSize = sizeof(textAlignment), .value = &textAlignment },
		{ .spec = kCTParagraphStyleSpecifierLineBreakMode, .valueSize = sizeof(lineBreakMode), .value = &lineBreakMode }
	};
	CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 2);
	
	NSDictionary *attributes = @{
		(id) kCTFontAttributeName: (__bridge_transfer id) font,
		(id) kCTParagraphStyleAttributeName: (__bridge_transfer id) paragraphStyle
	};
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
	
	CGRect bounds = CGPathGetPathBoundingBox(letters);
	CGFloat xOffset = 0;
	
	switch (self.contentHorizontalAlignment) {
		case UIControlContentHorizontalAlignmentLeft:
			xOffset = MIN(rect.origin.x, 0);
			break;
			
		case UIControlContentHorizontalAlignmentCenter:
			xOffset = rect.origin.x + 0.5 * (rect.size.width - bounds.size.width - MIN(bounds.origin.x, 0));
			break;
			
		case UIControlContentHorizontalAlignmentRight:
			xOffset = CGRectGetMaxX(rect) - CGRectGetMaxX(bounds);
			break;
			
		default:
			break;
	}
	
	CGFloat yOffset = 0;
	switch (self.contentVerticalAlignment) {
		case UIControlContentVerticalAlignmentBottom:
			yOffset = -MIN(bounds.origin.y, 0);
			break;
		case UIControlContentVerticalAlignmentCenter:
			yOffset = rect.origin.y + 0.5 * (rect.size.height - bounds.size.height - MIN(bounds.origin.y, 0));
			break;
		case UIControlContentVerticalAlignmentTop:
			yOffset = CGRectGetMaxY(rect) - CGRectGetMaxY(bounds);
			break;
			
		default:
			break;
	}
	CGAffineTransform alignmentTransform = CGAffineTransformMakeTranslation(xOffset, yOffset);
	
	CGMutablePathRef mutablePath = CGPathCreateMutable();
	CGPathMoveToPoint(mutablePath, &alignmentTransform, rect.origin.x, rect.origin.y);
	CGPathAddPath(mutablePath, &alignmentTransform, letters);
	CGPathCloseSubpath(mutablePath);
	CGPathRelease(letters);
	
	self.textPath = [UIBezierPath bezierPathWithCGPath: mutablePath];
	CGPathRelease(mutablePath);
}
- (void) az_sharedInit
{
	self.backgroundColor = [UIColor whiteColor];
	self.contentMode = UIViewContentModeRedraw;
	self.font = [[self class] az_defaultFont];
	self.textColor = [UIColor blackColor];
	self.userInteractionEnabled = NO;
}
- (void) drawRect: (CGRect) rect
{
	rect = UIEdgeInsetsInsetRect(rect, self.textEdgeInsets);
	
	if (!self.textPath && self.text.length)
		[self az_recalculateTextPath];
	
	if (self.gradientDict)
	{
		self.gradient = [[AZGradient alloc] initWithColorsAtLocations: self.gradientDict];
		self.gradientDict = nil;
	}
	
	if (self.shadowDict)
	{
		id <AZShadow> shadow = [[AZShadow alloc] init];
		if (self.shadowDict[@"shadowBlurRadius"])
			shadow.shadowBlurRadius = [self.shadowDict[@"shadowBlurRadius"] floatValue];
		if (self.shadowDict[@"shadowColor"])
			shadow.shadowColor = self.shadowDict[@"shadowColor"];
		if (self.shadowDict[@"shadowOffset"])
			shadow.shadowOffset = [self.shadowDict[@"shadowOffset"] CGSizeValue];
		self.shadow = shadow;
		self.shadowDict = nil;
	}

	if (self.innerShadowDict)
	{
		id <AZShadow> innerShadow = [[AZShadow alloc] init];
		if (self.innerShadowDict[@"shadowBlurRadius"])
			innerShadow.shadowBlurRadius = [self.innerShadowDict[@"shadowBlurRadius"] floatValue];
		if (self.innerShadowDict[@"shadowColor"])
			innerShadow.shadowColor = self.innerShadowDict[@"shadowColor"];
		if (self.innerShadowDict[@"shadowOffset"])
			innerShadow.shadowOffset = [self.innerShadowDict[@"shadowOffset"] CGSizeValue];
		self.innerShadow = innerShadow;
		self.innerShadowDict = nil;
	}
    
    UIGraphicsContextPerformBlock(^(CGContextRef ctx) {
        CGContextTranslateCTM(ctx, 0, rect.size.height);
        CGContextScaleCTM(ctx, 1, -1);
        
		id <AZShadow> shadow = self.shadowForCurrentState;
		[shadow set];

		CGContextBeginTransparencyLayer(ctx, NULL);
		{
			if (self.shouldUseGradientForCurrentState)
			{
				[self.gradientForCurrentState drawInBezierPath: self.textPath direction: self.gradientDirectionForCurrentState];
			}
			else
			{
				[self.textPath addClip];
				CGContextSetFillColorWithColor(ctx, self.textColorForCurrentState.CGColor);
				CGContextFillRect(ctx, self.textPath.bounds);
			}
		}
		CGContextEndTransparencyLayer(ctx);
		
		id <AZShadow> innerShadow = self.innerShadowForCurrentState;
		CGRect textBorderRect = CGRectInset(self.textPath.bounds, -shadow.shadowBlurRadius, -innerShadow.shadowBlurRadius);
		textBorderRect = CGRectOffset(textBorderRect, -innerShadow.shadowOffset.width, -innerShadow.shadowOffset.height);
		textBorderRect = CGRectInset(CGRectUnion(textBorderRect, self.textPath.bounds), -1, -1);
		
		UIBezierPath *textNegativePath = [UIBezierPath bezierPathWithRect: textBorderRect];
		[textNegativePath appendPath: self.textPath];
		textNegativePath.usesEvenOddFillRule = YES;
        
        UIGraphicsContextPerformBlock(^(CGContextRef ctx) {
			id <AZShadow> innerShadowCopy = [(NSObject *) innerShadow copy];
			CGFloat xOffset = innerShadow.shadowOffset.width + round(textBorderRect.size.width);
			CGFloat yOffset = innerShadow.shadowOffset.height;
			innerShadowCopy.shadowOffset = CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset));
			[innerShadowCopy set];
			
			[self.textPath addClip];
			
			CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(textBorderRect.size.width), 0);
			[textNegativePath applyTransform: transform];
			
			[[UIColor grayColor] setFill];
			[textNegativePath fill];
        });
    });
}
- (void) layoutSubviews
{
	[super layoutSubviews];
	[self az_recalculateTextPath];
}
- (void) setHighlighted: (BOOL) highlighted
{
	[super setHighlighted: highlighted];
	[self setNeedsDisplay];
}
- (void) willMoveToSuperview: (UIView *) newSuperview
{
	[super willMoveToSuperview: newSuperview];
	[self az_recalculateTextPath];
}

#pragma mark - Display Properties

- (void) setTextEdgeInsets: (UIEdgeInsets) textEdgeInsets
{
	_textEdgeInsets = textEdgeInsets;
	if (self.superview) [self setNeedsDisplay];
}

#pragma mark - Text Properties

- (void) setContentHorizontalAlignment: (UIControlContentHorizontalAlignment) contentHorizontalAlignment
{
	[super setContentHorizontalAlignment: contentHorizontalAlignment];
	[self az_recalculateTextPath];
	if (self.superview) [self setNeedsDisplay];
}
- (void) setContentVerticalAlignment: (UIControlContentVerticalAlignment) contentVerticalAlignment
{
	[super setContentVerticalAlignment: contentVerticalAlignment];
	[self az_recalculateTextPath];
	if (self.superview) [self setNeedsDisplay];
}
- (void) setFont: (UIFont *) font
{
	if (!font) [NSException raise: NSInvalidArgumentException format: @"Font cannot be nil"];
	_font = font;
	[self az_recalculateTextPath];
	if (self.superview) [self setNeedsDisplay];
}
- (void) setLineBreakMode: (UILineBreakMode) lineBreakMode
{
	_lineBreakMode = lineBreakMode;
	[self az_recalculateTextPath];
	if (self.superview) [self setNeedsDisplay];
}
- (void) setText: (NSString *) text
{
	_text = [text copy];
	[self az_recalculateTextPath];
	if (self.superview) [self setNeedsDisplay];
}

#pragma mark - State Value Getters

- (id) az_valueForAppearanceKeyForCurrentState: (NSString *) key
{
	if (!self.appearanceStorage)
		return nil;
	
	UIControlState currentState = self.state;
	id value = [self az_valueForAppearanceKey: key forState: currentState];
	
	if (!value && currentState == UIControlStateHighlighted) {
		currentState = UIControlStateSelected;
		value = [self az_valueForAppearanceKey: key forState: currentState];
	}
	
	if (!value && currentState == UIControlStateSelected)
	{
		currentState = UIControlStateHighlighted;
		value = [self az_valueForAppearanceKey: key forState: currentState];
	}
	
	if (!value)
	{
		value = [self az_valueForAppearanceKey: key forState: UIControlStateNormal];
	}
	
	return value;
}
- (id) az_valueForAppearanceKey: (NSString *) key forState: (UIControlState) state
{
	if (!self.appearanceStorage)
		return nil;
	
	return self.appearanceStorage[@(state)][key];
}

- (void) az_setValue: (id) value forAppearanceKey: (NSString *) key forState: (UIControlState) state
{
	if (!self.appearanceStorage)
		self.appearanceStorage = [NSMutableDictionary dictionary];
	
	id stateKey = @(state);
	NSMutableDictionary *stateStorage = self.appearanceStorage[stateKey];
	
	if (!stateStorage)
	{
		stateStorage = [NSMutableDictionary dictionary];
		self.appearanceStorage[stateKey] = stateStorage;
	}
	
	if (value)
		stateStorage[key] = value;
	else
		[stateStorage removeObjectForKey: key];
}

#pragma mark - Text Color

- (UIColor *) textColor
{
	return [self textColorForState: UIControlStateNormal];
}
- (UIColor *) textColorForState: (UIControlState) state
{
	return [self az_valueForAppearanceKey: @"textColor" forState: state];
}

- (void) setTextColor: (UIColor *) color
{
	[self setTextColor: color forState: UIControlStateNormal];
}
- (void) setTextColor: (UIColor *) color forState: (UIControlState) state
{
	[self az_setValue: color forAppearanceKey: @"textColor" forState: state];
}

#pragma mark - Shadow

- (id <AZShadow>) shadow
{
	return [self shadowForState: UIControlStateNormal];
}
- (id <AZShadow>) shadowForState: (UIControlState) controlState
{
	return [self az_valueForAppearanceKey: @"shadow" forState: controlState];
}

- (void) setShadow: (id <AZShadow>) shadow
{
	[self setShadow: shadow forState: UIControlStateNormal];
}
- (void) setShadow: (id <AZShadow>) shadow forState: (UIControlState) controlState
{
	[self az_setValue: shadow forAppearanceKey: @"shadow" forState: controlState];
}

#pragma mark - Inner Shadow

- (id <AZShadow>) innerShadow
{
	return [self innerShadowForState: UIControlStateNormal];
}
- (id <AZShadow>) innerShadowForState: (UIControlState) controlState
{
	return [self az_valueForAppearanceKey: @"innerShadow" forState: controlState];
}

- (void) setInnerShadow: (id <AZShadow>) innerShadow
{
	[self setInnerShadow: innerShadow forState: UIControlStateNormal];
}
- (void) setInnerShadow: (id <AZShadow>) innerShadow forState: (UIControlState) controlState
{
	[self az_setValue: innerShadow forAppearanceKey: @"innerShadow" forState: controlState];
}

#pragma mark - Gradient

- (AZGradient *) gradient
{
	return [self gradientForState: UIControlStateNormal];
}
- (AZGradient *) gradientForState: (UIControlState) controlState
{
	return [self az_valueForAppearanceKey: @"gradient" forState: controlState];
}

- (void) setGradient: (AZGradient *) gradient
{
	[self setGradient: gradient forState: UIControlStateNormal];
}
- (void) setGradient: (AZGradient *) gradient forState: (UIControlState) controlState
{
	[self az_setValue: gradient forAppearanceKey: @"gradient" forState: controlState];
}

#pragma mark - Gradient Direction

- (AZGradientDirection) gradientDirection
{
	return [self gradientDirectionForState: UIControlStateNormal];
}
- (AZGradientDirection) gradientDirectionForState: (UIControlState) controlState
{
	return [[self az_valueForAppearanceKey: @"shadowBlur" forState: controlState] unsignedIntegerValue];
}

- (void) setGradientDirection: (AZGradientDirection) gradientDirection
{
	[self setGradientDirection: gradientDirection forState: UIControlStateNormal];
}
- (void) setGradientDirection: (AZGradientDirection) gradientDirection forState: (UIControlState) controlState
{
	[self az_setValue: @(gradientDirection) forAppearanceKey: @"gradientDirection" forState: controlState];
}

#pragma mark - Gradient KVC support

- (void) setValue: (id) value forKeyPath: (NSString *) keyPath
{
	if ([keyPath rangeOfString: @"gradient." options: NSCaseInsensitiveSearch].location != NSNotFound)
	{
		if ([keyPath rangeOfString: @"gradient.direction" options: NSCaseInsensitiveSearch].location != NSNotFound)
		{
			self.gradientDirection = [value unsignedIntegerValue];
		}
		else
		{
			if (!self.gradientDict) self.gradientDict = [NSMutableDictionary dictionary];
			self.gradientDict[AZGradientGetKeyForKVC(keyPath)] = value;
		}
	}
	else if ([keyPath rangeOfString: @"innerShadow." options: NSCaseInsensitiveSearch].location != NSNotFound)
	{
		if (!self.innerShadowDict) self.innerShadowDict = [NSMutableDictionary dictionary];
		self.innerShadowDict[[keyPath substringFromIndex: @"innerShadow.".length]] = value;
	}
	else if ([keyPath rangeOfString: @"shadow." options: NSCaseInsensitiveSearch].location != NSNotFound)
	{
		if (!self.shadowDict) self.shadowDict = [NSMutableDictionary dictionary];
		self.shadowDict[[keyPath substringFromIndex: @"shadow.".length]] = value;
	}
	else
	{
		[super setValue: value forKeyPath: keyPath];
	}
}

#pragma mark - Internal State Getters

- (AZGradient *) az_gradientForCurrentState
{
	return [self az_valueForAppearanceKeyForCurrentState: @"gradient"];
}

- (AZGradientDirection) az_gradientDirectionForCurrentState
{
	return [[self az_valueForAppearanceKeyForCurrentState: @"gradientDirection"] unsignedIntegerValue];
}

- (id <AZShadow>) az_innerShadowForCurrentState
{
	return [self az_valueForAppearanceKeyForCurrentState: @"innerShadow"];
}
- (id <AZShadow>) az_shadowForCurrentState
{
	return [self az_valueForAppearanceKeyForCurrentState: @"shadow"];
}

- (BOOL) az_shouldUseGradientForCurrentState
{
	if (!self.appearanceStorage)
		return NO;
	
	UIControlState currentState = self.state;
	id gradient = [self az_valueForAppearanceKey: @"gradient" forState: currentState];
	id color = [self az_valueForAppearanceKey: @"textColor" forState: currentState];
	
	if (gradient)
		return YES;
	
	if (color)
		return NO;
	
	if (currentState == UIControlStateHighlighted)
	{
		currentState = UIControlStateSelected;
		gradient = [self az_valueForAppearanceKey: @"gradient" forState: currentState];
		color = [self az_valueForAppearanceKey: @"textColor" forState: currentState];
	}
	
	if (gradient)
		return YES;
	
	if (color)
		return NO;
	
	if (currentState == UIControlStateSelected)
	{
		currentState = UIControlStateHighlighted;
		gradient = [self az_valueForAppearanceKey: @"gradient" forState: currentState];
		color = [self az_valueForAppearanceKey: @"textColor" forState: currentState];
	}
	
	if (gradient)
		return YES;
	
	return NO;
}

- (UIColor *) az_textColorForCurrentState
{
	return [self az_valueForAppearanceKeyForCurrentState: @"textColor"];
}

#pragma mark - Accessibility

- (BOOL) isAccessibilityElement
{
	return YES;
}

- (NSString *) accessibilityLabel
{
	return self.text;
}

- (UIAccessibilityTraits) accessibilityTraits
{
	return UIAccessibilityTraitStaticText;
}

@end
