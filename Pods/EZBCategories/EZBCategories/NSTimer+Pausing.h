//
//  NSTimer+Pausing.h
//  EasyBenefitDoctor
//
//  Created by EasyBenefit on 15/7/9.
//  Copyright (c) 2015年 EasyBenefit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Pausing)
- (NSMutableDictionary *)pauseDictionary;
- (void)pause;
- (void)resume;
@end
