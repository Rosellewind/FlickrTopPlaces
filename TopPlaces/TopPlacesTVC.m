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
#import "PhotosVC.h"

@interface TopPlacesTVC ()
@end

@implementation TopPlacesTVC
@synthesize tableData = _tableData;

#pragma mark - Getters and Setters

-(void) setTableData:(NSArray *)tableData{
    if (![tableData isEqualToArray:self.tableData]){
        _tableData = tableData;
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"places";
    UITableViewCell *cell = [[UITableViewCell  alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//ios6    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
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
    NSLog(@"prepareForSegue");
    if ([segue.destinationViewController isMemberOfClass:[PhotosVC class]]){
        PhotosVC *vc = segue.destinationViewController;
        vc.place = [self.tableData objectAtIndex:[self.tableView indexPathForCell:sender].row];
        vc.isUsingMapOrTable = USING_TABLE;
    }
}

//this method not needed for ios6
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        [self performSegueWithIdentifier:@"table to photos" sender:[tableView cellForRowAtIndexPath:indexPath]];
}

@end
