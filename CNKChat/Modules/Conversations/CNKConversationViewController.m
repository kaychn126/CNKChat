//
//  CNKConversationViewController.m
//  CNKChat
//
//  Created by chenkai on 2016/11/15.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKConversationViewController.h"
#import "CNKChatViewController.h"
#import "CNKChatMessageModel.h"

@interface CNKConversationViewController ()
@end

@implementation CNKConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Conversations";
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [chatButton setTitle:@"Chat View" forState:UIControlStateNormal];
    [chatButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [chatButton addTarget:self action:@selector(chatButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:chatButton];
    [chatButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.centerY.mas_equalTo(self.view).mas_offset(100);
        make.size.mas_equalTo(CGSizeMake(100, 50));
    }];
}

- (void)chatButtonAction:(UIButton *)button{
    CNKChatViewController *chatvc = [[CNKChatViewController alloc] init];
    [self.navigationController pushViewController:chatvc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
