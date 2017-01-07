//
//  CNKCache.h
//  CNKChat
//
//  Created by chenkai on 2016/11/16.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CNKCache : NSObject
+ (CNKCache*)sharedInstance;
@property (nonatomic, strong) dispatch_queue_t ioQueue;

- (BOOL)containsObjectForKey:(NSString *)key;


- (void)containsObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key, BOOL contains))block;


- (id<NSCoding>)cacheObjectForKey:(NSString *)key;


- (void)cacheObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key, id<NSCoding> object))block;


- (void)setCacheObject:(id<NSCoding>)object forKey:(NSString *)key;


- (void)setCacheObject:(id<NSCoding>)object forKey:(NSString *)key withBlock:(void(^)(void))block;


- (void)removeObjectForKey:(NSString *)key;


- (void)removeObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key))block;


- (void)removeAllObjects;


- (void)removeAllObjectsWithBlock:(void(^)(void))block;


- (void)removeAllObjectsWithProgressBlock:(void(^)(int removedCount, int totalCount))progress
                                 endBlock:(void(^)(BOOL error))end;
@end
