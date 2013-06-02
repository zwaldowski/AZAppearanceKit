//
//  AZShadow.m
//  AZAppearanceKit
//
//  Created by Zachary Waldowski on 10/29/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import "AZShadow.h"

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED

#define NSUINT_BIT (CHAR_BIT * sizeof(NSUInteger))
#define NSUINTROTATE(val, howmuch) ((((NSUInteger)val) << howmuch) | (((NSUInteger)val) >> (NSUINT_BIT - howmuch)))

static NSString *const AZShadowColorCodingKey = @"NSShadowColor";
static NSString *const AZShadowHorizKey = @"NSShadowHoriz";
static NSString *const AZShadowVertKey = @"NSShadowVert";
static NSString *const AZShadowBlurRadiusCodingKey = @"NSShadowBlurRadius";

@implementation AZShadow

@synthesize shadowBlurRadius = _shadowBlurRadius;
@synthesize shadowColor = _shadowColor;
@synthesize shadowOffset = _shadowOffset;

- (BOOL) isEqual: (id) object
{
	if (object == self) return YES;
	if (![object isKindOfClass: [self class]]) return NO;
	if ([object shadowBlurRadius] != self.shadowBlurRadius) return NO;
	if (!CGSizeEqualToSize([object shadowOffset], self.shadowOffset)) return NO;
	if (![[object shadowColor] isEqual: self.shadowColor]) return NO;
	return YES;
}

- (id) init
{
	if (NSClassFromString(@"NSShadow"))
	{
		self = [[NSClassFromString(@"NSShadow") alloc] init];
		return self;
	}
	
	self = [super init];
	return self;
}
+ (id <AZShadow>) shadowWithOffset: (CGSize) shadowOffset blurRadius: (CGFloat) shadowBlurRadius
{
	return [self shadowWithOffset: shadowOffset blurRadius: shadowBlurRadius color: nil];
}
+ (id <AZShadow>) shadowWithOffset: (CGSize) shadowOffset blurRadius: (CGFloat) shadowBlurRadius color: (id) shadowColor
{
	id <AZShadow> ret = NSClassFromString(@"NSShadow") ? [NSClassFromString(@"NSShadow") new] : [AZShadow new];
	ret.shadowOffset = shadowOffset;
	ret.shadowBlurRadius = shadowBlurRadius;
	ret.shadowColor = shadowColor;
	
	return ret;
}

+ (id <AZShadow>) shadowWithDictionary:(NSDictionary *)dictionary
{
	id <AZShadow> ret = NSClassFromString(@"NSShadow") ? [NSClassFromString(@"NSShadow") new] : [AZShadow new];
    
    if (dictionary[@"shadowBlurRadius"])
        ret.shadowBlurRadius = [dictionary[@"shadowBlurRadius"] floatValue];
    else
        ret.shadowBlurRadius = 0;
    
    if (dictionary[@"shadowColor"])
        ret.shadowColor = dictionary[@"shadowColor"];
    else
        ret.shadowColor = nil;
    if (dictionary[@"shadowOffset"])
        ret.shadowOffset = [dictionary[@"shadowOffset"] CGSizeValue];
    else
        ret.shadowOffset = CGSizeZero;
    
	return ret;
}

- (NSUInteger) hash
{
	NSUInteger hash = [self.shadowColor hash];
	hash ^= [@(self.shadowBlurRadius) hash];
	hash ^= [[NSValue valueWithCGSize: self.shadowOffset] hash];
	
	return hash;
}

- (NSString *) description
{
	NSMutableString *ret = [NSMutableString stringWithFormat: @"<AZShadow %@", NSStringFromCGSize(self.shadowOffset)];
	if (self.shadowBlurRadius)
		[ret appendFormat: @" blur = %f", self.shadowBlurRadius];
	if (self.shadowColor)
		[ret appendFormat: @" color = {%@}", self.shadowColor];
	[ret appendString: @">"];
	return ret;
}

+ (void) clearInContext:(CGContextRef)ctx
{
	CGContextSetShadowWithColor(ctx, CGSizeZero, 0, NULL);
}
+ (void) clear
{
	[self clearInContext:UIGraphicsGetCurrentContext()];
}
- (void) setInContext:(CGContextRef)ctx
{
	if (self.shadowColor)
		CGContextSetShadowWithColor(ctx, self.shadowOffset, self.shadowBlurRadius, [self.shadowColor CGColor]);
	else
		CGContextSetShadow(ctx, self.shadowOffset, self.shadowBlurRadius);
}
- (void) set
{
	[self setInContext:UIGraphicsGetCurrentContext()];
}

#pragma mark - Coding

- (id) initWithCoder: (NSCoder *) aDecoder
{
	if ((self = [super init]))
	{
		CGSize size;
#if CGFLOAT_IS_DOUBLE
		size.width = [aDecoder decodeDoubleForKey: AZShadowHorizKey];
		size.height = [aDecoder decodeDoubleForKey: AZShadowVertKey];
		self.shadowBlurRadius = [aDecoder decodeDoubleForKey: AZShadowBlurRadiusCodingKey];
#else
		size.width = [aDecoder decodeFloatForKey: AZShadowHorizKey];
		size.height = [aDecoder decodeFloatForKey: AZShadowVertKey];
		self.shadowBlurRadius = [aDecoder decodeFloatForKey: AZShadowBlurRadiusCodingKey];
#endif
		self.shadowOffset = size;
		
		if ([aDecoder containsValueForKey: AZShadowColorCodingKey])
		{
			self.shadowColor = [aDecoder decodeObjectForKey: AZShadowColorCodingKey];
		}
	}
	return self;
}

- (void) encodeWithCoder: (NSCoder *) aCoder
{
#if CGFLOAT_IS_DOUBLE
	[aCoder encodeDouble: self.shadowOffset.width forKey: AZShadowHorizKey];
	[aCoder encodeDouble: self.shadowOffset.height forKey: AZShadowVertKey];
	[aCoder encodeDouble: self.shadowBlurRadius forKey: AZShadowBlurRadiusCodingKey];
#else
	[aCoder encodeFloat: self.shadowOffset.width forKey: AZShadowHorizKey];
	[aCoder encodeFloat: self.shadowOffset.height forKey: AZShadowVertKey];
	[aCoder encodeFloat: self.shadowBlurRadius forKey: AZShadowBlurRadiusCodingKey];
#endif
	
	if (self.shadowColor)
	{
		[aCoder encodeObject: self.shadowColor forKey: AZShadowColorCodingKey];
	}
}

#pragma mark - Copying

- (id) copyWithZone: (NSZone *) zone
{
	return [[self class] shadowWithOffset: self.shadowOffset blurRadius: self.shadowBlurRadius color: self.shadowColor];
}

@end

#endif

@implementation NSShadow (AZShadow)

@dynamic shadowBlurRadius;
@dynamic shadowColor;
@dynamic shadowOffset;

+ (id <AZShadow>) shadowWithOffset: (CGSize) shadowOffset blurRadius: (CGFloat) shadowBlurRadius
{
	return [self shadowWithOffset: shadowOffset blurRadius: shadowBlurRadius color: nil];
}
+ (id <AZShadow>) shadowWithOffset: (CGSize) shadowOffset blurRadius: (CGFloat) shadowBlurRadius color: (id) shadowColor
{
	id <AZShadow> ret = [[[self class] alloc] init];
	ret.shadowOffset = shadowOffset;
	ret.shadowBlurRadius = shadowBlurRadius;
	if (shadowColor) // Setting to `nil` will cause a flag to be set
		ret.shadowColor = shadowColor;
	return ret;
}
+ (id <AZShadow>) shadowWithDictionary:(NSDictionary *)dictionary
{
    id <AZShadow> ret = [[[self class] alloc] init];
    
    if (dictionary[@"shadowBlurRadius"])
        ret.shadowBlurRadius = [dictionary[@"shadowBlurRadius"] floatValue];
    else
        ret.shadowBlurRadius = 0;
    
    if (dictionary[@"shadowColor"])
        ret.shadowColor = dictionary[@"shadowColor"];
    else
        ret.shadowColor = nil;
    if (dictionary[@"shadowOffset"])
        ret.shadowOffset = [dictionary[@"shadowOffset"] CGSizeValue];
    else
        ret.shadowOffset = CGSizeZero;

	return ret;
}

+ (void) clearInContext:(CGContextRef)ctx {
	CGContextSetShadowWithColor(ctx, CGSizeZero, 0, NULL);
}
+ (void) clear {
#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
	CGContextRef ctx = UIGraphicsGetCurrentContext();
#else
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
#endif
	[self clearInContext:ctx];
}
#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED

- (void) setInContext:(CGContextRef)ctx {
	if (self.shadowColor)
		CGContextSetShadowWithColor(ctx, self.shadowOffset, self.shadowBlurRadius, [self.shadowColor CGColor]);
	else
		CGContextSetShadow(ctx, self.shadowOffset, self.shadowBlurRadius);
}
- (void) set {
#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
	CGContextRef ctx = UIGraphicsGetCurrentContext();
#else
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
#endif
	[self setInContext:ctx];
	
}
#endif

@end
