//
//  AZBarDemoViewController.h
//  AZAppearanceKitDemo
//
//  Created by Zachary Waldowski on 7/16/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

@class AZNavigationBar, AZTabBar, AZToolbar;

@interface AZBarDemoViewController : UIViewController

@property (weak, nonatomic) IBOutlet AZNavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet AZTabBar *tabBar;
@property (weak, nonatomic) IBOutlet AZToolbar *toolbar;

@end
