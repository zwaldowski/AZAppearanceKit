//
//  AZLabel.h
//  AZAppearanceKit
//
//  Created by Zach Waldowski on 3/18/13.
//  Copyright (c) 2013 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import "AZLabel.h"
#import "AZDrawingFunctions.h"
#import "AZShadow.h"
#import <CoreText/CoreText.h>
#import <objc/runtime.h>

NSString *const AZLabelGradientForegroundAttributeName = @"AZLabelGradientForeground";
NSString *const AZLabelGradientForegroundDirectionAttributeName = @"AZLabelGradientFillDirection";
NSString *const AZLabelInnerShadowAttributeName = @"AZLabelInnerShadow";
NSString *const AZLabelShadowAttributeName = @"AZLabelShadow";

@interface AZLabelRunInfo : NSObject

@property (nonatomic) CGPathRef path;
@property (nonatomic, copy) NSDictionary *attributes;

@end

@implementation AZLabelRunInfo

- (void)dealloc {
	CGPathRelease(_path);
}

- (void)setPath:(CGPathRef)path {
	if (_path) CGPathRelease(_path);
	_path = CGPathRetain(path);
}

@end

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000

typedef NSLineBreakMode AZLineBreakMode;
typedef NSTextAlignment AZTextAlignment;
static const AZLineBreakMode AZLineBreakByCharWrapping = NSLineBreakByCharWrapping;
#define AZShadowPreferredAttributeName NSShadowAttributeName
#define AZForegroundColorPreferredAttributeName NSForegroundColorAttributeName
#define AZParagraphStylePreferredAttributeName NSParagraphStyleAttributeName
#define AZFontPreferredAttributeName NSFontAttributeName

static inline CTLineBreakMode CTLineBreakModeForAZLineBreakMode(AZLineBreakMode lineBreak) {
	switch (lineBreak) {
		case NSLineBreakByWordWrapping:     return kCTLineBreakByWordWrapping;
		case NSLineBreakByCharWrapping:     return kCTLineBreakByCharWrapping;
		case NSLineBreakByClipping:         return kCTLineBreakByClipping;
		case NSLineBreakByTruncatingHead:   return kCTLineBreakByTruncatingHead;
		case NSLineBreakByTruncatingTail:   return kCTLineBreakByTruncatingTail;
		case NSLineBreakByTruncatingMiddle: return kCTLineBreakByTruncatingMiddle;
	}
}

static inline CTTextAlignment CTTextAlignmentForAZTextAlignment(AZTextAlignment align) {
	switch (align) {
		case NSTextAlignmentLeft:			return kCTLeftTextAlignment;
		case NSTextAlignmentCenter:			return kCTCenterTextAlignment;
		case NSTextAlignmentRight:			return kCTRightTextAlignment;
		case NSTextAlignmentJustified:		return kCTJustifiedTextAlignment;
        case NSTextAlignmentNatural:		return kCTNaturalTextAlignment;
	}
}

#else

typedef UILineBreakMode AZLineBreakMode;
typedef UITextAlignment AZTextAlignment;
static const AZLineBreakMode AZLineBreakByCharWrapping = UILineBreakModeCharacterWrap;
#define AZShadowPreferredAttributeName AZLabelShadowAttributeName
#define AZForegroundColorPreferredAttributeName (__bridge NSString *)kCTForegroundColorAttributeName
#define AZParagraphStylePreferredAttributeName (__bridge NSString *)kCTParagraphStyleAttributeName
#define AZFontPreferredAttributeName (__bridge NSString *)kCTFontAttributeName

static inline CTLineBreakMode CTLineBreakModeForAZLineBreakMode(AZLineBreakMode lineBreak) {
	switch (lineBreak) {
		case UILineBreakModeWordWrap:			return kCTLineBreakByWordWrapping;
		case UILineBreakModeCharacterWrap:		return kCTLineBreakByCharWrapping;
		case UILineBreakModeClip:				return kCTLineBreakByClipping;
		case UILineBreakModeHeadTruncation:		return kCTLineBreakByTruncatingHead;
		case UILineBreakModeTailTruncation:		return kCTLineBreakByTruncatingTail;
		case UILineBreakModeMiddleTruncation:	return kCTLineBreakByTruncatingMiddle;
	}
}

static inline CTTextAlignment CTTextAlignmentForAZTextAlignment(AZTextAlignment align) {
    if (align == ((UITextAlignment)kCTJustifiedTextAlignment)) return kCTJustifiedTextAlignment;
	switch (align) {
		case UITextAlignmentLeft:				return kCTLeftTextAlignment;
		case UITextAlignmentCenter:				return kCTCenterTextAlignment;
		case UITextAlignmentRight:				return kCTRightTextAlignment;
		default:								return kCTNaturalTextAlignment;
	}
}

#endif

static inline BOOL CTLineBreakModeTruncates(CTLineBreakMode mode) {
	return (mode == kCTLineBreakByTruncatingHead || mode == kCTLineBreakByTruncatingMiddle || mode == kCTLineBreakByTruncatingTail);
}

static inline CGFloat CTTextAlignmentGetFlush(CTTextAlignment align) {
	switch (align) {
		case kCTTextAlignmentCenter:	return 0.5f;
		case kCTTextAlignmentRight:		return 1.0f;
		default:						return 0.0f;
	}
}

static CGFloat azfloorr(CGFloat dim, CGFloat scale) {
    return floor(dim * scale) / scale;
}

static CGFloat azceilr(CGFloat dim, CGFloat scale) {
    return ceil(dim * scale) / scale;
}

static CGFloat azroundr(CGFloat dim, CGFloat scale) {
    return round(dim * scale) / scale;
}

static void AZFrameEachLine(CTFrameRef frame, NSUInteger maxNumberOfLines, void(^block)(CTLineRef, CGPoint, BOOL)){
	CFRetain(frame);
	
	NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
	NSUInteger numLines = MIN(maxNumberOfLines, lines.count);
	
	CGPoint *lineOrigins = calloc(sizeof(CGPoint), numLines);
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numLines), lineOrigins);

	[lines enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, numLines)] options:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		CTLineRef line = (__bridge CTLineRef)obj;
		CGPoint lineOrigin = lineOrigins[idx];
        
        block(line, lineOrigin, (idx == numLines - 1));
	}];
	
	free(lineOrigins);
	CFRelease(frame);
}

static void AZLineEachRun(CTLineRef line, void(^block)(CTRunRef, NSUInteger)) {
	CFRetain(line);
	
	NSArray *runs = (__bridge NSArray *)CTLineGetGlyphRuns(line);
	[runs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		CTRunRef run = (__bridge CTRunRef)obj;
		
		block(run, idx);
	}];
	
	CFRelease(line);
}

static void AZRunEachGlyph(CTRunRef run, void(^block)(CGGlyph glyph, CGPoint position, CGSize advance, NSUInteger)){
	CFRetain(run);
	
	const CGGlyph *glyphs = CTRunGetGlyphsPtr(run);
	const CGPoint *positions = CTRunGetPositionsPtr(run);
	const CGSize *advances = CTRunGetAdvancesPtr(run);
	
	for (NSUInteger i = 0; i < CTRunGetGlyphCount(run); i++) {
		CGGlyph glyph = glyphs[i];
		CGPoint position = positions[i];
		CGSize advance = advances[i];
		
		block(glyph, position, advance, i);
	}
	
	CFRelease(run);
}

static NSArray *AZLabelSketchTextInRect(NSAttributedString *string, CTFramesetterRef framesetter, CGRect rect, NSUInteger numberOfLines, BOOL truncatesLastLine, CGRect *outTextBounds) {
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, NULL, rect);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
	
	NSRange wholeRange = NSMakeRange(0, string.length);
	
	NSMutableArray *array = [NSMutableArray array];
	__block CGRect allPathsBounds = CGRectNull;
	
	AZFrameEachLine(frame, numberOfLines, ^(CTLineRef line, CGPoint lineOrigin, BOOL isLast) {
		
		if (isLast) {
			// Check if the range of text in the last line reaches the end of the full attributed string
            CFRange lastLineRange = CTLineGetStringRange(line);
			
			if (truncatesLastLine && !(lastLineRange.length == 0 && lastLineRange.location == 0) && lastLineRange.location + lastLineRange.length < wholeRange.location + wholeRange.length) {
				NSUInteger truncationAttributePosition = lastLineRange.location;
				CTLineTruncationType truncationType = kCTLineTruncationEnd;
				
				NSDictionary *tokenAttributes = [string attributesAtIndex:truncationAttributePosition effectiveRange:NULL];
                NSString *tokenString = @"\u2026"; // Unicode Character 'HORIZONTAL ELLIPSIS' (U+2026)
				NSAttributedString *attributedTokenString = [[NSAttributedString alloc] initWithString:tokenString attributes:tokenAttributes];
                CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attributedTokenString);
				
				// Append truncationToken to the string
                // because if string isn't too long, CT wont add the truncationToken on it's own
                // There is no change of a double truncationToken because CT only add the token if it removes characters (and the one we add will go first)
                NSMutableAttributedString *truncationString = [[string attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
                if (lastLineRange.length > 0) {
                    // Remove any newline at the end (we don't want newline space between the text and the truncation token). There can only be one, because the second would be on the next line.
                    unichar lastCharacter = [[truncationString string] characterAtIndex:lastLineRange.length - 1];
                    if ([[NSCharacterSet newlineCharacterSet] characterIsMember:lastCharacter]) {
                        [truncationString deleteCharactersInRange:NSMakeRange(lastLineRange.length - 1, 1)];
                    }
                }
                [truncationString appendAttributedString:attributedTokenString];
                CTLineRef truncationLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncationString);
                line = CTLineCreateTruncatedLine(truncationLine, rect.size.width, truncationType, truncationToken);
				
				CTTextAlignment align = kCTTextAlignmentRight;
				id style = tokenAttributes[AZParagraphStylePreferredAttributeName];
				
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
				if ([NSMutableParagraphStyle class]) {
					if (style) align = CTTextAlignmentForAZTextAlignment([style alignment]);
				} else
#endif
				{
					if (style) CTParagraphStyleGetValueForSpecifier((__bridge CTParagraphStyleRef)style, kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &align);
				}
				
				CGFloat flushFactor = CTTextAlignmentGetFlush(align);
				lineOrigin.x = CTLineGetPenOffsetForFlush(line, flushFactor, rect.size.width);
			}
		}
		
		AZLineEachRun(line, ^(CTRunRef run, NSUInteger jdx) {
			NSDictionary *attr = (__bridge NSDictionary *)CTRunGetAttributes(run);
			
			CTFontRef runFont = (__bridge CTFontRef)attr[(id)kCTFontAttributeName];
			
			CGMutablePathRef linePath = CGPathCreateMutable();
			AZRunEachGlyph(run, ^(CGGlyph glyph, CGPoint position, CGSize advance, NSUInteger kdx){
				CGAffineTransform t = CGAffineTransformMakeTranslation(lineOrigin.x + position.x, lineOrigin.y + position.y);
                CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, &t);
                CGPathAddPath(linePath, NULL, letter);
                CGPathRelease(letter);
			});
			
			AZLabelRunInfo *info = [AZLabelRunInfo new];
			info.attributes = [attr dictionaryWithValuesForKeys:@[AZShadowPreferredAttributeName, AZLabelInnerShadowAttributeName, AZLabelGradientForegroundAttributeName, AZLabelGradientForegroundDirectionAttributeName, AZForegroundColorPreferredAttributeName]];
			info.path = linePath;
			[array addObject:info];
			
			CGRect bounds = CGPathGetBoundingBox(linePath);
			
			if (CGRectIsNull(allPathsBounds))
				allPathsBounds = bounds;
			else
				allPathsBounds = CGRectUnion(allPathsBounds, bounds);
			
			CGPathRelease(linePath);
		});
	});
	
	if (outTextBounds) *outTextBounds = allPathsBounds;
	
	return [array copy];
}

@interface AZLabel () {
    BOOL _needsFramesetter;
    BOOL _needsAttributedTextString;
	BOOL _attributedStringIsPlaintext;
	BOOL _az_needsTextPaths;
}

@property (nonatomic, strong, setter = az_setGradientDict:) NSMutableDictionary *az_gradientDict;
@property (nonatomic, strong, setter = az_setShadowDict:) NSMutableDictionary *az_shadowDict;
@property (nonatomic, strong, setter = az_setInnerShadowDict:) NSMutableDictionary *az_innerShadowDict;

@property (nonatomic, strong) NSArray *textPaths;
@property (nonatomic, readonly) CGRect textPathsBounds;
@property (nonatomic) CGSize textPathsGeneratedForSize;

@property (nonatomic, strong, setter = az_setAttributedTextString:) NSAttributedString *az_attributedTextString;
@property (nonatomic, readonly) CTFramesetterRef az_framesetter;

@property (nonatomic, setter = az_setTruncatesLastLine:) BOOL az_truncatesLastLine;
@property (nonatomic, setter = az_setTextIsAttributed:) BOOL az_textIsAttributed;

@end

@implementation AZLabel

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000

+ (void)load {
	@autoreleasepool {
		if ([UILabel instancesRespondToSelector: @selector(setAttributedText:)]) {
			IMP imp = class_getMethodImplementation(self, @selector(az_setAttributedText:));
			Method m = class_getInstanceMethod(self, @selector(az_setAttributedText:));
			
			class_addMethod(self, @selector(setAttributedText:), imp, method_getTypeEncoding(m));
		}
	}
}

#endif

- (void)dealloc {
    if (_az_framesetter) CFRelease(_az_framesetter);
}

- (void)layoutSubviews
{
	[super layoutSubviews];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
	if ([self respondsToSelector:@selector(invalidateIntrinsicContentSize)])
		[self invalidateIntrinsicContentSize];
#endif
}

#pragma mark - Attribute string conversion

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000

- (NSAttributedString *)az_copyOfAttributedTextByForcingLineBreakMode {
	NSAttributedString *string = self.attributedText;
	NSMutableAttributedString *mutableString = string.mutableCopy;
	AZLineBreakMode keepLineBreakMode = NO;
	
	[mutableString beginEditing];
	
	NSRange range = NSMakeRange(0, mutableString.length);
	NSRangePointer rangePtr = &range;
	NSUInteger loc = range.location;
	
	while (NSLocationInRange(loc, range))
	{
		NSParagraphStyle *current = [string attribute:AZParagraphStylePreferredAttributeName atIndex:loc longestEffectiveRange:rangePtr inRange:range];
		
		NSMutableParagraphStyle *newStyle = nil;
		
		if (current) {
			newStyle = [current mutableCopy];
			keepLineBreakMode |= CTLineBreakModeTruncates(CTLineBreakModeForAZLineBreakMode(current.lineBreakMode));
		} else {
			newStyle = [NSMutableParagraphStyle new];
		}
		newStyle.lineBreakMode = AZLineBreakByCharWrapping;
		
		// apparently there's an Apple leak on some OS version?
		[mutableString removeAttribute:AZParagraphStylePreferredAttributeName range:*rangePtr];
		[mutableString addAttribute:AZParagraphStylePreferredAttributeName value:newStyle range:*rangePtr];
		
		loc = NSMaxRange(*rangePtr);
	}
	
	[mutableString endEditing];
	
	self.az_truncatesLastLine = keepLineBreakMode;
	
	return mutableString;
}

#endif

- (NSDictionary *)az_formattableStringAttributes {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
	if ([NSMutableParagraphStyle class]) {        
		NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
		paragraphStyle.alignment = self.textAlignment;
		paragraphStyle.lineBreakMode = self.numberOfLines == 1 ? self.lineBreakMode : AZLineBreakByCharWrapping;
		
		return @{
			AZFontPreferredAttributeName: self.font,
			AZParagraphStylePreferredAttributeName: paragraphStyle
		};
	} else
#endif
	{
		CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, self.font.pointSize, NULL);

		CTTextAlignment alignment = CTTextAlignmentForAZTextAlignment(self.textAlignment);
		CTLineBreakMode lineBreakMode = CTLineBreakModeForAZLineBreakMode(self.numberOfLines == 1 ? self.lineBreakMode : AZLineBreakByCharWrapping);
		CTParagraphStyleSetting paragraphStyles[2] = {
			{.spec = kCTParagraphStyleSpecifierAlignment, .valueSize = sizeof(CTTextAlignment), .value = (const void *)&alignment},
			{.spec = kCTParagraphStyleSpecifierLineBreakMode, .valueSize = sizeof(CTLineBreakMode), .value = (const void *)&lineBreakMode}
        };
		CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(paragraphStyles, 2);
				
		NSDictionary *ret = @{
			AZFontPreferredAttributeName: (__bridge id)font,
			AZParagraphStylePreferredAttributeName: (__bridge id)paragraphStyle
		};
		
		CFRelease(paragraphStyle);
		CFRelease(font);
		
		return ret;
	}
}

#pragma mark - Lazy attributed string

- (NSAttributedString *)az_attributedTextString {
    if (_needsAttributedTextString || !_az_attributedTextString) {
        @synchronized(self) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
			if (self.az_textIsAttributed) {
				_attributedStringIsPlaintext = NO;
				if (self.numberOfLines != 1) {
					_az_attributedTextString = [self az_copyOfAttributedTextByForcingLineBreakMode];
				} else {
					_az_attributedTextString = self.attributedText;
				}
			} else
#endif
			{
				_attributedStringIsPlaintext = YES;
				_az_attributedTextString = [[NSAttributedString alloc] initWithString: self.text attributes: [self az_formattableStringAttributes]];
			}
            _needsAttributedTextString = NO;
        }
    }
    return _az_attributedTextString;
}

- (void)invalidateAttributedTextString {
    _needsAttributedTextString = YES;
    _az_attributedTextString = nil;
    _needsFramesetter = YES;
	[self invalidateTextPaths];
}

- (CTFramesetterRef)framesetter {
    if (_needsFramesetter || !_az_framesetter) {
        @synchronized(self) {
            if (_az_framesetter) CFRelease(_az_framesetter);
            NSAttributedString *string = self.az_attributedTextString;
            _az_framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)string);
            _needsFramesetter = NO;
        }
    }
    return _az_framesetter;
}

#pragma mark - Path caching

- (void)az_createTextPathsIfNeededForRect:(CGRect)bounds {
	if (_az_needsTextPaths || !_textPaths) {
		@synchronized(self) {
			self.textPaths = AZLabelSketchTextInRect(self.az_attributedTextString, self.framesetter, bounds, self.numberOfLines, self.az_truncatesLastLine, &_textPathsBounds);
			self.textPathsGeneratedForSize = bounds.size;
			_az_needsTextPaths = NO;
		}
	}
}

- (void)invalidateTextPaths {
    _az_needsTextPaths = YES;
    self.textPaths = nil;
}

#pragma mark - Drawing

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    return [super textRectForBounds: UIEdgeInsetsInsetRect(bounds, self.textEdgeInsets) limitedToNumberOfLines: numberOfLines];
}

- (BOOL)az_textRequiresSpecialDrawing {
	if (!self.az_textIsAttributed) {
		return (self.gradient || (self.shadow && self.shadow.shadowBlurRadius != 0) || self.shadowBlurRadius != 0|| self.innerShadow);
	}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
	else {
		if (!self.attributedText.length) return NO;

		NSAttributedString *str = self.attributedText;
		NSRange ran = NSMakeRange(0, str.length);
		
		BOOL(^testForAttribute)(NSString *) = ^(NSString *attributeName) {
			__block BOOL foundAttr = NO;
			[str enumerateAttribute:attributeName inRange:ran options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
				foundAttr = YES;
				*stop = YES;
			}];
			return foundAttr;
		};
		
		if (testForAttribute(AZLabelGradientForegroundAttributeName)) return YES;
		if (testForAttribute(AZLabelInnerShadowAttributeName)) return YES;
		if (testForAttribute(AZLabelShadowAttributeName)) return YES;
		
		return NO;
	}
#endif
	return NO;
}

- (void)az_calculateCompositeProperties {
	if (self.az_gradientDict) {
		_gradient = [[AZGradient alloc] initWithColorsAtLocations:self.az_gradientDict];
		self.az_gradientDict = nil;
	}
	
	if (self.az_shadowDict)
	{
		_shadow = [AZShadow shadowWithDictionary:self.az_shadowDict];
		if (self.shadowColor && !_shadow.shadowColor)
			_shadow.shadowColor = self.shadowColor;
		if (!CGSizeEqualToSize(self.shadowOffset, CGSizeZero)
			&& CGSizeEqualToSize(_shadow.shadowOffset, CGSizeZero))
			_shadow.shadowOffset = self.shadowOffset;
		self.az_shadowDict = nil;
	}
	
	if (self.az_innerShadowDict)
	{
		_innerShadow = [AZShadow shadowWithDictionary:self.az_innerShadowDict];
		self.az_innerShadowDict = nil;
	}
}

- (void)drawTextInRect:(CGRect)rect {
    rect = UIEdgeInsetsInsetRect(rect, self.textEdgeInsets);
	
	[self az_calculateCompositeProperties];
	
	if (![self az_textRequiresSpecialDrawing]) {
		[super drawTextInRect: rect];
		return;
	}
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	BOOL shouldInvalidate = (!CGSizeEqualToSize(rect.size, self.textPathsGeneratedForSize) && self.contentMode != UIViewContentModeRedraw);
	
	if (shouldInvalidate) {
		[self invalidateTextPaths];
	}
	
	[self az_createTextPathsIfNeededForRect: rect];
	if (!self.textPaths.count || CGRectIsNull(self.textPathsBounds)) return;

	const CGFloat scale = self.window.screen.scale;
	
	CGRect allPathsBounds = self.textPathsBounds;
	CGFloat newX, newY;
	CGFloat nativeVertCenter = rect.origin.y + (rect.size.height - allPathsBounds.size.height) / 2.0;
	CGFloat nativeHorzCenter = rect.origin.x + (rect.size.width - allPathsBounds.size.width) / 2.0;
	
	if (!shouldInvalidate) {
		// translate context according to bounds
		switch (self.contentMode) {
			case UIViewContentModeCenter:
				newX = nativeHorzCenter;
				newY = nativeVertCenter;
				break;
			case UIViewContentModeTop:
				newX = nativeHorzCenter;
				newY = CGRectGetMinY(allPathsBounds);
				break;
			case UIViewContentModeBottom:
				newX = nativeHorzCenter;
				newY = CGRectGetMaxY(rect) - CGRectGetMaxY(allPathsBounds);
				break;
			case UIViewContentModeRight:
				newX = CGRectGetMaxX(rect) - CGRectGetMaxX(allPathsBounds);
				newY = nativeVertCenter;
				break;
			case UIViewContentModeTopLeft:
				newX = CGRectGetMinX(allPathsBounds);
				newY = CGRectGetMinY(allPathsBounds);
				break;
			case UIViewContentModeTopRight:
				newX = CGRectGetMaxX(rect) - CGRectGetMaxX(allPathsBounds);
				newY = CGRectGetMinY(allPathsBounds);
				break;
			case UIViewContentModeBottomLeft:
				newX = CGRectGetMinX(allPathsBounds);
				newY = CGRectGetMaxY(rect) - CGRectGetMaxY(allPathsBounds);
				break;
			case UIViewContentModeBottomRight:
				newX = CGRectGetMaxX(rect) - CGRectGetMaxX(allPathsBounds);
				newY = CGRectGetMaxY(rect) - CGRectGetMaxY(allPathsBounds);
				break;
			case UIViewContentModeLeft:
			default:
				newX = CGRectGetMinX(allPathsBounds);
				newY = nativeVertCenter;
				break;
		}
	} else {
		newX = CGRectGetMinX(allPathsBounds);
		newY = nativeVertCenter;
	}
	
	CGPoint oldOrigin = allPathsBounds.origin;
    allPathsBounds.origin.x = azroundr(newX, scale);
    allPathsBounds.origin.y = azroundr(newY, scale);
    allPathsBounds.size.width = azceilr(CGRectGetMaxX(allPathsBounds) - azfloorr(newX, scale), scale);
    allPathsBounds.size.height = azceilr(CGRectGetMaxY(allPathsBounds) - azfloorr(newY, scale), scale);
	CGFloat originXDelta = allPathsBounds.origin.x - oldOrigin.x;
	CGFloat originYDelta = allPathsBounds.origin.y - oldOrigin.y;

	CGContextTranslateCTM(ctx, originXDelta, rect.size.height - originYDelta);
    CGContextScaleCTM(ctx, 1, -1);
	
	for (AZLabelRunInfo *info in self.textPaths) {
		NSDictionary *attr = info.attributes;
		CGPathRef path = info.path;
		
		id <AZShadow> shadow = nil;
		if (self.highlighted && self.highlightedShadow) {
			shadow = self.highlightedShadow;
		} else if (_attributedStringIsPlaintext) {
			shadow = self.shadow ?: (self.shadowColor ? [AZShadow shadowWithOffset: self.shadowOffset blurRadius: self.shadowBlurRadius color: self.shadowColor] : nil);
		} else {
			shadow = attr[AZShadowPreferredAttributeName];
		}
		if ([shadow isEqual: [NSNull null]]) shadow = nil;
		
		id <AZShadow> innerShadow = nil;
		if (self.highlighted && self.highlightedInnerShadow) {
			innerShadow = self.highlightedInnerShadow;
		} else if (_attributedStringIsPlaintext) {
			innerShadow = self.innerShadow;
		} else {
			innerShadow = attr[AZLabelInnerShadowAttributeName];
		}
		if ([innerShadow isEqual: [NSNull null]]) innerShadow = nil;
		
		AZGradient *gradient = nil;
		AZGradientDirection direction;
		if (self.highlighted && self.highlightedGradient) {
			gradient = self.highlightedGradient;
			direction = self.highlightedGradientDirection;
		} else if (_attributedStringIsPlaintext) {
			gradient = self.gradient;
			direction = self.gradientDirection;
		} else {
			gradient = attr[AZLabelGradientForegroundAttributeName];
			NSNumber *directionValue = attr[AZLabelGradientForegroundDirectionAttributeName];
			direction = directionValue ? [directionValue unsignedIntegerValue] : AZGradientDirectionVertical;
		}
		if ([gradient isEqual: [NSNull null]]) gradient = nil;
		
		UIColor *color = nil;
		if (!gradient) {
			if (self.highlighted && self.highlightedTextColor) {
				color = self.highlightedTextColor;
			} else if (!_attributedStringIsPlaintext) {
				color = attr[AZForegroundColorPreferredAttributeName];
			}
			if (!color || [color isEqual: [NSNull null]]) color = self.textColor;
		}
		
		// shadow stabbing
		if (shadow) {
			CGContextTranslateCTM(ctx, shadow.shadowOffset.width, -shadow.shadowOffset.height);
			[shadow set];
		}
		
		const CGRect pathBounds = CGPathGetBoundingBox(path);
		
		// gradient drawing
		CGContextBeginTransparencyLayer(ctx, NULL);
		{
			CGContextAddPath(ctx, path);
			
			if (gradient) {
				CGContextClip(ctx);
				[gradient drawInRect: pathBounds direction: direction];
			} else {
				CGContextSetFillColorWithColor(ctx, color.CGColor);
				CGContextFillPath(ctx);
			}
		}
		CGContextEndTransparencyLayer(ctx);
		
		// inner shadow drawing
		if (innerShadow) {
			CGRect textBorderRect = CGRectInset(pathBounds, -innerShadow.shadowBlurRadius, -innerShadow.shadowBlurRadius);
			textBorderRect = CGRectOffset(textBorderRect, -innerShadow.shadowOffset.width, -innerShadow.shadowOffset.height);
			textBorderRect = CGRectInset(CGRectUnion(textBorderRect, pathBounds), -1, -1);
			
			UIGraphicsContextPerformBlock(^(CGContextRef ctx) {
				id <AZShadow> innerShadowCopy = [(id)innerShadow copy];
				CGFloat xOffset = innerShadow.shadowOffset.width + round(textBorderRect.size.width);
				CGFloat yOffset = innerShadow.shadowOffset.height;
				innerShadowCopy.shadowOffset = CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset));
				[innerShadowCopy set];
				
				CGContextAddPath(ctx, path);
				CGContextClip(ctx);
				
				CGContextTranslateCTM(ctx, -round(textBorderRect.size.width), 0);
				CGContextAddRect(ctx, textBorderRect);
				CGContextAddPath(ctx, path);
				CGContextSetFillColorWithColor(ctx, UIColor.grayColor.CGColor);
				CGContextEOFillPath(ctx);
			});
		}
		
		// reset shadow changes
		if (shadow) {
			[AZShadow clear];
			CGContextTranslateCTM(ctx, -shadow.shadowOffset.width, shadow.shadowOffset.height);
		}
	}
}

#pragma mark - Setters

typedef NS_ENUM(int, AZLabelPropertyChangeType) {
	AZLabelDrawable,
	AZLabelAttributedFormattable,
	AZLabelPlaintextFormattable,
	AZLabelPlaintextDrawable,
	AZLabelHighlightDrawable
};

- (void)az_propertyChange:(AZLabelPropertyChangeType)change {
	switch (change) {
		case AZLabelDrawable: break;
		case AZLabelAttributedFormattable:
			[self invalidateAttributedTextString];
			break;
		case AZLabelPlaintextFormattable:
			if (!self.az_textIsAttributed) {
				[self invalidateAttributedTextString];
			} else {
				return;
			}
			break;
		case AZLabelPlaintextDrawable:
			if (self.az_textIsAttributed) return;
			break;
		case AZLabelHighlightDrawable:
			if (!self.highlighted) return;
			break;
	}
	
	if (self.superview) [self setNeedsDisplay];
}

- (void)setTextEdgeInsets:(UIEdgeInsets)textEdgeInsets {
	_textEdgeInsets = textEdgeInsets;
	[self az_propertyChange: AZLabelDrawable];
	[self setNeedsDisplay];
}

#pragma mark Formattable

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000

- (void)az_setAttributedText:(NSAttributedString *)attributedText {
	[super setAttributedText: attributedText];
	self.az_textIsAttributed = YES;
	[self az_propertyChange: AZLabelAttributedFormattable];
}

#endif

- (void)setText:(NSString *)text {
	[super setText:text];
	self.az_textIsAttributed = NO;
	[self az_propertyChange: AZLabelPlaintextFormattable];
}

- (void)setFont:(UIFont *)font {
	[super setFont:font];
	[self az_propertyChange: AZLabelPlaintextFormattable];
}

- (void)setTextAlignment:(AZTextAlignment)textAlignment {
	[super setTextAlignment:textAlignment];
	[self az_propertyChange: AZLabelPlaintextFormattable];
}

- (void)setLineBreakMode:(AZLineBreakMode)lineBreakMode {
	[super setLineBreakMode:lineBreakMode];
	[self az_propertyChange: AZLabelPlaintextFormattable];
}

#pragma mark Plaintext setters

- (void)setTextColor:(UIColor *)textColor {
	[super setTextColor:textColor];
	[self az_propertyChange: AZLabelPlaintextDrawable];
}

- (void)setShadowColor:(UIColor *)shadowColor {
	[super setShadowColor:shadowColor];
	[self az_propertyChange: AZLabelPlaintextDrawable];
}

- (void)setShadowOffset:(CGSize)shadowOffset {
	[super setShadowOffset:shadowOffset];
	[self az_propertyChange: AZLabelPlaintextDrawable];
}

- (void)setShadowBlurRadius:(CGFloat)shadowBlurRadius {
	_shadowBlurRadius = shadowBlurRadius;
	[self az_propertyChange: AZLabelPlaintextDrawable];
}

- (void)setShadow:(id<AZShadow>)shadow {
	_shadow = shadow;
	[self az_propertyChange: AZLabelPlaintextDrawable];
}

- (void)setInnerShadow:(id<AZShadow>)innerShadow {
	_innerShadow = innerShadow;
	[self az_propertyChange: AZLabelPlaintextDrawable];
}

- (void)setGradient:(AZGradient *)gradient {
	_gradient = gradient;
	[self az_propertyChange: AZLabelPlaintextDrawable];
}

- (void)setGradientDirection:(AZGradientDirection)gradientDirection {
	_gradientDirection = gradientDirection;
	[self az_propertyChange: AZLabelPlaintextDrawable];
}

#pragma mark Highlighted setters

- (void)setHighlightedTextColor:(UIColor *)highlightedTextColor {
	[super setHighlightedTextColor:highlightedTextColor];
	[self az_propertyChange: AZLabelHighlightDrawable];
}

- (void)setHighlightedShadow:(id<AZShadow>)highlightedShadow {
	_highlightedShadow = highlightedShadow;
	[self az_propertyChange: AZLabelHighlightDrawable];
}

- (void)setHighlightedInnerShadow:(id<AZShadow>)highlightedInnerShadow {
	_highlightedInnerShadow = highlightedInnerShadow;
	[self az_propertyChange: AZLabelHighlightDrawable];
}

- (void)setHighlightedGradient:(AZGradient *)highlightedGradient {
	_highlightedGradient = highlightedGradient;
	[self az_propertyChange: AZLabelHighlightDrawable];
}

- (void)setHighlightedGradientDirection:(AZGradientDirection)highlightedGradientDirection {
	_highlightedGradientDirection = highlightedGradientDirection;
	[self az_propertyChange: AZLabelHighlightDrawable];
}

#pragma mark Event changes

- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
	[self setNeedsDisplay];
}

#pragma mark - IB KVC support

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath
{
	if ([keyPath rangeOfString:@"gradient." options:NSCaseInsensitiveSearch].location != NSNotFound)
	{
		if ([keyPath rangeOfString:@"gradient.direction" options:NSCaseInsensitiveSearch].location != NSNotFound)
		{
			_gradientDirection = [value unsignedIntegerValue];
		}
		else
		{
			if (!self.az_gradientDict) self.az_gradientDict = [NSMutableDictionary dictionary];
			self.az_gradientDict[AZGradientGetKeyForKVC(keyPath)] = value;
		}
	}
	else if ([keyPath rangeOfString:@"innerShadow." options:NSCaseInsensitiveSearch].location != NSNotFound)
	{
		if (!self.az_innerShadowDict) self.az_innerShadowDict = [NSMutableDictionary dictionary];
		self.az_innerShadowDict[[keyPath substringFromIndex:@"innerShadow.".length]] = value;
	}
	else if ([keyPath rangeOfString:@"shadow." options:NSCaseInsensitiveSearch].location != NSNotFound)
	{
		if (!self.az_shadowDict) self.az_shadowDict = [NSMutableDictionary dictionary];
		self.az_shadowDict[[keyPath substringFromIndex:@"shadow.".length]] = value;
	}
	else
	{
		[super setValue: value forKeyPath: keyPath];
	}
}

@end
