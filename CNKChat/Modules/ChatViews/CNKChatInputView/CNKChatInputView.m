//
//  CNKChatInputView.m
//  CNKChat
//
//  Created by chenkai on 2016/11/15.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKChatInputView.h"
#import "TZImagePickerController.h"
#import "CNKAudioManager.h"
#import "CNKRecordDisplayView.h"

@interface CNKChatInputView()<UITextViewDelegate>
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, assign) double currentTextViewHeight;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIButton *voiceButton;

//点击录音按钮
@property (nonatomic, strong) UIButton *recordButton;

@end

@implementation CNKChatInputView

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = kGrayColor(240);
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = kGrayColor(215);
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(0);
            make.height.mas_equalTo(0.5);
        }];
        self.layer.shadowColor = kGrayColor(200).CGColor;//shadowColor阴影颜色
        self.layer.shadowOffset = CGSizeMake(0,-6);
        self.layer.shadowOpacity = 0.2;
        self.layer.shadowRadius = 6;
        [self inputView];
        [self textView];
        [self addButton];
        [self voiceButton];
        [self recordButton];
        _currentTextViewHeight = kInputViewMinHeight;
    }
    return self;
}

#pragma mark- getter

- (UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.font = [UIFont systemFontOfSize:16];
        _textView.textColor = [UIColor blackColor];
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.layer.cornerRadius = 4.0;
        _textView.layer.borderColor = kRGBAColor(180, 180, 180, 1).CGColor;
        _textView.layer.borderWidth = 0.5;
        
        _textView.delegate = self;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.scrollEnabled = NO;
        [self addSubview:_textView];
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(50);
            make.right.mas_equalTo(-50);
            make.top.mas_equalTo(kInputTextViewInset);
            make.bottom.mas_equalTo(-kInputTextViewInset);
        }];
        _textView.hidden = NO;
    }
    return _textView;
}

- (UIButton *)addButton{
    if (!_addButton) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addButton setImage:[UIImage imageNamed:@"multiMedia"] forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_addButton];
        [_addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kInputViewMinHeight-2*kInputTextViewInset, kInputTextViewMinHeight));
            make.right.mas_equalTo(-7);
            make.bottom.mas_equalTo(-kInputTextViewInset);
        }];
    }
    return _addButton;
}

- (UIButton *)voiceButton{
    if (!_voiceButton) {
        _voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_voiceButton setImage:[UIImage imageNamed:@"chatViewVoice"] forState:UIControlStateNormal];
        [_voiceButton addTarget:self action:@selector(voiceButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_voiceButton];
        [_voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kInputTextViewMinHeight, kInputTextViewMinHeight));
            make.left.mas_equalTo(7);
            make.bottom.mas_equalTo(-kInputTextViewInset);
        }];
    }
    return _voiceButton;
}

- (UIButton *)recordButton{
    if (!_recordButton) {
        _recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _recordButton.backgroundColor = kGrayColor(240);
        _recordButton.layer.cornerRadius = 4.0;
        _recordButton.layer.borderColor = kRGBAColor(180, 180, 180, 1).CGColor;
        _recordButton.layer.borderWidth = 0.5;
        
        [_recordButton setTitle:@"按住 说话" forState:UIControlStateNormal];
        [_recordButton setTitle:@"松开 结束" forState:UIControlStateHighlighted];
        [_recordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_recordButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        _recordButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        
        [_recordButton addTarget:self action:@selector(buttonTouchDownAction:) forControlEvents:UIControlEventTouchDown];
        [_recordButton addTarget:self action:@selector(buttonTouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
        [_recordButton addTarget:self action:@selector(buttonTouchDragExit:) forControlEvents:UIControlEventTouchDragExit];
        [_recordButton addTarget:self action:@selector(buttonTouchDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
        [_recordButton addTarget:self action:@selector(butttonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        
        [self addSubview:_recordButton];
        [_recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(50);
            make.right.mas_equalTo(-50);
            make.top.mas_equalTo(kInputTextViewInset);
            make.bottom.mas_equalTo(-kInputTextViewInset);
        }];
        
        _recordButton.hidden = YES;
    }
    return _recordButton;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

#pragma mark- action

- (void)addButtonPressed:(UIButton *)button{
    
    if (!_isMediaViewShown) {
        _isMediaViewShown = !_isMediaViewShown;
        [self showMediaView];
    } else {
        _isMediaViewShown = !_isMediaViewShown;
        [self hideMediaView];
    }
}

- (void)voiceButtonPressed:(UIButton *)button{
    if (_recordButton.hidden) {
        [self showRecordButton];
    } else {
        [self showTextView];
    }
}

#pragma mark- set state

- (void)showTextView{
    _isMediaViewShown = NO;
    _recordButton.hidden = YES;
    _textView.hidden = NO;
    [_textView becomeFirstResponder];
    [self setInputViewHeight:_currentTextViewHeight];
}

- (void)showRecordButton{
    _isMediaViewShown = NO;
    _recordButton.hidden = NO;
    _textView.hidden = YES;
    [_textView resignFirstResponder];
    [UIView animateWithDuration:0.25 animations:^{
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kInputViewMinHeight);
            make.bottom.mas_equalTo(0);
        }];
        [[self ezb_getClosestViewController].view layoutIfNeeded];
    }];
}

- (void)showMediaView{
    _recordButton.hidden = YES;
    _textView.hidden = NO;
    [self setInputViewHeight:_currentTextViewHeight];
    [_textView resignFirstResponder];
    if ([_delegate respondsToSelector:@selector(inputView:addButtonAction:)]) {
        [_delegate inputView:self addButtonAction:YES];
    }
}

- (void)hideMediaView{
    if ([_delegate respondsToSelector:@selector(inputView:addButtonAction:)]) {
        [_delegate inputView:self addButtonAction:NO];
    }
}

#pragma mark- record action

- (void)buttonTouchDownAction:(UIButton *)button{
    _recordButton.backgroundColor = kGrayColor(180);
    [[CNKAudioManager sharedInstance] startRecordShowUI:YES];
}

- (void)buttonTouchUpInsideAction:(UIButton *)button{
    Weakfy(weakSelf);
    _recordButton.backgroundColor = kGrayColor(240);
    [[CNKAudioManager sharedInstance] stopRecordWithCompletionBlock:^(NSURL *audioContentOfUrl) {
        Strongfy(strongSelf, weakSelf);
        if ([strongSelf.delegate respondsToSelector:@selector(inputView:sendAudioAction:)]) {
            [strongSelf.delegate inputView:self sendAudioAction:audioContentOfUrl.absoluteString];
        }
    }];
}

- (void)buttonTouchDragExit:(UIButton *)button{
    [[CNKAudioManager sharedInstance].recordDisplayView setDisplayStatus:CNKRecordDisplayViewStatusCancel];
}

- (void)buttonTouchDragEnter:(UIButton *)button{
    [[CNKAudioManager sharedInstance].recordDisplayView setDisplayStatus:CNKRecordDisplayViewStatusNormal];
}

- (void)butttonTouchUpOutside:(UIButton *)button{
    _recordButton.backgroundColor = kGrayColor(240);
    [[CNKAudioManager sharedInstance] stopRecordWithCompletionBlock:nil];
}

#pragma mark- textView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    _isMediaViewShown = NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        //发送
        if ([_delegate respondsToSelector:@selector(inputView:sendTextAction:)]) {
            [_delegate inputView:self sendTextAction:textView.text];
            textView.text = @"";
            [self setInputViewHeight:kInputViewMinHeight];
        }
        return NO;
    }
    return YES;
}

#pragma mark -Notification
- (void)textViewDidChange:(UITextView *)textView{
    CGFloat width = CGRectGetWidth(textView.frame);
    CGSize newSize = [textView sizeThatFits:CGSizeMake(width,MAXFLOAT)];
    CGFloat textViewHeight = newSize.height<kInputTextViewMinHeight?kInputTextViewMinHeight:newSize.height;
    [self setInputViewHeight:textViewHeight + kInputTextViewInset*2];
}

- (void)setInputViewHeight:(double)height{
    if (height > kInputViewMaxHeight) {
        [_textView setScrollEnabled:YES];
    } else {
        [_textView setScrollEnabled:NO];
    }
    _currentTextViewHeight = height;
    _currentTextViewHeight = _currentTextViewHeight > kInputViewMaxHeight ? kInputViewMaxHeight : _currentTextViewHeight;
    
    [UIView animateWithDuration:0.25 animations:^{
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(_currentTextViewHeight);
        }];
        [[self ezb_getClosestViewController].view layoutIfNeeded];
    }];
}
@end
