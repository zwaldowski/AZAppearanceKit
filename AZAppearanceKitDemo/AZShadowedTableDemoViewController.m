//
//  AZShadowedTableDemoViewController.m
//  AZAppearanceKitDemo
//
//  Created by Zachary Waldowski on 6/27/12.
//  Copyright (c) 2012-2013 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import "AZShadowedTableDemoViewController.h"
#import "AZShadowedTableView.h"

@implementation AZShadowedTableDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	UIView *view = [UIView new];
	view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
	self.tableView.backgroundView = view;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"MainCell"];
	
    cell.textLabel.text = [NSString stringWithFormat:@"Cell %i", indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.backgroundColor = [UIColor whiteColor];
}

- (IBAction)switchToggled:(id)sender {
	[(AZShadowedTableView *)self.tableView setHidesShadows: ![sender isOn] animated: YES];
}

@end
