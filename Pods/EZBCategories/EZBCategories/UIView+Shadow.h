//
//  UIView+Shadow.h
//  Shadow Maker Example
//
//  Created by Philip Yu on 5/14/13.
//  Copyright (c) 2013 Philip Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSInteger, DirectionType)
{
    DirectionLeft,
    DirectionRight,
    DirectionTop,
    DirectionBottom,
};

@interface UIView (Shadow)

- (void)makeShadowAndCorderWithCornerRadius:(float)cornerRadius andBorderColor:(UIColor*)borderColor andBorderWidth:(float)borderWidth andShadowColor:(UIColor*)shadowColor andShadowRadious:(float)shadowRadious andShadowOpacity:(float)shadowOpacity andDirection:(DirectionType)direction;

@end
