//
//  EBPhotoBroswerViewController.h
//  EasyBenefitMass
//
//  Created by EasyBenefit on 15/11/20.
//  Copyright © 2015年 EasyBenefit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EBPhotoBroswerViewController :  UIViewController
@property(nonatomic ,assign)NSInteger index;
@property(nonatomic ,retain)NSMutableArray *data;

- (id)initWithSourceData:(NSMutableArray *)data withIndex:(NSInteger)index;
@end
