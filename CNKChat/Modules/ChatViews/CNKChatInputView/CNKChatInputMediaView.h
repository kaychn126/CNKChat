//
//  CNKChatInputMediaView.h
//  CNKChat
//
//  Created by chenkai on 2016/11/18.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNKChatLocation.h"

typedef NS_ENUM(NSInteger, CNKChatInputMediaItemType){
    CNKChatInputMediaItemTypeCamera  = 0,
    CNKChatInputMediaItemTypePhotoAlbum = 1,
    CNKChatInputMediaItemTypeShortVideo = 2,
    CNKChatInputMediaItemTypeLocation = 3
};
@class CNKChatInputMediaView;

@protocol CNKChatInputMediaViewDelegate <NSObject>

- (void)inputMediaView:(CNKChatInputMediaView *)inputMediaView sendImageAction:(NSArray<UIImage *>*)imageList;

- (void)inputMediaView:(CNKChatInputMediaView *)inputMediaView sendLocationAction:(CNKChatLocation*)location;
@end

@interface CNKChatInputMediaView : UIView
@property (nonatomic, copy) NSArray *itemTypeList;
@property (nonatomic, assign) id<CNKChatInputMediaViewDelegate> delegate;

+ (double)inputMediaViewHeightWithItemTypeList:(NSArray *)itemTypeList;
@end

@interface CNKChatInputMediaItemView : UIView
@property (nonatomic, strong) UIImageView *itemImageView;
@property (nonatomic, strong) UILabel *itemTitleLabel;

- (instancetype)initWithItemType:(NSInteger)itemType actionBlock:(void(^)(CNKChatInputMediaItemType itemType))actionBlock;

@end
