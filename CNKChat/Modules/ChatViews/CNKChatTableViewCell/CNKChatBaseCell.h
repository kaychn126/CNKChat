//
//  CNKChatBaseCell.h
//  CNKChat
//
//  Created by chenkai on 2016/11/15.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNKChatMessageModel.h"

@interface CNKChatBaseCell : UITableViewCell{
    CNKChatMessageModel *_message;
    UILabel *_timeLabel;
    UILabel *_nameLabel;
    UIImageView *_avatarImageView;
    BOOL _showName;
    UIButton *_sendFaildButton;
    UIActivityIndicatorView *_sendingIndicatorView;
}
@property (nonatomic, strong)CNKChatMessageModel *message;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIButton *sendFaildButton;
@property (nonatomic, strong) UIActivityIndicatorView *sendingIndicatorView;

@property (nonatomic, assign) BOOL showName;

- (void)sendStatusChanged:(CNKChatMessageSendStatus)sendStatus;
@end