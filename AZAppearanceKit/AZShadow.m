//
//  AZShadow.m
//  AZAppearanceKit
//
//  Created by Zachary Waldowski on 10/29/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import "AZShadow.h"

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED

@interface AZShadow ()

@property (nonatomic, readonly, getter = az_hasShadowColor) BOOL hasShadowColor;

@end

static NSString *const AZShadowColorKey = @"NSShadowColor";
static NSString *const AZShadowHorizKey = @"NSShadowHoriz";
static NSString *const AZShadowVertKey = @"NSShadowVert";
static NSString *const AZShadowBlurRadiusKey = @"NSShadowBlurRadius";

@implementation AZShadow

@synthesize shadowOffset = _shadowOffset, shadowBlurRadius = _shadowBlurRadius, shadowColor = _shadowColor;

+ (id)shadowWithOffset:(CGSize)shadowOffset blurRadius:(CGFloat)shadowBlurRadius {
	return [self shadowWithOffset: shadowOffset blurRadius: shadowBlurRadius color: nil];
}

+ (id)shadowWithOffset:(CGSize)shadowOffset blurRadius:(CGFloat)shadowBlurRadius color:(id)shadowColor {
	id <AZShadow> ret = NSClassFromString(@"NSShadow") ? [NSClassFromString(@"NSShadow") new] : [AZShadow new];
	ret.shadowOffset = shadowOffset;
	ret.shadowBlurRadius = shadowBlurRadius;
	ret.shadowColor = shadowColor;
	return ret;
}

- (id)init {
	if (NSClassFromString(@"NSShadow")) {
		return (id)[[NSClassFromString(@"NSShadow") alloc] init];
	}
	return [super init];
}

- (id)copyWithZone:(NSZone *)zone {
	id <AZShadow> ret = [[[self class] alloc] init];
	ret.shadowOffset = self.shadowOffset;
	ret.shadowBlurRadius = self.shadowBlurRadius;
	ret.shadowColor = self.shadowColor;
	return ret;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super init])) {
		CGSize size;
#if CGFLOAT_IS_DOUBLE
		size.width = [aDecoder decodeDoubleForKey: AZShadowHorizKey];
		size.height = [aDecoder decodeDoubleForKey: AZShadowVertKey];
		self.shadowBlurRadius = [aDecoder decodeDoubleForKey: AZShadowBlurRadiusKey];
#else
		size.width = [aDecoder decodeFloatForKey: AZShadowHorizKey];
		size.height = [aDecoder decodeFloatForKey: AZShadowVertKey];
		self.shadowBlurRadius = [aDecoder decodeFloatForKey: AZShadowBlurRadiusKey];
#endif
		self.shadowOffset = size;
		if ([aDecoder containsValueForKey: AZShadowColorKey]) {
			self.shadowColor = [aDecoder decodeObjectForKey: AZShadowColorKey];
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
#if CGFLOAT_IS_DOUBLE
	[aCoder encodeDouble: self.shadowOffset.width forKey: AZShadowHorizKey];
	[aCoder encodeDouble: self.shadowOffset.height forKey: AZShadowVertKey];
	[aCoder encodeDouble: self.shadowBlurRadius forKey: AZShadowBlurRadiusKey];
#else
	[aCoder encodeFloat: self.shadowOffset.width forKey: AZShadowHorizKey];
	[aCoder encodeFloat: self.shadowOffset.height forKey: AZShadowVertKey];
	[aCoder encodeFloat: self.shadowBlurRadius forKey: AZShadowBlurRadiusKey];
#endif
	if (self.hasShadowColor) {
		[aCoder encodeObject: self.shadowColor forKey: AZShadowColorKey];
	}
}

- (BOOL)az_hasShadowColor {
	return !!_shadowColor;
}

- (BOOL)isEqual:(id)object {
	if (object == self) return YES;
	if (![object isKindOfClass: [self class]]) return NO;
	if ([object shadowBlurRadius] != self.shadowBlurRadius) return NO;
	if (!CGSizeEqualToSize([object shadowOffset], self.shadowOffset)) return NO;
	if (![[object shadowColor] isEqual: self.shadowColor]) return NO;
	return YES;
}

- (NSString *)description {
	NSMutableString *ret = [NSMutableString stringWithFormat: @"AZShadow %@", NSStringFromCGSize(self.shadowOffset)];
	if (self.shadowBlurRadius)
		[ret appendFormat: @" blur = %f", self.shadowBlurRadius];
	if (self.hasShadowColor)
		[ret appendFormat: @" color = {%@}", self.shadowColor];
	return ret;
}

- (void)set {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	if (self.hasShadowColor)
		CGContextSetShadowWithColor(ctx, self.shadowOffset, self.shadowBlurRadius, [self.shadowColor CGColor]);
	else
		CGContextSetShadow(ctx, self.shadowOffset, self.shadowBlurRadius);
}

+ (void)clear {
	CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeZero, 0, NULL);
}

@end

@implementation NSShadow (AZShadow)

@dynamic shadowBlurRadius, shadowColor, shadowOffset;

+ (id)shadowWithOffset:(CGSize)shadowOffset blurRadius:(CGFloat)shadowBlurRadius {
	return [self shadowWithOffset: shadowOffset blurRadius: shadowBlurRadius color: nil];
}

+ (id)shadowWithOffset:(CGSize)shadowOffset blurRadius:(CGFloat)shadowBlurRadius color:(id)shadowColor {
	NSShadow *ret = [[[self class] alloc] init];
	ret.shadowOffset = shadowOffset;
	ret.shadowBlurRadius = shadowBlurRadius;
	if (shadowColor) // setting to nil will cause a flag to be set
		ret.shadowColor = shadowColor;
	return ret;
}

- (void)set {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	if (self.shadowColor)
		CGContextSetShadowWithColor(ctx, self.shadowOffset, self.shadowBlurRadius, [self.shadowColor CGColor]);
	else
		CGContextSetShadow(ctx, self.shadowOffset, self.shadowBlurRadius);
}

+ (void)clear {
	CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeZero, 0, NULL);
}

@end

#endif