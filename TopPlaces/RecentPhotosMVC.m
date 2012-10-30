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
-(void) initialSetup{//maybe?
    NSLog(@"initialMapSetup");
    [super initialSetup];
    NSDictionary *photo = [self.mapData objectAtIndex:0];
    
    //    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake([[photo valueForKey:FLICKR_LATITUDE]doubleValue],[[photo valueForKey:FLICKR_LONGITUDE] doubleValue]), MKCoordinateSpanMake(1, 1)) animated:YES];
    
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake([[photo valueForKey:FLICKR_LATITUDE]doubleValue],[[photo valueForKey:FLICKR_LONGITUDE] doubleValue]), 1, 1) animated:YES];
}

@end
