//
//  UIAlertView+EBBlock.h
//  EasyBenefitMass
//
//  Created by EasyBenefit on 15/7/2.
//  Copyright (c) 2015年 EasyBenefit. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^CompleteBlock) (NSInteger buttonIndex);
@interface UIAlertView (EBBlock)
// 用Block的方式回调，这时候会默认用self作为Delegate
- (void)showAlertViewWithCompleteBlock:(CompleteBlock) block;
@end
