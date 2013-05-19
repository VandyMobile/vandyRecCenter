//
//  homeViewController.h
//  vandyRecCenter
//
//  Created by Brendan McNamara on 3/25/13.
//  Copyright (c) 2013 Brendan McNamara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIColor-BMColors.h"

@interface homeViewController : UIViewController <UIScrollViewDelegate>

#define DIMENSIONS_OF_PAGE_PORTRAIT 220
#define DIMENSIONS_OF_PAGE_LANDSCAPE 180
#define LABEL_DIMENSIONS_PORTRAIT 190
#define LABEL_DIMENSIONS_LANDSCAPE 130

@property (nonatomic, weak) IBOutlet UIScrollView* scrollView;

@property (nonatomic, weak) IBOutlet UIButton *leftScroller;
@property (nonatomic, weak) IBOutlet UIButton *rightScroller;

- (IBAction) scrollLeft;
- (IBAction) scrollRight;

@end
