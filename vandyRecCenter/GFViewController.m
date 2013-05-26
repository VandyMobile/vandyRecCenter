//
//  GFViewController.m
//  vandyRecCenter
//
//  Created by Brendan McNamara on 5/26/13.
//  Copyright (c) 2013 Brendan McNamara. All rights reserved.
//

#import "GFViewController.h"

@interface GFViewController ()

@end

@implementation GFViewController
@synthesize model = _model;

#pragma mark - getters

- (GFModel*) model {
    if (_model == nil) {
        _model = [[GFModel alloc] init];
    }
    return _model;
}

#pragma mark - initializers
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.model loadData:^(NSError *error, NSArray *data) {
       // NSLog(@"%@", data);
    
    } forMonth: 4 andYear: 2013];
    TimeString *time = [[TimeString alloc] initWithTimeString: @"13:37"];
    NSLog(@"%i, %i, %i", time.hours, time.minutes, time.isAM);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
