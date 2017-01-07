//
//  CNKChatMessageSender.h
//  CNKChat
//
//  Created by chenkai on 2016/11/18.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const CNKChatMessageSendStatusChangedNotification;

@class CNKChatMessageModel;

@interface CNKChatMessageSender : NSOperation
@property (nonatomic, strong) CNKChatMessageModel *message;
@property (nonatomic, assign) CNKChatMessageSendStatus sendStatus;

- (instancetype)initWithChatMessage:(CNKChatMessageModel *)message completionBlock:(void(^)(BOOL success, CNKChatMessageModel *sendedMessage))completionBlock;

@end


@interface CNKChatMessageSenderManager : NSObject
+ (instancetype)sharedInstance;

//发送单个消息
- (CNKChatMessageSender *)startSendMessage:(CNKChatMessageModel *)message completionBlock:(void(^)(BOOL success, CNKChatMessageModel *sendedMessage))completionBlock;

//发送消息数组
- (NSArray <CNKChatMessageSender *>*)startSendMessageList:(NSArray <CNKChatMessageModel *>*)messageList;

- (void)startSendWithMessageSender:(CNKChatMessageSender *)messageSender;

- (BOOL)isExecutingWithMessage:(CNKChatMessageModel *)message;

- (void)cancelAllSendOperation;
@end
