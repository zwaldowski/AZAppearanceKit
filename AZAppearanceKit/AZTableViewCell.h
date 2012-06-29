//
//  AZTableViewCell.h
//  AZAppearanceKit
//
//  Created by Victor Pena Placer on 2/28/12.
//  Copyright (c) 2012 Victor Pena Placer. All rights reserver.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AZGradient;

/** `AZTableViewCell` is a subclass of `UITableViewCell`, and is
 compatible with any `UITableView`.
 
 `AZTableViewCell` adds a set of customizations such as corner radius, 
 shadow, background gradient, and selection gradient.
 
 ### Using it
 
 In your `dataSource`'s `-tableView:cellForRowAtIndexPath:`, change all
 references to `UITableViewCell` to `AZTableViewCell`.
 
 ### Customizing appearance
 
 Cells are compatible with both grouped and plain tables, though they
 generally look better in grouped tables.
 
 #### Grouped tables
 
 You can change the cell's appearance as follows:
 
 - cell's drop shadow color (border will be disabled when set).
 - cell's background color or gradient.
 - cell's border color (ignored when the shadow color is set).
 - cell's corner radius.
 - cell's separator color.
 - cell's selection gradient.
 
 #### Plain tables
 
 You can change the cell's appearance as follows:
 
 - cell's background color or gradient.
 - cell's separator.
 - cell's selection gradient. 
 */
@interface AZTableViewCell : UITableViewCell


/** @name Customizing appearance */

/** Specifies the color used for the table view cell.
 
 At this time, the cell is drawn with a shadow blur of 3
 points and an offset of 1 vertical point. The color can
 be used to customize the hue and opacity of the shadow.
 
 */
@property (nonatomic, strong) UIColor *shadowColor;

/** Specifies the gradient used when the cell is not selected.
 
 By default, this is `nil`, yielding a white background.
 
 */
@property (nonatomic, strong) AZGradient *gradient;

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

/** Holds a reference to a custom view inside the cell.
 
 The custom view is layed out above the background view,
 but *not inside the content view*. Its frame will match
 the size of the cell with all shadow insets applied. It
 is also masked to the cell's shape.
 
 */
@property (nonatomic, strong) UIView *customView;

/** Returns the needed height for a cell placed in the given index path.
 
 You should always implement `tableView:heightForRowAtIndexPath:` method of 
 your tableView's delegate. Inside get your cell's normal height, add the 
 result of calling `tableView:neededHeightForIndexPath:` and return the resulting
 value.
 
 */
+ (CGFloat) tableView:(UITableView *)tableView neededHeightForIndexPath:(NSIndexPath *)indexPath;

@end
