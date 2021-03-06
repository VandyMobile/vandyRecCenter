//
//  homeViewController.m
// 
//
//  Created by Brendan McNamara on 3/25/13.
//  Copyright (c) 2013 Brendan McNamara. All rights reserved.
//

#import "homeViewController.h"

@interface homeViewController ()

@property (nonatomic, strong) NSArray* pagesInScrollView;
@property (nonatomic, assign) NSInteger indexOfScroll;
@property (nonatomic, strong) NewsModel* newsModel;
@property (nonatomic, assign) BOOL dataLoaded;
@property (nonatomic, strong) BMLoadView* loadIndicator;
@end

@implementation homeViewController

@synthesize indexOfScroll = _indexOfScroll;

@synthesize scrollView = _scrollView;
@synthesize leftScroller = _leftScroller;
@synthesize rightScroller = _rightScroller;

@synthesize pagesInScrollView = _pagesInScrollView;
@synthesize newsModel = _newsModel;

#pragma mark - getters

- (NSArray*) pagesInScrollView {
    if (_pagesInScrollView == nil) {
        _pagesInScrollView = [[NSArray alloc] init];
    }
    return _pagesInScrollView;
}

- (NewsModel*) newsModel {
    if (_newsModel == nil) {
        _newsModel = [[NewsModel alloc] init];
    }
    return _newsModel;
}

- (BMLoadView*) loadIndicator {
    if (_loadIndicator == nil) {
        _loadIndicator = [[BMLoadView alloc] initWithParent: self.view];
        _loadIndicator.backgroundColor = [UIColor whiteColor];
        _loadIndicator.titleView.textColor = [UIColor blackColor];
        _loadIndicator.loadSpiral.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _loadIndicator.alpha = .8;
    }
    return _loadIndicator;
}

#pragma mark - events

- (void) scrollLeft {
    self.indexOfScroll--;
    if (self.indexOfScroll < 0) {
        self.indexOfScroll = self.newsModel.news.count - 1;
    }
    [self.scrollView setContentOffset: CGPointMake(self.indexOfScroll * self.scrollView.frame.size.width, 0) animated: YES];
    
}
- (void) scrollRight {
    self.indexOfScroll = (self.indexOfScroll + 1) % self.newsModel.news.count;
    [self.scrollView setContentOffset: CGPointMake(self.indexOfScroll * self.scrollView.frame.size.width, 0) animated:YES];
}

#pragma mark - lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];
    self.scrollView.delegate = self;
}

- (void) viewDidLayoutSubviews {
    
    
    [self setScrollViewSubviews];
    
}


#pragma mark - manage views

//NOTE THAT CALLING REMOVEFROMSUPERVIEW METHOD ON SELF.VIEWS CAUSES THIS METHOD TO AUTOMATICALLY BE CALLED
- (void) setScrollViewSubviews {
    
    [self removeAllViewsFromScrollView];
    
    CGRect frameOfLeftScroller;
    CGRect frameOfRightScroller;
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        frameOfLeftScroller = CGRectMake(ARROW_BORDER_PADDING_PORTRAIT, (self.view.frame.size.height - ARROW_DIMENSIONS_PORTRAIT)/2.0, ARROW_DIMENSIONS_PORTRAIT, ARROW_DIMENSIONS_PORTRAIT);
        frameOfRightScroller = CGRectMake(self.view.frame.size.width - ARROW_BORDER_PADDING_PORTRAIT - ARROW_DIMENSIONS_PORTRAIT, (self.view.frame.size.height - ARROW_DIMENSIONS_PORTRAIT)/2.0, ARROW_DIMENSIONS_PORTRAIT, ARROW_DIMENSIONS_PORTRAIT);
    } else {
       
        frameOfLeftScroller = CGRectMake(ARROW_BORDER_PADDING_LANDSCAPE, (self.view.frame.size.height - ARROW_DIMENSIONS_LANDSCAPE)/2.0, ARROW_DIMENSIONS_LANDSCAPE, ARROW_DIMENSIONS_LANDSCAPE);
        frameOfRightScroller = CGRectMake(self.view.frame.size.width - ARROW_BORDER_PADDING_LANDSCAPE - ARROW_DIMENSIONS_LANDSCAPE, (self.view.frame.size.height - ARROW_DIMENSIONS_LANDSCAPE)/2.0, ARROW_DIMENSIONS_LANDSCAPE, ARROW_DIMENSIONS_LANDSCAPE);
    
    }
   
    
    if (!self.dataLoaded) {
        
        
        [self.loadIndicator begin];
    
        [self.newsModel loadData:^(NSError *error) {
            
            if (error) {
                //should make sure the error message is readable
                UIAlertView *connectionAlert = [[UIAlertView alloc] initWithTitle: @"Error With Internet Connection" message: [error localizedDescription] delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
                [connectionAlert show];
               
            } else {
                
                
                self.leftScroller = [[UIButton alloc] init];
                self.rightScroller = [[UIButton alloc] init];
                
                [self.leftScroller setImage: [UIImage imageNamed:@"leftArrow.png"] forState: UIControlStateNormal];
                [self.rightScroller setImage: [UIImage imageNamed: @"rightArrow.png"] forState: UIControlStateNormal];
                [self.view addSubview: self.leftScroller];
                [self.view addSubview: self.rightScroller];
                
                [self.leftScroller addTarget: self action: @selector(scrollLeft) forControlEvents:UIControlEventTouchUpInside];
                [self.rightScroller addTarget: self action: @selector(scrollRight) forControlEvents:UIControlEventTouchUpInside];

                BOOL hideScroller = NO;
                if (self.newsModel.news.count == 0) {
                    self.newsModel.news = [[NSArray alloc] initWithObjects:@"There is currently no important news for the recreation center.", nil];
                }
                if (self.newsModel.news.count == 1) {
                    self.scrollView.bounces = NO;
                    hideScroller = YES;
                }
                
                self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.newsModel.news.count, self.scrollView.frame.size.height);
                
                for (NSUInteger i = 0; i < self.newsModel.news.count; ++i) {
                    [self addPageToScrollViewAtIndex: i hideScrollersInPortraitOrientation: hideScroller];
                }
                
                //set up offset
                [self.scrollView setContentOffset: CGPointMake(self.indexOfScroll * self.scrollView.frame.size.width, 0) animated: YES];
                self.dataLoaded = YES;
            }
            
            
            [self.loadIndicator end];
        }];
     
    } else {
        //use existing data to layout subviews and scroll view
        BOOL hideScroller = NO;
        if (self.newsModel.news.count == 1) {
            self.scrollView.bounces = NO;
            hideScroller = YES;
        }
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.newsModel.news.count, self.scrollView.frame.size.height);
        
        for (NSUInteger i = 0; i < self.newsModel.news.count; ++i) {
            [self addPageToScrollViewAtIndex: i hideScrollersInPortraitOrientation: hideScroller];
        }
        
        //set up offset
        [self.scrollView setContentOffset: CGPointMake(self.indexOfScroll * self.scrollView.frame.size.width, 0) animated: YES];
        
    }
    self.leftScroller.frame = frameOfLeftScroller;
    self.rightScroller.frame = frameOfRightScroller;
    
}


//hideScrollers determines if the scrollers are to be hidden when in portriat orientation
//scrollers are always hidden in landscape orientation and should be hidden
//in portrait orientation only when there is only a single page to display
- (void) addPageToScrollViewAtIndex: (NSUInteger) index hideScrollersInPortraitOrientation: (BOOL) hideScrollers {
    
    //define variables that are dependent on device orientation here
    //so that they may be set in the below conditional statement
    CGRect frameOfPage;
    CGRect frameOfLabel;
    CGRect frameOfLogo;
    CGFloat fontSize;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        
        frameOfPage = CGRectMake((self.scrollView.frame.size.width - DIMENSIONS_OF_PAGE_PORTRAIT)/2.0 + (index *self.scrollView.frame.size.width), (self.scrollView.frame.size.height - DIMENSIONS_OF_PAGE_PORTRAIT)/2.0, DIMENSIONS_OF_PAGE_PORTRAIT, DIMENSIONS_OF_PAGE_PORTRAIT);
        
        frameOfLabel = CGRectMake((DIMENSIONS_OF_PAGE_PORTRAIT - LABEL_DIMENSIONS_PORTRAIT)/2.0, (DIMENSIONS_OF_PAGE_PORTRAIT - LABEL_DIMENSIONS_PORTRAIT)/2.0, LABEL_DIMENSIONS_PORTRAIT, LABEL_DIMENSIONS_PORTRAIT);
        
        
        frameOfLogo = CGRectMake((DIMENSIONS_OF_PAGE_PORTRAIT - LOGO_DIMENSIONS_PORTRAIT)/2.0, LOGO_Y_COOR_PORTRAIT, LOGO_DIMENSIONS_PORTRAIT, LOGO_DIMENSIONS_PORTRAIT);
        
        fontSize = DESCRIPTION_FONT_SIZE_PORTRAIT;
        
        if (hideScrollers) {
            self.leftScroller.hidden = YES;
            self.rightScroller.hidden = YES;
        } else {
            self.leftScroller.hidden = NO;
            self.rightScroller.hidden = NO;
        }
        
    } else {
        
        //for now, add height translation in landscape orientation
        frameOfPage = CGRectMake((self.scrollView.frame.size.width - DIMENSIONS_OF_PAGE_LANDSCAPE)/2.0 + (index *self.scrollView.frame.size.width), (self.scrollView.frame.size.height - DIMENSIONS_OF_PAGE_LANDSCAPE)/2.0, DIMENSIONS_OF_PAGE_LANDSCAPE, DIMENSIONS_OF_PAGE_LANDSCAPE);
        
        frameOfLabel = CGRectMake((DIMENSIONS_OF_PAGE_LANDSCAPE - LABEL_DIMENSIONS_LANDSCAPE)/2.0, (DIMENSIONS_OF_PAGE_LANDSCAPE - LABEL_DIMENSIONS_LANDSCAPE)/2.0, LABEL_DIMENSIONS_LANDSCAPE, LABEL_DIMENSIONS_LANDSCAPE);
        
        
        frameOfLogo = CGRectMake((DIMENSIONS_OF_PAGE_LANDSCAPE - LOGO_DIMENSIONS_LANDSCAPE)/2.0, LOGO_Y_COOR_LANDSCAPE, LOGO_DIMENSIONS_LANDSCAPE, LOGO_DIMENSIONS_LANDSCAPE);
        
        fontSize = DESCRIPTION_FONT_SIZE_LANDSCAPE;
        
        if (hideScrollers) {
            self.leftScroller.hidden = YES;
            self.rightScroller.hidden = YES;
        } else {
            self.leftScroller.hidden = NO;
            self.rightScroller.hidden = NO;
        }
        
    }
    
    UIView* page = [[UIView alloc] initWithFrame: frameOfPage];
    page.backgroundColor = [UIColor vanderbiltGold];
    page.layer.borderWidth = 2.f;
    page.layer.borderColor = [[UIColor whiteColor] CGColor];
    page.layer.cornerRadius = 5.f;
    
    UILabel* descriptionLabel = [[UILabel alloc] initWithFrame: frameOfLabel];
    descriptionLabel.text = [self.newsModel.news objectAtIndex: index];
    descriptionLabel.backgroundColor = [UIColor clearColor];
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.numberOfLines = 8;
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.font = [UIFont systemFontOfSize: fontSize];
    
    [page addSubview: descriptionLabel];
    
    
    [self.scrollView addSubview: page];
    //keep track of pages so they may be removed when needed
    self.pagesInScrollView = [self.pagesInScrollView arrayByAddingObject: page];
}
- (void) removeAllViewsFromScrollView {
    for (UIView* view in self.pagesInScrollView) {
        [view removeFromSuperview];
    }
    self.pagesInScrollView = [[NSArray alloc] init];
}

#pragma mark - scroll delegate

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.indexOfScroll = self.view.frame.size.width / self.scrollView.contentOffset.x;
    
}
@end
