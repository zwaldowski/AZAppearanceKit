//
//  AZShadowedTableDemoViewController.h
//  AZAppearanceKitDemo
//
//  Created by Zachary Waldowski on 6/27/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AZShadowedTableView;

@interface AZShadowedTableDemoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet AZShadowedTableView *tableView;

@end
