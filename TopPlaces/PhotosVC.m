//
//  PhotosVC.m
//  TopPlaces
//
//  Created by Roselle Milvich on 10/30/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import "PhotosVC.h"
#import "FlickrFetcher.h"
#import "PhotosTVC.h"
#import "PhotosMVC.h"

#define MAX_RESULTS 5

@interface PhotosVC ()

@end

@implementation PhotosVC
@synthesize place = _place;

-(void) initialSetup{
    self.tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Photos Table"];
    self.mvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Photos Map"];
    [self addChildViewController:self.tvc];
    [self addChildViewController:self.mvc];
    
    if (self.isUsingMapOrTable)
        [self.containerView addSubview:self.mvc.view];
    else [self.containerView addSubview:self.tvc.view];
}

-(void)setData{
    //show spinner while getting data
    [self showSpinnerInToolBar];
    
    //get data
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr place data downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *photos = [FlickrFetcher photosInPlace:self.place maxResults:MAX_RESULTS];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.dataArray = photos;
            self.navigationItem.rightBarButtonItem = self.refreshButton;
        });
    });
}

@end
