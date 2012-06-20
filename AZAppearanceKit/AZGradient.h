//
//  AZGradient.h
//  AZAppearanceKit
//
//  Created by Zachary Waldowski on 5/8/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED

#import <UIKit/UIKit.h>

/** `AZGradient` defines a transition between colors.  The transition
 is defined over a range from 0.0 to 1.0 inclusive.  A gradient typically
 contains a color at location 0.0, and one at location 1.0 with additional
 colors assigned to locations between 0.0 and 1.0.
 
 `AZGradient` is a drawing primitive that can draw itself as a linear
 or radial gradient.  The color value at location 0.0 is considered the
 starting color, the color value at location 1.0 is considered the ending
 color.
 */
@interface AZGradient : NSObject <NSCoding, NSCopying>

/** Initializes a gradient with a starting color at location 0.0 and ending color at location 1.0, using a generic RGB color space. */
- (id)initWithStartingColor:(UIColor *)startingColor endingColor:(UIColor *)endingColor;

/** Initializes a gradient with the first color in the array at 0.0, the last color in the array at 1.0, and intervening colors at equal intervals in between, using a generic RGB color space. */
- (id)initWithColors:(NSArray *)colorArray;

/** This initializer takes the first color, then the first location as a `CGFloat`, then an alternating list of colors and `CGFloat`s, terminated by nil.  If no color is provided for 0.0 or 1.0, the created color gradient will use the color provided at the locations closest to 0.0 and 1.0 for those values.  A generic RGB color space is used. */
- (id)initWithColorsAndLocations:(UIColor *)firstColor, ... NS_REQUIRES_NIL_TERMINATION;

/** Initializes a gradient with pairs of colors and locations provided in the color dictionary.  Each key should be a `NSNumber` representing a number between 0.0 and 1.0. */
- (id)initWithColorsAtLocations:(NSDictionary *)colorsWithLocations;

/** Initializes a gradient by pairing the colors provided in the color array with the locations provided in the locations array.  Each location should be a CGFloat between 0.0 and 1.0.  The color array and location array should not be empty, and should contain the same number of items.  This is the designated initializer. */
- (id)initWithColors:(NSArray *)colorArray atLocations:(const CGFloat *)locations colorSpace:(CGColorSpaceRef)colorSpace;

/** Draws a linear gradient from start point to end point.  The option flags control whether the gradient draws itself before the start point, or after the end point.  The gradient is drawn in the current graphics context without performing any additinal clipping.  This is the primitive method for drawing a linear gradient. */
- (void)drawFromPoint:(CGPoint)startingPoint toPoint:(CGPoint)endingPoint options:(CGGradientDrawingOptions)options;

/** This convenience method draws a linear gradient inside the specified rectangle. The gradient is drawn so that the start and end colors are guaranteed to be visible in opposite corners of the rectangle. The angle of rotation determines which corner contains the start color. The gradient’s color transitions occur along the line formed by the angle of rotation. For example, a rotation of 0 degrees results in colors changing from left-to-right across the rectangle, while a rotation of 90 degrees results in the start color gradating from the top vertically to the end color at the bottom. */
- (void)drawInRect:(CGRect)rect angle:(CGFloat)angle;

/** Convenience method for drawing a linear gradient to fill a specified path.  The gradient is drawn so that the start and end colors are guaranteed to be visible in opposite corners of the rectangle. The angle of rotation determines which corner contains the start color. The gradient’s color transitions occur along the line formed by the angle of rotation. For example, a rotation of 0 degrees results in colors changing from left-to-right across the rectangle, while a rotation of 90 degrees results in the start color gradating from the top vertically to the end color at the bottom. */
- (void)drawInBezierPath:(UIBezierPath *)path angle:(CGFloat)angle;

/** Draws a radial gradient between two circles defined by the center point and radius of each circle.  The option flags control whether the gradient draws itself before the start point, or after the end point.  The gradient is drawn in the current graphics context without performing any additinal clipping.  This is the primitive method for drawing a radial gradient. */
- (void)drawFromCenter:(CGPoint)startCenter radius:(CGFloat)startRadius toCenter:(CGPoint)endCenter radius:(CGFloat)endRadius options:(CGGradientDrawingOptions)options;

/** Convenience method for drawing a radial gradient to fill a rect.  Draws a radial gradient clipped by the provided rect.  The starting circle is always a single point located at the center of the ending circle which encloses the drawn rect.  The radius of the ending circle is determined by the relative center position.
 
 The relative center position proportionally adjusts the center location of the radial gradient.  It maps the four corners of the rectangle to (-1.0, -1.0), (1.0, -1.0), (1.0, 1.0) and (-1.0, 1.0), with (0.0, 0.0) in the center of the rectangle.  Use NSZeroPoint to center the radial gradient in the rect.  The radius of the ending circle is the distance from the relative center to the opposite corner of the rect. */
- (void)drawInRect:(CGRect)rect relativeCenterPosition:(CGPoint)relativeCenterPosition;

/** Convenience method for drawing a radial gradient to fill a path.  Draws a radial gradient clipped by the provided path.  The starting circle is always a single point located at the center of the ending circle which encloses the drawn path.  The radius of the ending circle is determined by the relative center position.
 
 The relative center position proportionally adjusts the center location of the radial gradient.  It maps the four corners of the path bounding rect to (-1.0, -1.0), (1.0, -1.0), (1.0, 1.0) and (-1.0, 1.0), with (0.0, 0.0) in the center of path bounding rect.  Use NSZeroPoint to center the radial gradient in the path bounding rect.  The radius of the ending circle is the distance from the relative center to the opposite corner of the path bounding rect. */
- (void)drawInBezierPath:(UIBezierPath *)path relativeCenterPosition:(CGPoint)relativeCenterPosition;

/** Returns the color and location at a particular index in the color gradient */
- (void)getColor:(UIColor **)color location:(CGFloat *)location atIndex:(NSInteger)index;

/** This method will return a color for the interpolated gradient value at the given location.  For example, in a two color gradient with white at location 0.0 and black at location 1.0, the interpolated color at location 0.5 would be 50% gray. */
- (UIColor *)interpolatedColorAtLocation:(CGFloat)location;

/** The number of color stops in the color gradient. */
@property (nonatomic, readonly) NSInteger numberOfColorStops;

- (CGColorSpaceRef)colorSpace;

@end

#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)

#import <AppKit/AppKit.h>

@compatibility_alias AZGradient NSGradient;

#endif

typedef enum _AZGradientDirection {
	AZGradientDirectionVertical,
	AZGradientDirectionHorizontal
} AZGradientDirection;

@interface AZGradient (AZGradientFeatures)

- (id)gradientByReversingGradient;

- (void)drawInRect:(CGRect)rect direction:(AZGradientDirection)direction;
- (void)drawInBezierPath:(id)path direction:(AZGradientDirection)direction;

@end