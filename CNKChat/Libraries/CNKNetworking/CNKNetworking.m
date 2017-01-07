//
//  CNKNetworking.m
//  CNKChat
//
//  Created by EasyBenefit on 16/12/15.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKNetworking.h"
#import "AFNetworking.h"

@interface CNKNetworking()
@end

@implementation CNKNetworking

+ (instancetype) startRequestWithUrl:(NSString *)url
                          parameters:(id)parameters
                       requestMethod:(CNKRequestMethod)requestMethod
                       cacheResponse:(BOOL)cacheResponse
                         description:(NSString *)description
                        successBlock:(CNKRequestSuccessBlock)successBlock
                        faliureBlock:(CNKRequestFaliureBlock)faliureBlock{
    NSURLSessionConfiguration *sc = [[NSURLSessionConfiguration alloc] init];
    sc.timeoutIntervalForRequest = 25;
    sc.allowsCellularAccess = YES;
    
    return nil;
}

@end
