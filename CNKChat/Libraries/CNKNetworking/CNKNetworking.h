//
//  CNKNetworking.h
//  CNKChat
//
//  Created by EasyBenefit on 16/12/15.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  使用startRequestWithUrl方法请求时的成功回调block
 *
 *  @param responseObj 返回值
 *  @param isCache  是否是缓存数据
 */
typedef void(^CNKRequestSuccessBlock)(id<NSCoding> responseObj, BOOL isCache);
typedef void(^CNKRequestFaliureBlock)(id errors);

typedef NS_ENUM(NSInteger, CNKRequestMethod){
    CNKRequestMethodGET = 0,
    CNKRequestMethodPOST = 1,
    CNKRequestMethodPUT = 2,
    CNKRequestMethodDELETE = 3
};

@interface CNKNetworking : NSObject

+ (instancetype) startRequestWithUrl:(NSString *)url
                          parameters:(id)parameters
                       requestMethod:(CNKRequestMethod)requestMethod
                       cacheResponse:(BOOL)cacheResponse
                         description:(NSString *)description
                        successBlock:(CNKRequestSuccessBlock)successBlock
                        faliureBlock:(CNKRequestFaliureBlock)faliureBlock;

@end
