//
//  AZNavigationBar.h
//  AZAppearanceKit
//
//  Created by Victor Pena Placer on 3/1/12.
//  Copyright (c) 2012 Victor Pena Placer. All rights reserved.
//  Copyright (c) 2012 Zachary Waldowski. All rights reserved.
//

@class AZGradient;

/** `AZNavigationBar` is a subclass of `UINavigationBar` that removes the
 glossy effect and lets you customize its colors.
 
 You can change the navigation bar appearance as follows:
 
 - shadow opacity
 - gradient
 - top line volor
 - bottom line color

 */
@interface AZNavigationBar : UINavigationBar

/** Specifies the navigation bar shadow's opacity.
 
 By default is `0.5`. */
@property (nonatomic, assign) CGFloat shadowOpacity;

/** Specifies the gradient's start color.
 
 By default, it is a gradient made up of blue tones. */
@property (nonatomic, strong) AZGradient *gradient;

/** Specifies the gradient's top line color.
 
 By default is a blue tone. */
@property (nonatomic, strong) UIColor *topLineColor;

/** Specifies the gradient's bottom line color.
 
 By default is a blue tone. */
@property (nonatomic, strong) UIColor *bottomLineColor;

@end
