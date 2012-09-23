//
//  AZShadowedTableView.h
//  AZAppearanceKit
//
//  Created by Matt Gallagher on 8/21/09.
//  Copyright (c) 2009 Matt Gallagher. All rights reserved.
//  Copyright (c) 2011-2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

/** `AZShadowedTableView` is a drop-in subclass of `UITableView`.
 It draws four shadows into the table: two at the top and bottom
 of the entire frame, and two above the first and last cells.
 
 `AZShadowedTableView` is intended only for use with the plain table
 view style, and will raise an exception if attempted otherwise.
 
 `AZShadowedTableView` has no customization properties at this time.
 */
@interface AZShadowedTableView : UITableView

@property (nonatomic) BOOL hidesShadows;
- (void)setHidesShadows:(BOOL)hidesShadows animated:(BOOL)animated;

@end
