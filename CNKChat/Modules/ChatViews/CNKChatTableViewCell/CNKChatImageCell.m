//
//  CNKChatImageCell.m
//  CNKChat
//
//  Created by chenkai on 2016/11/15.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKChatImageCell.h"
#import "CNKChatMessageHelper.h"

@interface CNKChatImageCell()
@property (nonatomic, strong) UIButton *tapButton;
@property (nonatomic, strong) UIImageView *sendMaskImageView;
@property (nonatomic, strong) UIImageView *receiveMaskImageView;

@end

@implementation CNKChatImageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _sendMaskImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"chat_bubbleView_send"] resizableImageWithCapInsets:UIEdgeInsetsMake(27, 6, 6, 13)]];
        
        _receiveMaskImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"chat_bubbleView_receive"] resizableImageWithCapInsets:UIEdgeInsetsMake(27, 13, 6, 6)]];
        [self contentImageView];
        [self tapButton];
    }
    return self;
}

#pragma mark- getter

- (UIImageView* )contentImageView{
    if (!_contentImageView) {
        _contentImageView = [[UIImageView alloc] init];
        _contentImageView.contentMode = UIViewContentModeScaleAspectFill;
        _contentImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:_contentImageView];
        [_contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_avatarImageView.mas_top);
            make.left.mas_equalTo(_avatarImageView.mas_right).mas_offset(10);
            make.size.mas_equalTo(CGSizeMake(0, 0));
        }];
    }
    return _contentImageView;
}

- (UIButton *)tapButton{
    if (!_tapButton) {
        _tapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tapButton addTarget:self action:@selector(tapButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_contentImageView addSubview:_tapButton];
        [_tapButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return _tapButton;
}

#pragma mark- setter

- (void)setMessage:(CNKChatMessageModel *)message{
    [super setMessage:message];
    
    _message = message;
    
    UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:message.msgContentMd5Key];
    if (!image) {
        image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:message.msgContentMd5Key];
    }
    [_contentImageView setImage:image];
    
    CGSize imageSize = [CNKChatMessageHelper imageSizeWithMsg:message];
    
    if ([CNKChatMessageHelper isMyMessage:message]) {
        
        [_contentImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_avatarImageView.mas_top);
            make.right.mas_equalTo(_avatarImageView.mas_left).mas_offset(-10);
            make.size.mas_equalTo(imageSize);
        }];
        
        _sendMaskImageView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        _contentImageView.layer.mask = _sendMaskImageView.layer;
        
        [_sendFaildButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(_contentImageView.mas_centerY);
            make.right.mas_equalTo(_contentImageView.mas_left);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        
        [_sendingIndicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(_sendFaildButton);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
    } else {
        
        [_contentImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_avatarImageView.mas_top);
            make.left.mas_equalTo(_avatarImageView.mas_right).mas_offset(10);
            make.size.mas_equalTo(imageSize);
        }];
        
        _receiveMaskImageView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        _contentImageView.layer.mask = _receiveMaskImageView.layer;
    }
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

#pragma mark- action

- (void)tapButtonAction:(UIButton *)button{
    if ([_delegate respondsToSelector:@selector(chatImageCell:didSelectImageView:)]) {
        [_delegate chatImageCell:self didSelectImageView:_contentImageView];
    }
}

@end
