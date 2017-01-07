//
//  NSString+Trim.h
//  EasyBenefitMass
//
//  Created by EasyBenefit on 15/7/24.
//  Copyright (c) 2015年 EasyBenefit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Trim)
- (NSString *)trim;
- (BOOL)isNotEmpty;
- (BOOL)isReallyEmpty;
- (NSString *)stringByRemovingAllWhitespaces;
- (NSString *)stringByRemovingUnsupportedCharacters;
@end
