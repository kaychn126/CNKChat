//
//  CNKSendLocationViewController.h
//  CNKChat
//
//  Created by EasyBenefit on 16/12/1.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CNKChatLocation;
@interface CNKChatSendLocationViewController : UIViewController
@property (nonatomic, copy) void(^sendActionBlock)(CNKChatLocation *sendLocation);

@end
