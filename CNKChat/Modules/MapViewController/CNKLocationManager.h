//
//  CNKLocationManager.h
//  CNKChat
//
//  Created by EasyBenefit on 16/12/2.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface CNKLocationManager : NSObject
//用户定位
@property (nonatomic, strong) CLLocation *userLocation;

//用户展示区域，根据locationCoordinate算出
@property (nonatomic, assign) MKCoordinateRegion userCoordinateRegion;

+ (instancetype)sharedInstance;

//开始定位
- (void)startLoactionManage;

- (void)snapshotMapviewWithCoordinate:(CLLocationCoordinate2D)coordinate size:(CGSize)size completionBlock:(void(^)(UIImage *snappedImage))completionBlock;

- (void)snapshotMapviewWithRegion:(MKCoordinateRegion)region size:(CGSize)size completionBlock:(void(^)(UIImage *snappedImage))completionBlock;
@end
