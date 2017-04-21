//
//  EBPhotoBroswerViewController.m
//  EasyBenefitMass
//
//  Created by EasyBenefit on 15/11/20.
//  Copyright © 2015年 EasyBenefit. All rights reserved.
//

#import "EBPhotoBroswerViewController.h"
#import "CNKImgShowView.h"

@interface EBPhotoBroswerViewController ()<UIActionSheetDelegate>
@property(nonatomic, strong)CNKImgShowView *imgShowView;
@property(nonatomic, strong)UILabel *pageLabel;
@end

@implementation EBPhotoBroswerViewController

- (id)initWithSourceData:(NSMutableArray *)data withIndex:(NSInteger)index{
    if (self = [super init]) {
        _data = data;
        _index = index;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    self.fd_interactivePopDisabled = YES;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longAction:)];
    [self.view addGestureRecognizer:longPress];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor blackColor];
    [self creatImgShow];
}

// 初始化视图
- (void)creatImgShow{
    Weakfy(weakSelf);
    _imgShowView = [[CNKImgShowView alloc]
                                  initWithFrame:self.view.frame
                                  withSourceData:_data
                                  withIndex:_index];
    [_imgShowView requireDoubleGestureRecognizer:[[self.view gestureRecognizers] lastObject]];
    [self.view addSubview:_imgShowView];
    _imgShowView.pageIndexChangeBlock = ^(NSInteger index){
        Strongfy(strongSelf, weakSelf);
        if(strongSelf.pageLabel){
            strongSelf.pageLabel.text = [NSString stringWithFormat:@"%ld/%ld",(unsigned long)index+1,(unsigned long)strongSelf.data.count];
        }
    };
    
    _imgShowView.singleTapBlock = ^(CNKImgShowView *showView){
        [weakSelf dismissViewControllerAnimated:NO completion:nil];
    };
    
    _pageLabel = [[UILabel alloc] init];
    _pageLabel.font = [UIFont systemFontOfSize:15];
    _pageLabel.textColor = [UIColor whiteColor];
    _pageLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_pageLabel];
    _pageLabel.text = [NSString stringWithFormat:@"%ld/%ld",(unsigned long)_index+1,(unsigned long)_data.count];
    [_pageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(30);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
    _pageLabel.hidden = _data.count==1;
}

#pragma mark -UIGestureReconginzer
- (void)tapAction:(UITapGestureRecognizer *)tap
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)longAction:(UILongPressGestureRecognizer *)longGesture{
    if(longGesture.state == UIGestureRecognizerStateBegan){
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存图片", nil];
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        if(_imgShowView.curIndex >= _data.count-1){
            NSString *selectUrl = [_data objectAtIndex:_imgShowView.curIndex];
            UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[CNKUtils md5String:selectUrl]];
            if(image){
                UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
            }
        }
    }
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
        [self.view cnk_showSuccessWithText:@"成功保存到相册"];
    }else
    {
        [self.view cnk_showErrorWithText:@"保存失败"];
    }
}

@end
