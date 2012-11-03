//
//  PhotosMVC.h
//  TopPlaces
//
//  Created by Roselle Milvich on 10/30/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopPlacesMVC.h"

@class PhotoVC;

@interface PhotosMVC : TopPlacesMVC

-(void)prepareVC:(PhotoVC*)vc withView:(MKAnnotationView*)view;

@end
