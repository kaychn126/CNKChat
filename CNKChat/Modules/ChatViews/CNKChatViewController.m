//
//  CNKChatViewController.m
//  CNKChat
//
//  Created by chenkai on 2016/11/15.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKChatViewController.h"
#import "CNKChatView.h"

@interface CNKChatViewController ()
@property (nonatomic, strong) CNKChatView *chatView;
@end

@implementation CNKChatViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_chatView viewWillAppear];
}

- (void)dealloc{
    [_chatView destroyView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _chatView = [[CNKChatView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight-64) conversationId:@"14"];
    [self.view addSubview:_chatView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
