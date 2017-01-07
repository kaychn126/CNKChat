//
//  CNKCache.m
//  CNKChat
//
//  Created by chenkai on 2016/11/16.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKCache.h"
#import "YYCache.h"

@interface CNKCache()
@property(nonatomic, strong)YYCache *globalCache;
@end

@implementation CNKCache
+ (CNKCache*)sharedInstance{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedInstance = [[self alloc] initSingleton];
    });
    return sharedInstance;
}

- (instancetype)initSingleton{
    self = [super init];
    if(self){
        NSString* cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        cachesDirectory = [[[cachesDirectory stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]] stringByAppendingPathComponent:@"YYCacheDirectory"] copy];
        _globalCache = [[YYCache alloc] initWithPath:cachesDirectory];
        _globalCache.memoryCache.countLimit = 50;
        _globalCache.diskCache.countLimit = 100;
        _ioQueue = dispatch_queue_create("com.cnkchat.query_db_queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (instancetype)init{
    return [CNKCache sharedInstance];
}

- (BOOL)containsObjectForKey:(NSString *)key{
    return [_globalCache containsObjectForKey:key];
}

- (void)containsObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key, BOOL contains))block{
    [_globalCache containsObjectForKey:key withBlock:block];
}

- (id<NSCoding>)cacheObjectForKey:(NSString *)key{
    return [_globalCache objectForKey:key];
}

- (void)cacheObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key, id<NSCoding> object))block{
    [_globalCache objectForKey:key withBlock:block];
}

- (void)setCacheObject:(id<NSCoding>)object forKey:(NSString *)key{
    [_globalCache setObject:object forKey:key];
}


- (void)setCacheObject:(id<NSCoding>)object forKey:(NSString *)key withBlock:(void(^)(void))block;{
    [_globalCache setObject:object forKey:key withBlock:block];
}


- (void)removeObjectForKey:(NSString *)key{
    [_globalCache removeObjectForKey:key];
}


- (void)removeObjectForKey:(NSString *)key withBlock:(void(^)(NSString *key))block{
    [_globalCache removeObjectForKey:key withBlock:block];
}


- (void)removeAllObjects{
    [_globalCache removeAllObjects];
}


- (void)removeAllObjectsWithBlock:(void(^)(void))block{
    [_globalCache removeAllObjectsWithBlock:block];
}


- (void)removeAllObjectsWithProgressBlock:(void(^)(int removedCount, int totalCount))progress
                                 endBlock:(void(^)(BOOL error))end{
    [_globalCache removeAllObjectsWithProgressBlock:progress endBlock:end];
}
@end
