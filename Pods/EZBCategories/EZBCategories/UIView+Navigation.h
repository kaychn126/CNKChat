//
//  UIView+Navigation.h
//  EasyBenefitMass
//
//  Created by EasyBenefit on 16/9/8.
//  Copyright © 2016年 EasyBenefit. All rights reserved.
//
/**
 *  导航相关
 */


#import <UIKit/UIKit.h>

@interface UIView (Navigation)

/**
 *  获取图形树中最接近的UIViewController
 */
- (UIViewController *)ezb_getClosestViewController;

/**
 *  获取图形树中最接近的UINavigationController
 */
- (UINavigationController *)ezb_getNavigationController;

@end
