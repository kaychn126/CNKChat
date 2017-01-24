//
//  CNKAppDelegate.m
//  CNKChat
//
//  Created by chenkai on 2016/11/15.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKAppDelegate.h"
#import "CNKConversationViewController.h"
#import "CNKLoginUser.h"
#import "MNFrameRate.h"
#import "CNKChatMessageHelper.h"
#import "CNKLocationManager.h"
#import "CNKChatBaseCell.h"

@interface CNKAppDelegate ()

@end

@implementation CNKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setupBaseConfigure];
    CNKConversationViewController *conversationVc = [[CNKConversationViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:conversationVc];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setRootViewController:nav];
    [self.window makeKeyAndVisible];
//    [MNFrameRate sharedFrameRate].enabled = YES;
    return YES;
}

- (void)setupBaseConfigure{
    [CNKUtils executeBlockInGlobalQueue:^{
        [[LKDBHelper getUsingLKDBHelper] setDBPath:[[FCFileManager pathForCachesDirectory] stringByAppendingPathComponent:@"database/cnkchat.db"]];
        
        [CNKLoginUser sharedInstance].userName = @"ck";
        [CNKLoginUser sharedInstance].userId = @"ckidckid";
        
        //初始化缓存服务
        [CNKCache sharedInstance];
        
        //预计算cell高度
        [CNKChatMessageHelper preCalculateAndCacheAllCellHeight];
        
    }];
    
    //初始化位置信息(要在主线程初始化)
    [CNKLocationManager sharedInstance];
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}

@end
