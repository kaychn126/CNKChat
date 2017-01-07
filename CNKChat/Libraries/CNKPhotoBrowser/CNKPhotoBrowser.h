//
//  CNKPhotoBrowser.h
//  CNKChat
//
//  Created by chenkai on 2016/11/16.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNKPhotoBrowser : UIView

+ (void)showImageWithUrlList:(NSArray <NSString *>*)urlList selectView:(UIView *)selectView selectIndex:(NSInteger)selectIndex;

@end
