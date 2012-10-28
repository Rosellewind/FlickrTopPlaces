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

#define MAX_RESULTS 50

@interface PhotosTVC ()
@end

@implementation PhotosTVC
@synthesize place = _place;


#pragma mark - Data

-(void)setData{// called in viewDidLoad
    //show spinner while getting data
    [self showSpinnerInToolBar];
    
    //get data
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr place data downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *photos = [FlickrFetcher photosInPlace:self.place maxResults:MAX_RESULTS];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem = self.refreshButton;
            if (![photos isEqualToArray:self.tableData]) {
                self.tableData = photos;
                [self.tableView reloadData];
            }
        });
    });

}

- (IBAction)refresh:(id)sender {
    [self setData];
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
    
    //set the spinner for image view
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    double circumference = spinner.frame.size.height;
    spinner.frame = CGRectMake(5, 5, circumference, circumference);
    [spinner startAnimating];
    cell.imageView.image = [UIImage imageNamed:@"white 30x30.png"];
    [self removeSubviewsFromImageView:cell.imageView];
    [cell.imageView addSubview:spinner];
    
    //get the image view
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatSquare]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (indexPath.row == [tableView indexPathForCell:cell].row){
                cell.imageView.image = image;
                [self removeSubviewsFromImageView:cell.imageView];
            }
        });
    });
//    dispatch_release(downloadQueue);

    
    
    return cell;
}

-(void) removeSubviewsFromImageView:(UIImageView*)imageView{
    NSArray *subviews = [imageView subviews];
    for (int i = 0; i<subviews.count; i++) {
        [[subviews objectAtIndex:i]removeFromSuperview];
    }
}

/*
- (IBAction)refresh:(id)sender
{
    // might want to use introspection to be sure sender is UIBarButtonItem
    // (if not, it can skip the spinner)
    // that way this method can be a little more generic
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *photos = [FlickrFetcher recentGeoreferencedPhotos];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem = sender;
            self.photos = photos;
        });
    });
    dispatch_release(downloadQueue);
}
*/
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
        if (recentlyViewed){
            NSUInteger index = [recentlyViewed indexOfObject:photo];
            if (index != NSNotFound)//swap places............
                [recentlyViewed exchangeObjectAtIndex:0 withObjectAtIndex:[recentlyViewed indexOfObject:photo]];
            else{
                [recentlyViewed insertObject:photo atIndex:0];
                if (recentlyViewed.count > 100) {
                    recentlyViewed = [[recentlyViewed subarrayWithRange:NSMakeRange(0, 89)]mutableCopy];
                }
            }
            [defaults setObject:recentlyViewed forKey:@"recentlyViewed"];
            [defaults synchronize];
        }
    });
}

@end
