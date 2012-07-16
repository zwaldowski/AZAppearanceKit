//
//  AZTabBar.h
//  AZAppearanceKit
//
//  Created by Victor Pena Placer on 3/1/12.
//  Copyright (c) 2012 Victor Pena Placer. All rights reserved.
//  Copyright (c) 2012 Zachary Waldowski. All rights reserved.
//

@class AZGradient;

/** `AZTabBar` is a subclass of `UITabBar` that removes the
 glossy effect and lets you customize its colors.
 
 You can change the tab bar appearance as follows:
 
 - gradient
 - separator line volor

 */
@interface AZTabBar : UITabBar

/** Specifies the toolbar shadow's opacity.
 
 By default is `0.5`. */
@property (nonatomic, assign) float shadowOpacity;

/** Specifies the gradient's start color.
 
 By default, it is a gradient made up of black tones. */
@property (nonatomic, strong) AZGradient *gradient;

/** Specifies the top separator's color.
 
 By default is a black tone. */
@property (nonatomic, strong) UIColor *separatorLineColor;

@end
