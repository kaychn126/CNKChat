//
//  CNKRecordDisplayView.h
//  CNKChat
//
//  Created by chenkai on 2016/11/17.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CNKRecordDisplayViewStatus){
    CNKRecordDisplayViewStatusNormal,
    CNKRecordDisplayViewStatusCancel,
    CNKRecordDisplayViewStatusToShort
};

@interface CNKRecordDisplayView : UIView

@property (nonatomic, assign) CNKRecordDisplayViewStatus displayStatus;

- (void)setLevel:(NSInteger)level;

- (void)dismiss;

+ (CNKRecordDisplayView *)defaultDisplayView;

@end
