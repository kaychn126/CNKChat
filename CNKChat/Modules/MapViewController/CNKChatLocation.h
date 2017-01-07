//
//  CNKChatLocation.h
//  CNKChat
//
//  Created by EasyBenefit on 16/12/1.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CNKChatLocation : NSObject
@property (nonatomic, assign) CGFloat longitude;//经度
@property (nonatomic, assign) CGFloat latitude;//纬度
@property (nonatomic, copy) NSString *placeName;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *placeImageKey;

@end
