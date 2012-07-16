//
//  AZBarDemoViewController.m
//  AZAppearanceKitDemo
//
//  Created by Zachary Waldowski on 7/16/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import "AZBarDemoViewController.h"

@implementation AZBarDemoViewController

@synthesize navigationBar, tabBar, toolbar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"Bars", @"Bars");
		self.tabBarItem.image = [UIImage imageNamed:@"AZBarDemoViewController"];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

@end
