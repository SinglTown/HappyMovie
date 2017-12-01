//
//  ReleaseViewController.m
//  happyMovieEditor
//
//  Created by lanou3g on 16/1/18.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "ReleaseViewController.h"
#import "LocationManager.h"
#import <MapKit/MapKit.h>
#import "PassMergeHandle.h"
#import "UMSocial.h"
#import <AVOSCloud/AVOSCloud.h>
#import "ReleaseModel.h"
typedef void(^PASSMODELBLOCK) (ReleaseModel*model);
@interface ReleaseViewController ()<UITextFieldDelegate,UMSocialDataDelegate,UMSocialUIDelegate>


@property (strong, nonatomic) IBOutlet UITextField *desTF;

@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property(nonatomic,assign)NSInteger  flag;

@property (strong, nonatomic) IBOutlet UIButton *imageButton;
@property(nonatomic,strong)CLLocation*myCllocation;
@property(nonatomic,copy)PASSMODELBLOCK passModel;

@property(nonatomic,strong)ReleaseModel*releaseModel;

@end

@implementation ReleaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"iconfont-fanhui(1)"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(leftaction)];
    
    self.navigationItem.leftBarButtonItem = leftItem;
 
    if ([PassMergeHandle sharedHandle].imageArray.count != 0) {
         [self.imageButton setBackgroundImage:[[PassMergeHandle sharedHandle].imageArray objectAtIndex:0] forState:UIControlStateNormal];
    }
   
    
    self.desTF.delegate =self;
    
}
-(void)leftaction{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
    
}

//更换头像按钮
- (IBAction)imageButton:(id)sender {
  self.flag++;
    if (self.flag < (NSInteger)[[PassMergeHandle sharedHandle].imageArray count] )
    {
       
        
        [self.imageButton setBackgroundImage:[[PassMergeHandle sharedHandle].imageArray objectAtIndex:self.flag] forState:UIControlStateNormal];
        
        
    }else{
        
        self.flag = 0;
        
    }
    
   
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self.desTF resignFirstResponder];
    return YES;
}

//定位
- (IBAction)locationButtonAction:(id)sender {
   
    //添加网络判断
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                [self alertViewWithString:@"当前网络不可用,请检测网络连接"];
                break;
            case AFNetworkReachabilityStatusNotReachable:
                [self alertViewWithString:@"当前网络不可用,请检测网络连接"];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                [self getLocation];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [self getLocation];
                break;
            default:
                break;
        }
    }];
    
       
}
-(void)alertViewWithString:(NSString *)string
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:string delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [alertView show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
    });
    
}
-(void)getLocation
{
    self.locationLabel.text = @"定位中....";
    self.locationLabel.font = [ UIFont systemFontOfSize:14] ;
    
    [[LocationManager sharedLocationManager] startLocation];
    [LocationManager sharedLocationManager].clocationBlock = ^(CLLocation*cl){
        
        _myCllocation = cl;
        
    };
    
    [LocationManager sharedLocationManager].updateBlock=^(CLLocationCoordinate2D coor){
        
        //把定位好的位置信息传递给MKMapView
        MKCoordinateRegion region;
        //设置位置的中心点
        region.center=coor;
        
        [[LocationManager sharedLocationManager]getAddressWithCoodianate:coor withFinsh:^(NSString *address) {
            
            self.locationLabel.text= address;
            
            
            // NSLog(@"++++%@",address);
        }];
    };
    
}
//人人
- (IBAction)frendsButton:(id)sender {

    if (self.releaseModel == nil) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@" 提示:请上传之后再进行分享" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:cancelAction];
        
        
        [self presentViewController:alertVC animated:YES completion:nil];
    }
    
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToRenren] content:self.releaseModel.releaseVideoUrl image:nil location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *shareResponse){
        if (shareResponse.responseCode == UMSResponseCodeSuccess) {
          
            [self alertViewWithString:@"分享成功"];
        }
    }];

}
//新浪

- (IBAction)xinlangButton:(id)sender {

    if (self.releaseModel == nil) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@" 提示:请上传之后再进行分享" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:cancelAction];
        
        
        [self presentViewController:alertVC animated:YES completion:nil];
    }

    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeVideo url:self.releaseModel.releaseVideoUrl];
    //调用快速分享接口
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"568f5168e0f55a5aeb001443"
                                      shareText:@"@乐影"
                                     shareImage:nil
                                shareToSnsNames:@[UMShareToSina]
                                       delegate:self];
    
    
}

//QQ
- (IBAction)zoonButton:(id)sender {

    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQQ] content:self.releaseModel.releaseVideoUrl image:self.releaseModel.releaseImageURL location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
        if (response.responseCode == UMSResponseCodeSuccess) {
           
            [self alertViewWithString:@"分享成功"];
        }
    }];
}

//发布
- (IBAction)releaseAction:(id)sender {
    
 
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                [self alertViewWithString:@"当前网络不可用,请检测网络连接"];
                break;
            case AFNetworkReachabilityStatusNotReachable:
                [self alertViewWithString:@"当前网络不可用,请检测网络连接"];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                //分享
                [self showToNetWorkWithURL];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                //分享
                [self showToNetWorkWithURL];
                break;
            default:
                break;
        }
    }];
    
  }
//分享
-(void)showToNetWorkWithURL{
    
    if ([PassMergeHandle sharedHandle].finalMovieString != 0) {
        
            NSData * data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[PassMergeHandle sharedHandle].finalMovieString]];
        
        if ([[PassMergeHandle sharedHandle].imageArray  count]==0) {
            
            //提示信息
            [self message];
            
            }
        
        NSData *imgdata = UIImageJPEGRepresentation([[PassMergeHandle sharedHandle].imageArray objectAtIndex:self.flag], 0.7);
        AVFile *imgfile = [AVFile fileWithName:@"resume.jpg" data:imgdata];
        
        AVFile *file = [AVFile fileWithName:@"resume.mp4" data:data];
 
        AVObject *obj = [AVObject objectWithClassName:@"MovieRelease"];
        [obj setObject:self.locationLabel.text forKey:@"location"];
        [obj setObject:self.desTF.text forKey:@"description"];
        [obj setObject:imgfile         forKey:@"img"];
        [obj setObject:file         forKey:@"attached"];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                
                AVQuery *query =[AVQuery queryWithClassName:@"MovieRelease"];
                
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        
                        [[PassMergeHandle sharedHandle].releaseArr removeAllObjects];
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"上传成功" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
                        [alertView show];
                        //2秒后自动消失
                        [self performSelector:@selector(removeAlert:) withObject:alertView afterDelay:2];
                        
                        
                        for (AVObject*obj in objects) {
                            
                            ReleaseModel*model = [[ReleaseModel alloc]init];
                            model.releaseDescription = [obj objectForKey:@"description"];
                            model.releaseLocation = [obj objectForKey:@"location"];
                            model.releaseImageURL = ((AVFile*)obj[@"img"]).url;
                            
                            model.releaseVideoUrl =((AVFile *)obj[@"attached"]).url;
                            
                            [[PassMergeHandle sharedHandle].releaseArr addObject:model];
                            
                        }
                        
                        self.releaseModel = (ReleaseModel*)([PassMergeHandle sharedHandle].releaseArr.lastObject);
                        
                        
                    } else {
                        // 输出错误信息
                        // NSLog(@"Error: %@ %@", error, [error userInfo]);
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"上传失败" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
                        [alertView show];
                        //2秒后自动消失
                        [self performSelector:@selector(removeAlert:) withObject:alertView afterDelay:2];
                        
                    }
                }];
                }
            
        }];
        
    }else{
        
        //提示信息
        [self message];
     }
}

-(void)removeAlert:(UIAlertView *)alertView{
   
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    
}
-(void)message{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@" 提示:您还没有制作完成(⊙o⊙)哦" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
    [alertVC addAction:saveAction];
    
    
    
    [self presentViewController:alertVC animated:YES completion:nil];

}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
  
    [self.desTF resignFirstResponder];

}

@end
