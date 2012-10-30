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

-(void) initialSetup{
    self.mapView.delegate = self;
    self.mapDelegate = self;
    self.mapView.mapType = MKMapTypeHybrid;
    NSDictionary *photo = [self.mapData objectAtIndex:0];
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake([[photo valueForKey:FLICKR_LATITUDE]doubleValue],[[photo valueForKey:FLICKR_LONGITUDE] doubleValue]), 100000, 100000) animated:YES];
}

#pragma mark - Map

-(MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    MKAnnotationView *annView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"annView"];
    if (!annView){
        annView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"annView"];
        annView.canShowCallout = YES;
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
         if ([mapView.selectedAnnotations containsObject:view]){
         dispatch_async(dispatch_get_main_queue(), ^{
         [(UIImageView*)view.leftCalloutAccessoryView setImage:image];
         });
         }
    });
}

-(void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    [self performSegueWithIdentifier:@"map to photo" sender:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isMemberOfClass:[PhotoVC class]]){
        PhotoVC *vc = (PhotoVC*)segue.destinationViewController;
        vc.photo = [[self.mapView.selectedAnnotations lastObject] photo];
    }
}


#pragma mark - MapDelegate
-(UIImage*) viewController:(TopPlacesMVC*) vc imageForAnnotation:(id <MKAnnotation>) annotation{
    FlickrPhotoAnnotation *ann = (FlickrPhotoAnnotation*)annotation;
    NSURL *photoURL = [FlickrFetcher urlForPhoto:ann.photo format:FlickrPhotoFormatSquare];
    NSData *data = [NSData dataWithContentsOfURL:photoURL];
    return data ? [UIImage imageWithData:data] : nil;
}


@end
