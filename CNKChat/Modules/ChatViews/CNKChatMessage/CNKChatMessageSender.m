//
//  CNKChatMessageSender.m
//  CNKChat
//
//  Created by chenkai on 2016/11/18.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKChatMessageSender.h"
#import "CNKChatMessageModel.h"

NSString *const CNKChatMessageSendStatusChangedNotification = @"CNKChatMessageSendStatusChangedNotification";

@interface CNKChatMessageSender()
@property (nonatomic, copy)void(^sendCompletionBlock)(BOOL success, CNKChatMessageModel *sendedMessage);

@end

@implementation CNKChatMessageSender
- (instancetype)initWithChatMessage:(CNKChatMessageModel *)message completionBlock:(void(^)(BOOL success, CNKChatMessageModel *sendedMessage))completionBlock{
    if (self = [super init]) {
        _message = message;
        _sendCompletionBlock = completionBlock;
    }
    return self;
}

- (void)start{
    
    if (!self.isCancelled) {
        [self willChangeValueForKey:@"isExecuting"];
        self.sendStatus = CNKChatMessageSendStatusSending;
        [self didChangeValueForKey:@"isExecuting"];
        
        [self sendMessage];
    } else {
        [self notifyCompletionWithStatus:CNKChatMessageSendStatusCancelled];
    }
}

- (void)sendMessage{
    [CNKUtils executeBlockInMainQueue:^{
        uint32_t randInt = arc4random();
        [self notifyCompletionWithStatus:randInt%2?CNKChatMessageSendStatusSuccess:CNKChatMessageSendStatusFaild];
    } delay:5];
}

- (void)finishOperationWithStatus:(CNKChatMessageSendStatus)status
{
    // Cancel the connection in case cancel was called directly
    
    // Let's finish the operation once and for all
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    self.sendStatus = status;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)notifyCompletionWithStatus:(CNKChatMessageSendStatus)status{
    _message.sendStatus = status;
    
    [CNKUtils executeBlockInDBQueue:^{
        [_message updateToDB];
    }];
    [CNKUtils executeBlockInMainQueue:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:CNKChatMessageSendStatusChangedNotification object:_message];
        if (_sendCompletionBlock) {
            _sendCompletionBlock(status==CNKChatMessageSendStatusSuccess?YES:NO, _message);
        }
    }];
    
    [self finishOperationWithStatus:status];
}

- (void)cancel
{
    [self willChangeValueForKey:@"isCancelled"];
    [self notifyCompletionWithStatus:CNKChatMessageSendStatusCancelled];
    [self didChangeValueForKey:@"isCancelled"];
}

#pragma mark- getter
- (BOOL)isExecuting
{
    return self.sendStatus == CNKChatMessageSendStatusSending;
}

- (BOOL)isCancelled
{
    return self.sendStatus == CNKChatMessageSendStatusCancelled;
}

- (BOOL)isFinished
{
    return self.sendStatus == CNKChatMessageSendStatusCancelled || self.sendStatus == CNKChatMessageSendStatusSuccess || self.sendStatus == CNKChatMessageSendStatusFaild;
}
@end

#pragma mark-- CNKChatMessageSenderManager

@interface CNKChatMessageSenderManager()
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation CNKChatMessageSenderManager

- (instancetype)init{
    if (self = [super init]) {
        self.operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static CNKChatMessageSenderManager *sharedManager = nil;
    dispatch_once(&onceToken, ^{
        sharedManager = [[CNKChatMessageSenderManager alloc] init];
        [sharedManager.operationQueue setName:@"com.cnk.sendmessagequeue"];
    });
    return sharedManager;
}

- (CNKChatMessageSender *)startSendMessage:(CNKChatMessageModel *)message completionBlock:(void(^)(BOOL success, CNKChatMessageModel *sendedMessage))completionBlock{
    CNKChatMessageSender *messageSender = [[CNKChatMessageSender alloc] initWithChatMessage:message completionBlock:completionBlock];
    [self.operationQueue addOperation:messageSender];
    return messageSender;
}

- (NSArray <CNKChatMessageSender *>*)startSendMessageList:(NSArray <CNKChatMessageModel *>*)messageList{
    NSMutableArray <CNKChatMessageSender *> *senderList = [NSMutableArray arrayWithCapacity:messageList.count];
    for (CNKChatMessageModel *message in messageList) {
        [senderList addObject:[[CNKChatMessageSenderManager sharedInstance] startSendMessage:message completionBlock:nil]];
    }
    return senderList;
}

- (void)startSendWithMessageSender:(CNKChatMessageSender *)messageSender{
    [self.operationQueue addOperation:messageSender];
}

- (BOOL)isExecutingWithMessage:(CNKChatMessageModel *)message{
    for (CNKChatMessageSender *messageSender in [self.operationQueue operations]) {
        if ([messageSender.message.msgId isEqualToString:message.msgId]) {
            if (messageSender.sendStatus == CNKChatMessageSendStatusSending) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)cancelAllSendOperation{
    for (CNKChatMessageSender *messageSender in [self.operationQueue operations]) {
        [messageSender cancel];
    }
}

@end
