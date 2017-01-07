//
//  CNKMacroDefine.h
//  CNKChat
//
//  Created by chenkai on 2016/11/19.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CNKChatMessageSendStatus){
    CNKChatMessageSendStatusSending = 1,
    CNKChatMessageSendStatusSuccess = 2,
    CNKChatMessageSendStatusFaild = 3,
    CNKChatMessageSendStatusCancelled = 4
};
