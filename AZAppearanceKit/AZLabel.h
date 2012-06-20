//
//  AZLabel.h
//  AZAppearanceKit
//
//  Created by Zachary Waldowski on 3/17/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AZGradient.h"

@interface AZLabel : UIControl <UIAppearance>

@property (nonatomic, copy) NSString             *text;				// default is nil
@property (nonatomic, strong) UIFont             *font;				// default is nil (system font 17 plain)
@property (nonatomic) NSLineBreakMode            lineBreakMode;		// default is NSLineBreakByTruncatingTail. used for single and multiple lines of text
@property (nonatomic) UIEdgeInsets				 textEdgeInsets;

@property (nonatomic, readonly) UIColor *textColor;					// default is black; returns text color for default mode
- (void)setTextColor:(UIColor *)color forState:(UIControlState)state;
- (UIColor *)textColorForState:(UIControlState)state;

@property (nonatomic, readonly) CGSize shadowOffset;
@property (nonatomic, readonly) CGFloat shadowBlur;
@property (nonatomic, readonly) UIColor *shadowColor;
- (void)setShadowOffset:(CGSize)shadowOffset blur:(CGFloat)shadowBlur color:(UIColor *)shadowColor forState:(UIControlState)controlState;
- (CGSize)shadowOffsetForState:(UIControlState)controlState;
- (CGFloat)shadowBlurForState:(UIControlState)controlState;
- (UIColor *)shadowColorForState:(UIControlState)controlState;

@property (nonatomic, readonly) CGSize innerShadowOffset;
@property (nonatomic, readonly) CGFloat innerShadowBlur;
@property (nonatomic, readonly) UIColor *innerShadowColor;
- (void)setInnerShadowOffset:(CGSize)innerShadowOffset blur:(CGFloat)innerShadowBlur color:(UIColor *)innerShadowColor forState:(UIControlState)controlState;
- (CGSize)innerShadowOffsetForState:(UIControlState)controlState;
- (CGFloat)innerShadowBlurForState:(UIControlState)controlState;
- (UIColor *)innerShadowColorForState:(UIControlState)controlState;

@property (nonatomic, readonly) AZGradient *gradient;
@property (nonatomic, readonly) AZGradientDirection gradientDirection;
- (void)setGradient:(AZGradient *)gradient direction:(AZGradientDirection)gradientDirection forState:(UIControlState)controlState;
- (AZGradient *)gradientForState:(UIControlState)controlState;
- (AZGradientDirection)gradientDirectionForState:(UIControlState)controlState;

@property (nonatomic, strong, readonly) UIBezierPath *textPath;

/*@property(nonatomic) NSInteger numberOfLines;
@property(nonatomic) BOOL adjustsFontSizeToFitWidth;				// default is NO
@property(nonatomic) UIBaselineAdjustment baselineAdjustment;		// default is UIBaselineAdjustmentAlignBaselines
@property(nonatomic) CGFloat minimumFontSize;					// default is 0.0
 - (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines;*/

@end
