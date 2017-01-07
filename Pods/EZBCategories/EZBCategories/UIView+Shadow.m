//
//  UIView+Shadow.m
//  Shadow Maker Example
//
//  Created by Philip Yu on 5/14/13.
//  Copyright (c) 2013 Philip Yu. All rights reserved.
//

#import "UIView+Shadow.h"

@implementation UIView (Shadow)

- (void)makeShadowAndCorderWithCornerRadius:(float)cornerRadius andBorderColor:(UIColor*)borderColor andBorderWidth:(float)borderWidth andShadowColor:(UIColor*)shadowColor andShadowRadious:(float)shadowRadious andShadowOpacity:(float)shadowOpacity andDirection:(DirectionType)direction{
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    self.layer.shadowPath = path;
    CGPathCloseSubpath(path);
    CGPathRelease(path);
    
    self.layer.shadowColor = shadowColor.CGColor;
    self.layer.shadowRadius = shadowRadious;
    self.layer.cornerRadius = cornerRadius;
    self.layer.borderColor = borderColor.CGColor;
    self.layer.borderWidth = borderWidth;
    self.layer.shadowOpacity = shadowOpacity;

    if (direction == DirectionTop) {
        self.layer.shadowOffset = CGSizeMake(0, -shadowRadious);
    }else if (direction == DirectionBottom){
        self.layer.shadowOffset = CGSizeMake(0, shadowRadious);
    }else if (direction == DirectionLeft){
        self.layer.shadowOffset = CGSizeMake(-shadowRadious, 0);
    }else if (direction == DirectionRight){
        self.layer.shadowOffset = CGSizeMake(shadowRadious, 0);
    }
}
@end
