//
//  FlickrPhotoAnnotation.h
//  TopPlaces
//
//  Created by Roselle Milvich on 10/28/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

//part of controller, bridges model and view
@interface FlickrPhotoAnnotation : NSObject <MKAnnotation>

@property(nonatomic, strong) NSDictionary *photo;
@property(nonatomic, strong) NSDictionary *place;

+(FlickrPhotoAnnotation*) annotationForPhoto:(NSDictionary*)photo;
+(FlickrPhotoAnnotation*) annotationForPlace:(NSDictionary*)place;

@end
