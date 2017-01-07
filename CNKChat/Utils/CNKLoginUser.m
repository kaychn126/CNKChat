//
//  CNKLoginUser.m
//  CNKChat
//
//  Created by chenkai on 2016/11/16.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKLoginUser.h"
#import <objc/runtime.h>

@interface CNKLoginUser()
@property (nonatomic) id propertyForKVO;//use for kvo
@end

@implementation CNKLoginUser
+ (CNKLoginUser *)sharedInstance{
  static CNKLoginUser *instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    
      NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"com.cnk.loginuserid"];
      if (!userId) {
          instance = [[CNKLoginUser alloc] init];
      } else {
          instance = [CNKLoginUser searchSingleWithWhere:[NSString stringWithFormat:@"userId='%@'",userId] orderBy:nil];
          if (!instance) {
              instance = [[CNKLoginUser alloc] init];
          }
      }

      [instance addObserver:instance forKeyPath:@"propertyForKVO" options:NSKeyValueObservingOptionNew context:nil];
  });
  return instance;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"propertyForKVO" context:nil];
}

- (void)setUserId:(NSString *)userId{
  _userId = userId;
  [[NSUserDefaults standardUserDefaults] setValue:_userId forKey:@"com.cnk.loginuserid"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    //属性改变，保存
    [CNKUtils executeBlockInDBQueue:^{
        [self saveToDB];
    }];
}

+ (NSString *)getTableName{
  return [NSString stringWithFormat:@"%@Table",NSStringFromClass([self class])];
}

//将所有其他的property设置为propertyForKVO的依赖，这样任意的依赖发生改变之后propertyForKVO的观察者都会观察到
+ (NSSet *)keyPathsForValuesAffectingPropertyForKVO{
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    NSMutableSet *keypathSet = [NSMutableSet setWithCapacity:propertyCount];
    for (int i = 0; i < propertyCount; i++) {
        NSString *keypath = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
        if (keypath && ![keypath isEqualToString:@"propertyForKVO"]) {
            [keypathSet addObject:keypath];
        }
    }
    free(properties);
    return keypathSet;
}
@end
