//
//  LocationManager.h
//  mapEngineering
//
//  Created by lanou3g on 15/12/14.
//  Copyright (c) 2015年 第一组. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
typedef void(^LOCATIONBLOCK)(CLLocationCoordinate2D coor);
typedef void(^LOCATIONB)(CLLocation* cllocation);
typedef void(^GEOCODINGBlock)(CLLocationCoordinate2D coordinate,NSDictionary *dic);
typedef void(^unGEOCODINGBlock)(NSString *address);
@interface LocationManager : NSObject
#pragma mark 实时更新地图位置的Block 回调
@property(nonatomic,copy)LOCATIONBLOCK updateBlock;
@property(nonatomic,copy)LOCATIONB clocationBlock;
+(instancetype)sharedLocationManager;
#pragma mark--开始定位
-(void)startLocation;
#pragma mark 地理编码 --根据地址获取经纬度
-(void)getCoordinateWithAddress:(NSString*)address  withFinsh:(GEOCODINGBlock)finshBlock;
#pragma mark 逆地理编码--根据经纬度获取地址
-(void)getAddressWithCoodianate:(CLLocationCoordinate2D)coordinate withFinsh:(unGEOCODINGBlock)finshBlock;
@end
