//
//  RecentlyViewedTVC.m
//  TopPlaces
//
//  Created by Roselle Milvich on 10/7/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import "RecentPhotosTVC.h"
#import "PhotoVC.h"

@interface RecentPhotosTVC ()
@end

@implementation RecentPhotosTVC

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.splitViewController){
        id vc = [self.splitViewController.viewControllers lastObject];
        if ([vc isKindOfClass:[PhotoVC class]]){
            [self prepareVC:vc];
            [vc loadImage];
        }
    }
    else {//else not needed in ios6, nor didSelectRowAtIndexPath if else not in super
        [self performSegueWithIdentifier:@"recent table to photo" sender:[tableView cellForRowAtIndexPath:indexPath]];
    }
}

@end
