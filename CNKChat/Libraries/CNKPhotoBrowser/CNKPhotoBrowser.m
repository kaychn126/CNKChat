//
//  CNKPhotoBrowser.m
//  CNKChat
//
//  Created by chenkai on 2016/11/16.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKPhotoBrowser.h"
#import "CNKImgShowView.h"
#import "CNKStrokeLabel.h"

@implementation CNKPhotoBrowser

+ (void)showImageWithUrlList:(NSArray <NSString *>*)urlList selectView:(UIView *)selectView selectIndex:(NSInteger)selectIndex{
    if (!urlList || urlList.count < selectIndex + 1) {
        return;
    }
    
    NSString *selectedUrl = [urlList objectAtIndex:selectIndex];
    UIImage *selectedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[CNKUtils md5String:selectedUrl]];
    
    if (!selectedImage) {
        return;
    }
    
    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
    
    UIView *backView = [[UIView alloc] initWithFrame:window.bounds];
    backView.backgroundColor = [UIColor blackColor];
    backView.alpha = 0;
    [window addSubview:backView];
    
    CNKImgShowView *imgShowView = [[CNKImgShowView alloc]
                                   initWithFrame:window.frame
                                   withSourceData:[NSMutableArray arrayWithArray:urlList]
                                   withIndex:selectIndex];
    [imgShowView requireDoubleGestureRecognizer:[[backView gestureRecognizers] lastObject]];
    [window addSubview:imgShowView];
    imgShowView.hidden = YES;
    
    // page index
    CNKStrokeLabel *pageLabel = [[CNKStrokeLabel alloc] init];
    pageLabel.font = [UIFont systemFontOfSize:15];
    pageLabel.textAlignment = NSTextAlignmentCenter;
    pageLabel.outLineWidth = 1;
    pageLabel.outLinetextColor = kRGBAColor(51, 51, 51, 0.6);
    pageLabel.labelTextColor = [UIColor whiteColor];
    
    [window addSubview:pageLabel];
    pageLabel.text = [NSString stringWithFormat:@"%ld/%ld",(unsigned long)selectIndex+1,(unsigned long)urlList.count];
    [pageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
    pageLabel.hidden = urlList.count==1;
    
    __block NSInteger currentIndex = selectIndex;
    imgShowView.pageIndexChangeBlock = ^(NSInteger index){
        currentIndex = index;
        pageLabel.text = [NSString stringWithFormat:@"%ld/%ld",(unsigned long)currentIndex+1,(unsigned long)urlList.count];
    };
    
    CGRect originalRect = [selectView convertRect: selectView.bounds toView:window];
    UIImageView *originImageView = [CNKPhotoBrowser tempImageViewWithImage:selectedImage];
    originImageView.frame = originalRect;
    [window addSubview:originImageView];
    
    [UIView animateWithDuration:0.2 animations:^{
        originImageView.frame = CGRectMake(5, 0, kScreenWidth-10, kScreenHeight);
        backView.alpha = 1;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        imgShowView.hidden = NO;
        originImageView.hidden = YES;
        [originImageView removeFromSuperview];
    }];
    
    imgShowView.singleTapBlock = ^(CNKImgShowView *showView){
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [pageLabel removeFromSuperview];
        [UIView animateWithDuration:0.2 animations:^{
            showView.alpha = 0;
            backView.alpha = 0;
        } completion:^(BOOL finished) {
            [backView removeFromSuperview];
            [showView removeFromSuperview];
        }];
    };
}

+ (UIImageView *)tempImageViewWithImage:(UIImage *)image{
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:image];
    tempImageView.contentMode = UIViewContentModeScaleAspectFit;
    return tempImageView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
