//
//  UIView+Navigation.m
//  EasyBenefitMass
//
//  Created by EasyBenefit on 16/9/8.
//  Copyright © 2016年 EasyBenefit. All rights reserved.
//

#import "UIView+Navigation.h"
#import "UINavigationController+Navigation.h"

@implementation UIView (Navigation)


- (UIViewController *)ezb_getClosestViewController{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}


- (UINavigationController *)ezb_getNavigationController{
    UIViewController *viewController = [self ezb_getClosestViewController];
    if ([viewController isKindOfClass:UINavigationController.class]) {
        
        return (UINavigationController*)viewController;
        
    }else if(viewController.navigationController){
        
        return viewController.navigationController;
        
    }else{
        
        return [UINavigationController ezb_getDisplayingNavigationController];
    }
}

@end
