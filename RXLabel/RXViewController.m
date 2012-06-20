//
//  RXViewController.m
//  RXLabel
//
//  Created by Zachary Waldowski on 3/17/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "RXViewController.h"

@implementation RXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.label setShadowOffset: CGSizeMake(0, 1) blur: 0 color: [[UIColor whiteColor] colorWithAlphaComponent:0.75] forState: UIControlStateNormal];
	[self.label setInnerShadowOffset: CGSizeMake(0, 1) blur: 2.0f color: [[UIColor blackColor] colorWithAlphaComponent:0.5] forState: UIControlStateNormal];
	RXGradient *label1Gradient = [[RXGradient alloc] initWithColors: @[[UIColor colorWithRed:0.33 green:0.38 blue:0.47 alpha:1.0], [UIColor colorWithRed:0.41 green:0.47 blue:0.59 alpha:1.0]]];
	[self.label setGradient: label1Gradient direction: RXGradientDirectionVertical forState: UIControlStateNormal];
	
	[self.label2 setShadowOffset: CGSizeMake(0, 1) blur: 0 color: [[UIColor whiteColor] colorWithAlphaComponent:0.75] forState: UIControlStateNormal];
	[self.label2 setInnerShadowOffset: CGSizeMake(0, 1) blur: 2.0f color: [[UIColor blackColor] colorWithAlphaComponent:0.5] forState: UIControlStateNormal];
	RXGradient *label2Gradient = [[RXGradient alloc] initWithColors: @[[UIColor colorWithRed:0.33 green:0.38 blue:0.47 alpha:1.0], [UIColor colorWithRed:0.41 green:0.47 blue:0.59 alpha:1.0]]];
	[self.label2 setGradient: label2Gradient direction: RXGradientDirectionVertical forState: UIControlStateNormal];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
