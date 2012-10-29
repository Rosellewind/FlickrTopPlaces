//
//  TopPlacesTVC.m
//  TopPlaces
//
//  Created by Roselle Milvich on 10/7/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import "TopPlacesTVC.h"
#import "FlickrFetcher.h"
#import "PhotosTVC.h"
#import "RecentPhotosTVC.h"

@interface TopPlacesTVC ()
@end

@implementation TopPlacesTVC
@synthesize tableData;
@synthesize tableView;

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.tableView.clearsSelectionOnViewWillAppear = NO;
    [self setData];
}

#pragma mark - Data
- (IBAction)refresh:(id)sender {
    [self setData];
}

-(void)setData{
    //show spinner while getting data
    [self showSpinnerInToolBar];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr places data downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"_content" ascending:YES];
        NSArray *places = [[FlickrFetcher topPlaces] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem = self.refreshButton;
            if (![places isEqualToArray:self.tableData]){
                self.tableData = places;
                [self.tableView reloadData];
            }
        });
    });
}


-(void) showSpinnerInToolBar{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc]initWithCustomView:spinner];
    self.navigationItem.rightBarButtonItem = bbi;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"places";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell) cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"places"];
    NSDictionary *dic = [self.tableData objectAtIndex:indexPath.row];
    NSMutableArray *contentArray = [[[dic objectForKey:@"_content"] componentsSeparatedByString:@", "]mutableCopy];
    cell.textLabel.text = [contentArray objectAtIndex:0];
    [contentArray removeObjectAtIndex:0];
    cell.detailTextLabel.text = [contentArray componentsJoinedByString:@", "];

    return cell;
}

#pragma mark - Transitions


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isKindOfClass:[PhotosTVC class]]){
        PhotosTVC *vc = segue.destinationViewController;
        vc.place = [self.tableData objectAtIndex:[self.tableView indexPathForCell:sender].row];
    }
}

@end
