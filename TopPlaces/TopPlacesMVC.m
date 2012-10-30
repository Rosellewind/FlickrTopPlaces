//
//  TopPlacesMVC.m
//  TopPlaces
//
//  Created by Roselle Milvich on 10/29/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import "TopPlacesMVC.h"
#import "FlickrPhotoAnnotation.h"

@interface TopPlacesMVC ()

@end

@implementation TopPlacesMVC
@synthesize mapData = _mapData;
@synthesize mapView = _mapView;
@synthesize mapDelegate = _mapDelegate;

#pragma mark - Getters and Setters

-(void) setMapData:(NSArray *)mapData{
    if (![mapData isEqualToArray:self.mapData]){
        _mapData = mapData;
        [self updateMapView];
    }
}

-(void) setMapView:(MKMapView *)mapView{
    _mapView = mapView;
    mapView.delegate = self;
    self.mapDelegate = self;
    self.mapView.mapType = MKMapTypeHybrid;
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(15.623037,-38.320312), 10000000, 10000000) animated:YES];
    [self updateMapView];
}

#pragma mark - Map View

-(void) updateMapView{
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.mapData) [self.mapView addAnnotations:[self mapAnnotations]];
}

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

-(NSArray*) mapAnnotations{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:self.mapData.count];
    for (NSDictionary *place in self.mapData){
        [annotations addObject:[FlickrPhotoAnnotation annotationForPlace:place]];
    }
    return annotations;
}
-(UIImage*) viewController:(TopPlacesTVC*) vc imageForAnnotation:(id <MKAnnotation>) annotation{
    //move to photo
}
@end
