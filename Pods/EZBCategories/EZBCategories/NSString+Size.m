//
//  NSString+Size.m
//  EasyBenefitMass
//
//  Created by wxy on 15/6/2.
//  Copyright (c) 2015年 EasyBenefit. All rights reserved.
//

#import "NSString+Size.h"

@implementation NSString (Size)
#pragma mark - 获取文字高度
-(CGSize)getHeighFont:(UIFont*)font andLabelWidth:(float)labelWidth{
    CGSize size = CGSizeMake(labelWidth, 29999);//跟label的宽设置一样
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<7.0)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        size = [self sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];//ios7以上已经摒弃的这个方法
#pragma clang diagnostic pop
    }
    else
    {
        NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
        size =[self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    }
    return size;
}
@end
