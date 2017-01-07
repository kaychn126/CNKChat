//
//  CNKChatView.h
//  CNKChat
//
//  Created by chenkai on 2016/11/15.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNKChatInputMediaView.h"

@class CNKChatMessageModel;
@interface CNKChatView : UIView
@property (nonatomic, assign) BOOL showName;
@property (nonatomic, copy) NSString *conversationId;
@property (nonatomic, copy) NSArray <NSNumber *>*mediaItemTypeList;

- (instancetype)initWithFrame:(CGRect)frame conversationId:(NSString *)conversationId;

- (void)viewWillAppear;

- (void)destroyView;
@end
