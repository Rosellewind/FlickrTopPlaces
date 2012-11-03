//
//  PlacePhotosTVC.h
//  TopPlaces
//
//  Created by Roselle Milvich on 10/7/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopPlacesTVC.h"

@class PhotoVC;

@interface PhotosTVC : TopPlacesTVC
@property (nonatomic, strong) NSDictionary *place;

//prepareVC not needed in ios6
-(void)prepareVC:(PhotoVC*)vc;

@end
