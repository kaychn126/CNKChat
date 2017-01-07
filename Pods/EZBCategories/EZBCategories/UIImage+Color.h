//
//  UIImage+Color.h
//  EasyBenefitDoctor
//
//  Created by wxy on 15/5/20.
//  Copyright (c) 2015年 EasyBenefit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Color)
//将颜色合成图片
+(UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)eb_setTintColor:(UIColor*)color image:(UIImage*)image;
@end
