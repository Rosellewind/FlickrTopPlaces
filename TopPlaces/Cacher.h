//
//  Cacher.h
//  TopPlaces
//
//  Created by Roselle Milvich on 10/27/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cacher : NSObject
+(NSURL*) photoUrlForKey:(NSString*)key isThumb:(BOOL)isThumb;
+(void) cacheImage:(UIImage*)image withKey:(NSString*)key;
+(UIImage*) cachedImageForKey:(NSString*)key;
+(BOOL)isOverLimit;
+(void)removeCacheForKey:(NSString*)key;

@end
