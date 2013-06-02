//
//  AZCellTableViewControllerDemo.m
//  AZAppearanceKitDemo
//
//  Created by Zachary Waldowski on 10/26/12.
//  Copyright (c) 2012-2013 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import "AZCellTableViewControllerDemo.h"
#import "AZTableViewCell.h"

@implementation AZCellTableViewControllerDemo

// It's Jony Ive approved
#define AZTableViewAluminiumColor() [UIColor colorWithHue:.625 saturation:.04 brightness:.85 alpha:1]

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.tableView.backgroundView = [UIView new];
	self.tableView.backgroundView.backgroundColor = AZTableViewAluminiumColor();
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// the "super" here is the storyboard
	AZTableViewCell *cell = (AZTableViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];

	cell.tableViewBackgroundColor = AZTableViewAluminiumColor();

	return cell;
}

@end
