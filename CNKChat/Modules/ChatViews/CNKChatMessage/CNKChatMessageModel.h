//
//  CNKChatMessageModel.h
//  CNKChat
//
//  Created by chenkai on 2016/11/15.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNKChatLocation.h"

static double const kCNKChatCellShowTimeTopInset = 40;
static double const kCNKChatCellHideTimeTopInset = 20;
static double const kCNKChatVoiceCellBubbleViewHeight = 50;
static double const kCNKChatPlainTextCellMinTextViewHeight = 30;
static double const kCNKChatPlainTextCellMinBubbleViewHeight = 50;

typedef NS_ENUM(NSInteger, CNKMSGContentType){
    CNKMSGContentTypePlainText = 0,
    CNKMSGContentTypeVoice = 1,
    CNKMSGContentTypeImage = 2,
    CNKMSGContentTypeLocation = 3
};

@interface CNKChatMessageModel : NSObject
@property (nonatomic, copy) NSString *onwerId;
@property (nonatomic, copy) NSString *conversationId;
@property (nonatomic, copy) NSString *msgId;
@property (nonatomic, copy) NSString *senderId;
@property (nonatomic, copy) NSString *senderName;
@property (nonatomic, copy) NSString *senderAvatar;
@property (nonatomic, assign) CNKMSGContentType msgContentType;
@property (nonatomic, copy) NSString *msgContent;
@property (nonatomic, assign) double voiceLength;
@property (nonatomic, assign) long long timestamp;
@property (nonatomic, strong) CNKChatLocation *location;

//对msgContent做md5
@property (nonatomic, copy) NSString *msgContentMd5Key;

//消息是否已读
@property (nonatomic, assign) BOOL isMsgReaded;

//show time
@property (nonatomic, assign) BOOL showTime;

//语音是否播放过
@property (nonatomic, assign) BOOL isAudioPlayed;

//发送状态
@property (nonatomic, assign) CNKChatMessageSendStatus sendStatus;

//获取消息图片并缓存
- (void)getMsgImageWithCompletionBlock:(void(^)(UIImage *msgImage))completionBlock;

@end

