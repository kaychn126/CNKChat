//
//  CNKUtils.h
//  CNKChat
//
//  Created by chenkai on 2016/11/15.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CNKUtils : NSObject

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kWidthRate(width) width*(kScreenWidth/375)
#define kRGBColor(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define kRGBAColor(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define kGrayColor(v) kRGBColor(v,v,v)
#define Weakfy(weakSelf)  __weak __typeof(&*self)weakSelf = self
#define Strongfy(strongSelf,weakSelf)  __strong __typeof(&*self) strongSelf = weakSelf
#define kQueryDBQueue [CNKCache sharedInstance].ioQueue


+ (BOOL)isValidateURL:(NSString *)url;

+ (long long)timestampWithDate:(NSDate *)date;

+ (NSString *)chatDateStringWithTimestamp:(long long)timestamp;

+ (NSString *)md5String:(NSString *)string;

+ (void)addHighlightViewToButton:(UIButton*)button;

+ (void)addHighlightViewToButton:(UIButton*)button withHighlightColor:(UIColor*)color;

+ (void)executeBlockInMainQueue:(dispatch_block_t)block;

+ (void)executeBlockInGlobalQueue:(dispatch_block_t)block;

//io线程中执行
+ (void)executeBlockInDBQueue:(dispatch_block_t)block;

+ (void)executeBlockInMainQueue:(dispatch_block_t)block delay:(double)delay;

+ (void)executeBlockInGlobalQueue:(dispatch_block_t)block delay:(double)delay;

//主线程定时器
+ (dispatch_source_t)mainQueueTimerWithInterval:(double)interval eventBlock:(dispatch_block_t)eventBlock;

//全局线程定时器
+ (dispatch_source_t)globalQueueTimerWithInterval:(double)interval eventBlock:(dispatch_block_t)eventBlock;

//指定定时器执行的线程
+ (dispatch_source_t)createTimerWithInterval:(double)interval queue:(dispatch_queue_t)queue eventBlock:(dispatch_block_t)eventBlock;

//暂停计时器
+ (void)resumeTimer:(dispatch_source_t)timer;

//取消计时器
+ (void)cancelTimer:(dispatch_source_t)timer;

+ (UIImage *)cutCenterImage:(UIImage *)image size:(CGSize)size;

+ (UIImage*)getSubImage:(UIImage *)image withRect:(CGRect)rect;
@end
