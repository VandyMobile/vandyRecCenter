//
//  DayButton.h
//  vandyRecCenter
//
//  Created by Brendan McNamara on 5/27/13.
//  Copyright (c) 2013 Brendan McNamara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "UIColor-BMColors.h"
#import "NSDate-MyDateClass.h"
#import "NSDate-WeekDateClass.h"
@interface DayButton : UIControl

#define DEFAULT_HEIGHT 100
#define DEFAULT_WIDTH 75

#define DEFAULT_DAY_WIDTH 65
#define DEFAULT_DAY_HEIGHT 85
#define DEFAULT_DAY_PADDING 10



@property (nonatomic) CGFloat dayWidth;
@property (nonatomic) CGFloat dayHeight;
@property (nonatomic) CGFloat dayPadding;

@property (nonatomic, strong) NSDate* date;
@property (nonatomic) NSUInteger day;
@property (nonatomic) NSUInteger month;
@property (nonatomic) NSUInteger year;


@property (nonatomic, strong) UIView* dayView;
@property (nonatomic, strong) UILabel* weekDayLabel;
@property (nonatomic, strong) UILabel* dayLabel;
- (id) initWithDate: (NSDate*) date andPadding: (CGFloat) padding;
@end
