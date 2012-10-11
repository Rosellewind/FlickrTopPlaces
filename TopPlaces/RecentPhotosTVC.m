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

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.tableData = [defaults objectForKey:@"recentlyViewed"];
}

@end
