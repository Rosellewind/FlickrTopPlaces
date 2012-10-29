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

+(FlickrPhotoAnnotation*) annotationForPhoto:(NSDictionary*)photo;

@end
