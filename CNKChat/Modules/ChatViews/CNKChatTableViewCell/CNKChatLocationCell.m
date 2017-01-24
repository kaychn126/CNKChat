//
//  CNKChatLocationCell.m
//  CNKChat
//
//  Created by EasyBenefit on 16/12/2.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKChatLocationCell.h"
#import "CNKChatMessageHelper.h"
#import "CNKChatLocationViewController.h"

@interface CNKChatLocationCell()
@property (nonatomic, strong) UIButton *tapButton;
@property (nonatomic, strong) UIImageView *sendMaskImageView;
@property (nonatomic, strong) UIImageView *receiveMaskImageView;

@property (nonatomic, strong) UIView *carrierView;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UILabel *detailAddressLabel;
@property (nonatomic, strong) UIImageView *locationImageView;

@end

@implementation CNKChatLocationCell

+ (CNKMSGContentType)msgContentType {
    return CNKMSGContentTypeLocation;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _sendMaskImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"chat_bubbleView_send"] resizableImageWithCapInsets:UIEdgeInsetsMake(27, 6, 6, 13)]];
                
        _receiveMaskImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"chat_bubbleView_receive"] resizableImageWithCapInsets:UIEdgeInsetsMake(27, 13, 6, 6)]];
        
        [self carrierView];
        [self addressLabel];
        [self detailAddressLabel];
        [self locationImageView];
        [self tapButton];
    }
    return self;
}

#pragma mark- getter

- (UIView *)carrierView {
    if (!_carrierView) {
        _carrierView = [[UIView alloc] init];
        _carrierView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_carrierView];
        
        [_carrierView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_avatarImageView.mas_top);
            make.left.mas_equalTo(_avatarImageView.mas_right).mas_offset(10);
            make.size.mas_equalTo(CGSizeMake(kCarrierViewWidth, kCarrierViewHeight));
        }];
    }
    return _carrierView;
}

- (UILabel *)addressLabel {
    if (!_addressLabel) {
        _addressLabel = [[UILabel alloc] init];
        _addressLabel.font = [UIFont systemFontOfSize:16];
        _addressLabel.textColor = [UIColor blackColor];
        [_carrierView addSubview:_addressLabel];
        [_addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(5);
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.height.mas_equalTo(20);
        }];
    }
    return _addressLabel;
}

- (UILabel *)detailAddressLabel{
    if (!_detailAddressLabel) {
        _detailAddressLabel = [[UILabel alloc] init];
        _detailAddressLabel.font = [UIFont systemFontOfSize:12];
        _detailAddressLabel.textColor = kGrayColor(150);
        [_carrierView addSubview:_detailAddressLabel];
        [_detailAddressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_addressLabel.mas_bottom);
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.height.mas_equalTo(15);
        }];
    }
    return _addressLabel;
}

- (UIImageView *)locationImageView{
    if (!_locationImageView) {
        _locationImageView = [[UIImageView alloc] init];
        _locationImageView.contentMode = UIViewContentModeScaleAspectFill;
        _locationImageView.clipsToBounds = YES;
        [_carrierView addSubview:_locationImageView];
        [_locationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.top.mas_equalTo(_detailAddressLabel.mas_bottom).mas_offset(5);
        }];
    }
    return _locationImageView;
}

- (UIButton *)tapButton{
    if (!_tapButton) {
        _tapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tapButton addTarget:self action:@selector(tapButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_carrierView addSubview:_tapButton];
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
    [_locationImageView setImage:image];
    _addressLabel.text = message.location.placeName;
    _detailAddressLabel.text = message.location.address;
    
    if ([CNKChatMessageHelper isMyMessage:message]) {
        
        [_carrierView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_avatarImageView.mas_top);
            make.right.mas_equalTo(_avatarImageView.mas_left).mas_offset(-10);
            make.size.mas_equalTo(CGSizeMake(kCarrierViewWidth, kCarrierViewHeight));
        }];
        
        _sendMaskImageView.frame = CGRectMake(0, 0, kCarrierViewWidth, kCarrierViewHeight);
        _carrierView.layer.mask = _sendMaskImageView.layer;
        
        [_sendFaildButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(_carrierView.mas_centerY);
            make.right.mas_equalTo(_carrierView.mas_left);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        
        [_sendingIndicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(_sendFaildButton);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
    } else {
        
        [_carrierView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_avatarImageView.mas_top);
            make.left.mas_equalTo(_avatarImageView.mas_right).mas_offset(10);
            make.size.mas_equalTo(CGSizeMake(kCarrierViewWidth, kCarrierViewHeight));
        }];
        
        _receiveMaskImageView.frame = CGRectMake(0, 0, kCarrierViewWidth, kCarrierViewHeight);
        _carrierView.layer.mask = _receiveMaskImageView.layer;
    }
}

#pragma mark- action

- (void)tapButtonAction:(UIButton *)button{
    CNKChatLocationViewController *locationVc = [[CNKChatLocationViewController alloc] init];
    locationVc.location = _message.location;
    [[self ezb_getNavigationController] pushViewController:locationVc animated:YES];
    
    if ([_delegate respondsToSelector:@selector(chatBaseCell:didSelectView:)]) {
        [_delegate chatBaseCell:self didSelectView:button];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
