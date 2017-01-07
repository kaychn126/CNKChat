//
//  CNKChatView.m
//  CNKChat
//
//  Created by chenkai on 2016/11/15.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKChatView.h"
#import "CNKChatMessageModel.h"
#import "CNKChatInputView.h"
#import "CNKChatPlainTextCell.h"
#import "CNKChatVoiceCell.h"
#import "CNKChatImageCell.h"
#import "CNKChatLocationCell.h"
#import "KeyboardManager.h"
#import "EBPhotoBroswerViewController.h"
#import "CNKPhotoBrowser.h"
#import "CNKAudioManager.h"
#import "CNKChatMessageSender.h"
#import "CNKChatMessageHelper.h"

static const double kKeyboardAnimationDuration = 0.25;

static NSString *kCNKPlainTextCellId = @"kCNKPlainTextCellId";
static NSString *kCNKVoiceCellId = @"kCNKVoiceCellId";
static NSString *kCNKImageCellId = @"kCNKImageCellId";
static NSString *kCNKLocationCellId = @"kCNKLocationCellId";

@interface CNKChatView()<UITableViewDelegate, UITableViewDataSource, CNKChatInputViewDelegate, CNKChatImageCellDelegate, CNKChatInputMediaViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CNKChatInputView *inputView;
@property (nonatomic, strong) CNKChatInputMediaView *inputMediaView;

@property (nonatomic, strong) NSMutableArray <CNKChatMessageModel *> *msgList;
@property (nonatomic, assign) double tableViewContentOffsetY;
@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicatorView;
@property (nonatomic, assign) BOOL hasMoreData;
@end

@implementation CNKChatView

- (void)dealloc{
    [self destroyView];
}

- (instancetype)initWithFrame:(CGRect)frame conversationId:(NSString *)conversationId{
    if (self = [super initWithFrame:frame]) {
        _conversationId = conversationId;
        [CNKChatMessageHelper preCalculateAndCacheCellHeightWithConversationId:_conversationId];
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(keyboardWillShow:)
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(keyboardWillHide:)
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
        self.backgroundColor = kGrayColor(240);
        _msgList = [NSMutableArray array];
        _mediaItemTypeList = [NSArray arrayWithObjects:[NSNumber numberWithInteger:CNKChatInputMediaItemTypeCamera],[NSNumber numberWithInteger:CNKChatInputMediaItemTypePhotoAlbum],[NSNumber numberWithInteger:CNKChatInputMediaItemTypeLocation], nil];
        
        [self inputView];
        [self inputMediaView];
        [self tableHeaderView];
        [self tableView];
        [self scrollToBottomWithAnimation:NO delay:NO];
        [self queryFirstPageMessages];
    }
    return self;
}

#pragma mark- getter

- (CNKChatInputView *)inputView{
    if (!_inputView) {
        _inputView = [[CNKChatInputView alloc] init];
        [self addSubview:_inputView];
        _inputView.delegate = self;
        [_inputView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.mas_equalTo(0);
            make.height.mas_equalTo(kInputViewMinHeight);
        }];
    }
    return _inputView;
}

- (CNKChatInputMediaView *)inputMediaView{
    if (!_inputMediaView) {
        _inputMediaView = [[CNKChatInputMediaView alloc] init];
        _inputMediaView.itemTypeList = _mediaItemTypeList;
        _inputMediaView.delegate = self;
        [self insertSubview:_inputMediaView belowSubview:_inputView];
        [_inputMediaView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(_inputView.mas_bottom);
            make.height.mas_equalTo(200);
        }];
    }
    return _inputMediaView;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        [self insertSubview:_tableView belowSubview:_inputView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(self.inputView.mas_top);
        }];
        [_tableView registerClass:CNKChatPlainTextCell.class forCellReuseIdentifier:kCNKPlainTextCellId];
        [_tableView registerClass:CNKChatVoiceCell.class forCellReuseIdentifier:kCNKVoiceCellId];
        [_tableView registerClass:CNKChatImageCell.class forCellReuseIdentifier:kCNKImageCellId];
        [_tableView registerClass:CNKChatLocationCell.class forCellReuseIdentifier:kCNKLocationCellId];
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
        footerView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = footerView;
        _tableView.tableHeaderView = _tableHeaderView;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [_tableView addGestureRecognizer:tap];
    }
    return _tableView;
}

- (UIView *)tableHeaderView{
    if (!_tableHeaderView) {
        _tableHeaderView = [[UIView alloc] init];
        _tableHeaderView.frame = CGRectMake(0, 0, kScreenWidth, 20);
        _tableHeaderView.backgroundColor = [UIColor clearColor];
    }
    return _tableHeaderView;
}

- (UIActivityIndicatorView *)loadingIndicatorView{
    if (!_loadingIndicatorView) {
        _loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_tableHeaderView addSubview:_loadingIndicatorView];
        [_loadingIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(_tableHeaderView);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
    }
    return _loadingIndicatorView;
}

#pragma mark- setter

- (void)setMediaItemTypeList:(NSArray<NSNumber *> *)mediaItemTypeList{
    _mediaItemTypeList = mediaItemTypeList;
    if (_inputMediaView) {
        _inputMediaView.itemTypeList = _mediaItemTypeList;
    }
}

#pragma mark- datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _msgList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CNKChatMessageModel *message = [_msgList objectAtIndex:indexPath.row];
    return [CNKChatMessageHelper cellHeightWithMsg:message];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CNKChatMessageModel *message = [_msgList objectAtIndex:indexPath.row];
    if (message.msgContentType == CNKMSGContentTypePlainText) {
        CNKChatPlainTextCell *cell = [tableView dequeueReusableCellWithIdentifier:kCNKPlainTextCellId];
        [cell setMessage:message];
        return cell;
    } else if (message.msgContentType == CNKMSGContentTypeVoice){
        CNKChatVoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:kCNKVoiceCellId];
        [cell setMessage:message];
        return cell;
    } else if (message.msgContentType == CNKMSGContentTypeImage){
        CNKChatImageCell *cell = [tableView dequeueReusableCellWithIdentifier:kCNKImageCellId];
        cell.delegate = self;
        [cell setMessage:message];
        return cell;
    } else if (message.msgContentType == CNKMSGContentTypeLocation){
        CNKChatLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:kCNKLocationCellId];
        [cell setMessage:message];
        return cell;
    }
    return [UITableViewCell new];
}

#pragma mark- tableview delegate

#pragma mark- query messages

- (void)queryFirstPageMessages{
    WS(weakSelf);
    [CNKChatMessageHelper loadFirstPageWithConversationId:_conversationId resultBlock:^(NSArray<CNKChatMessageModel *> *messageList, BOOL hasMoreData) {
        weakSelf.hasMoreData = hasMoreData;
        [weakSelf insertFirstPageMessageList:messageList];
    }];
}

- (void)queryNextPageMessagesCompletionBlock:(void(^)(BOOL hasMoreData))completionBlock{
    WS(weakSelf);
    [CNKChatMessageHelper loadNextPageWithLastMessage:[_msgList firstObject] resultBlock:^(NSArray<CNKChatMessageModel *> *messageList, BOOL hasMoreData) {
        [CNKUtils executeBlockInMainQueue:^{
            weakSelf.hasMoreData = hasMoreData;
            if (completionBlock) {
                completionBlock(hasMoreData);
            }
            [weakSelf insertOldMessageList:messageList];
        } delay:0.4];
    }];
}

#pragma mark- insert messages
//顶部插入数据
- (void)insertOldMessageList:(NSArray<CNKChatMessageModel*>*)messageList{
    _tableViewContentOffsetY = _tableView.contentOffset.y;
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:messageList.count];
    [messageList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        [indexPaths addObject:indexPath];
        CNKChatMessageModel *message = (CNKChatMessageModel*)obj;
        [_msgList insertObject:message atIndex:idx];
        _tableViewContentOffsetY += [CNKChatMessageHelper cellHeightWithMsg:message];
    }];
    _tableViewContentOffsetY = _tableViewContentOffsetY<0?0:_tableViewContentOffsetY;
    [UIView setAnimationsEnabled:NO];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [_tableView setContentOffset:CGPointMake(0, _tableViewContentOffsetY) animated:NO];
    [_tableView endUpdates];
    [UIView setAnimationsEnabled:YES];
}

//插入第一页数据
- (void)insertFirstPageMessageList:(NSArray<CNKChatMessageModel*>*)messageList{
    [_msgList addObjectsFromArray:messageList];
    _tableViewContentOffsetY = _tableView.contentOffset.y;
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:messageList.count];
    [messageList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        [indexPaths addObject:indexPath];
        CNKChatMessageModel *message = (CNKChatMessageModel*)obj;
        _tableViewContentOffsetY += [CNKChatMessageHelper cellHeightWithMsg:message];
    }];
    _tableViewContentOffsetY -= _tableView.frame.size.height;
    _tableViewContentOffsetY = _tableViewContentOffsetY<0?0:_tableViewContentOffsetY;
    [UIView setAnimationsEnabled:NO];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [_tableView setContentOffset:CGPointMake(0, _tableViewContentOffsetY) animated:NO];
    [_tableView endUpdates];
    [UIView setAnimationsEnabled:YES];
}

- (void)appendNewMessageList:(NSArray <CNKChatMessageModel*> *)messageList{
    if(messageList){
        messageList = [CNKChatMessageHelper checkShowDateWithMsgList:messageList];
        
        [CNKChatMessageModel insertArrayByAsyncToDB:messageList];
        
        [[CNKChatMessageSenderManager sharedInstance] startSendMessageList:messageList];
        [_msgList addObjectsFromArray:messageList];
        [_tableView reloadData];
        [self scrollToBottomWithAnimation:YES delay:YES];
    }
}

#pragma mark- CNKChatInputViewDelegate

- (void)inputView:(CNKChatInputView*)inputView sendTextAction:(NSString *)sendText{
    if (sendText.length == 0) {
        return;
    }
    CNKChatMessageModel *message = [[CNKChatMessageModel alloc] init];
    message.msgId = [[NSProcessInfo processInfo] globallyUniqueString];
    message.conversationId = _conversationId;
    message.senderId = @"123";
    message.msgContentType = CNKMSGContentTypePlainText;
    message.msgContent = sendText;
    message.senderAvatar = @"https://ws4.sinaimg.cn/thumbnail/7d11fac9gw1f9sw89f3a8j201e01ejr5.jpg";
    message.onwerId = [CNKLoginUser sharedInstance].userId;
    message.timestamp = [CNKUtils timestampWithDate:[NSDate date]];
    [self appendNewMessageList:[NSArray arrayWithObject:message]];
}

- (void)inputMediaView:(CNKChatInputMediaView *)inputMediaView sendImageAction:(NSArray<UIImage *> *)imageList{
    if (imageList.count == 0) {
        return;
    }
    NSMutableArray *imageMsgList = [NSMutableArray arrayWithCapacity:imageList.count];
    [imageList enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CNKChatMessageModel *message = [[CNKChatMessageModel alloc] init];
        message.msgId = [[NSProcessInfo processInfo] globallyUniqueString];
        message.conversationId = _conversationId;
        message.senderId = @"123";
        message.msgContentType = CNKMSGContentTypeImage;
        message.msgContent = message.msgId;
        
        //cache image
        [[SDImageCache sharedImageCache] storeImage:obj forKey:message.msgContentMd5Key];
        
        message.senderAvatar = @"https://ws4.sinaimg.cn/thumbnail/7d11fac9gw1f9sw89f3a8j201e01ejr5.jpg";
        message.onwerId = [CNKLoginUser sharedInstance].userId;
        
        //时间错开
        message.timestamp = [CNKUtils timestampWithDate:[NSDate date]] + idx;
        
        [imageMsgList addObject:message];
    }];
    [self appendNewMessageList:imageMsgList];
}

- (void)inputView:(CNKChatInputView *)inputView sendAudioAction:(NSString *)audioContentOfUrl{
    if (audioContentOfUrl.length == 0) {
        return;
    }
    CNKChatMessageModel *message = [[CNKChatMessageModel alloc] init];
    message.msgId = [[NSProcessInfo processInfo] globallyUniqueString];
    message.conversationId = _conversationId;
    message.senderId = @"123";
    message.msgContentType = CNKMSGContentTypeVoice;
    message.msgContent = audioContentOfUrl;
    message.senderAvatar = @"https://ws4.sinaimg.cn/thumbnail/7d11fac9gw1f9sw89f3a8j201e01ejr5.jpg";
    message.onwerId = [CNKLoginUser sharedInstance].userId;
    message.timestamp = [CNKUtils timestampWithDate:[NSDate date]];
    message.voiceLength = [CNKAudioManager getAudioLengthWithAudioCacheKey:message.msgContentMd5Key];
    message.isAudioPlayed = YES;
    [self appendNewMessageList:[NSArray arrayWithObject:message]];
}

- (void)inputMediaView:(CNKChatInputMediaView *)inputMediaView sendLocationAction:(CNKChatLocation *)location{
    if (!location) {
        return;
    }
    CNKChatMessageModel *message = [[CNKChatMessageModel alloc] init];
    message.msgId = [[NSProcessInfo processInfo] globallyUniqueString];
    message.conversationId = _conversationId;
    message.senderId = @"123";
    message.msgContentType = CNKMSGContentTypeLocation;
    message.msgContentMd5Key = location.placeImageKey;
    message.senderAvatar = @"https://ws4.sinaimg.cn/thumbnail/7d11fac9gw1f9sw89f3a8j201e01ejr5.jpg";
    message.onwerId = [CNKLoginUser sharedInstance].userId;
    message.timestamp = [CNKUtils timestampWithDate:[NSDate date]];
    message.location = location;
    [self appendNewMessageList:[NSArray arrayWithObject:message]];
    
}

- (void)inputView:(CNKChatInputView *)inputView addButtonAction:(BOOL)showMediaView{
    if (showMediaView) {
        [self inputViewMoveUpWithHeight:[CNKChatInputMediaView inputMediaViewHeightWithItemTypeList:_mediaItemTypeList]];
    } else {
        [self inputViewMoveDown];
    }
}

#pragma mark- noty
- (void)keyboardWillShow:(NSNotification *)notification{
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self inputViewMoveUpWithHeight:keyboardRect.size.height];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    [self inputViewMoveDown];
}

#pragma mark- inputView state change

- (void)inputViewMoveUpWithHeight:(double)height{
    double displayHeihgt = self.height - height - kInputViewMinHeight;
    double tableContentHeight = [CNKChatMessageHelper cellHeightWithMsgList:_msgList] + _tableView.tableHeaderView.height + _tableView.tableFooterView.height;
    
    if (displayHeihgt < tableContentHeight && tableContentHeight >= self.height - kInputViewMinHeight) {
        [_tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(self.height - kInputViewMinHeight);
            make.bottom.mas_equalTo(self.inputView.mas_top);
        }];
        
        [self scrollToBottomWithAnimation:YES delay:NO];
    } else {
        [_tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(self.inputView.mas_top);
        }];
        if (tableContentHeight < self.height - kInputViewMinHeight) {
            [self scrollToBottomWithAnimation:YES delay:YES];
        }
    }
    
    [UIView animateWithDuration:kKeyboardAnimationDuration animations:^{
        [_inputView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-height);
        }];
        
        [[self ezb_getClosestViewController].view layoutIfNeeded];
    }];
}

- (void)inputViewMoveDown{
    [UIView animateWithDuration:kKeyboardAnimationDuration animations:^{
        [_inputView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
        }];
        [[self ezb_getClosestViewController].view layoutIfNeeded];
    }];
}

#pragma mark- tap action

- (void)tapAction:(UIGestureRecognizer*)tap{
    [self endEditing:YES];
    [self inputViewMoveDown];
    _inputView.isMediaViewShown = NO;
}

#pragma mark- scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self tapAction:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    static BOOL isLoading = NO;
    if (scrollView.contentOffset.y <= 0 && !isLoading && _hasMoreData) {
        isLoading = YES;
        [self loadingIndicatorView].hidden = NO;
        [[self loadingIndicatorView] startAnimating];
        WS(weakSelf);
        [self queryNextPageMessagesCompletionBlock:^(BOOL hasMoreData) {
            isLoading = NO;
            weakSelf.hasMoreData = hasMoreData;
            [weakSelf loadingIndicatorView].hidden = YES;
            [[weakSelf loadingIndicatorView] stopAnimating];
        }];
    }
}

- (void)scrollToBottomWithAnimation:(BOOL)animation delay:(BOOL)delay{
    void(^scrollToBottomBlock)(void) = ^{
        double tableFrameHeight = self.tableView.frame.size.height;
        double tableContentHeight = self.tableView.contentSize.height;
        double contentOffsetY = tableContentHeight<=tableFrameHeight?0:(tableContentHeight-tableFrameHeight);
        if (contentOffsetY > 0) {
            [self.tableView setContentOffset:CGPointMake(0, contentOffsetY) animated:animation];
        } else if (contentOffsetY < 0) {
            [self.tableView setContentOffset:CGPointZero animated:animation];
        }
    };
    
    if (delay) {
        [CNKUtils executeBlockInMainQueue:^{
            scrollToBottomBlock();
        } delay:0.1];
    } else {
        scrollToBottomBlock();
    }
}

#pragma mark- CNKChatImageCellDelegate

- (void)chatImageCell:(CNKChatImageCell *)chatImageCell didSelectImageView:(UIImageView *)imageView{
    [self tapAction:nil];
    [CNKChatMessageHelper loadImageMessagesWithConversationId:_conversationId resultBlock:^(NSArray<CNKChatMessageModel *> *messageList) {
        __block NSInteger index = 0;
        NSMutableArray *photoList = [NSMutableArray arrayWithCapacity:messageList.count];
        [messageList enumerateObjectsUsingBlock:^(CNKChatMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([chatImageCell.message.msgId isEqualToString:obj.msgId]) {
                index = idx;
            }
            [photoList addObject:obj.msgContent];
        }];
        [CNKPhotoBrowser showImageWithUrlList:photoList selectView:imageView selectIndex:index];
    }];
}

#pragma mark- life cycle
- (void)viewWillAppear{
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)destroyView{
    if ([CNKAudioManager sharedInstance].isPlaying) {
        [[CNKAudioManager sharedInstance] stopPlayAudio];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _tableView.delegate = nil;
    _inputView.delegate = nil;
    _inputMediaView.delegate = nil;
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}
@end
