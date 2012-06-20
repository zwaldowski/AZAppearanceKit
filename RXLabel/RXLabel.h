//
//  RXLabel.h
//  RXLabel
//
//  Created by Zachary Waldowski on 3/17/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "RXGradient.h"

@interface RXLabel : UIControl <UIAppearance>

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

@property (nonatomic, readonly) RXGradient *gradient;
@property (nonatomic, readonly) RXGradientDirection gradientDirection;
- (void)setGradient:(RXGradient *)gradient direction:(RXGradientDirection)gradientDirection forState:(UIControlState)controlState;
- (RXGradient *)gradientForState:(UIControlState)controlState;
- (RXGradientDirection)gradientDirectionForState:(UIControlState)controlState;

@property (nonatomic, strong, readonly) UIBezierPath *textPath;

/*@property(nonatomic) NSInteger numberOfLines;
@property(nonatomic) BOOL adjustsFontSizeToFitWidth;				// default is NO
@property(nonatomic) UIBaselineAdjustment baselineAdjustment;		// default is UIBaselineAdjustmentAlignBaselines
@property(nonatomic) CGFloat minimumFontSize;					// default is 0.0
 - (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines;
 */

@end
