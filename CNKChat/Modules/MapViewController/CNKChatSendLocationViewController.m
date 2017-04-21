//
//  CNKSendLocationViewController.m
//  CNKChat
//
//  Created by EasyBenefit on 16/12/1.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKChatSendLocationViewController.h"
#import "CNKChatLocation.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CNKLocationManager.h"

#define MapCarrierViewLargeHeight self.view.width*0.8
#define MapCarrierViewSmallHeight self.view.width*0.5

static NSString *const cellIdentifier = @"CNKSendLocationViewControllerCellIdentifier";

@interface CNKChatSendLocationViewController ()<MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIView *mapCarrierView;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<CLPlacemark *> *placemarkList;
@property (nonatomic, strong) UIImageView *mapCenterPinImageView;
@property (nonatomic, strong) CLPlacemark *selectPlacemark;
@property (nonatomic, strong) UIImage *snapImage;
@end

@implementation CNKChatSendLocationViewController

- (void)dealloc{
    self.mapView.delegate = nil;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (_mapView) {
        [self applyMapViewMemoryFix];
        self.mapView.showsUserLocation = NO;
        self.mapView.userTrackingMode  = MKUserTrackingModeNone;
        [self.mapView.layer removeAllAnimations];
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView removeOverlays:self.mapView.overlays];
        [self.mapView removeFromSuperview];
    }
}

- (void)applyMapViewMemoryFix{
    
    switch (self.mapView.mapType) {
        case MKMapTypeHybrid:
        {
            self.mapView.mapType = MKMapTypeStandard;
        }
            
            break;
        case MKMapTypeStandard:
        {
            self.mapView.mapType = MKMapTypeHybrid;
        }
            
            break;
        default:
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendAction:)];
    self.navigationItem.rightBarButtonItem = sendItem;
    
    _placemarkList = [NSMutableArray array];
    
    [self mapCarrierView];
    [self mapView];
    [self tableView];
    // Do any additional setup after loading the view.
}

#pragma mark- getter

- (UIView *)mapCarrierView{
    if (!_mapCarrierView) {
        _mapCarrierView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, MapCarrierViewLargeHeight)];
        [self.view addSubview:_mapCarrierView];
    }
    return _mapCarrierView;
}

- (MKMapView *)mapView{
    if (!_mapView) {
        _mapView = [[MKMapView alloc] init];
        _mapView.delegate = self;
        _mapView.userTrackingMode = MKUserTrackingModeFollow;
        _mapView.showsUserLocation = YES;
        _mapView.showsScale = NO;
        [_mapView setCenterCoordinate:[CNKLocationManager sharedInstance].userLocation.coordinate animated:NO];
        [_mapView setRegion:[CNKLocationManager sharedInstance].userCoordinateRegion animated:NO];
        [[self mapCarrierView] addSubview:_mapView];
        [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return _mapView;
}

- (UIImageView *)mapCenterPinImageView{
    if (!_mapCenterPinImageView) {
        _mapCenterPinImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sendlocation_pin"]];
        [_mapCarrierView insertSubview:_mapCenterPinImageView aboveSubview:_mapView];
        [_mapCenterPinImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_mapCarrierView);
            make.centerY.mas_equalTo(_mapCarrierView).mas_offset(-16);
            make.size.mas_equalTo(CGSizeMake(18, 38));
        }];
    }
    return _mapCenterPinImageView;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.allowsMultipleSelection = NO;
        _tableView.tableFooterView = [UIView new];
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_mapCarrierView.mas_bottom);
            make.left.right.bottom.mas_equalTo(0);
        }];
    }
    return _tableView;
}

#pragma mark- datasource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _placemarkList.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    CLPlacemark *placemark = _placemarkList[indexPath.row];
    if (placemark == _selectPlacemark) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = placemark.name;
    
    cell.detailTextLabel.text = [CNKChatSendLocationViewController addressFromPlacemark:placemark];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:[_placemarkList indexOfObject:_selectPlacemark] inSection:0];
    UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:lastIndex];
    lastCell.accessoryType = UITableViewCellAccessoryNone;
    
    UITableViewCell *cell = [tableView  cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    _selectPlacemark = [_placemarkList objectAtIndex:indexPath.row];
    [_mapView setCenterCoordinate:_selectPlacemark.location.coordinate animated:YES];
}

#pragma mark- scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    static BOOL animating = NO;
    if (!animating) {
        if (_mapCarrierView.height > MapCarrierViewSmallHeight) {
            if (scrollView.contentOffset.y >= 10) {
                animating = YES;
                [UIView animateWithDuration:0.25 animations:^{
                    _mapCarrierView.frame = CGRectMake(0, 64, self.view.width, MapCarrierViewSmallHeight);
                    [self.view layoutIfNeeded];
                } completion:^(BOOL finished) {
                    animating = NO;
                }];
            }
        } else {
            if (scrollView.contentOffset.y <= -10) {
                animating = YES;
                [UIView animateWithDuration:0.25 animations:^{
                    _mapCarrierView.frame = CGRectMake(0, 64, self.view.width, MapCarrierViewLargeHeight);
                    [self.view layoutIfNeeded];
                } completion:^(BOOL finished) {
                    animating = NO;
                }];
            }
        }
    }
}

#pragma mark- mapview delegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
    Weakfy(weakSelf);
    [self queryPlaceListWithLocation:location completionBlock:^(NSArray *placemarkList) {
        [weakSelf.placemarkList removeAllObjects];
        if (placemarkList.count > 0) {
            [weakSelf.placemarkList addObjectsFromArray:placemarkList];
            weakSelf.selectPlacemark = weakSelf.placemarkList[0];
        }
        [weakSelf.tableView reloadData];
    }];
    
    _snapImage = nil;
    [[CNKLocationManager sharedInstance] snapshotMapviewWithCoordinate:_mapView.centerCoordinate size:CGSizeMake(200, 100) completionBlock:^(UIImage *snappedImage) {
        _snapImage = snappedImage;
    }];
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered{
    [self mapCenterPinImageView];
}

#pragma mark- action

- (void)cancelAction:(UIButton *)button{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendAction:(UIButton *)button{
    
    if (_snapImage) {
        CNKChatLocation *location = [self locationWithSnapImage:_snapImage];
        if (_sendActionBlock) {
            _sendActionBlock(location);
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.view cnk_showStatus:@"加载中..."];
        [[CNKLocationManager sharedInstance] snapshotMapviewWithCoordinate:_mapView.centerCoordinate size:CGSizeMake(200, 100) completionBlock:^(UIImage *snappedImage) {
            if (snappedImage) {
                _snapImage = snappedImage;
                [self.view cnk_dismissHUD];
                CNKChatLocation *location = [self locationWithSnapImage:snappedImage];
                if (_sendActionBlock) {
                    _sendActionBlock(location);
                }
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self.view cnk_showErrorWithText:@"加载位置失败！"];
            }
        }];
    }
}

- (CNKChatLocation *)locationWithSnapImage:(UIImage *)image{
    NSString *imageKey = [[NSProcessInfo processInfo] globallyUniqueString];
    [[SDImageCache sharedImageCache] storeImage:image forKey:imageKey];
    
    CNKChatLocation *location = [[CNKChatLocation alloc] init];
    location.placeImageKey = imageKey;
    location.latitude = _selectPlacemark.location.coordinate.latitude;
    location.longitude = _selectPlacemark.location.coordinate.longitude;
    location.placeName = _selectPlacemark.name;
    location.address = [CNKChatSendLocationViewController addressFromPlacemark:_selectPlacemark];
    return location;
}

- (void)queryPlaceListWithLocation:(CLLocation *)location completionBlock:(void(^)(NSArray *placemarkList))completionBlock{
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    // 根据经纬度反向得出位置城市信息
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (!error) {
            if (completionBlock) {
                completionBlock(placemarks);
            }
        } else {
            if (completionBlock) {
                completionBlock(nil);
            }
        }
    }];
}

+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0f);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

+ (NSString *)addressFromPlacemark:(CLPlacemark *)placemark{
    NSString *addressString = [NSString stringWithFormat:@"%@%@%@", placemark.administrativeArea, placemark.locality, placemark.thoroughfare];
    if (placemark.subThoroughfare) {
        addressString = [addressString stringByAppendingString:placemark.subThoroughfare];
    }
    return addressString;
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
