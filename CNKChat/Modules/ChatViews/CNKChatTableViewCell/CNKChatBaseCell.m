//
//  CNKChatTableViewCell.m
//  CNKChat
//
//  Created by chenkai on 2016/11/15.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKChatBaseCell.h"
#import "UIImageView+WebCache.h"
#import "UIView+ViewCorner.h"
#import "CNKChatMessageSender.h"
#import "CNKChatMessageHelper.h"

@interface CNKChatBaseCell()
@end

@implementation CNKChatBaseCell
@synthesize message = _message;
@synthesize timeLabel = _timeLabel;
@synthesize nameLabel = _nameLabel;
@synthesize avatarImageView = _avatarImageView;
@synthesize showName = _showName;
@synthesize sendFaildButton = _sendFaildButton;
@synthesize sendingIndicatorView = _sendingIndicatorView;
@synthesize delegate = _delegate;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageSendStatusChanged:) name:CNKChatMessageSendStatusChangedNotification object:nil];
        [self timeLabel];
        [self avatarImageView];
        [self nameLabel];
        [self sendFaildButton];
        [self sendingIndicatorView];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark- getter

- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont boldSystemFontOfSize:10];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_timeLabel];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView);
            make.top.mas_equalTo(15);
            make.height.mas_equalTo(15);
            make.width.mas_equalTo(0);
        }];
        
        UIImageView *labelBg = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"chat_time_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)]];
        [self.contentView insertSubview:labelBg belowSubview:_timeLabel];
        [labelBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(_timeLabel);
        }];
    }
    return _timeLabel;
}

- (UIImageView *)avatarImageView{
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.clipsToBounds = YES;
        [self addSubview:_avatarImageView];
        [_avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.top.mas_equalTo(_timeLabel.mas_bottom).mas_offset(10);
            make.size.mas_equalTo(CGSizeMake(50, 50));
        }];
    }
    return _avatarImageView;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:9];
        [self.contentView addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_avatarImageView.mas_top);
            make.left.mas_equalTo(_avatarImageView.mas_right).mas_offset(-10);
            make.height.mas_equalTo(16);
            make.width.mas_equalTo(0);
        }];
        _nameLabel.layer.cornerRadius = 8;
    }
    return _nameLabel;
}

- (UIButton *)sendFaildButton{
    if (!_sendFaildButton) {
        _sendFaildButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendFaildButton setImage:[UIImage imageNamed:@"sendFailure"] forState:UIControlStateNormal];
        [_sendFaildButton addTarget:self action:@selector(resendAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_sendFaildButton];
        [_sendFaildButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.centerY.mas_equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        _sendFaildButton.hidden = YES;
    }
    return _sendFaildButton;
}

- (UIActivityIndicatorView *)sendingIndicatorView{
    if (!_sendingIndicatorView) {
        _sendingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:_sendingIndicatorView];
        [_sendingIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(_sendFaildButton.center);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        _sendingIndicatorView.hidden = YES;
    }
    return _sendingIndicatorView;
}

#pragma mark- setter

- (void)setMessage:(CNKChatMessageModel *)message{
    _message = message;
    _nameLabel.text = message.senderName;
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:message.senderAvatar]];
    
    if (message.showTime) {
        _timeLabel.text = [CNKUtils chatDateStringWithTimestamp:message.timestamp];
        _timeLabel.hidden = NO;
        
        [_timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([CNKChatMessageHelper timeLabelWidthWithFont:_timeLabel.font text:_timeLabel.text] + 8);
        }];
    } else {
        _timeLabel.hidden = YES;
        [_timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
        }];
    }
    
    if ([CNKChatMessageHelper isMyMessage:message]) {
        _nameLabel.hidden = YES;
        [_avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-10);
            
            if (message.showTime) {
                make.top.mas_equalTo(_timeLabel.mas_bottom).mas_offset(10);
            } else {
                make.top.mas_equalTo(self.contentView).mas_offset(kCNKChatCellHideTimeTopInset);
            }
            
            make.size.mas_equalTo(CGSizeMake(50, 50));
        }];
        
        if ([[CNKChatMessageSenderManager sharedInstance] isExecutingWithMessage:_message]) {
            
            [self sendStatusChanged:CNKChatMessageSendStatusSending];
            
        } else {
            
            [self sendStatusChanged:_message.sendStatus];
            
        }
    } else {
        [self sendStatusChanged:CNKChatMessageSendStatusSuccess];
        _nameLabel.hidden = NO;
        [_avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            
            if (message.showTime) {
                make.top.mas_equalTo(_timeLabel.mas_bottom).mas_offset(10);
            } else {
                make.top.mas_equalTo(self.contentView).mas_offset(kCNKChatCellHideTimeTopInset);
            }
            
            make.size.mas_equalTo(CGSizeMake(50, 50));
        }];
    }
}

- (void)setShowName:(BOOL)showName{
    _showName = showName;
    if (_showName) {
        
        _nameLabel.hidden = NO;
    } else {
        _nameLabel.hidden = YES;
    }
}

#pragma mark- noty

- (void)messageSendStatusChanged:(NSNotification *)noty{
    if (noty) {
        CNKChatMessageModel *notyMessage = (CNKChatMessageModel *)[noty object];
        if ([notyMessage isKindOfClass:CNKChatMessageModel.class] && [notyMessage.msgId isEqualToString:_message.msgId]) {
            _message.msgId = notyMessage.msgId;
            _message.sendStatus = notyMessage.sendStatus;
            _message.timestamp = notyMessage.timestamp;
            [CNKUtils executeBlockInDBQueue:^{
                [_message updateToDB];
            }];
            [self sendStatusChanged:_message.sendStatus];
        }
    }
}

//修改状态
- (void)sendStatusChanged:(CNKChatMessageSendStatus)sendStatus{
    if (sendStatus == CNKChatMessageSendStatusSending) {
        _sendingIndicatorView.hidden = NO;
        _sendFaildButton.hidden = YES;
        [_sendingIndicatorView startAnimating];
    } else if (sendStatus == CNKChatMessageSendStatusSuccess) {
        _sendingIndicatorView.hidden = YES;
        _sendFaildButton.hidden = YES;
        [_sendingIndicatorView stopAnimating];
    } else if (sendStatus == CNKChatMessageSendStatusFaild || sendStatus == CNKChatMessageSendStatusCancelled) {
        _sendingIndicatorView.hidden = YES;
        _sendFaildButton.hidden = NO;
        [_sendingIndicatorView stopAnimating];
    } else {
        _sendingIndicatorView.hidden = YES;
        _sendFaildButton.hidden = YES;
        [_sendingIndicatorView stopAnimating];
    }
}

#pragma mark- action

- (void)resendAction:(UIButton *)button{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确定重新发送？" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"发送", nil];
    [alertView showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self sendStatusChanged:CNKChatMessageSendStatusSending];
            [[CNKChatMessageSenderManager sharedInstance] startSendMessage:_message completionBlock:nil];
        }
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

+ (NSString *)classNameWithContentType:(CNKMSGContentType)contentType {
    NSArray *classNameList = [self getAllSubClassNames];
    if (classNameList) {
        for (NSString *className in classNameList) {
            Class clazz = NSClassFromString(className);
            if ([clazz msgContentType] == contentType) {
                return className;
            }
        }
    }
    return nil;
}

+ (NSArray <NSString *> *)getAllSubClassNames {
    NSString *selfClassKey = [NSStringFromClass([self class]) stringByAppendingString:@"subclasscache"];
    NSArray *classNameList = (NSArray *)[[CNKCache sharedInstance] cacheObjectForKey:selfClassKey];
    if (!classNameList) {
        int numClasses;
        Class *classes = NULL;
        numClasses = objc_getClassList(NULL,0);
        
        if (numClasses >0 )
        {
            classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
            numClasses = objc_getClassList(classes, numClasses);
            NSMutableArray *classNameList = [NSMutableArray arrayWithCapacity:numClasses];
            for (int i = 0; i < numClasses; i++) {
                if (class_getSuperclass(classes[i]) == [self class]){
                    if (NSStringFromClass(classes[i])) {
                        [classNameList addObject:NSStringFromClass(classes[i])];
                        NSLog(@"%@", NSStringFromClass(classes[i]));
                    }
                }
            }
            free(classes);
            [[CNKCache sharedInstance] setCacheObject:classNameList forKey:selfClassKey];
            return classNameList;
        }
    } else {
        return classNameList;
    }
    return nil;
}

+ (CNKMSGContentType)msgContentType {
    return -1;
}

+ (NSString *)cellIdentifierWithContentType:(CNKMSGContentType)contentType {
    return [[self classNameWithContentType:contentType] stringByAppendingString:@"CellId"];
}

+ (void)registerTableCellClassWithTableView:(UITableView *)tableView {
    if (tableView) {
        NSArray *classNameList = [self getAllSubClassNames];
        for (NSString *className in classNameList) {
            [tableView registerClass:NSClassFromString(className) forCellReuseIdentifier:[className stringByAppendingString:@"CellId"]];
        }
    }
}
@end
