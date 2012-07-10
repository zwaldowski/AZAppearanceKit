//
//  AZTableViewCellDemoViewController.m
//  AZAppearanceKitDemo
//
//  Created by Zachary Waldowski on 6/29/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import "AZTableViewCellDemoViewController.h"
#import "AZTableViewCell.h"

@interface AZTableViewCellDemoViewController ()

@end

@implementation AZTableViewCellDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"Table Cells", @"Table Cells");
		self.tabBarItem.image = [UIImage imageNamed:@"AZTableViewCellDemoViewController"];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return 6;
	} else if (section == 1) {
		return 1;
	} else if (section == 2) {
		return 10;
	}
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DecoratedCell";
    AZTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[AZTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = @"Text";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
