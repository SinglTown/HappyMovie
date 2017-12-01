//
//  ResetPwdViewController.m
//  happyMovieEditor
//
//  Created by lanou3g on 16/1/9.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "ResetPwdViewController.h"
#import "LoginViewController.h"
#import <AVOSCloud/AVOSCloud.h>
@interface ResetPwdViewController ()
@property (strong, nonatomic) IBOutlet UITextField *securityCodeTF;
@property (strong, nonatomic) IBOutlet UITextField *newsPwdTF;

@end

@implementation ResetPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.27 green:0.24 blue:0.22 alpha:1];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconfont-fanhui.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.securityCodeTF becomeFirstResponder];
    });

}
#pragma mark - 回收键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
#pragma mark - 返回
-(void)backAction:(UIBarButtonItem *)sender
{
    [self.view endEditing:YES];
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self presentViewController:loginNC animated:YES completion:nil];
    
}

- (IBAction)resetPasswordButtonAction:(id)sender {
    
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
                [self reset];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [self reset];
                break;
            default:
                break;
        }
    }];

}

-(void)reset
{
    [AVUser resetPasswordWithSmsCode:self.securityCodeTF.text newPassword:self.newsPwdTF.text block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [self presentViewController:loginNC animated:YES completion:nil];
            [self alertViewWithString:@"重置密码成功"];
        } else {
            showAlertMessage(@"验证码错误", @"提示");
        }
    }];
}

-(void)alertViewWithString:(NSString *)string
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:string preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault  handler:nil];
    [alertVC addAction:action];
    [self presentViewController:alertVC animated:YES completion:nil];
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
