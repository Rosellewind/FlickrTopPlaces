//
//  Cacher.m
//  TopPlaces
//
//  Created by Roselle Milvich on 10/27/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import "Cacher.h"

#define MB_TO_BYTE(mb) mb * 1048576

@implementation Cacher


+(NSURL*) photoUrlForKey:(NSString*)key isThumb:(BOOL)isThumb{
    NSString *pathComponent = isThumb ? @"thumb" : @"photos";
    NSFileManager *manager = [[NSFileManager alloc]init];
    NSURL *cacheURL = [[manager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *url = [[cacheURL URLByAppendingPathComponent:pathComponent] URLByAppendingPathComponent:key];
    return url;
}

+(UIImage*) cachedImageForKey:(NSString*)key isThumb:(BOOL)isThumb{
//    NSLog(@"fetching: cachedImageForKey");
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[self photoUrlForKey:key isThumb:isThumb]]];
}

+(void) cacheImage:(UIImage*)image withKey:(NSString*)key isThumb:(BOOL)isThumb{
    NSFileManager *manager = [[NSFileManager alloc]init];
    NSData *data = UIImagePNGRepresentation(image);
    
    if (![manager fileExistsAtPath:[[self photoUrlForKey:@"" isThumb:isThumb] path]]) {
        [manager createDirectoryAtURL:[self photoUrlForKey:@"" isThumb:isThumb] withIntermediateDirectories:NO attributes:nil error:nil];
    }
    [data writeToURL:[self photoUrlForKey:key isThumb:isThumb] atomically:YES];
}

+(BOOL)isOverLimitIsThumb:(BOOL)isThumb{
    NSFileManager *manager = [[NSFileManager alloc]init];
    int maxMB = isThumb ? 2 : 10;
    if ([[manager attributesOfItemAtPath:[self photoUrlForKey:@"" isThumb:isThumb].path error:nil]fileSize] > MB_TO_BYTE(maxMB))
        return YES;
    else return NO;
}

+(void)removeCacheForKey:(NSString*)key isThumb:(BOOL)isThumb{
    NSFileManager *manager = [[NSFileManager alloc]init];
    [manager removeItemAtURL:[self photoUrlForKey:key isThumb:isThumb] error:nil];
}

@end
