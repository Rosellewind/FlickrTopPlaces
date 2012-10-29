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


+(NSURL*) urlForKey:(NSString*)key{
    NSFileManager *manager = [[NSFileManager alloc]init];
    NSURL *cacheURL = [[manager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *url = [[cacheURL URLByAppendingPathComponent:@"photos"] URLByAppendingPathComponent:key];
    return url;
}

+(UIImage*) cachedImageForKey:(NSString*)key{
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[self urlForKey:key]]];
}
+(void) cacheImage:(UIImage*)image withKey:(NSString*)key{
    NSFileManager *manager = [[NSFileManager alloc]init];
    NSData *data = UIImagePNGRepresentation(image);
    
    if (![manager fileExistsAtPath:[[self urlForKey:@""] path]]) {
        [manager createDirectoryAtURL:[self urlForKey:@""] withIntermediateDirectories:NO attributes:nil error:nil];
    }
    [data writeToURL:[self urlForKey:key] atomically:YES];
}

+(BOOL)isOverLimit{
    NSFileManager *manager = [[NSFileManager alloc]init];
    if ([[manager attributesOfItemAtPath:[self urlForKey:@""].path error:nil]fileSize] > MB_TO_BYTE(10))
        return YES;
    else return NO;
}

+(void)removeCacheForKey:(NSString*)key{
    NSFileManager *manager = [[NSFileManager alloc]init];
    [manager removeItemAtURL:[self urlForKey:key] error:nil];
}

@end
