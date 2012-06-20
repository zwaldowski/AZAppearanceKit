//
//  AZAppDelegate.h
//  AZAppearanceKitDemo
//
//  Created by Zachary Waldowski on 6/19/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AZAppearanceKitDemoAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@end
