//
//  UINavigationItem+indicatorView.m
//  EasyBenefitMass
//
//  Created by EasyBenefit on 16/1/9.
//  Copyright © 2016年 EasyBenefit. All rights reserved.
//

#import "UINavigationItem+indicatorView.h"
#import <objc/runtime.h>
#import "Masonry.h"

static char kAssociatedNavigationItemIndicatorViewKey;

@implementation UINavigationItem (indicatorView)

- (void)setEb_indicatorView:(EBNavigationItemIndicatorView *)eb_indicatorView{
    if (self.eb_indicatorView != eb_indicatorView) {
        self.titleView = eb_indicatorView;
        objc_setAssociatedObject(self, &kAssociatedNavigationItemIndicatorViewKey, eb_indicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (EBNavigationItemIndicatorView*)eb_indicatorView{
    return objc_getAssociatedObject(self, &kAssociatedNavigationItemIndicatorViewKey);
}

- (void)showIndicatorViewWithStatus:(NSString*)status{
    if (!self.eb_indicatorView) {
        EBNavigationItemIndicatorView *indicatorView = [[EBNavigationItemIndicatorView alloc] init];
        [self setEb_indicatorView:indicatorView];
        [self.eb_indicatorView setStatus:status];
    } else {
        [self.eb_indicatorView setStatus:status];
    }
}
- (void)hideIndicatorView{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.eb_indicatorView) {
            [self.eb_indicatorView.indicatorView stopAnimating];
            self.titleView = nil;
        }
    });
}
@end

@interface EBNavigationItemIndicatorView()
@property(nonatomic, strong)UILabel *label;
@end

@implementation EBNavigationItemIndicatorView

- (instancetype)init{
    if(self = [super init]){
        _label = [[UILabel alloc] init];
        _label.font = [UIFont systemFontOfSize:17];
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self addSubview:_indicatorView];
        self.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-200)/2, 0, 200, 44);
    }
    return self;
}

- (void)setStatus:(NSString *)status{
    _status = status;
    if(_status.length>0){
        _label.text = _status;
        CGSize lableSize = [_label sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width-100, 44)];
        [_label mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self);
            make.centerX.mas_equalTo(self).mas_offset(20);
            make.size.mas_equalTo(CGSizeMake(lableSize.width, 44));
        }];
        [_indicatorView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self);
            make.right.mas_equalTo(_label.mas_left);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];
        [_indicatorView startAnimating];
    }else{
        //只显示_indicatorView
        _label.text = _status;
        [_indicatorView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self);
            make.centerX.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];
        [_indicatorView startAnimating];
    }
}
@end