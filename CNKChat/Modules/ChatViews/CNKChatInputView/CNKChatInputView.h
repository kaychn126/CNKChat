//
//  CNKChatInputView.h
//  CNKChat
//
//  Created by chenkai on 2016/11/15.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CNKChatInputView;
static const double kInputViewMinHeight = 52;
static const double kInputViewMaxHeight = 110;
static const double kInputTextViewInset = 8;
static const double kInputTextViewMinHeight = kInputViewMinHeight-2*kInputTextViewInset;

@protocol CNKChatInputViewDelegate <NSObject>

- (void)inputView:(CNKChatInputView*)inputView sendTextAction:(NSString *)sendText;

- (void)inputView:(CNKChatInputView*)inputView sendAudioAction:(NSString *)audioContentOfUrl;

- (void)inputView:(CNKChatInputView*)inputView addButtonAction:(BOOL)showMediaView;
@end

@interface CNKChatInputView : UIView
@property (nonatomic, assign) id<CNKChatInputViewDelegate> delegate;
@property (nonatomic, assign) BOOL isMediaViewShown;
@end
