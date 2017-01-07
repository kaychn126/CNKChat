//
//  UIActionSheet+Block.m
//  CNKChat
//
//  Created by chenkai on 2016/11/17.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "UIActionSheet+Block.h"
#import <objc/runtime.h>

@implementation UIActionSheet (Block)

static char key;

- (void)showInView:(UIView *)view completionBlock:(CNKActionSheetCompletionBlock)completionBlock{
    if (completionBlock) {
        objc_removeAssociatedObjects(self);
        objc_setAssociatedObject(self, &key, completionBlock, OBJC_ASSOCIATION_COPY);
        self.delegate = (id<UIActionSheetDelegate>)self;
    }
    [self showInView:view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    CNKActionSheetCompletionBlock block = objc_getAssociatedObject(self, &key);
    if (block) {
        ///block传值
        block(buttonIndex);
    }
}

@end
