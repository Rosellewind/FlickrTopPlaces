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
#import "Cacher.h"
//#import "PhotosVC.h"


@interface PhotosMVC ()
@property (strong, nonatomic) NSMutableArray *cachedThumbs;
@end

@implementation PhotosMVC
@synthesize cachedThumbs = _cachedThumbs;

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
}

#pragma mark - Map View Delegate

-(UIImage*) viewController:(TopPlacesMVC*) vc imageForAnnotation:(id <MKAnnotation>) annotation{//in thread
    FlickrPhotoAnnotation *ann = (FlickrPhotoAnnotation*)annotation;
    NSURL *photoURL = [FlickrFetcher urlForPhoto:ann.photo format:FlickrPhotoFormatSquare];
    
    //    NSLog(@"fetching: imageForAnnotation");
    NSData *data = [NSData dataWithContentsOfURL:photoURL];
    return data ? [UIImage imageWithData:data] : nil;
}

-(void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    NSString *key = [[(FlickrPhotoAnnotation*)view.annotation photo] objectForKey:@"id"];
    
    //check to see if photo is cached
    UIImage *cachedImage = [Cacher cachedImageForKey:key isThumb:YES];
    if (cachedImage){
        [(UIImageView*)view.leftCalloutAccessoryView setImage:cachedImage];
    }
    else{
        //get photo
        dispatch_queue_t downloadQueue = dispatch_queue_create("annotation image downloader", NULL);
        dispatch_async(downloadQueue, ^{
            UIImage *image = [self.mapDelegate viewController:self imageForAnnotation:view.annotation];
            if (
                [mapView.selectedAnnotations containsObject:view.annotation]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [(UIImageView*)view.leftCalloutAccessoryView setImage:image];
                });
            }
            //manage cache
            [self.cachedThumbs insertObject:key atIndex:0];
            if ([Cacher isOverLimitIsThumb:YES]){
                [Cacher removeCacheForKey:[self.cachedThumbs lastObject] isThumb:YES];// take ooff isthumb
                [self.cachedThumbs removeLastObject];
            }
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:self.cachedThumbs forKey:@"cachedThumbs"];
            [defaults synchronize];
            [Cacher cacheImage:image withKey:key isThumb:YES];
        });
    }
}

-(void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    if (self.splitViewController){
        id vc = [self.splitViewController.viewControllers lastObject];
        if ([vc isKindOfClass:[PhotoVC class]]){
            [self prepareVC:vc withView:view];
            [vc loadImage];
        }
    }
    else [self performSegueWithIdentifier:@"map to photo" sender:view];
}

#pragma mark - Transitions

-(void)prepareVC:(PhotoVC*)vc withView:(MKAnnotationView*)view{
    NSDictionary *photo = [(FlickrPhotoAnnotation*)[(MKAnnotationView*)view annotation] photo];
    [Cacher savePicToRecentlyViewed:photo];
    vc.photo = photo;
    vc.description =[(FlickrPhotoAnnotation*)view.annotation title];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isMemberOfClass:[PhotoVC class]]){
        PhotoVC *vc = (PhotoVC*)segue.destinationViewController;
        [self prepareVC:vc withView:(MKAnnotationView*)sender];
        vc.photo = [(FlickrPhotoAnnotation*)[(MKAnnotationView*)sender annotation] photo];
    }
}

#pragma mark - Life Cycle

-(void)viewDidLoad{
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.cachedThumbs = [[defaults arrayForKey:@"cachedThumbs"]mutableCopy];
    if (!self.cachedThumbs) self.cachedThumbs = [[NSMutableArray alloc]init];
}


@end
