//
//  AZShadowedTableDemoViewController.m
//  AZAppearanceKitDemo
//
//  Created by Zachary Waldowski on 6/27/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import "AZShadowedTableDemoViewController.h"
#import "AZShadowedTableView.h"

@interface AZShadowedTableDemoViewController ()

@end

@implementation AZShadowedTableDemoViewController
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"Shadowed Table", @"Shadowed Table");
		self.tabBarItem.image = [UIImage imageNamed:@"AZShadowedTableDemoViewController"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.tableView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
		cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
	
	cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = @"Text";
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    return cell;
}

@end
