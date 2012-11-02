//
//  TopPlacesVC.m
//  TopPlaces
//
//  Created by Roselle Milvich on 10/29/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import "TopPlacesVC.h"
#import "FlickrFetcher.h"
#import "TopPlacesTVC.h"
#import "TopPlacesMVC.h"



@interface TopPlacesVC ()

@end

@implementation TopPlacesVC
@synthesize containerView = _containerView;
@synthesize tvc = _tvc;
@synthesize mvc = _mvc;
@synthesize dataArray = _dataArray;
@synthesize refreshButton = _refreshButton;
@synthesize mapOrTableControl = _mapOrTableControl;
@synthesize isUsingMapOrTable = _isUsingMapOrTable;

#pragma mark - Setup

-(void) viewDidLoad{
    [super viewDidLoad];
    [self setData];
    [self initialSetup];
}

-(void) initialSetup{
    self.tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Places Table"];
    self.mvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Places Map"];
    [self addChildViewController:self.tvc];
    [self addChildViewController:self.mvc];
    
    self.isUsingMapOrTable = USING_TABLE;
    [self.containerView addSubview:self.tvc.view];
}

#pragma mark - Getters and Setters
-(void) setDataArray:(NSArray *)dataArray{
    if (![self.dataArray isEqualToArray:dataArray]){
        _dataArray = dataArray;
        if (self.isUsingMapOrTable == USING_MAP) {
            self.mvc.mapData = self.dataArray;
        }
        else{
            self.tvc.tableData = self.dataArray;
        }
    }
}

#pragma mark - Data
- (IBAction)refresh:(id)sender {
    [self setData];
}

-(void)setData{
    //show spinner while getting data
    [self showSpinnerInToolBar];
    
    //download data in another thread
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr places data downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"_content" ascending:YES];
        NSArray *places = [[FlickrFetcher topPlaces] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.dataArray = places;
            self.navigationItem.rightBarButtonItem = self.refreshButton;

        });
    });
}

-(void) showSpinnerInToolBar{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc]initWithCustomView:spinner];
    self.navigationItem.rightBarButtonItem = bbi;
}

#pragma mark - Transitions

- (IBAction)choseView:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.tvc.tableData = self.dataArray;
        [self transitionFromViewController:(UIViewController*)self.mvc toViewController:(UIViewController*)self.tvc duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionCurveEaseIn animations:^{} completion:^(BOOL finished){
            self.isUsingMapOrTable = USING_TABLE;
        }];
    }
    else{
        self.mvc.mapData = self.dataArray;
        [self transitionFromViewController:(UIViewController*)self.tvc toViewController:(UIViewController*)self.mvc duration:1.0 options:UIViewAnimationOptionTransitionFlipFromRight | UIViewAnimationOptionCurveEaseIn animations:^{} completion:^(BOOL finished){
            self.isUsingMapOrTable = USING_MAP;
        }];
    }
}

- (void)viewDidUnload {
    [self setMapOrTableControl:nil];
    [super viewDidUnload];
}

@end
