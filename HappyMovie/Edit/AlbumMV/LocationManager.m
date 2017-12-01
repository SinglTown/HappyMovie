//
//  LocationManager.m
//  mapEngineering
//
//  Created by lanou3g on 15/12/14.
//  Copyright (c) 2015年 第一组. All rights reserved.
//

#import "LocationManager.h"
#import <CoreLocation/CoreLocation.h>
@interface LocationManager()<CLLocationManagerDelegate>
@property (nonatomic,strong)CLLocationManager *locationManager;
@end
static LocationManager *_manager=nil;
@implementation LocationManager
+(instancetype)sharedLocationManager{
    return [[self alloc]init];
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (_manager==nil) {
            _manager=[super allocWithZone:zone];
        }
    });
    return _manager;
}

#pragma mark--开始定位
-(void)startLocation{
    //定位管理器类 CLLocationManager
    if (self.locationManager==nil) {
        self.locationManager=[[CLLocationManager alloc]init];
        //设置代理
        self.locationManager.delegate=self;
        //请求用户允许使用定位(弹出框提醒用户是否定位    )
        [self.locationManager requestWhenInUseAuthorization];
    }
    //定位的精度CoreLoaction这个框架只能尽量的保证定位的精度(定位的频率)
    CLLocationDistance distance=10;
    self.locationManager.distanceFilter=distance;
    //定位的质量(误差)
    //定位很耗电,如果质量选择越高,耗电越快
    self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    //判断定位服务是否可用 并且用户是否允许定位
    if ([CLLocationManager locationServicesEnabled]&&[CLLocationManager authorizationStatus ]!=kCLAuthorizationStatusDenied) {
        //开启定位服务,开始更新位置
        [self.locationManager startUpdatingLocation];
    }
  
    
   //位置信息类CLLocation
    //经纬度信息CLLocationCoordinate2D

}

//高德地图是以火星为坐标 //百度是以地球
#pragma mark--更新了位置信息的代理方法
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
   // NSLog(@"你出来不");
    CLLocation *location=locations.firstObject;
    if (self.updateBlock) {
        CLLocationCoordinate2D coordinate=location.coordinate;
        //得到火星坐标
//        coordinate=[self getMarsCoorWithEarthCoor:coordinate];
        
        //把经纬度传出去
        
        self.clocationBlock(location);
        
        self.updateBlock(coordinate);
        //置空可以解决循环引用问题,但是前提是要保证这个block在调用过一次之后不再进行使用
      //  self.updateBlock=nil;
    }
}


//地图需要配置的plist文件
//
//NSLocationAlwaysUsageDescription或者
//
//NSLocationWhenInUseUsageDescription


#pragma mark 定位失败代理方法
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
   // NSLog(@"定位失败");
}
#pragma mark -火星坐标

const double pi = 3.14159265358979324;
const double a = 6378245.0;
const double ee = 0.00669342162296594323;


//将CLLocation定位的coordinate传进来，就可以计算出用于在高德地图中使用的火星坐标了
-(CLLocationCoordinate2D)getMarsCoorWithEarthCoor:(CLLocationCoordinate2D)earthCoor
{
    CLLocationCoordinate2D marsCoor;
    if (outOfChina(earthCoor.latitude, earthCoor.longitude)) {
        marsCoor = earthCoor;
        return marsCoor;
    }
    double dLat = transformLat(earthCoor.longitude-105.0, earthCoor.latitude-35.0);
    double dLon = transformLon(earthCoor.longitude-105.0, earthCoor.latitude-35.0);
    double radLat = earthCoor.latitude/180.0*pi;
    double magic = sin(radLat);
    magic = 1-ee*magic*magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi);
    marsCoor = CLLocationCoordinate2DMake(earthCoor.latitude+dLat, earthCoor.longitude+dLon);
    return marsCoor;
}

static bool outOfChina(double lat, double lon)
{
    if (lon < 72.004 || lon > 137.8347)
        return true;
    if (lat < 0.8293 || lat > 55.8271)
        return true;
    return false;
}

static double transformLat(double x, double y)
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));

    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
    return ret;
}

static double transformLon(double x, double y)
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0;
    return ret;
}
-(BOOL)ismainStringContainSubString:(NSString *)mainString  subString:(NSString *)subString
{
    
    NSRange range=[mainString rangeOfString:subString];
    if(range.location!=NSNotFound){
        return true;
    }else{
        return false;
    }
}

#pragma mark 地理编码 --根据地址获取经纬度
-(void)getCoordinateWithAddress:(NSString*)address  withFinsh:(GEOCODINGBlock)finshBlock{
    //地理编码和逆地理编码都需要通过ios提供一个编码类CLGeocoder
    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
       dispatch_async(dispatch_get_main_queue(), ^{
           //坐标位置
           CLPlacemark *placemark=placemarks.firstObject;
           //显示国家街道地名等信息
         //  NSLog(@"%@",placemark.addressDictionary);
           finshBlock(//经纬度
                      placemark.location.coordinate,placemark.addressDictionary);
       });
    }];
}
#pragma mark 逆地理编码--根据经纬度获取地址
-(void)getAddressWithCoodianate:(CLLocationCoordinate2D)coordinate withFinsh:(unGEOCODINGBlock)finshBlock{
     //地理编码和逆地理编码都需要通过ios提供一个编码类CLGeocoder
    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
    //Latitude经度 longitude纬度
    CLLocation *location=[[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
         //地标   //拿出找到的第一个元素
            CLPlacemark *mark=placemarks.firstObject;
            finshBlock(mark.name);
        });
    }];
}
/*我们要设置好自己选定的地图样式
 iOS中有一个系统自带的完整的一套地图框架——MapKit.Framework和CoreLocation.Framework。
 
 在工程中添加这两个框架后，就可以进行地图开发了。
 
 #import <MapKit/MapKit.h>
 首先先定义个一个地图视图

 @property (nonatomic,retain) MKMapView *mapView;
 还有对mapView的初始化，那些自己按喜好来初始化就行了。无非是Frame的设置。
 
 设置地图试图的显示风格，通过MapType属性来控制，该属性是一个枚举变量，有三个枚举成员： [_mapView setMapType:MKMapTypeStandard];
 接下来就设置，是否显示GPS定位的手机用户的位置——就是那个小蓝点。
 

 [_mapView setShowsUserLocation:YES];
 将mapView加载到主视图上。
 
 [self.view addSubview:_mapView];
 至此，我们已经把MapView的地图视图搭建好了。但是它不能获取用户的位置信息，所以我们就需要到CLLocationManager来获取用户当前的位置信息，并把这个信息显示到地图视图上。
 我们先定义个个CLLocationManager。

 @property (nonatomic,retain) CLLocationManager *locaManager;
 并且在视图控制器上设置代理CLLocationManagerDelegate
 接下来初始化我们定义的CLLocationManager。
 
 //初始化LocationManager
 self.locaManager = [[[CLLocationManager alloc] init] autorelease];
 
 //设置代理
 [_locaManager setDelegate:self];
 
 //设置位置的精度
 [_locaManager setDesiredAccuracy:kCLLocationAccuracyBest];
 
 //是指多远才更新位置信息
 [_locaManager setDistanceFilter:5.0f];
 
 //开始定位
 [_locaManager startUpdatingLocation];
 初始化和设置好 CLLocationManager后我们还要设置它的delegate方法。
 

 -(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
 
 //停止获取位置信息
 [self.locaManager stopUpdatingLocation];
 
 //获取位置对象
 CLLocation *lastLocation = [locations lastObject];
 
 //提取位置信息里的经度，纬度
 CLLocationCoordinate2D myLocation ;
 //纬度
 myLocation.latitude = [lastLocation coordinate].latitude;
 //经度
 myLocation.longitude = [lastLocation coordinate].longitude;
 
 //地图显示的区域
 MKCoordinateRegion region = MKCoordinateRegionMake(myLocation, MKCoordinateSpanMake(0.1f, 0.1f)) ;
 [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
 
 
 
 } */
@end
