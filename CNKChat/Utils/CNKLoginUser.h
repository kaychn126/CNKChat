//
//  CNKLoginUser.h
//  CNKChat
//
//  Created by chenkai on 2016/11/16.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CNKLoginUser : NSObject
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;

+ (CNKLoginUser *)sharedInstance;
@end
