//
//  TopPlacesMVC.h
//  TopPlaces
//
//  Created by Roselle Milvich on 10/29/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class TopPlacesTVC;
@protocol MapDelegate <NSObject>
-(UIImage*) viewController:(TopPlacesTVC*) vc imageForAnnotation:(id <MKAnnotation>) annotation;
@end

@interface TopPlacesMVC : UIViewController <MKMapViewDelegate, MapDelegate>
@property (nonatomic, strong) NSArray *mapData;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) id <MapDelegate> mapDelegate;

@end
