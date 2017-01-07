//
//  CNKLocation.m
//  CNKChat
//
//  Created by EasyBenefit on 16/12/1.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKChatLocation.h"

@implementation CNKChatLocation

+ (NSString *)getTableName{
    return [NSString stringWithFormat:@"%@Table",NSStringFromClass([self class])];
}

@end
