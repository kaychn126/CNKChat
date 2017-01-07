//
//  UIView+HUD.m
//  CNKChat
//
//  Created by EasyBenefit on 16/12/14.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "UIView+HUD.h"
#import "MBProgressHUD.h"

@implementation UIView (HUD)

- (BOOL)cnk_hasHUD{
    return [MBProgressHUD HUDForView:self]?YES:NO;
}

- (MBProgressHUD *)cnk_progressHUD{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self];
    if (hud) {
        return hud;
    } else {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self];
        hud.removeFromSuperViewOnHide = YES;
        [self addSubview:hud];
        [self bringSubviewToFront:hud];
        return hud;
    }
}

- (void)cnk_showStatus:(NSString *)status{
    dispatch_main_async_safe(^{
        BOOL hasHUD = [self cnk_hasHUD];
        MBProgressHUD *hud = [self cnk_getProgressHUDView];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = status;
        [hud showAnimated:hasHUD?NO:YES];
    });
}

- (void)cnk_showProgress:(CGFloat)progress status:(NSString *)status{
    dispatch_main_async_safe(^{
        BOOL hasHUD = [self cnk_hasHUD];
        MBProgressHUD *hud = [self cnk_getProgressHUDView];
        hud.mode = MBProgressHUDModeDeterminate;
        hud.progress = progress;
        hud.label.text = status;
        [hud showAnimated:hasHUD?NO:YES];
    });
}

- (void)cnk_showInfoWithText:(NSString *)text{
    [self cnk_showInfoWithText:text hideWithDelay:[self cnk_getDurationWithText:text]];
}

- (void)cnk_showInfoWithText:(NSString *)text hideWithDelay:(NSTimeInterval) delay{
    dispatch_main_async_safe(^{
        BOOL hasHUD = [self cnk_hasHUD];
        MBProgressHUD *hud = [self cnk_getProgressHUDView];
        hud.mode = MBProgressHUDModeCustomView;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cnk_progresshud_info"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        imageView.tintColor = hud.contentColor;
        hud.customView = imageView;
        hud.label.text = text;
        [hud showAnimated:hasHUD?NO:YES];
        [self cnk_dismissHUDWithDelay:delay];
    });
}

- (void)cnk_showSuccessWithText:(NSString *)text {
    [self cnk_showSuccessWithText:text hideWithDelay:[self cnk_getDurationWithText:text]];
}

- (void)cnk_showSuccessWithText:(NSString *)text hideWithDelay:(NSTimeInterval)delay {
    dispatch_main_async_safe(^{
        BOOL hasHUD = [self cnk_hasHUD];
        MBProgressHUD *hud = [self cnk_getProgressHUDView];
        hud.mode = MBProgressHUDModeCustomView;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cnk_progresshud_success"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        imageView.tintColor = hud.contentColor;
        hud.customView = imageView;
        hud.label.text = text;
        [hud showAnimated:hasHUD?NO:YES];
        [self cnk_dismissHUDWithDelay:delay];
    });
}

- (void)cnk_showErrorWithText:(NSString *)text{
    [self cnk_showErrorWithText:text hideWithDelay:[self cnk_getDurationWithText:text]];
}

- (void)cnk_showErrorWithText:(NSString *)text hideWithDelay:(NSTimeInterval) delay{
    dispatch_main_async_safe(^{
        BOOL hasHUD = [self cnk_hasHUD];
        MBProgressHUD *hud = [self cnk_getProgressHUDView];
        hud.mode = MBProgressHUDModeCustomView;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cnk_progresshud_error"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        imageView.tintColor = hud.contentColor;
        hud.customView = imageView;
        hud.label.text = text;
        [hud showAnimated:hasHUD?NO:YES];
        [self cnk_dismissHUDWithDelay:delay];
    });
}

- (void)cnk_showWithImage:(UIImage *)image text:(NSString *)text{
    [self cnk_showWithImage:image text:text hideWithDelay:[self cnk_getDurationWithText:text]];
}

- (void)cnk_showWithImage:(UIImage *)image text:(NSString *)text hideWithDelay:(NSTimeInterval) delay{
    if (!image) {
        return;
    }
    dispatch_main_async_safe(^{
        BOOL hasHUD = [self cnk_hasHUD];
        MBProgressHUD *hud = [self cnk_getProgressHUDView];
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc] initWithImage:image];
        CGSize size = hud.bezelView.bounds.size;
        hud.minSize = CGSizeMake(size.height, size.height);
        hud.label.text = text;
        [hud showAnimated:hasHUD?NO:YES];
        [self cnk_dismissHUDWithDelay:delay];
    });
}

- (void)cnk_dismissHUD{
    dispatch_main_async_safe(^{
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self];
        if (hud) {
            [hud hideAnimated:YES];
        }
    });
}

- (void)cnk_dismissHUDWithDelay:(NSTimeInterval)delay{
    dispatch_main_async_safe(^{
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self];
        if (hud) {
            [hud hideAnimated:YES afterDelay:delay];
        }
    });
}

- (MBProgressHUD *)cnk_getProgressHUDView{
    MBProgressHUD *hud = [self cnk_progressHUD];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.minShowTime = 2.0;
    hud.defaultMotionEffectsEnabled = NO;
    hud.animationType = MBProgressHUDAnimationFade;
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = kRGBAColor(0, 0, 0, 0.6);
    hud.contentColor = [UIColor whiteColor];
    hud.minSize = CGSizeMake(100, 100);
    return hud;
}

- (CGFloat)cnk_getDurationWithText:(NSString *)text{
     return 2 + text.length * 0.2;
}

+ (UIView *)cnk_displayingView {
    return [UIApplication sharedApplication].keyWindow.rootViewController.view;
}
@end
