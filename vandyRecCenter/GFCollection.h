//
//  GFCollection.h
//  vandyRecCenter
//
//  Created by Brendan McNamara on 5/26/13.
//  Copyright (c) 2013 Brendan McNamara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GFModel.h"
@interface GFCollection : NSObject

@property (nonatomic, strong) NSArray* models;


- (id) init;

//loads the collection with a single element
//in the model array that represents the current date
- (void) loadCurrentMonth: (void(^)(NSError*error, GFModel* currentModel)) block;

- (void) loadMonth: (NSUInteger) month andYear: (NSUInteger) year block: (void(^)(NSError* error, NSDictionary* json)) block;


- (BOOL) dataLoadedForYear: (NSUInteger) year month: (NSUInteger) month;

//gets the classes for the current day
//if the GFClasses for the the day have not
//loaded, they are loaded before calling the block
- (void) GFClassesForCurrentDay: (void (^)(NSError* error, NSArray* GFClasses)) block;
- (void) GFClassesForYear: (NSUInteger) year month: (NSUInteger) month day: (NSUInteger) day block: (void (^)(NSError* error, NSArray* GFClasses)) block;

- (void) GFModelForCurrentMonth: (void (^)(NSError* error, GFModel *model)) block;
- (void) GFModelForYear: (NSUInteger) year month: (NSUInteger) month block: (void (^)(NSError *error, GFModel* model)) block;


@end