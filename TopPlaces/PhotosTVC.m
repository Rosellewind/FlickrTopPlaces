//
//  PlacePhotosTVC.m
//  TopPlaces
//
//  Created by Roselle Milvich on 10/7/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import "PhotosTVC.h"
#import "FlickrFetcher.h"
#import "PhotoVC.h"

#define MAX_RESULTS 2

@interface PhotosTVC ()
@end

@implementation PhotosTVC
@synthesize place = _place;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableData = [FlickrFetcher photosInPlace:self.place maxResults:MAX_RESULTS];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"pictures";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell) cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"places"];
    NSDictionary *photo = [self.tableData objectAtIndex:indexPath.row];
    NSString *title = [photo objectForKey:@"title"];
    NSString *description = [photo valueForKeyPath:@"description._content"];
    if (!title) title = @"";
    if (!description) description = @"";
    if (title.length == 0){
        if (description.length ==0)
            title = @"Unknown";
        else{
            title = description;
            description = @"";
        }
    }
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = description;
    cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatSquare]]];
    
    return cell;
}
#pragma mark - Table view delegate

-(PhotoVC*) splitViewPhotoVC{
    id vc = [self.splitViewController.viewControllers lastObject];
    if (![vc isKindOfClass:[PhotoVC class]])
        vc = nil;
    return vc;
}

-(void)prepareVC:(PhotoVC*)vc{
    NSIndexPath *index= [self.tableView indexPathForSelectedRow];
    NSDictionary *photo = [self.tableData objectAtIndex:index.row];
    vc.photo = photo;
    vc.description = [[[self.tableView cellForRowAtIndexPath:index]textLabel]text];
    [self savePicToRecentlyViewed:photo];
    [vc loadImage];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.splitViewController){
        id vc = [self.splitViewController.viewControllers lastObject];
        if ([vc isKindOfClass:[PhotoVC class]]){
            [self prepareVC:vc];
            [vc prepareImage];
        }
    }
}

-(void)savePicToRecentlyViewed:(NSDictionary*)photo{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *newRecentlyViewed = [NSArray arrayWithObject:photo];
    NSArray *oldRecentlyViewed = [defaults objectForKey:@"recentlyViewed"];
    if (oldRecentlyViewed){
        if ([oldRecentlyViewed containsObject:photo])
            newRecentlyViewed = oldRecentlyViewed;
        else
            newRecentlyViewed = [newRecentlyViewed arrayByAddingObjectsFromArray:oldRecentlyViewed];
    }
    [defaults setObject:newRecentlyViewed forKey:@"recentlyViewed"];
    [defaults synchronize];
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isKindOfClass:[PhotoVC class]]){
        PhotoVC *vc = segue.destinationViewController;
        [self prepareVC:vc];
    }
}

@end
