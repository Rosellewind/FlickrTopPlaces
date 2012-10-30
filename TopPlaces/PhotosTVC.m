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
#import "FlickrPhotoAnnotation.h"

#define MAX_RESULTS 50

@interface PhotosTVC ()
@end

@implementation PhotosTVC
@synthesize place = _place;

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
    

    cell.imageView.image = [UIImage imageNamed:@"white 30x30.png"];

    //get the image view
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatSquare]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (indexPath.row == [tableView indexPathForCell:cell].row){
                cell.imageView.image = image;
            }
        });
    });
    return cell;
}

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
}


#pragma mark - Transitions


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isKindOfClass:[PhotoVC class]]){
        PhotoVC *vc = segue.destinationViewController;
        [self prepareVC:vc];
    }
}

-(PhotoVC*) splitViewPhotoVC{
    id vc = [self.splitViewController.viewControllers lastObject];
    if (![vc isKindOfClass:[PhotoVC class]])
        vc = nil;
    return vc;
}

-(void)prepareVC:(PhotoVC*)vc{
    NSIndexPath *index= [self.tableView indexPathForSelectedRow];
    NSDictionary *photo = [self.tableData objectAtIndex:index.row];
    [self savePicToRecentlyViewed:photo];
    vc.photo = photo;
    vc.description = [[[self.tableView cellForRowAtIndexPath:index]textLabel]text];
}


-(void)savePicToRecentlyViewed:(NSDictionary*)photo{
    dispatch_queue_t defaultsQueue = dispatch_queue_create("save to defaults", NULL);
    dispatch_async(defaultsQueue, ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *recentlyViewed = [[defaults objectForKey:@"recentlyViewed"] mutableCopy];
        if(!recentlyViewed) recentlyViewed = [[NSMutableArray alloc]init];
        NSUInteger index = [recentlyViewed indexOfObject:photo];
        if (index != NSNotFound)//swap places............
            [recentlyViewed exchangeObjectAtIndex:0 withObjectAtIndex:[recentlyViewed indexOfObject:photo]];
        else{
            [recentlyViewed insertObject:photo atIndex:0];
            if (recentlyViewed.count > 20) {
                recentlyViewed = [[recentlyViewed subarrayWithRange:NSMakeRange(0, 19)]mutableCopy];
            }
        }
        [defaults setObject:recentlyViewed forKey:@"recentlyViewed"];
        [defaults synchronize];
    });
}

@end
