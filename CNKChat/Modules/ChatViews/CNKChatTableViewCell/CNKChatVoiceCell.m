//
//  CNKChatVoiceCell.m
//  CNKChat
//
//  Created by chenkai on 2016/11/15.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKChatVoiceCell.h"
#import "CNKAudioManager.h"
#import "CNKChatMessageHelper.h"

@interface CNKChatVoiceCell()
@property (nonatomic, strong) UIImageView *bubbleView;
@property (nonatomic, strong) UIImageView *playingAudioImageView;
@property (nonatomic, strong) UILabel *audioLengthLabel;
@property (nonatomic, strong) UIImageView *unreadImageView;
@end

@implementation CNKChatVoiceCell

+ (CNKMSGContentType)msgContentType {
    return CNKMSGContentTypeVoice;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupInterface];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPlayAudioNotification:) name:@"StopPlayChatAudio" object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark- getter

- (UIImageView *)bubbleView{
    if (!_bubbleView) {
        _bubbleView = [[UIImageView alloc] init];
        _bubbleView.userInteractionEnabled = YES;
        [self.contentView addSubview:_bubbleView];
    }
    return _bubbleView;
}

- (UILabel *)audioLengthLabel{
    if (!_audioLengthLabel) {
        _audioLengthLabel = [[UILabel alloc] init];
        _audioLengthLabel.textColor = [UIColor lightGrayColor];
        _audioLengthLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_audioLengthLabel];
    }
    return _audioLengthLabel;
}

- (UIImageView *)unreadImageView{
    if (!_unreadImageView) {
        _unreadImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"badgePoint"]];
        _unreadImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_unreadImageView];
        [_unreadImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_bubbleView.mas_top).mas_offset(-4);
            make.left.mas_equalTo(_bubbleView.mas_right).mas_offset(5);
            make.size.mas_equalTo(CGSizeMake(8, 8));
        }];
        _unreadImageView.hidden = YES;
    }
    return _unreadImageView;
}

- (void)setupInterface{
    [self bubbleView];
    [self audioLengthLabel];
    [self unreadImageView];
    UIButton *voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [voiceButton addTarget:self action:@selector(playAudioAction:) forControlEvents:UIControlEventTouchUpInside];
    [_bubbleView addSubview:voiceButton];
    [voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    _playingAudioImageView = [[UIImageView alloc] init];
    [_bubbleView addSubview:_playingAudioImageView];
    _playingAudioImageView.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark- setter

- (void)setMessage:(CNKChatMessageModel *)message{
    [super setMessage:message];
    _message = message;
    double bubbleLength = _message.voiceLength/60.0*80 + 80;
    
    _audioLengthLabel.text = [NSString stringWithFormat:@"%d''",(int)message.voiceLength];
    
    NSString *voiceName = @"receiverVoiceNodePlaying";
    if ([CNKChatMessageHelper isMyMessage:_message]) {
        [_bubbleView setImage:[[UIImage imageNamed:@"chat_bubbleView_send"] resizableImageWithCapInsets:UIEdgeInsetsMake(27, 6, 6, 13)]];
        [_bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(_avatarImageView.mas_left).mas_offset(-10);
            make.top.mas_equalTo(_avatarImageView.mas_top);
            make.size.mas_equalTo(CGSizeMake(bubbleLength, 50));
        }];
        
        voiceName = @"senderVoiceNodePlaying";
        [_playingAudioImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(_bubbleView);
            make.right.mas_equalTo(-30);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
        
        _audioLengthLabel.textAlignment = NSTextAlignmentRight;
        [_audioLengthLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(_bubbleView.mas_left).mas_offset(-5);
            make.bottom.mas_equalTo(_bubbleView.mas_bottom).mas_equalTo(-10);
            make.size.mas_equalTo(CGSizeMake(40, 15));
        }];
        
        _unreadImageView.hidden = YES;
        
        [_sendFaildButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(_bubbleView.mas_centerY);
            make.right.mas_equalTo(_bubbleView.mas_left);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        
        [_sendingIndicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(_sendFaildButton);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
    } else {
        [_bubbleView setImage:[[UIImage imageNamed:@"chat_bubbleView_receive"] resizableImageWithCapInsets:UIEdgeInsetsMake(27, 13, 6, 6)]];
        [_bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_avatarImageView.mas_right).mas_offset(10);
            make.top.mas_equalTo(_avatarImageView.mas_top);
            make.size.mas_equalTo(CGSizeMake(bubbleLength, 50));
        }];
        [_playingAudioImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(_bubbleView);
            make.left.mas_equalTo(30);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
        
        _audioLengthLabel.textAlignment = NSTextAlignmentLeft;
        [_audioLengthLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_bubbleView.mas_right).mas_offset(5);
            make.bottom.mas_equalTo(_bubbleView.mas_bottom).mas_equalTo(-10);
            make.size.mas_equalTo(CGSizeMake(40, 15));
        }];
        
        if (!_message.isAudioPlayed) {
            _unreadImageView.hidden = NO;
        } else {
            _unreadImageView.hidden = YES;
        }
    }
    
    [_playingAudioImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@003",voiceName]]];
    NSMutableArray *imageArray = [NSMutableArray array];
    for(int i = 0;i<4;i++){
        [imageArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%@00%d",voiceName,i]]];
    }
    _playingAudioImageView.animationImages = imageArray;
    _playingAudioImageView.animationDuration = 0.8f;
    _playingAudioImageView.animationRepeatCount = 0;
    
    if ([[CNKAudioManager sharedInstance] isPlayingWithAudioCacheKey:_message.msgContentMd5Key]) {
        [_playingAudioImageView startAnimating];
    }
}

- (void)sendStatusChanged:(CNKChatMessageSendStatus)sendStatus{
    [super sendStatusChanged:sendStatus];
    
    if (sendStatus == CNKChatMessageSendStatusSending) {
        _audioLengthLabel.hidden = YES;
    } else if (sendStatus == CNKChatMessageSendStatusSuccess) {
        _audioLengthLabel.hidden = NO;
    } else if (sendStatus == CNKChatMessageSendStatusFaild || sendStatus == CNKChatMessageSendStatusCancelled) {
        _audioLengthLabel.hidden = YES;
    } else {
        _audioLengthLabel.hidden = NO;
    }
}

#pragma mark- action

- (void)playAudioAction:(UIButton *)button{
    
    if ([_delegate respondsToSelector:@selector(chatBaseCell:didSelectView:)]) {
        [_delegate chatBaseCell:self didSelectView:button];
    }
    
    if (!_message.isAudioPlayed) {
        _message.isAudioPlayed = YES;
        [CNKUtils executeBlockInDBQueue:^{
            [_message updateToDB];
        }];
        _unreadImageView.hidden = YES;
    }
    
    if (!_message.msgContent) {
        if ([CNKAudioManager sharedInstance].isPlaying) {
            [[CNKAudioManager sharedInstance] stopPlayAudio];
        }
        return;
    }
    
    if ([[CNKAudioManager sharedInstance] isPlayingWithAudioCacheKey:_message.msgContentMd5Key]) {
        //当前cell正在播放，点击停止
        [[CNKAudioManager sharedInstance] stopPlayAudio];
        return;
    } else {
        if ([[CNKAudioManager sharedInstance] isPlaying]) {
            [[CNKAudioManager sharedInstance] stopPlayAudio];
        };
    }
    
    if ([CNKAudioManager getAudioLengthWithAudioCacheKey:_message.msgContentMd5Key] > 0) {
        [_playingAudioImageView startAnimating];
        WS(weakSelf);
        [[CNKAudioManager sharedInstance] playWithMessage:_message completionBlock:^{
            [weakSelf.playingAudioImageView stopAnimating];
        }];
    }
    
}

- (void)stopPlayingAudioAnimation{
    [_playingAudioImageView stopAnimating];
    NSString *voiceName = @"receiverVoiceNodePlaying";
    if ([CNKChatMessageHelper isMyMessage:_message]) {
        voiceName = @"senderVoiceNodePlaying";
    }
     [_playingAudioImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@003",voiceName]]];
}

#pragma mark- noty

- (void)stopPlayAudioNotification:(NSNotification *)noty{
    [self stopPlayingAudioAnimation];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

+ (double)cellContentHeightWithMsg:(CNKChatMessageModel *)message {
    return kCNKChatVoiceCellBubbleViewHeight;
}
@end
