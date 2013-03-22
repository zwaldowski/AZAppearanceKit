//
//  AZLabel.h
//  AZAppearanceKit
//
//  Created by Zach Waldowski on 3/18/13.
//  Copyright (c) 2013 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AZGradient.h"
#import "AZShadow.h"

/** An attributed string attribute name; a gradient to color
 the attributed text with.
 
 Used in lieu of the foreground color attribute.
 
 The value of this attribute is an AZGradient object.
 */
extern NSString *const AZLabelGradientForegroundAttributeName;

/** An attributed string attribute name; the cardinal direction
 used for drawing a gradient.
 
 The value of this attribute is a boxed AZGradientDirection value.
*/
extern NSString *const AZLabelGradientForegroundDirectionAttributeName;

/** An attributed string attribute name; the inner shadow used
 for the attributed text.
 
 The value of this attribute is an NSShadow object (if available),
 or if used with AZLabel, an AZShadow could be used as well.
*/
extern NSString *const AZLabelInnerShadowAttributeName;

/** An attributed string attribute name; the drop shadow used for
 the attributed text.
 
 Equivalent to the `NSShadowAttributeName` property.
 
 The value of this attribute is an NSShadow object (if available),
 or if used with AZLabel, an AZShadow could be used as well.
*/
extern NSString *const AZLabelShadowAttributeName;

/** AZLabel is a drop-in subclass of UILabel with extra styles.
 
 Labels can be be created in Interface Builder using the UILabel template and
 then changing the class to AZLabel. Use user-defined attributes for extra
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
@interface AZLabel : UILabel

/** The inset or outset margins for the rectangle surrounding all of the label's
 text content.
 
 Use this property to resize and reposition the effective drawing rectangle for
 the label's text content. You can specify a different value for each of the
 four insets (top, left, bottom, and right). A positive value shrinks, or
 insets, that edge, thereby moving it loser to the center of the button. A
 negative value expands that edge. Use UIEdgeInsetsMake to construct a value for
 this property. The default value is UIEdgeInsetsZero.
 
 Modifying this value causes an immediate redraw.
 */
@property (nonatomic) UIEdgeInsets textEdgeInsets;

/** An amount of points designating the length of the shadow. Default is 0.0.
 
 The value of this property, like the standard UILabel `shadowColor` and `shadowOffset`
 properties, is overriden by the `shadow` property, and will be ignored if that property
 has a non-nil value.
 
 Modifying this value, if the content of the label isn't attributed and if `shadow` is
 not nil, will trigger a recalculation of the string and an immediate redraw.
 
 @see shadow
 @see shadowColor
 @see shadowOffset
 */
@property (nonatomic) CGFloat shadowBlurRadius;

/** The shadow for the text.
 
 An alternative to setting `shadowColor`, `shadowOffset`, and `shadowBlurRadius`.
 
 Setting this property to a non-nil value causes the primitive shadow properties
 to be ignored.
 
 Like the primitive shadow properties, this property is ignored if the content
 of the label is attributed. For targetting iOS 5 and above, see the
 `AZLabelShadowAttributeName` attribute. For iOS 6 and above, see
 `NSShadowAttributeName`.
 
 Modifying this property will trigger an immediate redraw for plaintext content.
 
 */
@property (nonatomic, strong) id <AZShadow> shadow;

/** The shadow used for the text in a highlighted state.
 
 Unlike its related `shadow` property, this property is not ignored if the
 content of the label is attributed.
 
 Modifying this property will trigger an immediate redraw if the label
 is highlighted.
 
 @see shadow
 */
@property (nonatomic, strong) id <AZShadow> highlightedShadow;

/** The inner shadow for the text.
 
 This property is ignored if the content of the label is an attributed
 string. For attributed strings used in AZLabel, see
 `AZLabelInnerShadowAttributeName`.
 
 Modifying this property will trigger an immediate redraw for plaintext
 content.
 
 @see shadow
 */
@property (nonatomic, strong) id <AZShadow> innerShadow;

/** The inner shadow used for the text in a highlighted state.
 
 Unlike its related `innerShadow` property, this property is not ignored if
 the content of the label is attributed.
 
 Modifying this property will trigger an immediate redraw if the label
 is highlighted.
 
 @see shadow
 */
@property (nonatomic, strong) id <AZShadow> highlightedInnerShadow;

/** The gradient used to color in the text.
 
 The default value for this property is nil, which means `textColor` is used
 instead.
 
 A gradient can be initialized from Interface Builder using a keypath beginning
 with "gradient" and ending as a representation of a position: `@(0.5)`,
 `(0.5)`, `topColor`, `bottomColor`, `leftColor`, `rightColor`, `startColor`,
 or `endColor`.
 
 Setting this property to a non-nil value causes the `textColor` property
 to be ignored.
 
 This property is ignored if the content of the label is an attributed
 string. For attributed strings used in AZLabel, see
 `AZLabelGradientForegroundAttributeName`.
 
 Modifying this property will trigger an immediate redraw for plaintext content.
 
 @see textColor;
 @see gradientDirection;
 */
@property (nonatomic, strong) AZGradient *gradient;

/** The gradient direction used to color in the text.
 
 The default value for this property is AZGradientDirectionVertical, which means
 the gradient will be draw from the top of the text to the bottom of the text.
 
 This property is ignored if the content of the label is an attributed
 string. For attributed strings used in AZLabel, see
 `AZLabelGradientForegroundDirectionAttributeName`. Similarly, if the
 appropriate attribute is not set on an attributed string, the gradient will
 be drawn from top to bottom.
 
 Modifying this property will trigger an immediate redraw for plaintext content.
 
 @see gradient;
 */
@property (nonatomic) AZGradientDirection gradientDirection;

/** The gradient used to color in the text in a highlighted state.
 
 The default value for this property is nil, which means `highlightedTextColor`
 is used instead.
 
 A gradient can be initialized from Interface Builder using a keypath beginning
 with "gradient" and ending as a representation of a position: `@(0.5)`,
 `(0.5)`, `topColor`, `bottomColor`, `leftColor`, `rightColor`, `startColor`,
 or `endColor`.
 
 Unlike the related `gradient` property, this property is not ignored if
 the content of the label is attributed.
 
 Modifying this property will trigger an immediate redraw if the label
 is highlighted.
 
 @see gradient
 @see highlightedTextColor;
 @see highlightedGradientDirection;
 */
@property (nonatomic, strong) AZGradient *highlightedGradient;

/** The gradient direction used to color in the text for the highlighted state.
 
 The default value for this property is AZGradientDirectionVertical, which means
 the gradient will be draw from the top of the text to the bottom of the text.
 
 Unlike the related `gradientDirection` property, this property is not ignored if
 the content of the label is attributed.
 
 Modifying this property will trigger an immediate redraw if the label
 is highlighted.
 
 @see highlightedGradient;
 @see gradientDirection;
 */
@property (nonatomic) AZGradientDirection highlightedGradientDirection;

@end
