//
//  AZLabel.m
//  AZAppearanceKit
//
//  Created by Zachary Waldowski on 3/17/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "AZLabel.h"
#import "AZGradient.h"
#import "AZDrawingFunctions.h"

extern AZGradient *AZGradientSetKVCValueForKey(NSMutableDictionary *dict, id key, id value);

@interface AZLabel ()

+ (UIFont *)az_defaultFont;
- (void) az_sharedInit;

@property (nonatomic, strong) NSMutableDictionary *appearanceStorage;
@property (nonatomic, strong) NSMutableDictionary *gradientDict;
@property (nonatomic, strong, readwrite) UIBezierPath *textPath;

- (id)az_valueForAppearanceKeyForCurrentState:(NSString *)key;
- (id)az_valueForAppearanceKey:(NSString *)key forState:(UIControlState)state;
- (void)az_setValue:(id)value forAppearanceKey:(NSString *)key forState:(UIControlState)state;

@property (nonatomic, readonly, getter = az_textColorForCurrentState) UIColor *textColorForCurrentState;
@property (nonatomic, readonly, getter = az_shadowOffsetForCurrentState) CGSize shadowOffsetForCurrentState;
@property (nonatomic, readonly, getter = az_shadowBlurForCurrentState) CGFloat shadowBlurForCurrentState;
@property (nonatomic, readonly, getter = az_shadowColorForCurrentState) UIColor *shadowColorForCurrentState;
@property (nonatomic, readonly, getter = az_innerShadowOffsetForCurrentState) CGSize innerShadowOffsetForCurrentState;
@property (nonatomic, readonly, getter = az_innerShadowBlurForCurrentState) CGFloat innerShadowBlurForCurrentState;
@property (nonatomic, readonly, getter = az_innerShadowColorForCurrentState) UIColor *innerShadowColorForCurrentState;
@property (nonatomic, readonly, getter = az_shouldUseGradientForCurrentState) BOOL shouldUseGradientForCurrentState;
@property (nonatomic, readonly, getter = az_gradientForCurrentState) AZGradient *gradientForCurrentState;
@property (nonatomic, readonly, getter = az_gradientDirectionForCurrentState) AZGradientDirection gradientDirectionForCurrentState;

@end

static inline UIControlContentHorizontalAlignment UIControlContentHorizontalAlignmentForUITextAlignment(UITextAlignment align) {
	switch (align) {
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

static inline CTTextAlignment CTTextAlignmentForUIContentHorizontalAlignment(UIControlContentHorizontalAlignment align) {
	switch (align) {
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

static inline CTLineBreakMode CTLineBreakModeForUILineBreakMode(UILineBreakMode lineBreak) {
	switch (lineBreak) {
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

@implementation AZLabel

@synthesize appearanceStorage = _appearanceStorage;
@synthesize textPath = _textPath;

@synthesize text = _text;
@synthesize font = _font;
@synthesize lineBreakMode = _lineBreakMode;
@synthesize textEdgeInsets = _textEdgeInsets;

+ (UIFont *)az_defaultFont {
	return [UIFont systemFontOfSize: 17];
}

- (void)az_sharedInit {
	self.font = [[self class] az_defaultFont];
	self.backgroundColor = [UIColor whiteColor];
	self.userInteractionEnabled = NO;
	self.contentMode = UIViewContentModeRedraw;
	[self setTextColor: [UIColor blackColor] forState: UIControlStateNormal];
}

- (id)init {
	if ((self = [super init])) {
		[self az_sharedInit];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame: frame])) {
		[self az_sharedInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder: aDecoder])) {
		self.text = [aDecoder decodeObjectForKey: @"UIText"];
		self.font = [aDecoder decodeObjectForKey: @"UIFont"] ?: [[self class] az_defaultFont];
		[self setTextColor: [aDecoder decodeObjectForKey: @"UITextColor"] ?: [UIColor blackColor] forState: UIControlStateNormal];
		[self setTextColor: [aDecoder decodeObjectForKey: @"UIHighlightedColor"] forState: UIControlStateHighlighted];
		if ([aDecoder containsValueForKey: @"UIShadowOffset"])
			[self setShadowOffset: [aDecoder decodeCGSizeForKey: @"UIShadowOffset"] forState: UIControlStateNormal];
		if ([aDecoder containsValueForKey: @"UIShadowColor"])
			[self setShadowColor: [aDecoder decodeObjectForKey: @"UIShadowColor"] forState: UIControlStateNormal];
		if ([aDecoder containsValueForKey: @"UILineBreakMode"])
			self.lineBreakMode = [aDecoder decodeIntegerForKey: @"UILineBreakMode"];
		if ([aDecoder containsValueForKey: @"UITextAlignment"])
			self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentForUITextAlignment([aDecoder decodeIntegerForKey: @"UITextAlignment"]);
		if ([aDecoder containsValueForKey: @"UIEnabled"])
			self.enabled = [aDecoder decodeBoolForKey: @"UIEnabled"];
		/*if ([aDecoder containsValueForKey: @"UINumberOfLines"])
			self.numberOfLines = [aDecoder decodeIntegerForKey: @"UINumberOfLines"];
		if ([aDecoder containsValueForKey: @"UIBaselineAdjustment"])
			self.baselineAdjustment = [aDecoder decodeIntegerForKey: @"UIBaselineAdjustment"];
		if ([aDecoder containsValueForKey: @"UIAdjustsFontSizeToFit"])
			self.adjustsFontSizeToFitWidth = [aDecoder decodeBoolForKey: @"UIAdjustsFontSizeToFit"];
		if ([aDecoder containsValueForKey: @"UIMinimumFontSize"])
			self.minimumFontSize = [aDecoder decodeFloatForKey: @"UIMinimumFontSize"];*/
	}
	return self;
}

- (void)az_recalculateTextPath {
	// Create path from text
    // See: http://www.codeproject.com/KB/iPhone/Glyph.aspx
    // License: The Code Project Open License (CPOL) 1.02 http://www.codeproject.com/info/cpol10.aspx
	
	// See: https://github.com/ole/Animated-Paths/blob/0347e90738cedf4f543c2cb9ab97d18780d461e2/Classes/AnimatedPathViewController.m#L86
	CGRect rect = self.bounds;
	
	if (!self.font || !self.text)
		return;
	
	CGMutablePathRef letters = CGPathCreateMutable();
	
	CTFontRef font = CTFontCreateWithName((__bridge CFStringRef) self.font.fontName, self.font.pointSize, NULL);
	
	CTTextAlignment textAlignment = CTTextAlignmentForUIContentHorizontalAlignment(self.contentHorizontalAlignment);
	CTLineBreakMode lineBreakMode = CTLineBreakModeForUILineBreakMode(self.lineBreakMode);
	
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

- (void) setHighlighted: (BOOL) highlighted
{
	[super setHighlighted: highlighted];
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	rect = UIEdgeInsetsInsetRect(rect, self.textEdgeInsets);
	
	if (!self.textPath && self.text.length)
		[self az_recalculateTextPath];

	if (self.gradientDict) {
		self.gradient = [[AZGradient alloc] initWithColorsAtLocations: self.gradientDict];
		self.gradientDict = nil;
	}
    
    UIGraphicsContextPerformBlock(^(CGContextRef ctx) {
        CGContextTranslateCTM(ctx, 0, rect.size.height);
        CGContextScaleCTM(ctx, 1, -1);
        
        CGContextSetShadowWithColor(ctx, self.shadowOffsetForCurrentState, self.shadowBlurForCurrentState, self.shadowColorForCurrentState.CGColor);
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
		
		CGRect textBorderRect = CGRectInset(self.textPath.bounds, -self.innerShadowBlurForCurrentState, -self.innerShadowBlurForCurrentState);
		textBorderRect = CGRectOffset(textBorderRect, -self.innerShadowOffsetForCurrentState.width, -self.innerShadowOffsetForCurrentState.height);
		textBorderRect = CGRectInset(CGRectUnion(textBorderRect, self.textPath.bounds), -1, -1);
		
		UIBezierPath *textNegativePath = [UIBezierPath bezierPathWithRect: textBorderRect];
		[textNegativePath appendPath: self.textPath];
		textNegativePath.usesEvenOddFillRule = YES;
        
        UIGraphicsContextPerformBlock(^(CGContextRef ctx) {
			CGFloat xOffset = self.innerShadowOffsetForCurrentState.width + round(textBorderRect.size.width);
			CGFloat yOffset = self.innerShadowOffsetForCurrentState.height;
			CGContextSetShadowWithColor(ctx, CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)), self.innerShadowBlurForCurrentState, self.innerShadowColorForCurrentState.CGColor);
			
			[self.textPath addClip];
			
			CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(textBorderRect.size.width), 0);
			[textNegativePath applyTransform: transform];
			
			[[UIColor grayColor] setFill];
			[textNegativePath fill];
        });
    });
}

- (CGSize) sizeThatFits: (CGSize) size
{
	size = [self.text sizeWithFont: self.font];
	size.height += fabs(self.shadowOffsetForCurrentState.height);
	size.width += fabs(self.shadowOffsetForCurrentState.width);
	return size;
}

#pragma mark - Properties that affect display

- (void) setTextEdgeInsets: (UIEdgeInsets) textEdgeInsets
{
	_textEdgeInsets = textEdgeInsets;
	[self setNeedsDisplay];
}

#pragma mark - Properties that affect text

- (void)setText:(NSString *)text {
	_text = [text copy];
	[self az_recalculateTextPath];
	if (self.superview)
		[self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font {
	if (!font)
		[NSException raise: NSInvalidArgumentException format: @"Font cannot be nil"];
	_font = font;
	[self az_recalculateTextPath];
	if (self.superview)
		[self setNeedsDisplay];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[self az_recalculateTextPath];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview: newSuperview];
	[self az_recalculateTextPath];
}

- (void)setLineBreakMode:(UILineBreakMode)lineBreakMode {
	_lineBreakMode = lineBreakMode;
	[self az_recalculateTextPath];
	if (self.superview) {
		[self setNeedsDisplay];
	}
}

- (void)setContentHorizontalAlignment:(UIControlContentHorizontalAlignment)contentHorizontalAlignment {
	[super setContentHorizontalAlignment:contentHorizontalAlignment];
	[self az_recalculateTextPath];
	if (self.superview) {
		[self setNeedsDisplay];
	}
}

- (void)setContentVerticalAlignment:(UIControlContentVerticalAlignment)contentVerticalAlignment {
	[super setContentVerticalAlignment: contentVerticalAlignment];
	[self az_recalculateTextPath];
	if (self.superview) {
		[self setNeedsDisplay];
	}
}

#pragma mark - State value getters

- (id)az_valueForAppearanceKeyForCurrentState:(NSString *)key {
	if (!self.appearanceStorage)
		return nil;
	
	UIControlState currentState = self.state;
	id value = [self az_valueForAppearanceKey: key forState: currentState];
	
	if (!value && currentState == UIControlStateHighlighted) {
		currentState = UIControlStateSelected;
		value = [self az_valueForAppearanceKey: key forState: currentState];
	}
	
	if (!value && currentState == UIControlStateSelected) {
		currentState = UIControlStateHighlighted;
		value = [self az_valueForAppearanceKey: key forState: currentState];
	}
	
	if (!value) {
		value = [self az_valueForAppearanceKey: key forState: UIControlStateNormal];
	}
	
	return value;
}

- (id)az_valueForAppearanceKey:(NSString *)key forState:(UIControlState)state {
	if (!self.appearanceStorage)
		return nil;
	
	id stateKey = [NSNumber numberWithUnsignedInteger: state];
	NSMutableDictionary *stateStorage = [self.appearanceStorage objectForKey: stateKey];
	
	return [stateStorage objectForKey: key];
}

- (void)az_setValue:(id)value forAppearanceKey:(NSString *)key forState:(UIControlState)state {
	if (!self.appearanceStorage)
		self.appearanceStorage = [NSMutableDictionary dictionary];
	
	id stateKey = [NSNumber numberWithUnsignedInteger: state];
	NSMutableDictionary *stateStorage = [self.appearanceStorage objectForKey: stateKey];
	
	if (!stateStorage) {
		stateStorage = [NSMutableDictionary dictionary];
		[self.appearanceStorage setObject: stateStorage forKey: stateKey];
	}
	
	if (value) {
		[stateStorage setObject: value forKey: key];
	} else {
		[stateStorage removeObjectForKey: key];
	}
}

#pragma mark - Properties per-state

- (UIColor *)textColor {
	return [self textColorForState: UIControlStateNormal];
}

- (void)setTextColor:(UIColor *)color {
	[self setTextColor: color forState: UIControlStateNormal];
}

- (void)setTextColor:(UIColor *)color forState:(UIControlState)state {
	[self az_setValue: color forAppearanceKey: @"textColor" forState: state];
}

- (UIColor *)textColorForState:(UIControlState)state {
	return [self az_valueForAppearanceKey: @"textColor" forState: state];
}

- (CGSize)shadowOffset {
	return [self shadowOffsetForState: UIControlStateNormal];
}

- (CGFloat)shadowBlur {
	return [self shadowBlurForState: UIControlStateNormal];
}

- (UIColor *)shadowColor {
	return [self shadowColorForState: UIControlStateNormal];
}

- (void)setShadowOffset:(CGSize)shadowOffset {
	[self setShadowOffset: shadowOffset forState: UIControlStateNormal];
}

- (void)setShadowBlur:(CGFloat)shadowBlur {
	[self setShadowBlur: shadowBlur forState: UIControlStateNormal];
}

- (void)setShadowColor:(UIColor *)shadowColor {
	[self setShadowColor: shadowColor forState: UIControlStateNormal];
}

- (void)setShadowOffset:(CGSize)shadowOffset forState:(UIControlState)controlState {
	[self az_setValue: [NSValue valueWithCGSize: shadowOffset] forAppearanceKey: @"shadowOffset" forState: controlState];
}

- (void)setShadowBlur:(CGFloat)shadowBlur forState:(UIControlState)controlState {
	[self az_setValue: [NSNumber numberWithDouble: shadowBlur] forAppearanceKey: @"shadowBlur" forState: controlState];
}

- (void)setShadowColor:(UIColor *)shadowColor forState:(UIControlState)controlState {
	[self az_setValue: shadowColor forAppearanceKey: @"shadowColor" forState: controlState];
}

- (CGSize)shadowOffsetForState:(UIControlState)controlState {
	return [[self az_valueForAppearanceKey: @"shadowOffset" forState: controlState] CGSizeValue];
}

- (CGFloat)shadowBlurForState:(UIControlState)controlState {
	return [[self az_valueForAppearanceKey: @"shadowBlur" forState: controlState] doubleValue];
}

- (UIColor *)shadowColorForState:(UIControlState)controlState {
	return [self az_valueForAppearanceKey: @"shadowColor" forState: controlState];
}

- (CGSize)innerShadowOffset {
	return [self innerShadowOffsetForState: UIControlStateNormal];
}

- (CGFloat)innerShadowBlur {
	return [self innerShadowBlurForState: UIControlStateNormal];
}

- (UIColor *)innerShadowColor {
	return [self innerShadowColorForState: UIControlStateNormal];
}

- (void)setInnerShadowOffset:(CGSize)innerShadowOffset {
	[self setInnerShadowOffset: innerShadowOffset forState: UIControlStateNormal];
}

- (void)setInnerShadowBlur:(CGFloat)innerShadowBlur {
	[self setInnerShadowBlur: innerShadowBlur forState: UIControlStateNormal];
}

- (void)setInnerShadowColor:(UIColor *)innerShadowColor {
	[self setInnerShadowColor: innerShadowColor forState: UIControlStateNormal];
}

- (void)setInnerShadowOffset:(CGSize)innerShadowOffset forState:(UIControlState)controlState {
	[self az_setValue: [NSValue valueWithCGSize: innerShadowOffset] forAppearanceKey: @"innerShadowOffset" forState: controlState];
}

- (void)setInnerShadowBlur:(CGFloat)innerShadowBlur forState:(UIControlState)controlState {
	[self az_setValue: [NSNumber numberWithDouble: innerShadowBlur] forAppearanceKey: @"innerShadowBlur" forState: controlState];
}

- (void)setInnerShadowColor:(UIColor *)innerShadowColor forState:(UIControlState)controlState {
	[self az_setValue: innerShadowColor forAppearanceKey: @"innerShadowColor" forState: controlState];
}

- (CGSize)innerShadowOffsetForState:(UIControlState)controlState {
	return [[self az_valueForAppearanceKey: @"innerShadowOffset" forState: controlState] CGSizeValue];
}

- (CGFloat)innerShadowBlurForState:(UIControlState)controlState {
	return [[self az_valueForAppearanceKey: @"innerShadowBlur" forState: controlState] doubleValue];
}

- (UIColor *)innerShadowColorForState:(UIControlState)controlState {
	return [self az_valueForAppearanceKey: @"innerShadowColor" forState: controlState];
}

- (AZGradient *)gradient {
	return [self gradientForState: UIControlStateNormal];
}

- (AZGradientDirection)gradientDirection {
	return [self gradientDirectionForState: UIControlStateNormal];
}

- (void)setGradient:(AZGradient *)gradient {
	[self setGradient: gradient forState: UIControlStateNormal];
}

- (void)setGradient:(AZGradient *)gradient forState:(UIControlState)controlState {
	[self az_setValue: gradient forAppearanceKey: @"gradient" forState: controlState];
}

- (void)setGradientDirection:(AZGradientDirection)gradientDirection {
	[self setGradientDirection: gradientDirection forState: UIControlStateNormal];
}

- (void)setGradientDirection:(AZGradientDirection)gradientDirection forState:(UIControlState)controlState {
	[self az_setValue: [NSNumber numberWithInteger: gradientDirection] forAppearanceKey: @"gradientDirection" forState: controlState];
}

- (AZGradient *)gradientForState:(UIControlState)controlState {
	return [self az_valueForAppearanceKey: @"gradient" forState: controlState];
}

- (AZGradientDirection)gradientDirectionForState:(UIControlState)controlState {
	return [[self az_valueForAppearanceKey: @"shadowBlur" forState: controlState] integerValue];
}

#pragma mark - Gradient KVC support

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
	if ([keyPath hasPrefix: @"gradient."]) {
		if ([keyPath isEqualToString: @"gradient.direction"]) {
			[self setGradientDirection: [value intValue]];
		} else {
			if (!self.gradientDict)
				self.gradientDict = [NSMutableDictionary dictionary];
			AZGradientSetKVCValueForKey(self.gradientDict, keyPath, value);
		}
		return;
	}
	[super setValue:value forKeyPath: keyPath];	
}

#pragma mark - Internal state getters

- (UIColor *)az_textColorForCurrentState {
	return [self az_valueForAppearanceKeyForCurrentState: @"textColor"];
}

- (CGSize)az_shadowOffsetForCurrentState {
	return [[self az_valueForAppearanceKeyForCurrentState: @"shadowOffset"] CGSizeValue];
}

- (CGFloat)az_shadowBlurForCurrentState {
	return [[self az_valueForAppearanceKeyForCurrentState: @"shadowBlur"] doubleValue];
}

- (UIColor *)az_shadowColorForCurrentState {
	return [self az_valueForAppearanceKeyForCurrentState: @"shadowColor"];
}

- (CGSize)az_innerShadowOffsetForCurrentState {
	return [[self az_valueForAppearanceKeyForCurrentState: @"innerShadowOffset"] CGSizeValue];
}

- (CGFloat)az_innerShadowBlurForCurrentState {
	return [[self az_valueForAppearanceKeyForCurrentState: @"innerShadowBlur"] doubleValue];
}

- (UIColor *)az_innerShadowColorForCurrentState {
	return [self az_valueForAppearanceKeyForCurrentState: @"innerShadowColor"];
}

- (BOOL)az_shouldUseGradientForCurrentState {
	if (!self.appearanceStorage)
		return NO;
	
	UIControlState currentState = self.state;
	id gradient = [self az_valueForAppearanceKey: @"gradient" forState: currentState];
	id color = [self az_valueForAppearanceKey: @"textColor" forState: currentState];
	
	if (gradient)
		return YES;
	
	if (color)
		return NO;
	
	if (currentState == UIControlStateHighlighted) {
		currentState = UIControlStateSelected;
		gradient = [self az_valueForAppearanceKey: @"gradient" forState: currentState];
		color = [self az_valueForAppearanceKey: @"textColor" forState: currentState];
	}
	
	if (gradient)
		return YES;
	
	if (color)
		return NO;
	
	if (currentState == UIControlStateSelected) {
		currentState = UIControlStateHighlighted;
		gradient = [self az_valueForAppearanceKey: @"gradient" forState: currentState];
		color = [self az_valueForAppearanceKey: @"textColor" forState: currentState];
	}
	
	if (gradient)
		return YES;
	
	return NO;
}

- (AZGradient *)az_gradientForCurrentState {
	return [self az_valueForAppearanceKeyForCurrentState: @"gradient"];
}

- (AZGradientDirection)az_gradientDirectionForCurrentState {
	return [[self az_valueForAppearanceKeyForCurrentState: @"gradientDirection"] integerValue];
}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement
{
	return YES;
}

- (NSString *)accessibilityLabel
{
	return self.text;
}

- (UIAccessibilityTraits)accessibilityTraits
{
	return UIAccessibilityTraitStaticText;
}

@end
