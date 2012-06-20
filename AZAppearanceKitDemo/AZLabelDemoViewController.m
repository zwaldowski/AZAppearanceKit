//
//  AZLabelDemoViewController
//  AZAppearanceKitDemo
//
//  Created by Zachary Waldowski on 6/19/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import "AZLabelDemoViewController.h"

@interface AZLabelDemoViewController ()

@end

@implementation AZLabelDemoViewController

@synthesize label, label2;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"Label", @"Label");
		self.tabBarItem.image = [UIImage imageNamed:@"AZLabelDemoViewController"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.label setShadowOffset: CGSizeMake(0, 1) blur: 0 color: [[UIColor whiteColor] colorWithAlphaComponent:0.75] forState: UIControlStateNormal];
	[self.label setInnerShadowOffset: CGSizeMake(0, 1) blur: 2.0f color: [[UIColor blackColor] colorWithAlphaComponent:0.5] forState: UIControlStateNormal];
	AZGradient *label1Gradient = [[AZGradient alloc] initWithColors: @[[UIColor colorWithRed:0.33 green:0.38 blue:0.47 alpha:1.0], [UIColor colorWithRed:0.41 green:0.47 blue:0.59 alpha:1.0]]];
	[self.label setGradient: label1Gradient direction: AZGradientDirectionVertical forState: UIControlStateNormal];
	
	[self.label2 setShadowOffset: CGSizeMake(0, 1) blur: 0 color: [[UIColor whiteColor] colorWithAlphaComponent:0.75] forState: UIControlStateNormal];
	[self.label2 setInnerShadowOffset: CGSizeMake(0, 1) blur: 2.0f color: [[UIColor blackColor] colorWithAlphaComponent:0.5] forState: UIControlStateNormal];
	AZGradient *label2Gradient = [[AZGradient alloc] initWithColors: @[[UIColor colorWithRed:0.33 green:0.38 blue:0.47 alpha:1.0], [UIColor colorWithRed:0.41 green:0.47 blue:0.59 alpha:1.0]]];
	[self.label2 setGradient: label2Gradient direction: AZGradientDirectionVertical forState: UIControlStateNormal];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
