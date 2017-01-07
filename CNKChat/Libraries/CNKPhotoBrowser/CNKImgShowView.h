//
//  CNKImgShowView.h
//  EasyBenefitMass
//
//  Created by EasyBenefit on 15/6/16.
//  Copyright (c) 2015年 EasyBenefit. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark -ENUM
typedef NS_ENUM(NSInteger, CNKImgLocation) {
    CNKImgLocationLeft,
    CNKImgLocationCenter,
    CNKImgLocationRight,
};

@class CNKImgShowView;

typedef void(^EBImgShowViewPageIndexChangeBlock)(NSInteger index);

typedef void(^EBImgShowViewSingleTapBlock)(CNKImgShowView *imageShowView);

#pragma mark -MRImgShowView
@interface CNKImgShowView : UIScrollView <UIScrollViewDelegate>
{
    NSDictionary* _imgViewDic;
}

@property(nonatomic ,assign)NSInteger curIndex;     // 当前显示图片在数据源中的下标

@property(nonatomic ,retain)NSMutableArray<NSString *> *imgSource;

@property(nonatomic ,readonly)CNKImgLocation imgLocation;    // 图片在空间中的位置

@property(nonatomic ,copy)EBImgShowViewPageIndexChangeBlock pageIndexChangeBlock;

@property(nonatomic ,copy)EBImgShowViewSingleTapBlock singleTapBlock;
- (id)initWithFrame:(CGRect)frame;

- (id)initWithFrame:(CGRect)frame withSourceData:(NSMutableArray <NSString *>*)imgSource withIndex:(NSInteger)index;

// 谦让双击放大手势
- (void)requireDoubleGestureRecognizer:(UITapGestureRecognizer *)tep;

@end
