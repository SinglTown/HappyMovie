//
//  SendCodeViewController.m
//  happyMovieEditor
//
//  Created by lanou3g on 16/1/9.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "SendCodeViewController.h"
#import "ResetPwdViewController.h"
#import <AVOSCloud/AVOSCloud.h>
@interface SendCodeViewController ()

@property (strong, nonatomic) IBOutlet UITextField *sendPhoneNumberTF;

@end

@implementation SendCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.27 green:0.24 blue:0.22 alpha:1];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconfont-fanhui.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.sendPhoneNumberTF becomeFirstResponder];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)getSecurityCodeButton:(id)sender {

    
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
                [self getCode];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [self getCode];
                break;
            default:
                break;
        }
    }];

}

-(void)getCode
{
    [AVUser requestPasswordResetWithPhoneNumber:self.sendPhoneNumberTF.text block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            ResetPwdViewController *sendVC = [[ResetPwdViewController alloc] init];
            UINavigationController *sendNC = [[UINavigationController alloc] initWithRootViewController:sendVC];
            sendNC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:sendNC animated:YES completion:nil];
        } else {
            [self alertViewWithString:@"无效的手机号"];
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
