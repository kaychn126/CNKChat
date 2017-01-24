//
//  CNKChatPlainTextCell.m
//  CNKChat
//
//  Created by chenkai on 2016/11/15.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKChatPlainTextCell.h"
#import "CNKChatMessageHelper.h"

@interface CNKChatPlainTextCell()
@property (nonatomic, strong) UIImageView *bubbleView;
@property (nonatomic, strong) UILabel *plainTextLabel;
@end

@implementation CNKChatPlainTextCell

+ (CNKMSGContentType)msgContentType {
    return CNKMSGContentTypePlainText;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self bubbleView];
        [self plainTextView];
    }
    return self;
}

#pragma mark- getter

- (UIImageView *)bubbleView{
    if (!_bubbleView) {
        _bubbleView = [[UIImageView alloc] init];
        [self.contentView addSubview:_bubbleView];
    }
    return _bubbleView;
}

- (UILabel *)plainTextView{
    if (!_plainTextLabel) {
        _plainTextLabel = [[UILabel alloc] init];
        _plainTextLabel.backgroundColor = [UIColor clearColor];
        _plainTextLabel.numberOfLines = 0;
        _plainTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _plainTextLabel.font = [UIFont systemFontOfSize:16];
        [_bubbleView addSubview:_plainTextLabel];
    }
    return _plainTextLabel;
}

#pragma mark- setter

- (void)setMessage:(CNKChatMessageModel *)message{
    [super setMessage:message];
    _message = message;
    _plainTextLabel.text = _message.msgContent;
    CGSize plainTextSize = [CNKChatMessageHelper plainTextSizeWithMsg:_message];
    
    if ([CNKChatMessageHelper isMyMessage:_message]) {
        [_plainTextLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_bubbleView).mas_offset(-3);
            make.centerY.mas_equalTo(_bubbleView);
            make.size.mas_equalTo(CGSizeMake(plainTextSize.width, plainTextSize.height));
        }];
        _plainTextLabel.textColor = [UIColor whiteColor];
        
        CGSize bubbleViewSize = CGSizeMake(plainTextSize.width<30?30:plainTextSize.width, plainTextSize.height<30?30:plainTextSize.height);
        
        [_bubbleView setImage:[[UIImage imageNamed:@"chat_bubbleView_send"] resizableImageWithCapInsets:UIEdgeInsetsMake(27, 6, 6, 13)]];
        [_bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(_avatarImageView.mas_left).mas_offset(-10);
            make.top.mas_equalTo(_avatarImageView.mas_top);
            make.size.mas_equalTo(CGSizeMake(bubbleViewSize.width + 30, bubbleViewSize.height + 20));
        }];
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
        [_plainTextLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_bubbleView).mas_offset(3);
            make.centerY.mas_equalTo(_bubbleView);
            make.size.mas_equalTo(CGSizeMake(plainTextSize.width, plainTextSize.height));
        }];
        _plainTextLabel.textColor = [UIColor blackColor];
        
        CGSize bubbleViewSize = CGSizeMake(plainTextSize.width<30?30:plainTextSize.width, plainTextSize.height<30?30:plainTextSize.height);
        
        [_bubbleView setImage:[[UIImage imageNamed:@"chat_bubbleView_receive"] resizableImageWithCapInsets:UIEdgeInsetsMake(27, 13, 6, 6)]];
        [_bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_avatarImageView.mas_right).mas_offset(10);
            make.top.mas_equalTo(_avatarImageView.mas_top);
            make.size.mas_equalTo(CGSizeMake(bubbleViewSize.width + 30, bubbleViewSize.height + 20));
        }];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        if ([_delegate respondsToSelector:@selector(chatBaseCell:didSelectView:)]) {
            [_delegate chatBaseCell:self didSelectView:_plainTextLabel];
        }
    }
    // Configure the view for the selected state
}

@end
