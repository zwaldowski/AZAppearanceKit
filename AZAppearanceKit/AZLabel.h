//
//  AZLabel.h
//  AZAppearanceKit
//
//  Created by Zachary Waldowski on 3/17/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AZGradient.h"
#import "AZShadow.h"

/** AZLabel is a styled drop-in replacement for text-only unattributed UILabel.
 
 Labels can be be created in Interface Builder using the UILabel template and
 then changing the class to AZLabel. Use user-defined attributes for the other
 AZLabel properties.
 
 A gradient can be initialized from Interface Builder using a keypath beginning
 with "gradient" and ending as a representation of a position: `@(0.5)`,
 `(0.5)`, `topColor`, `bottomColor`, `leftColor`, `rightColor`, `startColor`,
 or `endColor`.
 
 A shadow or inner shadow can be initialized from Interface Builder using a
 keypath beginning with "shadow" or "innerShadow", respectively, and ending
 with one of the following: `shadowBlurRadius`, `shadowColor`, `shadowOffset`.
 
 Includes code by [Ole Begemann](https://github.com/ole/Animated-Paths).
 Licensed under MIT. Copyright (c) 2010 Ole Begemann. All rights reserved.
 
 Includes code by [Sam King](http://www.codeproject.com/Articles/109729/Low-level-text-rendering).
 Licensed under [CPOL](http://www.codeproject.com/info/cpol10.aspx). Copyright (c) 2010 Sam King. All rights reserved.
 */
@interface AZLabel : UIControl <UIAppearance>

/** The text displayed by the label.
 
 This string is nil by default.
*/
@property (nonatomic, copy) NSString *text;

/** The font of the text.
 
 The default value for this property is the system font at a size of 17 points
 (using the `systemFontOfSize:` class method of `UIFont`). The value for the
 property can only be set to a non-nil value; setting this property to nil
 raises an exception.
 */
@property (nonatomic, strong) UIFont *font;

/** The technique to use for wrapping and truncating the label’s text.
 
 This property is set to UILineBreakModeTailTruncation by default.
 
 */
@property (nonatomic) UILineBreakMode lineBreakMode;

/** The inset or outset margins for the rectangle surrounding all of the label's
 text content.
 
 Use this property to resize and reposition the effective drawing rectangle for
 the label's text content. You can specify a different value for each of the
 four insets (top, left, bottom, and right). A positive value shrinks, or
 insets, that edge, thereby moving it loser to the center of the button. A
 negative value expands that edge. Use UIEdgeInsetsMake to construct a value for
 this property. The default value is UIEdgeInsetsZero.
 */
@property (nonatomic) UIEdgeInsets textEdgeInsets;

/** Returns the text color used for the default control state.
 
 The default value for this property is a black color.
 
 This property is ignored if a gradient is not nil.
 
 @see gradient;
 */
@property (nonatomic, strong) UIColor *textColor;

/** Sets the color of the text to use for a specified control state.
 
 In general, if a property is not specified for a state, the default is to use
 the UIControlStateNormal value. If the UIControlStateNormal value is not set,
 then the property defaults to a system value. Therefore, at a minimum, you
 should set the value for the normal state.
 
 @param color The color of the text to use for the specified state.
 @param state The state that uses the specified color.
 The possible values are described in UIControlState.
 
 */
- (void) setTextColor: (UIColor *) color forState: (UIControlState) state;

/** Returns the text color used for a state.
 
 @param state The state that uses the text color. The possible values are
 described in UIControlState.
 @return The color of the text for the specified state.

 */
- (UIColor *) textColorForState: (UIControlState) state;

/** The shadow for the text used for the default control state. */
@property (nonatomic, strong) id <AZShadow> shadow;

/** Sets the shadow to use on the text in a specified control state.
 
 @param shadow The shadow for the text to use for the specified state.
 @param state The state that uses the specified offset.
 */
- (void) setShadow: (id <AZShadow>) shadow forState: (UIControlState) controlState;

/** Returns the shadow used for a state.
 
 @param state The state that uses the shadow offset.
 @return The shadow of the text for the specified state.
 */
- (id <AZShadow>) shadowForState: (UIControlState) controlState;

/** The inner shadow for the text used for the default control state. */
@property (nonatomic, strong) id <AZShadow>innerShadow;

/** Sets the inner shadow to use on the text in a specified control state.
 
 @param innerShadow The inner shadow for the text to use for the specified
 state.
 @param state The state that uses the specified offset.
 */
- (void)setInnerShadow:(id <AZShadow>) innerShadow forState: (UIControlState) controlState;

/** Returns the inner shadow offset used for a state.
 
 @param state The state that uses the inner shadow offset.
 @return The inner shadow offset of the text for the specified state.
 */
- (id <AZShadow>) innerShadowForState: (UIControlState) controlState;

/** The gradient used to color in the text for the default control state.
 
 The default value for this property is nil, which means textColor is used
 instead.

 A gradient can be initialized from Interface Builder using a keypath beginning
 with "gradient" and ending as a representation of a position: `@(0.5)`,
 `(0.5)`, `topColor`, `bottomColor`, `leftColor`, `rightColor`, `startColor`,
 or `endColor`.
 
 @see textColor;
 @see gradientDirection;
 */
@property (nonatomic, strong) AZGradient *gradient;

/** Sets the gradient to use to fill the text in a specified control state.
 
 @param gradient The gradient for the text to use for the specified state.
 @param state The state that uses the specified gradient.
 
 */
- (void) setGradient: (AZGradient *) gradient forState: (UIControlState) controlState;

/** Returns the gradient used to fill the text for a state.
 
 @param state The state that uses the gradient.
 @return The gradient used to fill the text for the specified state.
 
 */
- (AZGradient *) gradientForState: (UIControlState) controlState;

/** The gradient direction used to color in the text for the default control
 state.
 
 The default value for this property is AZGradientDirectionVertical, which means
 the gradient will be draw from the top of the text to the bottom of the text.
 
 @see gradient;
 */
@property (nonatomic) AZGradientDirection gradientDirection;

/** Sets the direction for the gradient used to fill the text in a specified
 control state.
 
 @param gradient The gradient direction for the text to use for the specified
 state.
 @param state The state that uses the specified direction.
 */
- (void) setGradientDirection: (AZGradientDirection) gradientDirection forState: (UIControlState) controlState;

/** Returns the gradient direction used to fill the text for a state.
 
 @param state The state that uses the gradient direction.
 @return The direction used for the gradient that fills the text for the
 specified state.
 */
- (AZGradientDirection) gradientDirectionForState: (UIControlState) controlState;

/** Returns a bezier path calculated with respect to the text, size, line break
 mode, and alignment properties of the label. It is recalculated whenever these
 properties or the frame of the label changes. */
@property (nonatomic, strong, readonly) UIBezierPath *textPath;

@end
