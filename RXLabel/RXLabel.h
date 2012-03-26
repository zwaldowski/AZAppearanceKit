//
//  RXLabel.h
//  RXLabel
//
//  Created by Zachary Waldowski on 3/17/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

enum {
	RXLabelGradientDirectionHorizontal,
	RXLabelGradientDirectionVerical
};
typedef NSUInteger RXLabelGradientDirection;

@interface RXLabel : UILabel

@property (nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor *shadowColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGSize shadowOffset UI_APPEARANCE_SELECTOR;

@property (nonatomic) CGFloat shadowBlur UI_APPEARANCE_SELECTOR;

@property (nonatomic) CGSize innerShadowOffset UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat innerShadowBlur UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *innerShadowColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, copy) NSArray *gradientColors UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) NSArray *gradientLocations UI_APPEARANCE_SELECTOR;
@property (nonatomic) RXLabelGradientDirection gradientDirection UI_APPEARANCE_SELECTOR;

@end
