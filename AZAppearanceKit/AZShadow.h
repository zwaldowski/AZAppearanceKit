//
//  AZShadow.h
//  AZAppearanceKit
//
//  Created by Zachary Waldowski on 10/29/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED

#import <UIKit/UIKit.h>

@protocol AZShadow <NSObject, NSCopying, NSCoding>

@property (nonatomic, assign) CGSize shadowOffset;
@property (nonatomic, assign) CGFloat shadowBlurRadius;
@property (nonatomic, retain) id shadowColor;

+ (id)shadowWithOffset:(CGSize)shadowOffset blurRadius:(CGFloat)shadowBlurRadius;
+ (id)shadowWithOffset:(CGSize)shadowOffset blurRadius:(CGFloat)shadowBlurRadius color:(id)shadowColor;
+ (void)clear;
- (void)set;

@end

@interface AZShadow : NSObject <AZShadow>

@end

#else

#import <Cocoa/Cocoa.h>

@compatibility_alias AZShadow NSShadow;

#endif

@interface NSShadow (AZShadow) <AZShadow>

@end
