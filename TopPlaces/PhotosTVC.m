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
#import "PhotosVC.h"
#import "Cacher.h"

#define MAX_RESULTS 50

@interface PhotosTVC ()
@property (strong, nonatomic) NSMutableArray *cachedThumbs;
@end

@implementation PhotosTVC
@synthesize place = _place;
@synthesize cachedThumbs = _cachedThumbs;

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
    cell.imageView.image = [UIImage imageNamed:@"white 75x75.png"];
    
    NSString *key = [photo objectForKey:@"id"];
    
    //check to see if photo is cached
    UIImage *cachedImage = [Cacher cachedImageForKey:key isThumb:YES];
    if (cachedImage && (indexPath.row == [tableView indexPathForCell:cell].row)){
        cell.imageView.image = cachedImage;
    }
    else{
        //get the image view
        dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
        dispatch_async(downloadQueue, ^{
            //        NSLog(@"fetching: cellForRowAtIndexPath");
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatSquare]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (indexPath.row == [tableView indexPathForCell:cell].row)
                    cell.imageView.image = image;
            });
            //manage cache
            [self.cachedThumbs insertObject:key atIndex:0];
            if ([Cacher isOverLimitIsThumb:YES]){
                [Cacher removeCacheForKey:[self.cachedThumbs lastObject] isThumb:YES];// take ooff isthumb
                [self.cachedThumbs removeLastObject];
            }
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:self.cachedThumbs forKey:@"cachedThumbs"];
            [defaults synchronize];
            [Cacher cacheImage:image withKey:key isThumb:YES];
        });
    }

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
    [PhotosVC savePicToRecentlyViewed:photo];
//    [self savePicToRecentlyViewed:photo];
    vc.photo = photo;
    vc.description = [[[self.tableView cellForRowAtIndexPath:index]textLabel]text];
}
    
-(void)viewDidLoad{
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.cachedThumbs = [[defaults arrayForKey:@"cachedThumbs"]mutableCopy];
    if (!self.cachedThumbs) self.cachedThumbs = [[NSMutableArray alloc]init];
}

@end
