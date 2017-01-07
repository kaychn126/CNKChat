//
//  CNKStrokeLabel.m
//  CNKChat
//
//  Created by chenkai on 2016/11/17.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKStrokeLabel.h"

@implementation CNKStrokeLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)drawTextInRect:(CGRect)rect {
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(c, self.outLineWidth);
    
    CGContextSetLineJoin(c, kCGLineJoinRound);
    
    CGContextSetTextDrawingMode(c, kCGTextStroke);
    
    self.textColor = self.outLinetextColor;
    
    [super drawTextInRect:rect];
    
    self.textColor = self.labelTextColor;
    
    CGContextSetTextDrawingMode(c, kCGTextFill);
    
    [super drawTextInRect:rect];
    
}

@end
