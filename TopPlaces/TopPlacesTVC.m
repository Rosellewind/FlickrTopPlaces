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
#import "FlickrPhotoAnnotation.h"

@interface TopPlacesTVC ()
@end

@implementation TopPlacesTVC
@synthesize tableData = _tableData;
@synthesize tableView = _tableView;
@synthesize mapView = _mapView;
@synthesize mapDelegate = _mapDelegate;

#pragma mark - Getters and Setters

-(void) setMapView:(MKMapView *)mapView{
    _mapView = mapView;
    mapView.delegate = self;
    self.mapDelegate = self;
    self.mapView.mapType = MKMapTypeHybrid;
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(15.623037,-38.320312), 10000000, 10000000) animated:YES];
    [self updateMapView];
}
-(void) setTableData:(NSArray *)tableData{
    _tableData = tableData;
    [self.tableView reloadData];
    [self updateMapView];//every time? ipad?
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
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
            if (![places isEqualToArray:self.tableData])
                self.tableData = places;
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

#pragma mark - Map View

-(MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    MKAnnotationView *annView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"annView"];
    if (!annView){
        annView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"annView"];
        annView.canShowCallout = YES;
        annView.rightCalloutAccessoryView = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
    }
    else annView.annotation = annotation;
    return annView;
}
 
-(void) updateMapView{
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.tableData) [self.mapView addAnnotations:[self mapAnnotations]];
}

-(NSArray*) mapAnnotations{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:self.tableData.count];
    for (NSDictionary *place in self.tableData){
        [annotations addObject:[FlickrPhotoAnnotation annotationForPlace:place]];
    }
    return annotations;
}

#pragma mark - Transitions

- (IBAction)choseView:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        [UIView transitionFromView:self.mapView toView:self.tableView duration:.7 options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionCurveEaseIn completion:nil];
    }
    else{
        [self updateMapView];
        [UIView transitionFromView:self.tableView toView:self.mapView duration:.7 options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionFlipFromRight | UIViewAnimationOptionCurveEaseIn completion:nil];
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isKindOfClass:[PhotosTVC class]]){
        PhotosTVC *vc = segue.destinationViewController;
        vc.place = [self.tableData objectAtIndex:[self.tableView indexPathForCell:sender].row];
    }
}

@end
