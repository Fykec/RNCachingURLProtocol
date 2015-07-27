//
//  RNCache.h
//  currant
//
//  Created by Foster Yin on 6/16/15.
//  Copyright (c) 2015 Foster Yin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNCachedData.h"

@interface RNCache : NSObject

+ (instancetype)sharedInstance;

- (void)setHostList:(NSArray *)hostList; // host array

- (void)setExceptionRules:(NSArray *)exceptionRules; //regex

- (void)setDefaultTimeoutInterval:(NSTimeInterval)timeoutInterval;

- (BOOL)isRequestCached:(NSURLRequest *)request;

- (RNCachedData *)getCacheForRequest:(NSURLRequest *)request;

- (void)saveCache:(RNCachedData *)cache forRequest:(NSURLRequest *)request;

- (void)clearCache;

- (void)removeCacheForRequest:(NSURLRequest *)request

@end
