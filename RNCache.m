//
//  RNCache.m
//  currant
//
//  Created by Foster Yin on 6/16/15.
//  Copyright (c) 2015 Foster Yin. All rights reserved.
//

#import "RNCache.h"
#import "EGOCache.h"
#import "NSString+Sha1.h"

@interface RNCache () {
    NSArray *_hostList;

    NSArray *_exceptionRules;
}

@end


@implementation RNCache

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred;
    __strong static id sharedInstance = nil;

    dispatch_once(&pred, ^{
        sharedInstance = [[[self class] alloc] init];
    });

    return sharedInstance;
}


- (void)setHostList:(NSArray *)hostList {
    _hostList = hostList;
}

- (void)setExceptionRules:(NSArray *)exceptionRules {
    _exceptionRules = exceptionRules;
}

- (BOOL)isRequestPassRules:(NSURLRequest *)request {
    NSString *host = request.URL.host;
    NSString *urlStr = request.URL.absoluteString;
    if ([_hostList containsObject:host]) {
        __block id ret = nil;
        [_exceptionRules enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSRegularExpression *ex = [NSRegularExpression regularExpressionWithPattern:obj options:0 error:nil];
            NSRange matchRange = [ex rangeOfFirstMatchInString:urlStr options:0 range:NSMakeRange(0, urlStr.length)];
            if (matchRange.location != NSNotFound) {
                ret = obj;
                *stop = YES;
            }
        }];
        return ret == nil;
    }
    return NO;
}

- (void)setDefaultTimeoutInterval:(NSTimeInterval)timeoutInterval {
    [[EGOCache globalCache] setDefaultTimeoutInterval:timeoutInterval];
}

- (NSString *)keyForRequest:(NSURLRequest *)aRequest
{
    NSString *fileName = [[[aRequest URL] absoluteString] sha1];
    return fileName;
}

- (BOOL)isRequestCached:(NSURLRequest *)request {
    if (![self isRequestPassRules:request]) {
        return NO;
    }
    return [[[EGOCache globalCache] allKeys] containsObject:[self keyForRequest:request]];
}

- (RNCachedData *)getCacheForRequest:(NSURLRequest *)request {
    if (![self isRequestPassRules:request]) {
        return nil;
    }
    return (RNCachedData *)[[EGOCache globalCache] objectForKey:[self keyForRequest:request]];
}

- (void)saveCache:(RNCachedData *)cache forRequest:(NSURLRequest *)request {
    if (![self isRequestPassRules:request]) {
        return;
    }

    if (cache && cache.response) {
        [[EGOCache globalCache] setObject:cache forKey:[self keyForRequest:request]];
    }
}

- (void)clearCache
{
    [[EGOCache globalCache] clearCache];
}

- (void)removeCacheForRequest:(NSURLRequest *)request {
    [[EGOCache globalCache] removeCacheForKey:[self keyForRequest:request]];
}



@end
