//
//  CNKLocationManager.m
//  CNKChat
//
//  Created by EasyBenefit on 16/12/2.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKLocationManager.h"

@interface CNKLocationManager()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager* locationManager;
@end

@implementation CNKLocationManager

+ (instancetype)sharedInstance{
    static CNKLocationManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CNKLocationManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self locationManager];
        [self startLoactionManage];
    }
    return self;
}

- (CLLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy=kCLLocationAccuracyKilometer;
        _locationManager.distanceFilter=kCLLocationAccuracyThreeKilometers;
    }
    return _locationManager;
}

- (void)startLoactionManage{
    if ([CLLocationManager locationServicesEnabled]) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
            [[UIView cnk_displayingView] cnk_showInfoWithText:@"定位服务当前不可用！"];
            return;
        }else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
            [[UIView cnk_displayingView] cnk_showInfoWithText:@"定位服务未开启！"];
        }else{
            //如果没有授权则请求用户授权
            if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined){
                if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                    [self.locationManager requestWhenInUseAuthorization];
                }
            }
            //启动跟踪定位
            [self.locationManager startUpdatingLocation];
        }
    }
}

#pragma mark- CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    _userLocation = [locations lastObject];
}

#pragma mark- setter

- (void)setUserLocation:(CLLocation *)userLocation{
    _userLocation = userLocation;
    _userCoordinateRegion = MKCoordinateRegionMakeWithDistance(_userLocation.coordinate, 1000, 1000);
}

- (void)snapshotMapviewWithCoordinate:(CLLocationCoordinate2D)coordinate size:(CGSize)size completionBlock:(void(^)(UIImage *snappedImage))completionBlock{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000);
    [self snapshotMapviewWithRegion:region size:size completionBlock:completionBlock];
}

- (void)snapshotMapviewWithRegion:(MKCoordinateRegion)region size:(CGSize)size completionBlock:(void(^)(UIImage *snappedImage))completionBlock{
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.mapType = MKMapTypeStandard;
    options.region = region;
    options.size = size;
    options.scale = [[UIScreen mainScreen] scale];
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    
    [snapshotter startWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
              completionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
                  if (error) {
                      NSLog(@"[Error] %@", error);
                      return;
                  }
                  
                  MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:nil];
                  
                  UIImage *image = snapshot.image;
                  UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
                  {
                      [image drawAtPoint:CGPointMake(0.0f, 0.0f)];
                      
                      CGRect rect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
                      CGPoint point = [snapshot pointForCoordinate:region.center];
                      if (CGRectContainsPoint(rect, point)) {
                          point.x = point.x + pin.centerOffset.x -
                          (pin.bounds.size.width / 2.0f);
                          point.y = point.y + pin.centerOffset.y -
                          (pin.bounds.size.height / 2.0f);
                          [pin.image drawAtPoint:point];
                      }
                      
                      UIImage *compositeImage = UIGraphicsGetImageFromCurrentImageContext();
                      [CNKUtils executeBlockInMainQueue:^{
                          if (completionBlock) {
                              completionBlock(compositeImage);
                          }
                      }];
                  }
                  UIGraphicsEndImageContext();
              }];
}
@end
