//
//  AZGradientDemoViewController.m
//  AZAppearanceKitDemo
//
//  Created by Zachary Waldowski on 6/29/12.
//  Copyright (c) 2012 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import "AZGradientDemoViewController.h"
#import "AZGradientView.h"

@interface AZGradientDemoViewController () {
	NSMutableArray *_gradients;
}

@property (nonatomic) BOOL animationEnabled;

@end

@implementation AZGradientDemoViewController
@synthesize gradientView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"Gradient", @"Gradient");
		self.tabBarItem.image = [UIImage imageNamed:@"AZGradientDemoViewController"];
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
    [self changeGradient: nil];
	[self changeGradientType: nil];
	[self changeAngle: nil];
	[self changeCenter: nil];
}

- (IBAction)animationsSwitchChanged:(UISwitch *)sender {
	self.animationEnabled = sender.on;
}

- (IBAction)changeGradient:(id)sender {
	if (!_gradients) {
		_gradients = [NSMutableArray arrayWithCapacity: 5];
		[_gradients addObject: [[AZGradient alloc] initWithStartingColor: [UIColor blueColor] endingColor: [UIColor yellowColor]]];
		[_gradients addObject: [[AZGradient alloc] initWithStartingColor: [UIColor redColor] endingColor: [UIColor purpleColor]]];
		[_gradients addObject: [[AZGradient alloc] initWithStartingColor: [UIColor whiteColor] endingColor: [UIColor blackColor]]];
		[_gradients addObject: [[AZGradient alloc] initWithStartingColor: [UIColor orangeColor] endingColor: [UIColor brownColor]]];
		[_gradients addObject: [[AZGradient alloc] initWithStartingColor: [UIColor darkGrayColor] endingColor: [UIColor lightGrayColor]]];
	}
	AZGradient *gradient = [_gradients objectAtIndex: (rand() % _gradients.count)];
	[self.gradientView setGradient: gradient animated: self.animationEnabled];
}

- (IBAction)changeGradientType:(id)sender {
	AZGradientViewType type = (rand() % 2) ? AZGradientDirectionVertical : AZGradientDirectionHorizontal;
	[self.gradientView setType: type animated: self.animationEnabled];
}

- (IBAction)changeAngle:(id)sender {
	CGFloat angle = (CGFloat)(rand() % 360);
	[self.gradientView setAngle: angle animated: self.animationEnabled];
}

- (IBAction)changeCenter:(id)sender {
	CGPoint point;
	point.x = ((CGFloat)(rand() % 100) / 100);
	point.y = ((CGFloat)(rand() % 100) / 100);
	if (rand() % 2)
		point.x *= -1;
	if (rand() % 2)
		point.y *= -1;
	[self.gradientView setRelativeCenterPosition: point animated: self.animationEnabled];
}

@end
