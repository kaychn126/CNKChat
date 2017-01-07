//
//  UIImageView+TintColor.m
//  EasyBenefitMass
//
//  Created by EasyBenefit on 16/3/14.
//  Copyright © 2016年 EasyBenefit. All rights reserved.
//

#import "UIImageView+TintColor.h"

@implementation UIImageView (TintColor)
- (void)eb_setTintColor:(UIColor*)color{
    self.image = [self.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.tintColor = color;
}
@end
