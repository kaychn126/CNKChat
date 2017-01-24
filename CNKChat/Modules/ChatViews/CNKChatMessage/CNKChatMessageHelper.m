//
//  CNKChatMessageManager.m
//  CNKChat
//
//  Created by chenkai on 2016/11/18.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKChatMessageHelper.h"
#import "CNKChatMessageModel.h"
#import "CNKChatLocationCell.h"

@implementation CNKChatMessageHelper

+ (BOOL)isMyMessage:(CNKChatMessageModel *)message{
    if ([message.senderId isEqualToString:@"123"]) {
        return YES;
    }
    return NO;
}

#pragma mark- query messages

+ (void)loadImageMessagesWithConversationId:(NSString *)conversationId resultBlock:(void(^)(NSArray<CNKChatMessageModel *> *messageList))resultBlock{
    [CNKUtils executeBlockInDBQueue:^{
        NSString *sqlString = [NSString stringWithFormat:@"select * from %@ where conversationId='%@' and onwerId='%@' and msgContentType=2 order by timestamp desc",[CNKChatMessageModel getTableName],conversationId,[CNKLoginUser sharedInstance].userId];
        NSArray <CNKChatMessageModel *> *msgList = [CNKChatMessageModel searchWithSQL:sqlString];
        [CNKUtils executeBlockInMainQueue:^{
            if (resultBlock) {
                resultBlock([[msgList reverseObjectEnumerator] allObjects]);
            }
        }];
    }];
}

+ (void)loadFirstPageWithConversationId:(NSString *)conversationId resultBlock:(void(^)(NSArray<CNKChatMessageModel *> *messageList, BOOL hasMoreData))resultBlock{
    
    const NSInteger numberPerPage = 10;
    BOOL moreData = NO;
    NSString *sqlString = [NSString stringWithFormat:@"conversationId='%@' and onwerId='%@'",conversationId,[CNKLoginUser sharedInstance].userId];
    NSInteger allMessageCount = [CNKChatMessageModel rowCountWithWhere:sqlString];
    
    moreData = allMessageCount<=numberPerPage?NO:YES;
    NSArray *savedMessageList = [CNKChatMessageModel searchWithWhere:sqlString orderBy:@"timestamp desc" offset:0 count:numberPerPage];
    
    NSArray *msgList = [[savedMessageList reverseObjectEnumerator] allObjects];
    
    //缓存本页及下页数据
    [CNKUtils executeBlockInDBQueue:^{
        [msgList enumerateObjectsUsingBlock:^(CNKChatMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [[SDImageCache sharedImageCache] queryDiskCacheForKey:obj.msgContentMd5Key done:^(UIImage *image, SDImageCacheType cacheType) {
                
            }];
        }];
        
        [CNKChatMessageHelper preMemoryCacheImageDataWithLastMessage:[msgList firstObject]];
    }];
    
    if (resultBlock) {
        resultBlock([CNKChatMessageHelper checkShowDateWithMsgList:msgList], moreData);
    }
}

+ (void)loadNextPageWithLastMessage:(CNKChatMessageModel *)lastMessage resultBlock:(void(^)(NSArray<CNKChatMessageModel *> *messageList, BOOL hasMoreData))resultBlock{
    
    if (!lastMessage) {
        //没有lastMessage，返回nil
        if (resultBlock) {
            resultBlock(nil, NO);
        }
    } else {
        
        //从本地数据库加载数据库
        [CNKUtils executeBlockInDBQueue:^{
            const NSInteger numberPerPage = 20;
            NSString *sqlString = [NSString stringWithFormat:@"conversationId='%@' and onwerId='%@'",lastMessage.conversationId,[CNKLoginUser sharedInstance].userId];
            NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ and timestamp<%lld order by timestamp desc limit %ld",[CNKChatMessageModel getTableName], sqlString, lastMessage.timestamp, (long)numberPerPage];
            NSArray<CNKChatMessageModel *> *savedMessageList = [CNKChatMessageModel searchWithSQL:sql];
            BOOL moreData = savedMessageList.count < numberPerPage?NO:YES;
            NSArray *msgList = [CNKChatMessageHelper checkShowDateWithMsgList:[[savedMessageList reverseObjectEnumerator] allObjects]];
            
            [CNKChatMessageHelper preMemoryCacheImageDataWithLastMessage:[msgList firstObject]];
            
            [CNKUtils executeBlockInMainQueue:^{
                if (resultBlock) {
                    resultBlock(msgList, moreData);
                }
            }];
        }];
    }
}

//获取下一页图片消息
+ (void)loadNextPageImageMessagesWithLastMessage:(CNKChatMessageModel *)lastMessage resultBlock:(void(^)(NSArray<CNKChatMessageModel *> *messageList))resultBlock{
    
    if (!lastMessage) {
        //没有lastMessage，返回nil
        if (resultBlock) {
            resultBlock(nil);
        }
    } else {
        
        //从本地数据库加载数据库
        [CNKUtils executeBlockInDBQueue:^{
            const NSInteger numberPerPage = 20;
            NSString *sqlString = [NSString stringWithFormat:@"conversationId='%@' and onwerId='%@' and msgContentType=%ld",lastMessage.conversationId,[CNKLoginUser sharedInstance].userId, (long)CNKMSGContentTypeImage];
            NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ and timestamp<%lld order by timestamp desc limit %ld",[CNKChatMessageModel getTableName], sqlString, lastMessage.timestamp, (long)numberPerPage];
            NSArray<CNKChatMessageModel *> *savedMessageList = [CNKChatMessageModel searchWithSQL:sql];
            if (resultBlock) {
                resultBlock(savedMessageList);
            }
        }];
    }
}

//获取指定会话的所有消息
+ (void)loadMessagesWithConversationId:(NSString *)conversationId resultBlock:(void(^)(NSArray<CNKChatMessageModel *> *messageList))resultBlock{
    if (!conversationId) {
        if (resultBlock) {
            resultBlock(nil);
        }
        return;
    }
    
    //从本地数据库加载数据库
    [CNKUtils executeBlockInDBQueue:^{
        NSString *sqlString = [NSString stringWithFormat:@"conversationId='%@' and onwerId='%@'",conversationId,[CNKLoginUser sharedInstance].userId];
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ ",[CNKChatMessageModel getTableName], sqlString];
        NSArray<CNKChatMessageModel *> *savedMessageList = [CNKChatMessageModel searchWithSQL:sql];
        if (resultBlock) {
            resultBlock(savedMessageList);
        }
    }];
}

//获取所有会话的消息
+ (void)loadAllMessagesWithResultBlock:(void(^)(NSArray<CNKChatMessageModel *> *messageList))resultBlock{
    //从本地数据库加载数据库
    [CNKUtils executeBlockInDBQueue:^{
        NSString *sqlString = [NSString stringWithFormat:@"onwerId='%@'", [CNKLoginUser sharedInstance].userId];
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ ",[CNKChatMessageModel getTableName], sqlString];
        NSArray<CNKChatMessageModel *> *savedMessageList = [CNKChatMessageModel searchWithSQL:sql];
        if (resultBlock) {
            resultBlock(savedMessageList);
        }
    }];
}

+ (NSArray <CNKChatMessageModel*>*)checkShowDateWithMsgList:(NSArray <CNKChatMessageModel*>*)msgList{
    
    [msgList enumerateObjectsUsingBlock:^(CNKChatMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *sqlString = [NSString stringWithFormat:@"conversationId='%@' and onwerId='%@'",obj.conversationId,[CNKLoginUser sharedInstance].userId];
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ and timestamp<%lld order by timestamp desc limit 1", [CNKChatMessageModel getTableName], sqlString, obj.timestamp];
        NSArray<CNKChatMessageModel *> *savedMessageList = [CNKChatMessageModel searchWithSQL:sql];
        if (savedMessageList.count == 0) {
            obj.showTime = YES;
        } else {
            CNKChatMessageModel *preMessage = [savedMessageList lastObject];
            double timeInterval = obj.timestamp - preMessage.timestamp;
            if (timeInterval >= 60*1000) {
                obj.showTime = YES;
            } else {
                obj.showTime = NO;
            }
        }
    }];
    return msgList;
}

#pragma mark- cache

//在后台线程中预计算指定会话的cell高度并缓存
+ (void)preCalculateAndCacheCellHeightWithConversationId:(NSString *)conversationId{
    [CNKChatMessageHelper loadMessagesWithConversationId:conversationId resultBlock:^(NSArray<CNKChatMessageModel *> *messageList) {
        [CNKChatMessageHelper cellHeightWithMsgList:messageList];
    }];
}

//在后台线程中预计算所有会话的cell高度并缓存
+ (void)preCalculateAndCacheAllCellHeight{
    [CNKChatMessageHelper loadAllMessagesWithResultBlock:^(NSArray<CNKChatMessageModel *> *messageList) {
        [CNKChatMessageHelper cellHeightWithMsgList:messageList];
    }];
}

+ (void)preMemoryCacheImageDataWithLastMessage:(CNKChatMessageModel *)message{
    [CNKChatMessageHelper loadNextPageImageMessagesWithLastMessage:message resultBlock:^(NSArray<CNKChatMessageModel *> *messageList) {
        if (messageList.count > 0) {
            [messageList enumerateObjectsUsingBlock:^(CNKChatMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [[SDImageCache sharedImageCache] queryDiskCacheForKey:obj.msgContentMd5Key done:^(UIImage *image, SDImageCacheType cacheType) {
                    
                }];
            }];
        }
    }];
}

#pragma mark- cell height

+ (double)cellHeightWithMsg:(CNKChatMessageModel*)message{
    NSNumber *cellHeightNumber = (NSNumber *)[[CNKCache sharedInstance] cacheObjectForKey:message.msgId];
    if (cellHeightNumber) {
        return [cellHeightNumber doubleValue];
    }
    
    Class clazz = NSClassFromString([CNKChatBaseCell classNameWithContentType:message.msgContentType]);
    double cellHeight = [clazz cellContentHeightWithMsg:message];
    cellHeight = message.showTime?cellHeight+kCNKChatCellShowTimeTopInset:cellHeight+kCNKChatCellHideTimeTopInset;
    
    if (cellHeight > 0) {
        [[CNKCache sharedInstance] setCacheObject:[NSNumber numberWithDouble:cellHeight] forKey:message.msgId];
    }
    
    return cellHeight;
}

+ (double)cellHeightWithMsgList:(NSArray<CNKChatMessageModel *>*)msgList{
    __block double cellHeight = 0;
    [msgList enumerateObjectsUsingBlock:^(CNKChatMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        cellHeight += [CNKChatMessageHelper cellHeightWithMsg:obj];
    }];
    return cellHeight;
}

+ (void)cellHeightWithMsg:(CNKChatMessageModel*)message resultBlock:(void(^)(double cellHeight))resultBlock{
    [CNKUtils executeBlockInGlobalQueue:^{
        
        double cellHeight = [CNKChatMessageHelper cellHeightWithMsg:message];
        
        [CNKUtils executeBlockInMainQueue:^{
            
            if (resultBlock) {
                resultBlock(cellHeight);
            }
            
        }];
    }];
}

+ (CGSize)plainTextSizeWithMsg:(CNKChatMessageModel*)message{
    if (message.msgContentType == CNKMSGContentTypePlainText) {
        [SingleTextLabel sharedInstance].font = [UIFont systemFontOfSize:16];
        [SingleTextLabel sharedInstance].text = message.msgContent;
        CGSize textSize = [[SingleTextLabel sharedInstance] sizeThatFits:CGSizeMake(kScreenWidth-160, NSIntegerMax)];
        return textSize;
    }
    return CGSizeZero;
}

+ (double)timeLabelWidthWithFont:(UIFont*)font text:(NSString *)text{
    NSNumber *cellHeightNumber = (NSNumber*)[[CNKCache sharedInstance] cacheObjectForKey:text];
    if (cellHeightNumber) {
        return [cellHeightNumber doubleValue];
    }
    
    [SingleTextLabel sharedInstance].font = font;
    [SingleTextLabel sharedInstance].text = text;
    CGSize textSize = [[SingleTextLabel sharedInstance] sizeThatFits:CGSizeMake(kScreenWidth-30, NSIntegerMax)];
    [[CNKCache sharedInstance] setCacheObject:[NSNumber numberWithDouble:textSize.width] forKey:text];
    return textSize.width;
}

+ (CGSize)imageSizeWithMsg:(CNKChatMessageModel*)message{
    if (message.msgContentType != CNKMSGContentTypeImage) {
        return CGSizeZero;
    }
    
    //search from cache
    NSString *sizeValueCacheKey = [message.msgContentMd5Key stringByAppendingString:@"imagesize"];
    NSValue *sizeValue = (NSValue*)[[CNKCache sharedInstance] cacheObjectForKey:sizeValueCacheKey];
    if (sizeValue) {
        return [sizeValue CGSizeValue];
    }
    
    UIImage *msgImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:message.msgContentMd5Key];
    if (msgImage) {
        const double maxHeight = (kScreenWidth-60)/2;
        const double minHeight = maxHeight*0.6;
        CGSize originSize = msgImage.size;
        double scale = 1;
        if (originSize.width > originSize.height) {
            scale = maxHeight/originSize.width;
        } else {
            scale = maxHeight/originSize.height;
        }
        
        CGSize fixedSize = CGSizeMake(originSize.width * scale, originSize.height *  scale);
        fixedSize = CGSizeMake(fixedSize.width>minHeight?fixedSize.width:minHeight, fixedSize.height>minHeight?fixedSize.height:minHeight);
        
        //cache it
        [[CNKCache sharedInstance] setCacheObject:[NSValue valueWithCGSize:fixedSize] forKey:sizeValueCacheKey];
        
        return fixedSize;
    }
    return CGSizeZero;
}
@end

@implementation SingleTextLabel

+ (SingleTextLabel *)sharedInstance{
    static SingleTextLabel *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SingleTextLabel alloc] init];
        instance.numberOfLines = 0;
        instance.lineBreakMode = NSLineBreakByWordWrapping;
    });
    return instance;
}

@end
