//
//  CNKChatMessageHelper.h
//  CNKChat
//
//  Created by chenkai on 2016/11/18.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CNKChatMessageModel;

@interface CNKChatMessageHelper : NSObject

//是否是自己发送的消息
+ (BOOL)isMyMessage:(CNKChatMessageModel *)message;

#pragma mark- query messages

//获取第一页数据，resultBlock主线程返回
+ (void)loadFirstPageWithConversationId:(NSString *)conversationId resultBlock:(void(^)(NSArray<CNKChatMessageModel *> *messageList, BOOL hasMoreData))resultBlock;

//获取指定消息之后的一页数据，resultBlock主线程返回
+ (void)loadNextPageWithLastMessage:(CNKChatMessageModel *)lastMessage resultBlock:(void(^)(NSArray<CNKChatMessageModel *> *messageList, BOOL hasMoreData))resultBlock;

//获取指定会话的所有消息，resultBlock io线程返回
+ (void)loadMessagesWithConversationId:(NSString *)conversationId resultBlock:(void(^)(NSArray<CNKChatMessageModel *> *messageList))resultBlock;

//获取所有会话的消息，resultBlock io线程返回
+ (void)loadAllMessagesWithResultBlock:(void(^)(NSArray<CNKChatMessageModel *> *messageList))resultBlock;

//获取图片消息列表，resultBlock主线程返回
+ (void)loadImageMessagesWithConversationId:(NSString *)conversationId resultBlock:(void(^)(NSArray<CNKChatMessageModel *> *messageList))resultBlock;

//获取下一页图片消息
+ (void)loadNextPageImageMessagesWithLastMessage:(CNKChatMessageModel *)lastMessage resultBlock:(void(^)(NSArray<CNKChatMessageModel *> *messageList))resultBlock;

#pragma mark- cache

//在后台线程中预计算指定会话的cell高度并缓存
+ (void)preCalculateAndCacheCellHeightWithConversationId:(NSString *)conversationId;

//在后台线程中预计算所有会话的cell高度并缓存
+ (void)preCalculateAndCacheAllCellHeight;

//在后台线程中将下一页图片数据缓存到内存中
+ (void)preMemoryCacheImageDataWithLastMessage:(CNKChatMessageModel *)message;

#pragma mark- cell height
+ (double)cellHeightWithMsg:(CNKChatMessageModel*)message;

+ (double)cellHeightWithMsgList:(NSArray<CNKChatMessageModel *>*)msgList;

+ (void)cellHeightWithMsg:(CNKChatMessageModel*)message resultBlock:(void(^)(double cellHeight))resultBlock;

+ (CGSize)plainTextSizeWithMsg:(CNKChatMessageModel*)message;

+ (CGSize)imageSizeWithMsg:(CNKChatMessageModel*)message;

+ (double)timeLabelWidthWithFont:(UIFont*)font text:(NSString *)text;

#pragma mark- show time
//检查消息是否可以显示时间
+ (NSArray <CNKChatMessageModel*>*)checkShowDateWithMsgList:(NSArray <CNKChatMessageModel*>*)msgList;
@end

#pragma mark- SingleTextLabel

@interface SingleTextLabel : UILabel

+ (SingleTextLabel *)sharedInstance;

@end
