//
//  PhotoVC.h
//  TopPlaces
//
//  Created by Roselle Milvich on 10/8/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButtonDancer.h"

@interface PhotoVC : UIViewController <ButtonDancer>

@property (nonatomic, strong) NSDictionary *photo;
@property (nonatomic, strong) NSString *description;

-(void)loadImage;
-(void)prepareImage;

    
@end
