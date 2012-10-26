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

-(void)setData{// called in viewDidLoad
    dispatch_queue_t fromDefaults = dispatch_queue_create("data from defaults", NULL);
    dispatch_async(fromDefaults, ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.tableData = [defaults objectForKey:@"recentlyViewed"];
        [self.tableView reloadData];
    });

}

@end
