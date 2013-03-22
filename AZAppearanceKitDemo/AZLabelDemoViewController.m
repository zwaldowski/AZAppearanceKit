//
//  AZLabelDemoViewController.m
//  AZAppearanceKitDemo
//
//  Created by Zach Waldowski on 3/18/13.
//  Copyright (c) 2013 Alexsander Akers & Zachary Waldowski. All rights reserved.
//

#import "AZLabelDemoViewController.h"
#import "AZLabel.h"

@interface AZLabelDemoViewController ()

@end

@implementation AZLabelDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
    if ([NSParagraphStyle class] && [AZLabel instancesRespondToSelector: @selector(setAttributedText:)]) {
        NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString: @"an attributed label such as to cause lots of frustration"];
        NSRange firstRange = NSMakeRange(0, 3);
        NSRange secondRange = NSMakeRange(3, 10);
        NSRange thirdRange = NSMakeRange(13, as.length-13);
        NSRange wholeRange = NSMakeRange(0, as.length);
        
        AZGradient *gradient = [[AZGradient alloc] initWithStartingColor:[UIColor colorWithRed:0.330 green:0.380 blue:0.470 alpha:1.000] endingColor:[UIColor colorWithRed:0.410 green:0.470 blue:0.590 alpha:1.000]];
        AZGradientDirection direction = AZGradientDirectionVertical;
        NSShadow *innerShadow = [NSShadow shadowWithOffset:CGSizeMake(0, 1) blurRadius:2 color:[UIColor colorWithWhite:0.000 alpha:0.500]];
        NSShadow *shadow = [NSShadow shadowWithOffset:CGSizeMake(0, 1) blurRadius:0 color:[UIColor lightTextColor]];
        
        [as addAttribute:AZLabelGradientForegroundAttributeName value:gradient range:wholeRange];
        [as addAttribute:AZLabelGradientForegroundDirectionAttributeName value:@(direction) range:wholeRange];
        [as addAttribute:AZLabelInnerShadowAttributeName value:innerShadow range:wholeRange];
        [as addAttribute:NSShadowAttributeName value:shadow range:wholeRange];
        
        UIFont *firstFont = [UIFont fontWithName: @"HelveticaNeue" size:17];
        UIFont *secondFont = [UIFont fontWithName: @"HelveticaNeue-Bold" size:25];
        UIFont *thirdFont = [UIFont fontWithName: @"HelveticaNeue-LightItalic" size:14];
        
        [as addAttribute:NSFontAttributeName value:firstFont range:firstRange];
        [as addAttribute:NSFontAttributeName value:secondFont range:secondRange];
        [as addAttribute:NSFontAttributeName value:thirdFont range:thirdRange];
        
        UIColor *color = [UIColor darkTextColor];
        [as addAttribute:NSForegroundColorAttributeName value:color range:wholeRange];
        
        NSMutableParagraphStyle *ps = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        ps.lineBreakMode = NSLineBreakByTruncatingTail;
        
        [as addAttribute:NSParagraphStyleAttributeName value:ps range:wholeRange];
        
        self.attributedLabel.attributedText = as;
    }
#endif
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
