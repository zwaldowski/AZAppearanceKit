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
	
	self.label.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
	self.label.shadowOffset = CGSizeMake(0, 1);
	self.label.shadowBlur = 0.0f;
	
	self.label.innerShadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
	self.label.innerShadowOffset = CGSizeMake(0, 1);
	self.label.innerShadowBlur = 2.0f;
	
	self.label.gradientColors = @[[UIColor colorWithRed:0.33 green:0.38 blue:0.47 alpha:1.0],
	[UIColor colorWithRed:0.41 green:0.47 blue:0.59 alpha:1.0]];
	self.label.gradientDirection = RXLabelGradientDirectionVerical;
	
	self.label2.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
	self.label2.shadowOffset = CGSizeMake(0, 1);
	self.label2.shadowBlur = 0.0f;
	
	self.label2.innerShadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
	self.label2.innerShadowOffset = CGSizeMake(0, 1);
	self.label2.innerShadowBlur = 2.0f;
	
	self.label2.gradientColors = @[[UIColor colorWithRed:0.33 green:0.38 blue:0.47 alpha:1.0],
	[UIColor colorWithRed:0.41 green:0.47 blue:0.59 alpha:1.0]];
	self.label2.gradientDirection = RXLabelGradientDirectionVerical;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewDidUnload {
	[self setLabel:nil];
	[self setLabel2:nil];
	[super viewDidUnload];
}

@end
