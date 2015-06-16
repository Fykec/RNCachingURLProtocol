//
//  RNCachedData.h
//  currant
//
//  Created by Foster Yin on 6/15/15.
//  Copyright (c) 2015 Foster Yin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RNCachedData : NSObject <NSCoding>

@property (nonatomic, readwrite, strong) NSData *data;

@property (nonatomic, readwrite, strong) NSURLResponse *response;

@property (nonatomic, readwrite, strong) NSURLRequest *redirectRequest;



@end