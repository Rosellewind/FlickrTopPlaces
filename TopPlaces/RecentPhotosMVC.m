//
//  RecentPhotosMVC.m
//  TopPlaces
//
//  Created by Roselle Milvich on 10/30/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import "RecentPhotosMVC.h"
#import "FlickrFetcher.h"
#import "PhotoVC.h"

@interface RecentPhotosMVC ()

@end

@implementation RecentPhotosMVC

-(void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    if (self.splitViewController){
        id vc = [self.splitViewController.viewControllers lastObject];
        if ([vc isKindOfClass:[PhotoVC class]]){
            [self prepareVC:vc withView:view];
            [vc loadImage];
        }
    }
    else [self performSegueWithIdentifier:@"recent map to photo" sender:view];
}
@end
