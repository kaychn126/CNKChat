//
//  CNKChatImageCell.h
//  CNKChat
//
//  Created by chenkai on 2016/11/15.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKChatBaseCell.h"

@class CNKChatImageCell;

@protocol CNKChatImageCellDelegate <NSObject>

- (void)chatImageCell:(CNKChatImageCell *)chatImageCell didSelectImageView:(UIImageView *)imageView;

@end

@interface CNKChatImageCell : CNKChatBaseCell
@property (nonatomic, strong) UIImageView *contentImageView;
@property (nonatomic, assign) id<CNKChatImageCellDelegate> delegate;
@end
