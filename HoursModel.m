//
//  HoursModel.m
//  vandyRecCenter
//
//  Created by Brendan McNamara on 4/14/13.
//  Copyright (c) 2013 Brendan McNamara. All rights reserved.
//


#import "HoursModel.h"

@interface HoursModel()

@property (nonatomic, strong) NSArray* allHours;

@end
@implementation HoursModel

@synthesize allHours = _allHours;


#pragma mark - Getters and Setters

- (id) initWithPathToPList:(NSString *)path {
    
    self = [super init];
    if (self) {
        self.allHours = [[NSArray alloc] initWithContentsOfFile: path];
        
        //make selected hours the current hours
        
    }
    return self;
    
}

- (NSDictionary*) hoursWithTitle:(NSString *)title {
    NSEnumerator* hoursEnum = [self.allHours objectEnumerator];
    NSDictionary* nextHours;
    while (nextHours = [hoursEnum nextObject]) {
        if ([[nextHours objectForKey: @"title"] isEqualToString: title]) {
            return nextHours;
        }
    }
    return nil;
}


- (NSArray*) closedHours {
    NSArray *closeHours = [[NSArray alloc] init];
    NSEnumerator *enumerateHours = [self.allHours objectEnumerator];
    
    NSDictionary* nextHours;
    while (nextHours = [enumerateHours nextObject]) {
        
        if ([[nextHours objectForKey: @"closed"] boolValue]) {
            closeHours = [closeHours arrayByAddingObject: nextHours];
        }
    }
    return closeHours;
    
}

- (NSArray*) openHours {
    NSArray *openHours = [[NSArray alloc] init];
    NSEnumerator *enumerateHours = [self.allHours objectEnumerator];
    
    NSDictionary* nextHours;
    while (nextHours = [enumerateHours nextObject]) {
        
        if (![[nextHours objectForKey: @"closed"] boolValue]) {
            openHours = [openHours arrayByAddingObject: nextHours];
        }
    }
    return openHours;
}

- (NSArray*) mainHours {
    
    NSArray *mainHours = [[NSArray alloc] init];
    NSEnumerator *enumerateHours = [self.allHours objectEnumerator];
    
    NSDictionary* nextHours;
    while (nextHours = [enumerateHours nextObject]) {
        
        if (![[nextHours objectForKey: @"closed"] boolValue] && [[nextHours objectForKey:@"mainHours"] boolValue]) {
            mainHours = [mainHours arrayByAddingObject: nextHours];
        }
    }
    return mainHours;
}

- (NSArray*) otherHours {
    
    NSArray *mainHours = [[NSArray alloc] init];
    NSEnumerator *enumerateHours = [self.allHours objectEnumerator];
    
    NSDictionary* nextHours;
    while (nextHours = [enumerateHours nextObject]) {
        
        if (![[nextHours objectForKey: @"closed"] boolValue] && ![[nextHours objectForKey:@"mainHours"] boolValue]) {
            mainHours = [mainHours arrayByAddingObject: nextHours];
        }
    }
    return mainHours;
}



#pragma mark- Initializers

- (id) init {
    self = [self initWithPathToPList:nil];
    return self;
}

#pragma mark - Current Time

- (NSDictionary*) hoursForCurrentTime {
    
    NSEnumerator *hoursEnum = [self.allHours objectEnumerator];
    NSDictionary* nextHours;
    NSDictionary* currentHours;
    nextHours = [hoursEnum nextObject];
    
    NSDate *currentDate = [[NSDate alloc] init];
    while (nextHours = [hoursEnum nextObject]) {
        if (![[nextHours objectForKey: @"closed"] boolValue]) {
            
            if ([[nextHours objectForKey: @"facilityHours"] boolValue]) {
                if ([currentDate compare: [nextHours objectForKey: @"beginningDate"]] == NSOrderedDescending && [currentDate compare: [nextHours objectForKey: @"endDate"]] == NSOrderedAscending) {
                    currentHours = nextHours;
                    return currentHours;
                }
            }
        } else if ([currentDate compare: [nextHours objectForKey: @"beginningDate"]] == NSOrderedDescending && [currentDate compare: [nextHours objectForKey: @"endDate"]] == NSOrderedAscending) {
            currentHours = nextHours;
            return currentHours;
        }
        
    }
    
    return  currentHours;
}


- (NSString*) openingTime {
    NSArray* arrayOfHours = [[self hoursForCurrentTime] objectForKey: @"hours"];
    NSString* hours = [arrayOfHours objectAtIndex: [NSDate weekDayForTimeZone: [NSTimeZone timeZoneWithName: NASHVILLE_TIMEZONE]]];
    //get the string up until the space
    for (size_t i = 0; i < [hours length]; ++i) {
        if ([hours characterAtIndex: i] == ' ') {
            return [hours substringWithRange: NSMakeRange(0, i)];
        }
    }
    return nil;
}

- (NSString*) closingTime {
    NSArray* arrayOfHours = [[self hoursForCurrentTime] objectForKey: @"hours"];
    NSString* hours = [arrayOfHours objectAtIndex: [NSDate weekDayForTimeZone: [NSTimeZone timeZoneWithName: NASHVILLE_TIMEZONE]]];
    //get the string up until the space
    for (size_t i = 0; i < [hours length]; ++i) {
        if ([hours characterAtIndex: i] == '-') {
            return [hours substringWithRange: NSMakeRange(i+2, [hours length] - (i+2))];
        }
    }
    return nil;
}


- (BOOL) isOpen {
    
    NSDate *currentDate = [[NSDate alloc] init];
    
    NSDateFormatter *getTimeFormat = [[NSDateFormatter alloc] init];
    getTimeFormat.timeStyle = NSDateFormatterShortStyle;
    getTimeFormat.dateStyle = NSDateFormatterNoStyle;
    //set time to Nashville time
    getTimeFormat.timeZone = [NSTimeZone timeZoneWithName: NASHVILLE_TIMEZONE];
    
    
    //if the current time is after the opening time
    TimeString* opening = [[TimeString alloc] initWithString: [self openingTime]];
    TimeString* current = [[TimeString alloc] initWithString: [getTimeFormat stringFromDate: currentDate]];
    TimeString* closing = [[TimeString alloc] initWithString: [self closingTime]];

    if ([TimeString compareTimeString1: opening timeString2: current] == NSOrderedAscending || [TimeString compareTimeString1: opening timeString2: current] == NSOrderedSame) {
        TimeString* twelve = [[TimeString alloc] initWithString: @"12:00AM"];
        if ([TimeString compareTimeString1: twelve timeString2: closing] == NSOrderedSame) {
            return YES;
        } else if ([TimeString compareTimeString1: closing timeString2: current] == NSOrderedDescending) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) willOpenLaterToday {
    NSDate *currentDate = [[NSDate alloc] init];
    
    NSDateFormatter *getTimeFormat = [[NSDateFormatter alloc] init];
    getTimeFormat.timeStyle = NSDateFormatterShortStyle;
    getTimeFormat.dateStyle = NSDateFormatterNoStyle;
    //set time to Nashville time
    getTimeFormat.timeZone = [NSTimeZone timeZoneWithName: NASHVILLE_TIMEZONE];
    
    TimeString* current = [[TimeString alloc] initWithString:[getTimeFormat stringFromDate: currentDate]];
    TimeString* opening = [[TimeString alloc] initWithString: [self openingTime]];
    if ([self openingTime] && [TimeString compareTimeString1: opening timeString2: current] == NSOrderedDescending) {
        
        return YES;
    }
    return NO;
}

- (BOOL) wasOpenEarlierToday {
    NSDate *currentDate = [[NSDate alloc] init];
    
    NSDateFormatter *getTimeFormat = [[NSDateFormatter alloc] init];
    getTimeFormat.timeStyle = NSDateFormatterShortStyle;
    getTimeFormat.dateStyle = NSDateFormatterNoStyle;
    //set time to Nashville time
    getTimeFormat.timeZone = [NSTimeZone timeZoneWithName: NASHVILLE_TIMEZONE];
   
    TimeString* twelve = [[TimeString alloc] initWithString: @"12:00AM"];
    TimeString* closing = [[TimeString alloc] initWithString: [self closingTime]];
    TimeString* current = [[TimeString alloc] initWithString: [getTimeFormat stringFromDate: currentDate]];
    if ([self closingTime]) {
        if ([TimeString compareTimeString1: twelve timeString2: closing] == NSOrderedSame) {
            return NO;
        } else if ([TimeString compareTimeString1:closing timeString2: current] == NSOrderedAscending) {
            return YES;
        }
    }
    return NO;
    
}


- (NSTimeInterval) timeUntilClosed {
    
    if ([self isOpen]) {
        
        
        NSDate *currentDate = [NSDate dateByAddingTimeCurrentTime: [[NSTimeZone timeZoneWithName:NASHVILLE_TIMEZONE] secondsFromGMT]]; //adjust to nashville time
        NSDate *closingDate = [currentDate dateBySettingTimeToTime: [self closingTime]];
        TimeString* closing = [[TimeString alloc] initWithString: [self closingTime]];
        TimeString* twelve = [[TimeString alloc] initWithString: @"12:00AM"];
        if ([TimeString compareTimeString1: twelve timeString2: closing] == NSOrderedSame) {
            closingDate = [closingDate dateByAddingTimeInterval: 24*60*60];
        }
        return [closingDate timeIntervalSinceDate: currentDate];
    }
    return 0;
}

- (NSTimeInterval) timeUntilOpen {
    if ([self willOpenLaterToday]) {
        
        
       NSDate *currentDate = [NSDate dateByAddingTimeCurrentTime: [[NSTimeZone timeZoneWithName:NASHVILLE_TIMEZONE] secondsFromGMT]]; //adjust to nashville time
        NSDate *openingDate = [currentDate dateBySettingTimeToTime: [self openingTime]];
        return [openingDate timeIntervalSinceDate: currentDate];
    }
    return 0;
}



@end
