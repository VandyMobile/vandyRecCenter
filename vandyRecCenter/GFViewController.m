//
//  GFViewController.m
//  vandyRecCenter
//
//  Created by Brendan McNamara on 5/26/13.
//  Copyright (c) 2013 Brendan McNamara. All rights reserved.
//

#import "GFViewController.h"
#import "GFCollection.h"
@interface GFViewController ()

//find a better way to remove these
@property (nonatomic, strong) NSArray* cancelViews;
//find a better way to pass these along rather
//than an instance variable
@property (nonatomic, strong) NSDictionary* removalData;
@end

@implementation GFViewController
@synthesize GFTabs = _GFTabs;
@synthesize collection = _collection;
@synthesize GFTableView = _GFTableView;
@synthesize calendarView = _calendarView;
@synthesize cancelViews = _cancelViews;


#pragma mark - getter

- (NSArray*) cancelViews {
    if (_cancelViews == nil) {
        _cancelViews = [[NSArray alloc] init];
    }
    return _cancelViews;
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
    self.calendarView.calendarDelegate = self;
    [self.GFTabs addTarget: self action: @selector(tabChanged:) forControlEvents: UIControlEventValueChanged];
    self.collection = [[GFCollection alloc] init];
    
}

- (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    if (self.GFTableView != nil) {
        [self.GFTableView removeFromSuperview];
    }
    
    if (self.calendarView.hidden) {
        self.GFTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.calendarView.frame.origin.x, self.calendarView.frame.origin.y, self.view.frame.size.width, self.GFTableView.frame.size.height + self.calendarView.frame.size.height) style: UITableViewStylePlain];
        
        
    } else {
        
        self.GFTableView = [[UITableView alloc] initWithFrame: CGRectMake(0, self.calendarView.frame.size.height + HEIGHT_OF_GFTABS, self.view.frame.size.width, self.view.frame.size.height - self.calendarView.frame.size.height - HEIGHT_OF_GFTABS) style:UITableViewStylePlain];
        
    }
    //set properties on the table view here
    self.GFTableView.delegate = self;
    self.GFTableView.dataSource = self;
    self.GFTableView.allowsSelection = NO;
    
    [self.view addSubview: self.GFTableView];

    BMLoadView* loadIndicator = [[BMLoadView alloc] initWithParent: self.view];
    [loadIndicator begin];
    [self.collection GFModelForCurrentMonth:^(NSError *error, GFModel *model) {
        [loadIndicator end];
        
    }];
        
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Events
- (void) tabChanged: (UISegmentedControl*) tabControl {
    if (tabControl.selectedSegmentIndex == 0) {
        [self showCalendarView];
    } else {
        [self hideCalendarView];
    }
    [self.GFTableView reloadData];
}

- (void) pushClassToFavorites: (ContainerButton*) sender {
    
    //toggle the selector
    if (sender.selected) {
        sender.backgroundColor = [UIColor colorWithRed: 137/255.0 green:171/255.0 blue:255/255.0 alpha:1];
        sender.selected = NO;
        
        [self.collection.favorites removeGFClassWithID: [sender.data objectForKey: @"_id"]];
    } else {
        sender.backgroundColor = [UIColor colorWithRed:100/255.0 green: 1 blue: 75/255.0 alpha:1];
        
        sender.selected = YES;
        //add the class to favorites
        [self.collection.favorites add: sender.data];
    }
}

- (void) removeFavoriteCell: (ContainerButton*) sender {
    self.removalData = sender.data;
    UIAlertView* removeAlert = [[UIAlertView alloc] initWithTitle: @"Remove" message: @"Are you sure you would like to remove this fitness class from your list of favorite fitness classes" delegate:self cancelButtonTitle: @"NO" otherButtonTitles: @"YES", nil];
    [removeAlert show];
    
}

#pragma mark - Public

- (void) hideCalendarView {
    if (!self.calendarView.hidden) {
        self.calendarView.hidden = YES;
        self.GFTableView.frame = CGRectMake(self.calendarView.frame.origin.x, self.calendarView.frame.origin.y, self.GFTableView.frame.size.width, self.GFTableView.frame.size.height + self.calendarView.frame.size.height);
    }
}

- (void) showCalendarView {
    if (self.calendarView.hidden) {
        self.calendarView.hidden = NO;
        
        self.GFTableView.frame = CGRectMake(0, self.calendarView.frame.size.height + HEIGHT_OF_GFTABS, self.GFTableView.frame.size.width, self.GFTableView.frame.size.height - self.calendarView.frame.size.height);
    }
}

#pragma mark - Display

- (NSString*) displayDate: (NSDate*) date {
    
    return [NSString stringWithFormat: @"%@. %@ %i, %i", [DateHelper weekDayAbbreviationForIndex:[date weekDay]], [DateHelper monthNameForIndex: [date month]], [date day], [date year]];
}

#pragma mark - Calendar Delegate

- (void) calendarChangeToYear:(NSUInteger)year month:(NSUInteger)month {
    NSDate *date = [NSDate dateWithYear: year month: month andDay: 1];
    [self displayDate: date];
    
    //load the month
    BMLoadView* loadIndicator = [[BMLoadView alloc] initWithParent: self.GFTableView];
    [loadIndicator begin];
    [self.collection GFModelForYear: year month: month block:^(NSError *error, GFModel *model) {
        if (error) {
            [self connectionError];
        } else {
            [self.GFTableView reloadData];
        }
        [loadIndicator end];
    }];
    
    for (UIView* view in self.cancelViews) {
        [view removeFromSuperview];
    }
}

- (void) didSelectDateForYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day {
    
    NSDate *date = [NSDate dateWithYear: year month: month andDay: day];
    [self displayDate: date];
    //the data is reloaded based on the new variables for calendar view
    [self.GFTableView reloadData];
    for (UIView* view in self.cancelViews) {
        [view removeFromSuperview];
    }
}


#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString: @"Remove"] && buttonIndex == 1) {
        //should delete the cell
        [self.collection.favorites removeGFClassWithID: [self.removalData objectForKey: @"_id"]];
        [self.GFTableView deleteRowsAtIndexPaths: [[NSArray alloc] initWithObjects: [self.removalData objectForKey: @"indexPath"], nil] withRowAnimation: UITableViewRowAnimationTop];
        [self.GFTableView reloadData];
    }
    self.removalData = nil;
    
}
#pragma mark - Table View DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* allClassesID = @"GFClasses";
    static NSString* favoriteClassesID = @"favoriteClasses";
    
    UITableViewCell* cell;
    
    
    if (self.GFTabs.selectedSegmentIndex != 2) {
        __block NSDictionary* GFClass;
        if (self.GFTabs.selectedSegmentIndex == 0) {
          
            [self.collection GFClassesForYear: self.calendarView.year month: self.calendarView.month day:self.calendarView.day block:^(NSError *error, NSArray *GFClasses) {
                
                if (error) {[self connectionError];}
                else {
                    GFClass = [GFClasses objectAtIndex: indexPath.row];
                }
                
            }];
        } else if (self.GFTabs.selectedSegmentIndex == 1) {
            //THERE ARE 7 SECTIONS
            if (indexPath.section == 0) {
                [self.collection GFClassesForCurrentDay:^(NSError *error, NSArray *GFClasses) {
                    if (error) {[self connectionError];}
                    else {
                        GFClass = [GFClasses objectAtIndex: indexPath.row];
                    }
                }];
            } else {
                [self.collection GFClassesForDaysAfterCurrentDay: indexPath.section block:^(NSError * error, NSArray *GFClasses) {
                    if (error) {[self connectionError];}
                    else {
                        GFClass = [GFClasses objectAtIndex: indexPath.row];
                    }
                }];
            }
            
        }
       
        cell = [tableView dequeueReusableCellWithIdentifier: allClassesID];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:allClassesID];
        }
        
        UILabel* className = [[UILabel alloc] initWithFrame: CGRectMake( (self.GFTableView.frame.size.width - GFCELL_NAME_WIDTH) / 2.0, GFCELL_PADDING, GFCELL_NAME_WIDTH, GFCELL_MAINLABEL_HEIGHT)];
        className.text = [GFClass objectForKey: @"className"];
        className.font = [UIFont fontWithName: @"Helvetica-Bold" size: 18];
        className.textColor = [UIColor blueColor];
        className.textAlignment = NSTextAlignmentCenter;
        
        
        UILabel* instructor = [[UILabel alloc] initWithFrame: CGRectMake(10, GFCELL_PADDING*2 + GFCELL_MAINLABEL_HEIGHT, GFCELL_SUBLABEL_WIDTH, GFCELL_SUBLABEL_HEIGHT)];
        instructor.text = [GFClass objectForKey: @"instructor"];
        instructor.font = [UIFont fontWithName: @"Helvetica-Bold" size: 12];
        
        
        UILabel* timeRange = [[UILabel alloc] initWithFrame: CGRectMake(10, GFCELL_PADDING*3 + GFCELL_SUBLABEL_HEIGHT + GFCELL_MAINLABEL_HEIGHT, GFCELL_SUBLABEL_WIDTH, GFCELL_SUBLABEL_HEIGHT)];
        timeRange.text = [GFClass objectForKey: @"timeRange"];
        timeRange.font = [UIFont fontWithName: @"Helvetica-Bold" size: 12];
       
        ContainerButton* addToFavorites = [[ContainerButton alloc] initWithFrame: CGRectMake(self.view.frame.size.width - 20 - GFCELL_BUTTON_WIDTH, 40, GFCELL_BUTTON_WIDTH, GFCELL_BUTTON_HEIGHT)];
        addToFavorites.data = GFClass;
        [addToFavorites setTitle: @"Add" forState: UIControlStateNormal];
        addToFavorites.titleLabel.font = [UIFont fontWithName: @"Helvetica-Bold" size: 12];
        addToFavorites.layer.cornerRadius = 4;
        [addToFavorites setTitle: @"Favorite" forState: UIControlStateSelected];
        [addToFavorites setTitleColor: [UIColor blueColor] forState: UIControlStateNormal];
        [addToFavorites setTitleColor: [UIColor colorWithRed:47/255.0 green: 121/255.0 blue:35/255.0 alpha: 1] forState:UIControlStateSelected];
        
        
        [addToFavorites addTarget:self action:@selector(pushClassToFavorites:) forControlEvents:UIControlEventTouchUpInside];
        if ([self.collection.favorites isFavorite: GFClass]) {
            addToFavorites.selected = YES;
            addToFavorites.backgroundColor = [UIColor colorWithRed:100/255.0 green: 1 blue: 75/255.0 alpha:1];
        } else {
            addToFavorites.backgroundColor = [UIColor colorWithRed: 137/255.0 green:171/255.0 blue:255/255.0 alpha:1];
        }
        
        [cell addSubview: className];
        [cell addSubview: instructor];
        [cell addSubview: timeRange];
        [cell addSubview: addToFavorites];
        
        //check if the class is cancelled for today
        BOOL isCancelled = NO;
        NSArray* cancelledDates = [GFClass objectForKey: @"cancelledDates"];
        NSDate* date = [NSDate dateWithYear: self.calendarView.year month: self.calendarView.month andDay:self.calendarView.day];
        for (NSString* cancelledDate in cancelledDates) {
            if ([date compare: [NSDate dateWithDateString: cancelledDate]] == NSOrderedSame) {
                isCancelled = YES;
            }
        }
        
        if (isCancelled) {
            UILabel* cancelledLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, CELL_VIEW_HEIGHT_STANDARD)];
            cancelledLabel.text = @"Cancelled";
            cancelledLabel.textColor = [UIColor redColor];
            cancelledLabel.backgroundColor = [UIColor whiteColor];
            cancelledLabel.alpha = .65;
            cancelledLabel.font = [UIFont fontWithName: @"Helvetica-Bold" size: 20];
            cancelledLabel.textAlignment = NSTextAlignmentCenter;
            cancelledLabel.userInteractionEnabled = YES;
            [cell addSubview: cancelledLabel];
            self.cancelViews = [self.cancelViews arrayByAddingObject: cancelledLabel];
        }
        
        
    } else {
        //render the favorite cell style
        cell = [tableView dequeueReusableCellWithIdentifier: favoriteClassesID];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: favoriteClassesID];
        }
        
        NSDictionary* GFClass = [self.collection.favorites GFClassForIndex: indexPath.row];
        
        UILabel* className = [[UILabel alloc] initWithFrame: CGRectMake( (self.GFTableView.frame.size.width - GFCELL_NAME_WIDTH) / 2.0, GFCELL_PADDING, GFCELL_NAME_WIDTH, GFCELL_MAINLABEL_HEIGHT)];
        className.text = [GFClass objectForKey: @"className"];
        className.font = [UIFont fontWithName: @"Helvetica-Bold" size: 18];
        className.textColor = [UIColor blueColor];
        className.textAlignment = NSTextAlignmentCenter;
        
        UILabel* instructor = [[UILabel alloc] initWithFrame: CGRectMake(GFCELL_PADDING, GFCELL_PADDING * 2 + GFCELL_MAINLABEL_HEIGHT, GFCELL_SUBLABEL_WIDTH, GFCELL_SUBLABEL_HEIGHT)];
        instructor.text = [GFClass objectForKey: @"instructor"];
        instructor.font = [UIFont fontWithName: @"Helvetica-Bold" size: 12];
        
        UILabel* timeRange = [[UILabel alloc] initWithFrame: CGRectMake(GFCELL_PADDING, GFCELL_PADDING * 3 + GFCELL_MAINLABEL_HEIGHT + GFCELL_SUBLABEL_HEIGHT, GFCELL_SUBLABEL_WIDTH_EXTENDED, GFCELL_SUBLABEL_HEIGHT)];
        timeRange.text = [NSString stringWithFormat: @"%@ at %@", [DateHelper weekDayForIndex:[[GFClass objectForKey: @"dayOfWeek"] intValue]], [GFClass objectForKey: @"timeRange"]];
        timeRange.font = [UIFont fontWithName: @"Helvetica-Bold" size: 12];
        
        
        //get the current date for the time zone using
        //the date formatter method
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
        formatter.timeZone = [NSTimeZone timeZoneWithName: NASHVILLE_TIMEZONE];
        NSString* dateString = [formatter stringFromDate: [[NSDate alloc] init]];
        //add the 20 into the date for the year
        dateString = [[[dateString substringToIndex: dateString.length - 2] stringByAppendingString:@"20"] stringByAppendingString: [dateString substringFromIndex:dateString.length - 2]];
        NSDate *currentDate = [NSDate dateWithDateString: dateString];
        
        //check to see if the class being added to the favorites
        //list still exists in the schedule (the end date has not yet passed)
        if (![[GFClass objectForKey: @"endDate"] isEqualToString: @"*"] && [currentDate compare: [NSDate dateWithDateString: [GFClass objectForKey: @"endDate"]]] == NSOrderedDescending) {
            UILabel* discontinue = [[UILabel alloc] initWithFrame: CGRectMake((self.GFTableView.frame.size.width - GFCELL_SUBLABEL_WIDTH_EXTENDED)/2.0, CELL_VIEW_HEIGHT_FAVORITES - GFCELL_SUBLABEL_HEIGHT - GFCELL_PADDING, GFCELL_SUBLABEL_WIDTH_EXTENDED, GFCELL_SUBLABEL_HEIGHT)];
            discontinue.textColor = [UIColor redColor];
            discontinue.text = @"This class is discontinued";
            discontinue.font = [UIFont fontWithName: @"Helvetica-Bold" size: 12];
            discontinue.textAlignment = NSTextAlignmentCenter;
            
            [cell addSubview: discontinue];
        }

        ContainerButton* removeButton = [[ContainerButton alloc] initWithFrame: CGRectMake(self.GFTableView.frame.size.width - GFCELL_BUTTON_WIDTH - GFCELL_PADDING*3, GFCELL_PADDING*2 + GFCELL_MAINLABEL_HEIGHT, GFCELL_BUTTON_WIDTH, GFCELL_BUTTON_HEIGHT)];
        [removeButton setTitle: @"Remove" forState: UIControlStateNormal];
        [removeButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        [removeButton setTitleColor: [UIColor whiteColor] forState: UIControlStateHighlighted];
        removeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        removeButton.titleLabel.font = [UIFont fontWithName: @"Helvetica-Bold" size: 12];
        removeButton.backgroundColor = [UIColor redColor];
        //add the index path of the cell to the data being inserted in the
        //button
        NSMutableDictionary* mutableData = [GFClass mutableCopy];
        [mutableData setObject: indexPath forKey: @"indexPath"];
        //set the data to an immutable copy
        removeButton.data = [mutableData copy];
        
        removeButton.layer.cornerRadius = 10;
        [removeButton addTarget: self action: @selector(removeFavoriteCell:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [cell addSubview: className];
        [cell addSubview: timeRange];
        [cell addSubview: instructor];
        [cell addSubview: removeButton];
        
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    __block NSUInteger rowsInSection = 0;
    
    
    if (self.GFTabs.selectedSegmentIndex == 0) {
        [self.collection GFClassesForYear: self.calendarView.year month:self.calendarView.month day:self.calendarView.day  block:^(NSError *error, NSArray *GFClasses) {
            if (error) {
                [self connectionError];
            } else {
                rowsInSection = GFClasses.count;
            }

        }];
    } else if (self.GFTabs.selectedSegmentIndex == 1) {
        [self.collection GFClassesForDaysAfterCurrentDay: section block:^(NSError *error, NSArray *GFClasses) {
            if (error) {
                [self connectionError];
            } else {
                rowsInSection = GFClasses.count;
            }
        }];
        
    } else {
        //the selected tab is 2
        rowsInSection = [self.collection.favorites count];
    }
    
    
    return rowsInSection;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.GFTabs.selectedSegmentIndex == 1) {
        //section for each day of the week
        return 7;
    }
    return 1;
}

#pragma mark - Table View Delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIImageView* view = [[UIImageView alloc] init];
    view.image = [UIImage imageNamed: @"goldTint.png"];
    UILabel* monthLabel = [[UILabel alloc] initWithFrame: CGRectMake((self.view.frame.size.width - WIDTH_OF_MONTH_LABEL) / 2.0, (HEIGHT_OF_SECTION_HEADER - HEIGHT_OF_MONTH_LABEL) / 2.0,  WIDTH_OF_MONTH_LABEL, HEIGHT_OF_MONTH_LABEL)];
    
    monthLabel.textAlignment = NSTextAlignmentCenter;
    monthLabel.font = [UIFont fontWithName: @"TrebuchetMS-Bold" size: 18];
    monthLabel.backgroundColor = [UIColor clearColor];
    
    if (self.GFTabs.selectedSegmentIndex == 0) {
        monthLabel.text = [self displayDate: [self.calendarView selectedDate]];
    } else if (self.GFTabs.selectedSegmentIndex == 1) {
        if (section == 0) {
            monthLabel.text = @"Today";
        } else {
            NSDate* date = [DateHelper currentDateForTimeZone: [NSTimeZone timeZoneWithName: NASHVILLE_TIMEZONE]];
            date = [date dateByAddingTimeInterval: section * 24 * 60 * 60];
            monthLabel.text = [DateHelper weekDayForIndex: [date weekDay]];
        }
        
    } else {
        monthLabel.text = @"Favorites";
    }
    [view addSubview: monthLabel];
    return view;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HEIGHT_OF_SECTION_HEADER;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.GFTabs.selectedSegmentIndex == 2) {
        return CELL_VIEW_HEIGHT_FAVORITES;
    } else {
       return CELL_VIEW_HEIGHT_STANDARD;
    }
    
}

#pragma mark - Helpers

- (void) connectionError {
    UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle: @"Error with Internet Collection" message: @"Could not connect to the internet" delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
    [errorAlert show];
}

@end
