//
//  CNKChatMessageModel.m
//  CNKChat
//
//  Created by chenkai on 2016/11/15.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKChatMessageModel.h"
#import "LKDBHelper.h"
#import "YTKKeyValueStore.h"
#import "CNKChatMessageSender.h"
#import "CNKChatMessageHelper.h"

@implementation CNKChatMessageModel

#pragma mark- setter

- (void)setMsgContent:(NSString *)msgContent{
    _msgContent = msgContent;
    _msgContentMd5Key = [CNKUtils md5String:_msgContent];
}

- (void)getMsgImageWithCompletionBlock:(void(^)(UIImage *msgImage))completionBlock{
    if (self.msgContentType != CNKMSGContentTypeImage || self.msgContent.length==0) {
        if (completionBlock) {
            completionBlock(nil);
        }
        return;
    }
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.msgContentMd5Key];
    if (image) {
        if (completionBlock) {
            completionBlock(image);
        }
    } else {
        if ([CNKUtils isValidateURL:self.msgContent]) {
            //valid url
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:self.msgContent] options:SDWebImageCacheMemoryOnly progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (!error && image && finished) {
                    [[SDImageCache sharedImageCache] storeImage:image forKey:self.msgContentMd5Key];
                    if (completionBlock) {
                        completionBlock(image);
                    }
                } else {
                    if (completionBlock) {
                        completionBlock(nil);
                    }
                }
            }];
        } else {
            //local path
            UIImage *image = [UIImage imageWithContentsOfFile:self.msgContent];
            [[SDImageCache sharedImageCache] storeImage:image forKey:self.msgContentMd5Key];
            if (completionBlock) {
                completionBlock(image);
            }
        }
    }
}

#pragma mark- class method

+ (NSString *)getTableName{
    return [NSString stringWithFormat:@"%@Table",NSStringFromClass([self class])];
}

@end


