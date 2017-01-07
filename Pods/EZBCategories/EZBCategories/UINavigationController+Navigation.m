//
//  UINavigationController+Navigation.m
//  EasyBenefitMass
//
//  Created by EasyBenefit on 16/9/8.
//  Copyright © 2016年 EasyBenefit. All rights reserved.
//

#import "UINavigationController+Navigation.h"

@implementation UINavigationController (Navigation)

- (UIViewController *)ezb_getViewControllerWithClass:(Class)vcClass{
    for(UIViewController *vc in self.viewControllers){
        if([vc isKindOfClass:vcClass]){
            return vc;
        }
    }
    return nil;
}

- (void)ezb_popToViewControllerWithClass:(Class)vcClass{
    UIViewController *vc = [self ezb_getViewControllerWithClass:vcClass];
    if(vc){
        [self popToViewController:vc animated:YES];
    }else{
        [self popViewControllerAnimated:YES];
    }
}

- (void)ezb_deleteMiddleViewController{
    if (self.viewControllers.count > 2) {
        self.viewControllers = [NSArray arrayWithObjects:[self.viewControllers firstObject],[self.viewControllers lastObject], nil];
    }
}

- (void)ezb_deletePreviousViewController{
    NSMutableArray *vcs = [NSMutableArray arrayWithArray:self.viewControllers];
    if (vcs.count > 2) {
        [vcs removeObjectAtIndex:vcs.count-2];
        self.viewControllers = vcs;
    }
}

- (void)ezb_deleteLastViewControllerWithClass:(Class)clazz{
    if (!clazz) {
        return;
    }
    NSMutableArray *allVcList = [NSMutableArray arrayWithArray:self.viewControllers];
    [self.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:clazz]) {
            [allVcList removeObject:obj];
            self.viewControllers = allVcList;
            *stop = YES;
        }
    }];
}

/**
 *  获取当前正在显示的UINavigationController
 */
+ (UINavigationController *)ezb_getDisplayingNavigationController{
    UIViewController *topVc = [self ezb_getDisplayingViewController];
    if ([topVc isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController*)topVc;
    }
    if (topVc) {
        return topVc.navigationController;
    }
    return nil;
}

+ (UIViewController *)ezb_getDisplayingViewController{
    return [self ezb_getDisplayingViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController *)ezb_getDisplayingViewControllerWithRootViewController:(UIViewController *)rootViewController{
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self ezb_getDisplayingViewControllerWithRootViewController:tabBarController.selectedViewController];
        
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self ezb_getDisplayingViewControllerWithRootViewController:navigationController.visibleViewController];
        
    } else if (rootViewController.presentedViewController) {
        
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self ezb_getDisplayingViewControllerWithRootViewController:presentedViewController];
        
    } else {
        return rootViewController;
    }
}
@end
