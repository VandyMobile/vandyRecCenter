//
//  DateHelper.h
//  vandyRecCenter
//
//  Created by Brendan McNamara on 5/29/13.
//  Copyright (c) 2013 Brendan McNamara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateHelper : NSObject

+ (NSString*) monthNameForIndex: (NSUInteger) index;
+ (NSString*) weekDayForIndex: (NSUInteger) index;
+ (NSString*) weekDayAbbreviationForIndex: (NSUInteger) index;

+ (NSUInteger) daysForMonth: (NSUInteger) month year: (NSUInteger) year;
@end