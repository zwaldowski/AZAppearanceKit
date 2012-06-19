//
//  RXLabel.h
//  RXLabel
//
//  Created by Zachary Waldowski on 3/17/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

typedef enum {
	RXLabelGradientDirectionHorizontal,
	RXLabelGradientDirectionVertical
} RXLabelGradientDirection;

@interface RXLabel : UILabel

@property (nonatomic) CGFloat shadowBlur;

@property (nonatomic) CGSize innerShadowOffset;
@property (nonatomic) CGFloat innerShadowBlur;
@property (nonatomic, strong) UIColor *innerShadowColor;

@property (nonatomic, copy) NSArray *gradientColors;
@property (nonatomic, copy) NSArray *gradientLocations;
@property (nonatomic) RXLabelGradientDirection gradientDirection;

@property (nonatomic) UIEdgeInsets textEdgeInsets;

@end
