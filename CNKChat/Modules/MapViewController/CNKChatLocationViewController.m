//
//  CNKChatLocationViewController.m
//  CNKChat
//
//  Created by chenkai on 2016/12/3.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKChatLocationViewController.h"
#import "CNKChatLocation.h"
#import <MapKit/MapKit.h>
#import "CNKLocationManager.h"

#define kAddressViewHeight 70

@interface CNKChatLocationViewController ()<MKMapViewDelegate>
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIView *addressView;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UILabel *detailAddressLabel;
@property (nonatomic, strong) UIButton *systemMapButton;

@end

@implementation CNKChatLocationViewController

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
    self.title = @"位置";
    self.view.backgroundColor = [UIColor whiteColor];
    [self mapView];
    [self addressView];
    [self addressLabel];
    [self detailAddressLabel];
    [self systemMapButton];
}

#pragma mark- getter

- (MKMapView *)mapView{
    if (!_mapView) {
        _mapView = [[MKMapView alloc] init];
        _mapView.delegate = self;
        _mapView.showsUserLocation = YES;
        _mapView.showsScale = YES;
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(_location.latitude, _location.longitude);
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 2000, 2000);
        
        [_mapView setCenterCoordinate:coordinate animated:YES];
        [_mapView setRegion:region animated:YES];
        
        [self.view addSubview:_mapView];
        [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, kAddressViewHeight, 0));
        }];
        
        //add annotation
        MKPointAnnotation *pinAnnotation = [[MKPointAnnotation alloc] init];
        [pinAnnotation setCoordinate:coordinate];
        [_mapView addAnnotation:pinAnnotation];
    }
    return _mapView;
}

- (UIView *)addressView {
    if (!_addressView) {
        _addressView = [[UIView alloc] init];
        _addressView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_addressView];
        [_addressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.height.mas_equalTo(kAddressViewHeight);
        }];
    }
    return _addressView;
}

- (UILabel *)addressLabel {
    if (!_addressLabel) {
        _addressLabel = [[UILabel alloc] init];
        _addressLabel.font = [UIFont systemFontOfSize:22];
        _addressLabel.textColor = kGrayColor(51);
        [_addressView addSubview:_addressLabel];
        _addressLabel.text = _location.placeName;
        [_addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.bottom.mas_equalTo(_addressView.mas_centerY).mas_offset(4);
            make.right.mas_equalTo(-80);
            make.height.mas_equalTo(24);
        }];
    }
    return _addressLabel;
}

- (UILabel *)detailAddressLabel {
    if (!_detailAddressLabel) {
        _detailAddressLabel = [[UILabel alloc] init];
        _detailAddressLabel.font = [UIFont systemFontOfSize:13];
        _detailAddressLabel.textColor = kGrayColor(91);
        _detailAddressLabel.text = _location.address;
        [_addressView addSubview:_detailAddressLabel];
        [_detailAddressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.top.mas_equalTo(_addressView.mas_centerY).mas_offset(8);
            make.right.mas_equalTo(-80);
            make.height.mas_equalTo(17);
        }];
    }
    return _detailAddressLabel;
}

- (UIButton *)systemMapButton{
    if (!_systemMapButton) {
        _systemMapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_systemMapButton setImage:[UIImage imageNamed:@"chatlocation_gotosystem"] forState:UIControlStateNormal];
        [_systemMapButton setImage:[UIImage imageNamed:@"chatlocation_gotosystem"] forState:UIControlStateHighlighted];
        [_systemMapButton addTarget:self action:@selector(systemMapAction:) forControlEvents:UIControlEventTouchUpInside];
        [_addressView addSubview:_systemMapButton];
        [_systemMapButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(_addressView);
            make.right.mas_equalTo(-15);
            make.size.mas_equalTo(CGSizeMake(50, 50));
        }];
    }
    return _systemMapButton;
}

#pragma mark- MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    static NSString *pinAnnotationViewId = @"pinAnnotationViewId";
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    } else if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pinAnnotationViewId];
        if (!pinView) {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinAnnotationViewId];
        }
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.animatesDrop = NO;
        pinView.canShowCallout = NO;
        return pinView;
    }
    return nil;
}

#pragma mark- action

- (void)systemMapAction:(UIButton *)button {
    MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(_location.latitude, _location.longitude) addressDictionary:nil]];
    
    [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                   launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                                   MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
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
