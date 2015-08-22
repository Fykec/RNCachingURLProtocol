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

    NSArray *_entityRequiredMIMETypes;

    NSArray *_allowedStatusCodes;
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

- (void)setResponseEntityRequiredMIMETypes:(NSArray *)mimeTypes {
    _entityRequiredMIMETypes = mimeTypes;
}

- (void)setAllowedResponseStatusCodes:(NSArray *)statusCodes {
    _allowedStatusCodes = statusCodes;
}

- (BOOL)isRequestPassRules:(NSURLRequest *)request {
    NSString *authority = request.URL.port? [NSString stringWithFormat:@"%@:%@", request.URL.host, request.URL.port]: request.URL.host;
    NSString *urlStr = request.URL.absoluteString;
    if ([_hostList containsObject:authority]) {
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

- (BOOL)isCachedResponseEntityRequired:(NSURLResponse *)response {
    NSString *mimeType = response.MIMEType;
    return [_entityRequiredMIMETypes containsObject:mimeType];
}

- (BOOL)isAllowedResponseStatusCode:(NSURLResponse *)response {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
        return [_allowedStatusCodes containsObject:@(statusCode)];
    }
    else {
        return YES;
    }
}

- (RNCachedData *)getCacheForRequest:(NSURLRequest *)request {
    if (![self isRequestPassRules:request]) {
        return nil;
    }
    RNCachedData *cache = (RNCachedData *)[[EGOCache globalCache] objectForKey:[self keyForRequest:request]];
    if ([self isCachedResponseEntityRequired:cache.response]) {
        if (cache.data) {
            return cache;
        }
        else {
            return nil;
        }
    }
    else {
        return cache;
    }
}

- (void)saveCache:(RNCachedData *)cache forRequest:(NSURLRequest *)request {
    if (![self isRequestPassRules:request]) {
        return;
    }

    if (cache && cache.response && [self isAllowedResponseStatusCode:cache.response]) {
        if ([self isCachedResponseEntityRequired:cache.response]) {
            if (cache.data) {
                [[EGOCache globalCache] setObject:cache forKey:[self keyForRequest:request]];
            }
        }
        else {
            [[EGOCache globalCache] setObject:cache forKey:[self keyForRequest:request]];
        }
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
