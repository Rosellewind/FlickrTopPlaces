//
//  PhotosMVC.m
//  TopPlaces
//
//  Created by Roselle Milvich on 10/30/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import "PhotosMVC.h"
#import "FlickrPhotoAnnotation.h"
#import "FlickrFetcher.h"
#import "PhotoVC.h"


@interface PhotosMVC ()

@end

@implementation PhotosMVC


-(void) setRegion{
    CLLocationDegrees minLat, maxLat, minLon, maxLon;
    double pad = 0;//changes at .1, too far zoomed out
    double midLat, midLon, spanLat, spanLon;
    
    //iterate through annotations to find max and mins
    NSDictionary *place = [self.mapData objectAtIndex:0];
    minLat = maxLat = [[place valueForKey:FLICKR_LATITUDE]doubleValue];
    minLon = maxLon = [[place valueForKey:FLICKR_LONGITUDE]doubleValue];
    for (NSDictionary *dic in self.mapData){
        CLLocationDegrees lat = [[dic valueForKey:FLICKR_LATITUDE]doubleValue];
        CLLocationDegrees lon = [[dic valueForKey:FLICKR_LONGITUDE]doubleValue];
        if (lat < minLat) minLat = lat;
        if (lat > maxLat) maxLat = lat;
        if (lon < minLon) minLon = lon;
        if (lon > maxLon) maxLon = lon;
    }
    
    //span
    if ((minLat > 0 && maxLat > 0) || (minLat < 0 && maxLat < 0)){
        spanLat = fabs(minLat - maxLat);
    }
    else{
        spanLat = fabs(minLat) + fabs(maxLat);
    }
    if ((minLon > 0 && maxLon > 0) || (minLon < 0 && maxLon < 0)){
        spanLon = fabs(minLon - maxLon);
    }
    else{
        spanLon = fabs(minLon) + fabs(maxLon);
    }
    MKCoordinateSpan span = MKCoordinateSpanMake(spanLat + pad, spanLon + pad);
    
    //midpoint
    midLat = minLat + .5 * spanLat;
    midLon = minLon + .5 * spanLon;
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(midLat, midLon);
    
    [self.mapView setRegion:MKCoordinateRegionMake(center, span)];
//    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake([[photo valueForKey:FLICKR_LATITUDE]doubleValue],[[photo valueForKey:FLICKR_LONGITUDE] doubleValue]), 100000, 100000) animated:YES];
}
#pragma mark - Map

-(MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    MKAnnotationView *annView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"annView"];
    if (!annView){
        annView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"annView"];
        annView.canShowCallout = YES;
        annView.rightCalloutAccessoryView = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];

        annView.leftCalloutAccessoryView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    }
    else annView.annotation = annotation;
    
    [(UIImageView*)annView.leftCalloutAccessoryView setImage:nil];
    return annView;
}

-(NSArray*) mapAnnotations{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:self.mapData.count];
    for (NSDictionary *photo in self.mapData){
        [annotations addObject:[FlickrPhotoAnnotation annotationForPhoto:photo]];
    }
    return annotations;
}

-(void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    dispatch_queue_t downloadQueue = dispatch_queue_create("annotation image downloader", NULL);
    dispatch_async(downloadQueue, ^{
        UIImage *image = [self.mapDelegate viewController:self imageForAnnotation:view.annotation];
        if (
            [mapView.selectedAnnotations containsObject:view.annotation]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [(UIImageView*)view.leftCalloutAccessoryView setImage:image];
            });
        }
    });
}

-(void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    [self performSegueWithIdentifier:@"map to photo" sender:view];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isMemberOfClass:[PhotoVC class]]){
        PhotoVC *vc = (PhotoVC*)segue.destinationViewController;
        vc.photo = [(FlickrPhotoAnnotation*)[(MKAnnotationView*)sender annotation] photo];
    }
}

#pragma mark - MapDelegate
-(UIImage*) viewController:(TopPlacesMVC*) vc imageForAnnotation:(id <MKAnnotation>) annotation{//in thread
    FlickrPhotoAnnotation *ann = (FlickrPhotoAnnotation*)annotation;
    NSURL *photoURL = [FlickrFetcher urlForPhoto:ann.photo format:FlickrPhotoFormatSquare];
//    NSLog(@"fetching: imageForAnnotation");
    NSData *data = [NSData dataWithContentsOfURL:photoURL];
    return data ? [UIImage imageWithData:data] : nil;
}


@end
