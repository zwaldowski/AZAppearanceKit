//
//  UIImage+AZAppearanceKit.h
//  AZAppearanceKitDemo
//
//  Created by Zachary Waldowski on 11/9/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED

#import <UIKit/UIKit.h>

@interface UIImage (AZAppearanceKit)

+ (UIImage *)az_imageWithSize:(CGSize)size opaque:(BOOL)opaque usingBlock:(void(^)(void))drawingBlock;

@end

#endif