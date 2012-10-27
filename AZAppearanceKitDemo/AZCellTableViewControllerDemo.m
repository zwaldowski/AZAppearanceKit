//
//  AZCellTableViewControllerDemo.m
//  AZAppearanceKitDemo
//
//  Created by Zachary Waldowski on 10/26/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import "AZCellTableViewControllerDemo.h"

@implementation AZCellTableViewControllerDemo

- (void)viewDidLoad
{
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	
}

@end
