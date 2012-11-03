//
//  RecentPhotosVC.m
//  TopPlaces
//
//  Created by Roselle Milvich on 10/30/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import "RecentPhotosVC.h"
#import "RecentPhotosTVC.h"
#import "RecentPhotosMVC.h"

@interface RecentPhotosVC ()

@end

@implementation RecentPhotosVC

#pragma mark - Setup

-(void) initialSetup{
    self.tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Recent Table"];
    self.mvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Recent Map"];
    [self addChildViewController:self.tvc];
    [self addChildViewController:self.mvc];
    
    self.isUsingMapOrTable = USING_TABLE;
    [self.containerView addSubview:self.tvc.view];
}

-(void)setData{
    dispatch_queue_t fromDefaults = dispatch_queue_create("data from defaults", NULL);
    dispatch_async(fromDefaults, ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *recent = [defaults objectForKey:@"recentlyViewed"];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.dataArray = recent;
        });
    });
}

@end
