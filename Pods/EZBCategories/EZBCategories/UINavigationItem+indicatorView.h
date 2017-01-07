//
//  UINavigationItem+indicatorView.h
//  EasyBenefitMass
//
//  Created by EasyBenefit on 16/1/9.
//  Copyright © 2016年 EasyBenefit. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EBNavigationItemIndicatorView;
@interface UINavigationItem (indicatorView)
@property(nonatomic, strong)EBNavigationItemIndicatorView *eb_indicatorView;

- (void)showIndicatorViewWithStatus:(NSString*)status;
- (void)hideIndicatorView;
@end

@interface EBNavigationItemIndicatorView : UIView
@property(nonatomic, strong)NSString *status;
@property(nonatomic, strong)UIActivityIndicatorView *indicatorView;
@end