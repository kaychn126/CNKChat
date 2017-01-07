//
//  UIView+IndicatorView.m
//  EasyBenefitMass
//
//  Created by EasyBenefit on 15/12/3.
//  Copyright © 2015年 EasyBenefit. All rights reserved.
//

#import "UIView+IndicatorView.h"
#import "Masonry.h"

@implementation UIView (IndicatorView)
- (void)showIndicatorView:(BOOL)show{
    UIActivityIndicatorView *indicatorView = [self getIndicatorView];
    if(show){
        indicatorView.hidden = NO;
        [indicatorView startAnimating];
    }else{
        indicatorView.hidden = YES;
        [indicatorView stopAnimating];
    }
}

- (UIActivityIndicatorView*)getIndicatorView{
    UIActivityIndicatorView *indicatorView = [self viewWithTag:8970];
    if(!indicatorView){
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:indicatorView];
        [indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(50, 50));
        }];
    }
    indicatorView.hidden = YES;
    return indicatorView;
}
@end
