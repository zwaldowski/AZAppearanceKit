//
//  AZGradientDemoViewController.h
//  AZAppearanceKitDemo
//
//  Created by Zachary Waldowski on 6/29/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

@class AZGradientView;

@interface AZGradientDemoViewController : UIViewController

@property (weak, nonatomic) IBOutlet AZGradientView *gradientView;

- (IBAction)animationsSwitchChanged:(id)sender;

- (IBAction)changeGradient:(id)sender;
- (IBAction)changeGradientType:(id)sender;
- (IBAction)changeAngle:(id)sender;
- (IBAction)changeCenter:(id)sender;

@end
