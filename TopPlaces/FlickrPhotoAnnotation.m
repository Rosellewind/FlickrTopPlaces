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

+(FlickrPhotoAnnotation*) annotationForPhoto:(NSDictionary*)photo{
    FlickrPhotoAnnotation *annotation = [[FlickrPhotoAnnotation alloc]init];
    annotation.photo = photo;
    return annotation;
}

-(NSString*) title{
    NSString *title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
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
    return title;
}

-(NSString*) subtitle{
    NSString *title = [self.photo objectForKey:@"title"];
    NSString *description = [self.photo valueForKeyPath:@"description._content"];
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
    return description;
}

-(CLLocationCoordinate2D) coordinate{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.photo objectForKey:FLICKR_LATITUDE]doubleValue];
    coordinate.longitude = [[self.photo objectForKey:FLICKR_LONGITUDE]doubleValue];
    return coordinate;
}
@end
