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

@interface TopPlacesTVC ()
@end

@implementation TopPlacesTVC
@synthesize tableData;

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    [self setData];
}

-(void)setData{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"_content" ascending:YES];
    self.tableData = [[FlickrFetcher topPlaces] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
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
