//
//  RecentlyViewedTVC.m
//  TopPlaces
//
//  Created by Roselle Milvich on 10/7/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import "RecentPhotosTVC.h"

@interface RecentPhotosTVC ()
@end

@implementation RecentPhotosTVC

#pragma mark - Set-up
-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setData];
}

-(void)setData{
    //show spinner while getting data
    [self showSpinnerInToolBar];
    
    dispatch_queue_t fromDefaults = dispatch_queue_create("data from defaults", NULL);
    dispatch_async(fromDefaults, ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *recent = [defaults objectForKey:@"recentlyViewed"];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem = NULL;
            if (![recent isEqualToArray:self.tableData]) {
                self.tableData = recent;
                [self.tableView reloadData];
            }
                       NSLog(@"self.tableData:%@", self.tableData);
        });
    });
    NSLog(@"self.tableData:%@", self.tableData);
}

@end
