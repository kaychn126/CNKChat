//
//  UINavigationController+Navigation.h
//  EasyBenefitMass
//
//  Created by EasyBenefit on 16/9/8.
//  Copyright © 2016年 EasyBenefit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Navigation)

/**
 *  导航控制器中pop到特定类名的UIViewController
 *
 *  @param vcClass 类名
 */
- (void)ezb_popToViewControllerWithClass:(Class)vcClass;

/**
 *  删除导航控制器中第一个和最后一个中间所有的UIViewController
 */
- (void)ezb_deleteMiddleViewController;

/**
 *  删除导航控制器中前一个UIViewController
 */
- (void)ezb_deletePreviousViewController;

/**
 *  删除导航控制器中指定类名的UIViewController
 *
 *  @param clazz 类名
 */
- (void)ezb_deleteLastViewControllerWithClass:(Class)clazz;

/**
 *  获取正在显示的UINavigationController
 */
+ (UINavigationController *)ezb_getDisplayingNavigationController;

/**
 *  获取正在显示的UIViewController
 */
+ (UIViewController *)ezb_getDisplayingViewController;

@end
