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
-(void) initialSetup{
    self.tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Recent Table"];
    self.mvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Recent Map"];
    [self addChildViewController:self.tvc];
    [self addChildViewController:self.mvc];
    
    self.isUsingMapOrTable = USING_TABLE;
    [self.containerView addSubview:self.tvc.view];
}

-(void)setData{
    //show spinner to user to show that it went through
    //maybe take this out or put it in TopPlacesVC with variable isLoading if still loading
    [self showSpinnerInToolBar];
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.navigationItem.rightBarButtonItem = self.refreshButton;
    });
    
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
