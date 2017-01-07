//
//  UIView+HUD.h
//  CNKChat
//
//  Created by EasyBenefit on 16/12/14.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;
@interface UIView (HUD)

- (BOOL)cnk_hasHUD;

- (MBProgressHUD *)cnk_progressHUD;

- (void)cnk_showStatus:(NSString *)status;

- (void)cnk_showProgress:(CGFloat)progress status:(NSString *)status;

- (void)cnk_showInfoWithText:(NSString *)text;

- (void)cnk_showInfoWithText:(NSString *)text hideWithDelay:(NSTimeInterval) delay;

- (void)cnk_showSuccessWithText:(NSString *)text;

- (void)cnk_showSuccessWithText:(NSString *)text hideWithDelay:(NSTimeInterval) delay;

- (void)cnk_showErrorWithText:(NSString *)text;

- (void)cnk_showErrorWithText:(NSString *)text hideWithDelay:(NSTimeInterval) delay;

- (void)cnk_showWithImage:(UIImage *)image text:(NSString *)text;

- (void)cnk_showWithImage:(UIImage *)image text:(NSString *)text hideWithDelay:(NSTimeInterval) delay;

- (void)cnk_dismissHUD;

- (void)cnk_dismissHUDWithDelay:(NSTimeInterval)delay;

//rootviewcontroller.view
+ (UIView *)cnk_displayingView;
@end
