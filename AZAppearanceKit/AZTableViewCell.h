//
//  AZTableViewCell.h
//  AZAppearanceKit
//
//  Created by Victor Pena Placer on 2/28/12.
//  Copyright (c) 2012 Victor Pena Placer. All rights reserved.
//  Copyright (c) 2012-2013 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AZShadow.h"

@class AZGradient;

/** `AZTableViewCell` is a subclass of `UITableViewCell`, and is
 compatible with any `UITableView`.

 `AZTableViewCell` adds a set of customizations such as corner radius,
 shadow, background gradient, and selection gradient.

 ### Using it

 In your `dataSource`'s `-tableView:cellForRowAtIndexPath:`, change all
 references to `UITableViewCell` to `AZTableViewCell`.

 #### Performance considerations

 One tip that will get you very far with iOS graphics programming:
 alpha blending is slow. If you intend for a cell to have a shadow,
 *set the background color*. The resulting cell will be opaque, and
 composite onto screen extremely quickly.

 Normally, this also implies that the table view and cells must use
 the same solid background color - hey, it's flat UI design! However,
 the `UIColor` pattern system and pattern phase might still allow
 textured backgrounds.

 ### Customizing appearance

 Cells are compatible with both grouped and plain tables, though they
 generally look better in grouped tables.

 #### Grouped tables

 You can change the cell's appearance as follows:

 - cell's drop shadow color (border will be disabled when set).
 - cell's opaque background color (for when a shadow is used).
 - cell's fill color (using `backgroundColor`) or gradient.
 - cell's border color (ignored when the shadow color is set).
 - cell's corner radius.
 - cell's separator color.
 - cell's selection gradient.

 #### Plain tables

 You can change the cell's appearance as follows:

 - cell's fill color (using `backgroundColor`) or gradient.
 - cell's separator.
 - cell's selection gradient.
 */
@interface AZTableViewCell : UITableViewCell <UIAppearance>

/** @name Customizing appearance */

/** Specifies the shadow used to draw a shadow for the table view cell.

 By default, this is a shadow with a vertical offset of 1 point, a black color
 with an alpha of 0.7, and a blur radius of 3 points.

 */
@property (nonatomic, strong) id <AZShadow> shadow;

/** Specifies the gradient used when the cell is not selected.

 By default, this is `nil`, yielding a white background.

 */
@property (nonatomic, strong) AZGradient *gradient;

/** Specifies the color for the shadowed extremities of the cell.
 This should match the background color of the table view the
 cell is contained in.

 By default, this is `nil`, leading to reduced table view performance.

 This property is ignored when no shadow is set;

 */
@property (nonatomic, strong) UIColor *tableViewBackgroundColor;

/** Specifies the gradient used when the cell is selected.

 By default, this is made up of blue tones.

 */
@property (nonatomic, strong) AZGradient *selectionGradient;

/** Specifies the color used for the cell's border.

 If shadowColor has a value, borderColor will be ignored.

 This property has a gray color by default.

 */
@property (nonatomic, strong) UIColor *borderColor;

/** Specifies the radius used for the cell's corners.

 By default it is set to 8.

 */
@property (nonatomic, assign) float cornerRadius;

/** Specifies the color used for the cell's separator line.

 This property has a light gray color by default.

 */
@property (nonatomic, strong) UIColor *separatorColor;

/** In a regular table view cell, this is a subview behind all other
 views. It is unavailable for use with `AZTableViewCell`. */
@property (nonatomic, strong) UIView *backgroundView NS_UNAVAILABLE;

/** In a regular table view cell, this is a subview behind all other
 views used when the cell is selected. It is unavailable for use with
 `AZTableViewCell`. */
@property (nonatomic, strong) UIView *selectedBackgroundView NS_UNAVAILABLE;

@end
