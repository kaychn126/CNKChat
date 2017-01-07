//
//  CNKUtils.m
//  CNKChat
//
//  Created by chenkai on 2016/11/15.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKUtils.h"
#import "NSDate+Helper.h"
#import "NSDate+MCExtensions.h"

@implementation CNKUtils

+ (BOOL)isValidateURL:(NSString *)url{
    NSString *pattern = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:url];
    return isMatch;
}

+ (long long)timestampWithDate:(NSDate *)date{
    NSTimeInterval timeInterval = [date timeIntervalSince1970]*1000;
    return timeInterval;
}

+ (NSString *)chatDateStringWithTimestamp:(long long)timestamp{
    long long secTimestamp = timestamp/1000;
    long long todaySecTimestamp = [CNKUtils timestampWithDate:[NSDate date]]/1000;
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:secTimestamp];
    if ([date isToday]) {
        return [CNKUtils amOrPmStringWithDate:date];
    } else if (todaySecTimestamp - secTimestamp < 60*60*24*5){
        //五天之内显示星期
        NSString *weekString = @"星期";
        NSInteger weekNumber = [date weekday];
        if (weekNumber == 1) {
            weekString = [weekString stringByAppendingString:@"日"];
        } else if (weekNumber == 2) {
            weekString = [weekString stringByAppendingString:@"一"];
        } else if (weekNumber == 3) {
            weekString = [weekString stringByAppendingString:@"二"];
        } else if (weekNumber == 4) {
            weekString = [weekString stringByAppendingString:@"三"];
        } else if (weekNumber == 5) {
            weekString = [weekString stringByAppendingString:@"四"];
        } else if (weekNumber == 6) {
            weekString = [weekString stringByAppendingString:@"五"];
        } else if (weekNumber == 7) {
            weekString = [weekString stringByAppendingString:@"六"];
        }
        return [NSString stringWithFormat:@"%@ %@", weekString, [CNKUtils amOrPmStringWithDate:date]];
    } else {
        return [NSString stringWithFormat:@"%@ %@", [NSDate stringFromDate:date withFormat:@"yyyy年MM月dd日"], [CNKUtils amOrPmStringWithDate:date]];
    }
}

+ (NSString *)amOrPmStringWithDate:(NSDate *)date{
    NSInteger hour = [date hour];
    NSInteger minute = [date minute];
    
    NSString *minuteString = [NSString stringWithFormat:@"%ld",(long)minute];;
    if (minute < 10) {
        minuteString = [NSString stringWithFormat:@"0%ld",(long)minute];
    }
    
    if (hour < 12) {
        return [NSString stringWithFormat:@"上午%ld:%@",(long)hour, minuteString];
    } else if (hour > 12) {
        return [NSString stringWithFormat:@"下午%ld:%@",(long)(hour-12), minuteString];
    } else {
        return [NSString stringWithFormat:@"下午%ld:%@",(long)hour, minuteString];
    }
}

+ (NSString *)md5String:(NSString *)string{
    if (!string) {
        return nil;
    }
    return [CocoaSecurity md5:string].hex;
}

+ (void)addHighlightViewToButton:(UIButton*)button{
    [CNKUtils addHighlightViewToButton:button withHighlightColor:kRGBAColor(0, 0, 0, 0.1)];
}

+ (void)addHighlightViewToButton:(UIButton*)button withHighlightColor:(UIColor*)color{
    if (button && color) {
        UIImage *normalImage = [UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(10, 10)];
        UIImage *highlightImage = [UIImage imageWithColor:color size:CGSizeMake(10, 10)];
        [button setBackgroundImage:normalImage forState:UIControlStateNormal];
        [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    }
}

+ (void)executeBlockInMainQueue:(dispatch_block_t)block
{
    dispatch_main_async_safe(block);
}

+ (void)executeBlockInGlobalQueue:(dispatch_block_t)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

+ (void)executeBlockInDBQueue:(dispatch_block_t)block{

    dispatch_barrier_async(kQueryDBQueue, block);
}

+ (void)executeBlockInMainQueue:(dispatch_block_t)block delay:(double)delay
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay*NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

+ (void)executeBlockInGlobalQueue:(dispatch_block_t)block delay:(double)delay
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay*NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

//主线程定时器
+ (dispatch_source_t)mainQueueTimerWithInterval:(double)interval eventBlock:(dispatch_block_t)eventBlock{
    dispatch_queue_t  queue = dispatch_get_main_queue();
    
    return [CNKUtils createTimerWithInterval:interval queue:queue eventBlock:eventBlock];
}

//全局线程定时器
+ (dispatch_source_t)globalQueueTimerWithInterval:(double)interval eventBlock:(dispatch_block_t)eventBlock{
    // 全局队列
    dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    return [CNKUtils createTimerWithInterval:interval queue:queue eventBlock:eventBlock];
}

+ (dispatch_source_t)createTimerWithInterval:(double)interval queue:(dispatch_queue_t)queue eventBlock:(dispatch_block_t)eventBlock{
    // 创建一个 timer 类型定时器 （ DISPATCH_SOURCE_TYPE_TIMER）
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    //设置定时器的各种属性（何时开始，间隔多久执行）
    // GCD 的时间参数一般为纳秒 （1 秒 = 10 的 9 次方 纳秒）
    // 指定定时器开始的时间和间隔的时间
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, interval * NSEC_PER_SEC, 0);
    
    // 任务回调
    dispatch_source_set_event_handler(timer, eventBlock);
    
    dispatch_resume(timer);
    return timer;
}

+ (void)resumeTimer:(dispatch_source_t)timer{
    if (timer) {
        dispatch_activate(timer);
    }
}

+ (void)cancelTimer:(dispatch_source_t)timer{
    if (timer) {
        dispatch_cancel(timer);
    }
}

//根据size截取图片中间矩形区域的图片
+ (UIImage *)cutCenterImage:(UIImage *)image size:(CGSize)size{
    CGSize imageSize = image.size;
    
    CGFloat originX = size.width > imageSize.width?0:(imageSize.width-size.width)/2;
    CGFloat originY = size.height > imageSize.height?0:(imageSize.height-size.height)/2;
    CGFloat height = size.height > imageSize.height?imageSize.height:size.height;
    CGFloat width = size.width > imageSize.width?imageSize.width:size.width;
    
    return [CNKUtils getSubImage:image withRect:CGRectMake(originX*image.scale, originY*image.scale, width*image.scale, height*image.scale)];
}

+ (UIImage*)getSubImage:(UIImage *)image withRect:(CGRect)rect
{
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContextWithOptions(rect.size,NO,[UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    
    return smallImage;
}
@end
