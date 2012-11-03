//
//  Cacher.h
//  TopPlaces
//
//  Created by Roselle Milvich on 10/27/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cacher : NSObject

//save to sandbox
+(NSURL*) photoUrlForKey:(NSString*)key isThumb:(BOOL)isThumb;
+(UIImage*) cachedImageForKey:(NSString*)key isThumb:(BOOL)isThumb;
+(void) cacheImage:(UIImage*)image withKey:(NSString*)key isThumb:(BOOL)isThumb;
+(BOOL)isOverLimitIsThumb:(BOOL)isThumb;
+(void)removeCacheForKey:(NSString*)key isThumb:(BOOL)isThumb;

//save to nsuserdefaults
+(void)savePicToRecentlyViewed:(NSDictionary*)photo;

@end
