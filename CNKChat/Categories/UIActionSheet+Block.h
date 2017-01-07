//
//  UIActionSheet+Block.h
//  CNKChat
//
//  Created by chenkai on 2016/11/17.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CNKActionSheetCompletionBlock)(NSInteger buttonIndex);

@interface UIActionSheet (Block)

- (void)showInView:(UIView *)view completionBlock:(CNKActionSheetCompletionBlock)completionBlock;

@end
