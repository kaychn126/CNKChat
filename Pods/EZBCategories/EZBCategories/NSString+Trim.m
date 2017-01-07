//
//  NSString+Trim.m
//  EasyBenefitMass
//
//  Created by EasyBenefit on 15/7/24.
//  Copyright (c) 2015年 EasyBenefit. All rights reserved.
//

#import "NSString+Trim.h"
#define ILLEGAL_CHARACTER @"\u0060\u00b4\u2018\u2019\u201c\u201d"
@implementation NSString (Trim)
- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)isNotEmpty {
    return [self trim].length > 0;
}

- (BOOL)isReallyEmpty {
    return [self trim].length == 0;
}

- (NSString *)stringByRemovingAllWhitespaces {
    NSArray* components = [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [components componentsJoinedByString:@""];
}

- (NSString *)stringByRemovingUnsupportedCharacters {
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:ILLEGAL_CHARACTER];
    NSArray *components = [self componentsSeparatedByCharactersInSet:cs];
    return [components componentsJoinedByString:@""];
}
@end
