//
//  EBImgShowView.m
//  EasyBenefitMass
//
//  Created by EasyBenefit on 15/6/16.
//  Copyright (c) 2015年 EasyBenefit. All rights reserved.
//

#import "CNKImgShowView.h"
#import "UIImageView+WebCache.h"

#pragma mark -定义宏常量
#define kImgViewCount 3

#define kImgZoomScaleMin 1
#define kImgZoomScaleMax 3

#pragma mark -定义展示板
#define kImgVLeft (UIImageView *)[_imgViewDic valueForKey:@"imgLeft"];
#define kImgVCenter (UIImageView *)[_imgViewDic valueForKey:@"imgCenter"];
#define kImgVRight (UIImageView *)[_imgViewDic valueForKey:@"imgRight"];

@implementation CNKImgShowView
{
    UIScrollView *_scrCenter;
    BOOL _isDoubleTap;//是否是双击
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withSourceData:(NSMutableArray <NSString *>*)imgSource withIndex:(NSInteger)index;{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        // 初始化控件属性
        [self initScrollView];
        
        // 设置数据源
        [self setImgSource:imgSource];
        
        // 设置图片下标
        [self setCurIndex:index];
        
        
    }
    return self;
}

#pragma mark -初始化控件
- (void)initScrollView{
    
    // 设置代理
    self.delegate = self;
    
    // 不显示滚动条
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    
    // 设置分页显示
    self.pagingEnabled = YES;
    
    //设置背景颜色
    self.backgroundColor = [UIColor clearColor];
    
    // 构建展示组
    [self initImgViewDic];
}

// 通过创建展示板
- (UIImageView *)creatImageView{
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, width-10, height)];
    imgView.userInteractionEnabled = YES;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [imgView addGestureRecognizer:longPress];
    return imgView;
}

// 通过位置创建展示板
- (UIScrollView *)scrollViewWithPosition:(CNKImgLocation)imgLocation withImgView:(UIImageView *)imgView{
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(width * imgLocation, 0, width, height)];
    
    scrollView.backgroundColor = [UIColor clearColor];
    
    [scrollView addSubview:imgView];
    
    // 设置图片显示样式
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    return scrollView;
}

- (void)_initScrollCenter{
    // 设置缩放极限
    _scrCenter.maximumZoomScale = kImgZoomScaleMax;
    _scrCenter.minimumZoomScale = kImgZoomScaleMin;
    
    _scrCenter.delegate = self;
}

// 初始化展示板组
- (void)initImgViewDic{
    
    UIImageView *imgLeft = [self creatImageView];
    UIImageView *imgCenter =[self creatImageView];
    UIImageView *imgRight = [self creatImageView];
    
    _imgViewDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                   imgLeft, @"imgLeft",
                   imgCenter, @"imgCenter",
                   imgRight, @"imgRight", nil];
    
    UIScrollView *scrLeft =
    [self scrollViewWithPosition:CNKImgLocationLeft withImgView:imgLeft];
    _scrCenter =
    [self scrollViewWithPosition:CNKImgLocationCenter withImgView:imgCenter];
    UIScrollView *scrRight =
    [self scrollViewWithPosition:CNKImgLocationRight withImgView:imgRight];
    
    // 初始化scrCenter
    [self _initScrollCenter];
    
    // 添加双击手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapClick:)];
    doubleTap.numberOfTapsRequired = 2;
    
    [self addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];
    
    // 放入展示板
    [self addSubview:scrLeft];
    [self addSubview:_scrCenter];
    [self addSubview:scrRight];
}

#pragma mark -setAttribute
// 设置数据源
- (void)setImgSource:(NSMutableArray *)imgSource{
    
    if (_imgSource != imgSource) {
        _imgSource = imgSource;
        if(_imgSource.count==1){
            self.scrollEnabled = NO;
        }
        //  设置展示板尺寸
        [self setConSize];
    }
}

// 展示板尺寸设置
- (void)setConSize{
    
    CGSize size = self.frame.size;
    
    //设置内容视图的大小--单页填充、横向划动
    self.contentSize = CGSizeMake(size.width * kImgViewCount, size.height);
    
    // 设置显示页
    [self setContentOffset:CGPointMake(size.width, 0)];
}

- (void)setCurIndex:(NSInteger)curIndex{
    
    if (_imgSource.count > curIndex && curIndex >= 0) {
        _curIndex = curIndex;
    } else if (curIndex == -1){
        _curIndex = _imgSource.count - 1;
    } else if (curIndex == _imgSource.count){
        _curIndex = 0;
    }
    if(_pageIndexChangeBlock){
        _pageIndexChangeBlock(_curIndex);
    }
    // 判断数据类型 根据数据类型抉择使用情况
    
    if (_imgSource.count) {
        [self setAllImgVContentFromImage:[self imgListFromIndex:_curIndex]];
    }
}

#pragma mark -功能函数

// 根据当前索引赋值图片
- (NSArray *)imgListFromIndex:(NSInteger)curIndex{
    
    long sCount = _imgSource.count;
    NSArray *imgList;
    
    NSString *imgL;
    NSString *imgC;
    NSString *imgR;
    
    if (sCount) {
        
        // 首位
        if (curIndex == 0) {
            imgL = [_imgSource lastObject];
            imgC = _imgSource[curIndex];
            long nextIndex = curIndex == sCount - 1 ? curIndex : curIndex + 1;
            imgR = _imgSource[nextIndex];
            // 末位
        } else if (curIndex == sCount - 1){
            long lastIndex = curIndex == 0 ? curIndex : curIndex - 1;
            imgL = _imgSource[lastIndex] ;
            imgC = [_imgSource lastObject];
            imgR = _imgSource[0];
            // 中间
        } else {
            imgL = _imgSource[curIndex - 1];
            imgC = _imgSource[curIndex];
            imgR = _imgSource[curIndex + 1];
        }
        
        imgList = [[NSArray alloc] initWithObjects:imgL, imgC, imgR, nil];
    }
    
    return imgList;
}

// 载入一组图片
- (void)setAllImgVContentFromImage:(NSArray *)imgList{
    
    // 将所有imgList中的数据载入展示板
    UIImageView *vLeft = kImgVLeft;
    UIImageView *vCenter = kImgVCenter;
    UIImageView *vRight = kImgVRight;
    
    if (imgList.count) {
        NSString *leftUrl = imgList[CNKImgLocationLeft];
        NSString *centerUrl = imgList[CNKImgLocationCenter];
        NSString *rightUrl = imgList[CNKImgLocationRight];
        
        UIImage *leftImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[CNKUtils md5String:leftUrl]];
        if (leftImage) {
            [vLeft setImage:leftImage];
        } else if ([CNKUtils isValidateURL:leftUrl]){
            [vLeft sd_setImageWithURL:[NSURL URLWithString:leftUrl]];
        }
        
        UIImage *centerImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[CNKUtils md5String:centerUrl]];
        if (centerImage) {
            [vCenter setImage:centerImage];
        } else if ([CNKUtils isValidateURL:centerUrl]){
            [vCenter sd_setImageWithURL:[NSURL URLWithString:centerUrl]];
        }
        
        UIImage *rightImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[CNKUtils md5String:rightUrl]];
        if (rightImage) {
            [vRight setImage:rightImage];
        } else if ([CNKUtils isValidateURL:rightUrl]){
            [vRight sd_setImageWithURL:[NSURL URLWithString:rightUrl]];
        }
    }
}

// 谦让双击放大手势
- (void)requireDoubleGestureRecognizer:(UITapGestureRecognizer *)tap{
    [tap requireGestureRecognizerToFail:[[self gestureRecognizers] lastObject]];
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self == scrollView) {
        CGFloat width = self.frame.size.width;
        int currentOffset = scrollView.contentOffset.x/width - 1;
        [self setCurIndex:_curIndex + currentOffset];
        [scrollView setContentOffset:CGPointMake(width, 0) animated:NO];
        [_scrCenter setZoomScale:kImgZoomScaleMin];
    } else if (_scrCenter == scrollView)
    {
        CGFloat height = self.frame.size.height;
        CGFloat offsetY = _scrCenter.contentOffset.y;
        
        // 弹出判断
        if (height*1.8 < offsetY || offsetY < height*0.5) {
            [_scrCenter setZoomScale:kImgZoomScaleMin animated:YES];
        }
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    UIImageView *vCenter = kImgVCenter;
    return vCenter;
}

#pragma mark -Tap手势处理
- (void)doubleTapClick:(UITapGestureRecognizer *)tap{
    _isDoubleTap = YES;
    //判断当前放大的比例
    if (_scrCenter.zoomScale > kImgZoomScaleMin) {
        //缩小
        [_scrCenter setZoomScale:kImgZoomScaleMin animated:YES];
    }else{
        //放大
        [_scrCenter setZoomScale:kImgZoomScaleMax animated:YES];
    }
}

- (void)singleTapAction:(UITapGestureRecognizer *)tap{
    _isDoubleTap = NO;
    [CNKUtils executeBlockInMainQueue:^{
        if(!_isDoubleTap){
            if(_singleTapBlock){
                _singleTapBlock(self);
            }
        }
    } delay:0.3f];
}

- (void)longPressAction:(UITapGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIImageView *imageView = (UIImageView *)gestureRecognizer.view;
        if (imageView.image) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存到相册", nil];
            [actionSheet showInView:[UIApplication sharedApplication].keyWindow completionBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    UIImageWriteToSavedPhotosAlbum(imageView.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
                }
            }];
        }
    }
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
        
        [[self ezb_getClosestViewController].view cnk_showSuccessWithText:@"成功保存到相册"];
        
    } else {
        
        [[self ezb_getClosestViewController].view cnk_showErrorWithText:@"保存失败"];
        
    }
}
@end
