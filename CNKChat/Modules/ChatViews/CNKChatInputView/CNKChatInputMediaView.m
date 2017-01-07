//
//  CNKChatInputMediaView.m
//  CNKChat
//
//  Created by chenkai on 2016/11/18.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKChatInputMediaView.h"
#import "TZImagePickerController.h"
#import "CNKChatSendLocationViewController.h"

@interface CNKChatInputMediaView()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *itemViewList;
@end

@implementation CNKChatInputMediaView

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        _itemViewList = [NSMutableArray array];
    }
    return self;
}

#pragma mark- setter

- (void)setItemTypeList:(NSArray *)itemTypeList{
    _itemTypeList = itemTypeList;
    [_itemViewList makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [itemTypeList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        double itemWidth = (kScreenWidth - 30.f)/4.f;
        double itemX = (15 + itemWidth * (idx%4)) + kScreenWidth * (idx/8);
        double itemY = 15 + itemWidth * (idx/4);
        NSNumber *itemTypeNumber = (NSNumber *)obj;
        WS(weakSelf);
        CNKChatInputMediaItemView *itemView = [[CNKChatInputMediaItemView alloc] initWithItemType:itemTypeNumber.integerValue actionBlock:^(CNKChatInputMediaItemType itemType) {
            [weakSelf actionWithItemType:itemType];
        }];
        itemView.frame = CGRectMake(itemX, itemY, itemWidth, itemWidth);
        [self addSubview:itemView];
        [_itemViewList addObject:itemView];
    }];
}

- (void)actionWithItemType:(CNKChatInputMediaItemType)itemType{
    if (itemType == CNKChatInputMediaItemTypeCamera) {
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }else{
            return;
        }
        picker.allowsEditing = NO;
        [[self ezb_getNavigationController] presentViewController:picker animated:YES completion:nil];
    } else if (itemType == CNKChatInputMediaItemTypePhotoAlbum) {
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:nil];
        WS(weakSelf);
        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            if ([weakSelf.delegate respondsToSelector:@selector(inputMediaView:sendImageAction:)]) {
                [weakSelf.delegate inputMediaView:weakSelf sendImageAction:photos];
            }
        }];
        [[self ezb_getNavigationController] presentViewController:imagePickerVc animated:YES completion:nil];
        
    } else if (itemType == CNKChatInputMediaItemTypeShortVideo) {
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;//sourcetype有三种分别是camera，photoLibrary和photoAlbum
        NSArray *availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];//Camera所支持的Media格式都有哪些,共有两个分别是@"public.image",@"public.movie"
        ipc.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];//设置媒体类型为public.movie
        ipc.videoMaximumDuration = 60.0f;//60秒
        ipc.delegate = self;//设置委托
        [[self ezb_getClosestViewController] presentViewController:ipc animated:YES completion:nil];
    } else if (itemType == CNKChatInputMediaItemTypeLocation) {
        CNKChatSendLocationViewController *sendLocationVc = [[CNKChatSendLocationViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sendLocationVc];
        nav.view.backgroundColor = [UIColor whiteColor];
        sendLocationVc.hidesBottomBarWhenPushed = YES;
        WS(weakSelf);
        sendLocationVc.sendActionBlock = ^(CNKChatLocation *sendLocation){
            if ([weakSelf.delegate respondsToSelector:@selector(inputMediaView:sendLocationAction:)]) {
                [weakSelf.delegate inputMediaView:weakSelf sendLocationAction:sendLocation];
            }
        };
        [[self ezb_getClosestViewController] presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark- delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        //转成jpg格式的二进制数据
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *referenceUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
            if(!referenceUrl){
                //相机拍的照片
                UIImageWriteToSavedPhotosAlbum(originImage, self, nil, nil);
            }
        });
        if ([self.delegate respondsToSelector:@selector(inputMediaView:sendImageAction:)]) {
            [self.delegate inputMediaView:self sendImageAction:[NSArray arrayWithObject:originImage]];
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"不支持视频发送！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

+ (double)inputMediaViewHeightWithItemTypeList:(NSArray *)itemTypeList{
    if (itemTypeList.count <= 4) {
        return 105;
    } else {
        return 205;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@interface CNKChatInputMediaItemView()
@property(nonatomic, copy) void(^buttonActionBlock)(CNKChatInputMediaItemType itemType);
@property(nonatomic, assign)CNKChatInputMediaItemType itemType;
@end

@implementation CNKChatInputMediaItemView

- (instancetype)initWithItemType:(NSInteger)itemType actionBlock:(void(^)(CNKChatInputMediaItemType itemType))actionBlock{
    if (self = [super init]) {
        _buttonActionBlock = actionBlock;
        _itemType = itemType;
        [self itemImageView];
        [self itemTitleLabel];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        
        if (itemType == CNKChatInputMediaItemTypeCamera) {
            _itemTitleLabel.text = @"拍摄";
            [_itemImageView setImage:[UIImage imageNamed:@"chatinputitem_camera"]];
        } else if (itemType == CNKChatInputMediaItemTypePhotoAlbum) {
            _itemTitleLabel.text = @"照片";
            [_itemImageView setImage:[UIImage imageNamed:@"chatinputitem_album"]];
        } else if (itemType == CNKChatInputMediaItemTypeShortVideo) {
            _itemTitleLabel.text = @"小视频";
            [_itemImageView setImage:[UIImage imageNamed:@"chatinputitem_shortvideo"]];
        } else if (itemType == CNKChatInputMediaItemTypeLocation) {
            _itemTitleLabel.text = @"位置";
            [_itemImageView setImage:[UIImage imageNamed:@"chatinputitem_location"]];
        }
    }
    return self;
}

#pragma mark- getter

- (UIImageView *)itemImageView{
    if (!_itemImageView) {
        _itemImageView = [[UIImageView alloc] init];
        _itemImageView.backgroundColor = kGrayColor(0.98*255);
        _itemImageView.contentMode = UIViewContentModeCenter;
        _itemImageView.layer.cornerRadius = 6;
        _itemImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _itemImageView.layer.borderWidth = 0.5;
        [self addSubview:_itemImageView];
        [_itemImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.centerX.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(60, 60));
        }];
    }
    return _itemImageView;
}

- (UILabel *)itemTitleLabel{
    if (!_itemTitleLabel) {
        _itemTitleLabel = [[UILabel alloc] init];
        _itemTitleLabel.font = [UIFont systemFontOfSize:15];
        _itemTitleLabel.textColor = kGrayColor(128);
        _itemTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_itemTitleLabel];
        [_itemTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(_itemImageView.mas_bottom).mas_offset(5);
            make.height.mas_equalTo(20);
        }];
    }
    return  _itemTitleLabel;
}

#pragma mark- action

- (void)buttonAction:(UIButton *)button{
    if (_buttonActionBlock) {
        _buttonActionBlock(_itemType);
    }
}

@end
