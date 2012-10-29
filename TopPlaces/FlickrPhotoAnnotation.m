//
//  FlickrPhotoAnnotation.m
//  TopPlaces
//
//  Created by Roselle Milvich on 10/28/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import "FlickrPhotoAnnotation.h"
#import "FlickrFetcher.h"

@implementation FlickrPhotoAnnotation
@synthesize photo = _photo;
@synthesize place = _place;

+(FlickrPhotoAnnotation*) annotationForPhoto:(NSDictionary*)photo{
    FlickrPhotoAnnotation *annotation = [[FlickrPhotoAnnotation alloc]init];
    annotation.photo = photo;
    return annotation;
}

+(FlickrPhotoAnnotation*) annotationForPlace:(NSDictionary*)place{
    FlickrPhotoAnnotation *annotation = [[FlickrPhotoAnnotation alloc]init];
    annotation.place = place;
    return annotation;
}

-(NSString*) title{
    NSString *title;
    if (self.place) {
        NSArray *contentArray = [[self.place objectForKey:FLICKR_PHOTO_CONTENT] componentsSeparatedByString:@", "];
        title = [contentArray objectAtIndex:0];
    }
    else{
        title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
        NSString *description = [self.photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        if (!title) title = @"";
        if (!description) description = @"";
        if (title.length == 0){
            if (description.length ==0)
                title = @"Unknown";
            else{
                title = description;
                description = @"";
            }
        }
    }
    return title;
}

-(NSString*) subtitle{
    NSString *subtitle;
    if (self.place) {
        NSArray *contentArray = [[self.place objectForKey:FLICKR_PHOTO_CONTENT] componentsSeparatedByString:@", "];
        subtitle = [contentArray objectAtIndex:1];
    }
    else {
        NSString *title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
        subtitle = [self.photo objectForKey:FLICKR_PHOTO_CONTENT];
        if (!title) title = @"";
        if (!subtitle) subtitle = @"";
        if (title.length == 0){
            if (subtitle.length ==0)
                title = @"Unknown";
            else{
                title = subtitle;
                subtitle = @"";
            }
        }
    }
    return subtitle;
}

-(CLLocationCoordinate2D) coordinate{
    CLLocationCoordinate2D coordinate;
    if (self.place){
    coordinate.latitude = [[self.place objectForKey:FLICKR_LATITUDE]doubleValue];
    coordinate.longitude = [[self.place objectForKey:FLICKR_LONGITUDE]doubleValue];
    }
    else {
        coordinate.latitude = [[self.photo objectForKey:FLICKR_LATITUDE]doubleValue];
        coordinate.longitude = [[self.photo objectForKey:FLICKR_LONGITUDE]doubleValue];
    }
    return coordinate;
}
@end
