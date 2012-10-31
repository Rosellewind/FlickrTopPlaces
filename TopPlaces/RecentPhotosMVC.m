//
//  RecentPhotosMVC.m
//  TopPlaces
//
//  Created by Roselle Milvich on 10/30/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import "RecentPhotosMVC.h"
#import "FlickrFetcher.h"

@interface RecentPhotosMVC ()

@end

@implementation RecentPhotosMVC
-(void) setRegion{//delete*************
    NSDictionary *photo = [self.mapData objectAtIndex:0];
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake([[photo valueForKey:FLICKR_LATITUDE]doubleValue],[[photo valueForKey:FLICKR_LONGITUDE] doubleValue]), 100000, 100000) animated:YES];
}

@end
