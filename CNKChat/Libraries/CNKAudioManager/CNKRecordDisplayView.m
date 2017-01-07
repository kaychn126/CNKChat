//
//  CNKRecordDisplayView.m
//  CNKChat
//
//  Created by chenkai on 2016/11/17.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKRecordDisplayView.h"

@interface CNKRecordDisplayView()
@property (strong, nonatomic) UIView *recordingView;
@property (strong, nonatomic) UIImageView *recordingImage;
@property (strong, nonatomic) UIImageView *powerImage;

@property (strong, nonatomic) UIImageView *cancelImage;
@property (strong, nonatomic) UILabel *promptLabel;
@end

@implementation CNKRecordDisplayView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupInterface];
    }
    return self;
}

- (void)setupInterface{
    self.layer.cornerRadius = 6;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 0.5;
    
    self.backgroundColor = kRGBAColor(30, 30, 30, 0.8);
    _recordingView = [[UIView alloc] init];
    [self addSubview:_recordingView];
    [_recordingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(10);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    
    _recordingImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recordingBkg"]];
    _recordingImage.contentMode = UIViewContentModeCenter;
    [_recordingView addSubview:_recordingImage];
    [_recordingImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(60);
    }];
    
    _powerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recordingPower1"]];
    _powerImage.contentMode = UIViewContentModeCenter;
    [_recordingView addSubview:_powerImage];
    [_powerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(40);
    }];
    
    _cancelImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recordCancel"]];
    _cancelImage.contentMode = UIViewContentModeCenter;
    [self addSubview:_cancelImage];
    [_cancelImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(10);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    _cancelImage.hidden = YES;
    
    _promptLabel = [[UILabel alloc] init];
    _promptLabel.font = [UIFont systemFontOfSize:13];
    _promptLabel.textColor = [UIColor whiteColor];
    _promptLabel.layer.cornerRadius = 4;
    _promptLabel.layer.masksToBounds = YES;
    _promptLabel.textAlignment = NSTextAlignmentCenter;
    _promptLabel.text = @"手指上滑，取消发送";
    [self addSubview:_promptLabel];
    [_promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.bottom.right.mas_equalTo(-10);
        make.height.mas_equalTo(20);
    }];
}

- (void)setDisplayStatus:(CNKRecordDisplayViewStatus)displayStatus{
    _displayStatus = displayStatus;
    if (_displayStatus == CNKRecordDisplayViewStatusNormal) {
        [_powerImage setImage:[UIImage imageNamed:@"recordingPower1"]];
        _cancelImage.hidden = YES;
        _recordingView.hidden = NO;
        _promptLabel.font = [UIFont systemFontOfSize:13];
        _promptLabel.text = @"手指上滑，取消发送";
        _promptLabel.backgroundColor = [UIColor clearColor];
    } else if (_displayStatus == CNKRecordDisplayViewStatusCancel) {
        _cancelImage.hidden = NO;
        _recordingView.hidden = YES;
        [_cancelImage setImage:[UIImage imageNamed:@"recordCancel"]];
        _promptLabel.font = [UIFont boldSystemFontOfSize:13];
        _promptLabel.text = @"松开手指，取消发送";
        _promptLabel.backgroundColor = kRGBAColor(127, 30, 30, 0.8);
    } else if (_displayStatus == CNKRecordDisplayViewStatusToShort){
        _cancelImage.hidden = NO;
        _recordingView.hidden = YES;
        [_cancelImage setImage:[UIImage imageNamed:@"recordToShort"]];
        _promptLabel.font = [UIFont systemFontOfSize:13];
        _promptLabel.text = @"说话时间太短";
        _promptLabel.backgroundColor = [UIColor clearColor];
        [CNKUtils executeBlockInMainQueue:^{
            [self dismiss];
        } delay:1];
    }
}

- (void)setLevel:(NSInteger)level{
    if (level >= 1 && level <= 9) {
        [_powerImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"recordingPower%ld",(long)level]]];
    }
}

- (void)dismiss{
    [self removeFromSuperview];
}

+ (CNKRecordDisplayView *)defaultDisplayView{
    double viewWidth = 150;
    
    CNKRecordDisplayView *displayView = [[CNKRecordDisplayView alloc] initWithFrame:CGRectMake((kScreenWidth-viewWidth)/2, (kScreenHeight-viewWidth)/2, viewWidth, viewWidth)];
    return displayView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
