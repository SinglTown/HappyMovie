//
//  LoginViewController.m
//  happyMovieEditor
//
//  Created by lanou3g on 16/1/8.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "LoginViewController.h"
#import "UMSocial.h"
#import "RegisterViewController.h"
#import <AVOSCloud/AVOSCloud.h>
#import "SendCodeViewController.h"
#import "StartViewController.h"
#import "CreationViewController.h"
#import "AFNetworking.h"

@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UITextField *userNameTF;

@property (strong, nonatomic) IBOutlet UITextField *userPwdTF;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"登陆";
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.27 green:0.24 blue:0.22 alpha:1];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconfont-fanhui.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [self.userNameTF setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.userPwdTF setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    //自动弹出键盘
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.userNameTF becomeFirstResponder];
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
#pragma mark - 登陆按钮
- (IBAction)loginButtonAction:(id)sender {
    
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
                [self login];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [self login];
                break;
            default:
                break;
        }
    }];
    

    
}

-(void)login
{
    [AVUser logInWithUsernameInBackground:self.userNameTF.text password:self.userPwdTF.text block:^(AVUser *user, NSError *error) {
        if (user != nil) {
            CreationViewController *rootVC = [[CreationViewController alloc] init];
            [self presentViewController:rootVC animated:YES completion:nil];
        }else{
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"用户名或者密码错误,请重新输入" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
            [alertVC addAction:confirmAction];
            [self presentViewController:alertVC animated:YES completion:nil];
        }
    }];
}

#pragma mark - 找回密码
- (IBAction)findPwdAction:(id)sender {
    
    SendCodeViewController *sendVC = [[SendCodeViewController alloc] init];
    UINavigationController *sendNC = [[UINavigationController alloc] initWithRootViewController:sendVC];
    sendNC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:sendNC animated:YES completion:nil];
    
}

#pragma mark - 立即注册
- (IBAction)registerNowAction:(id)sender {
    
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    UINavigationController *registerNC = [[UINavigationController alloc] initWithRootViewController:registerVC];
    [self presentViewController:registerNC animated:YES completion:nil];
    
}

#pragma mark - QQ登陆
- (IBAction)qqLoginButtonAction:(id)sender {
    
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
                [self QQLogin];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [self QQLogin];
                break;
            default:
                break;
        }
    }];
}


-(void)QQLogin
{
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQQ];
            
           // NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
            [self thirdLoginActionWith:snsAccount];
        }});
    
}



#pragma mark - 人人登陆
- (IBAction)weixinLoginButtonAction:(id)sender {
    
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
                [self weChatLogin];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [self weChatLogin];
                break;
            default:
                break;
        }
    }];
}


-(void)weChatLogin
{
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToRenren];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQzone];
            
           // NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
            [self thirdLoginActionWith:snsAccount];
        }});

}


#pragma mark - 微博登陆
- (IBAction)weiboLoginButtonAction:(id)sender {
    
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
                [self weiboLogin];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [self weiboLogin];
                break;
            default:
                break;
        }
    }];
}

-(void)weiboLogin
{
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToSina];
            
           // NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
            [self thirdLoginActionWith:snsAccount];
            
        }});
}


#pragma mark - 三方登陆方法
-(void)thirdLoginActionWith:(UMSocialAccountEntity *)snsAccount
{
   
    
    AVQuery *query = [AVQuery queryWithClassName:@"_User"];
    [query whereKey:@"username" equalTo:snsAccount.userName];
    [query getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        //NSLog(@"%@",[object valueForKey:@"username"]);
        if (!object) {
            AVUser *user = [AVUser user];
            user.username = snsAccount.userName;
            user.password = @"123";
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:snsAccount.iconURL]];
            AVFile *file = [AVFile fileWithName:[NSString stringWithFormat:@"%@.png",snsAccount.userName] data:data];
            AVObject *userMessage = [AVObject objectWithClassName:@"UserMessage"];
            [userMessage setObject:snsAccount.userName forKey:@"name"];
            [userMessage setObject:snsAccount.userName forKey:@"nikename"];
            [userMessage setObject:file forKey:@"avatarImage"];
            [userMessage saveInBackground];
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                   
                    CreationViewController *rootVC = [[CreationViewController alloc] init];
                    [self presentViewController:rootVC animated:YES completion:nil];
                    
                    
                }else{
                   
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登陆失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                            
                }
            }];
        }else{
            [AVUser logInWithUsernameInBackground:snsAccount.userName password:@"123" block:^(AVUser *user, NSError *error) {
                if (user) {
                  
                    CreationViewController *rootVC = [[CreationViewController alloc] init];
                    [self presentViewController:rootVC animated:YES completion:nil];
                    
                    
                }else{
                  
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登陆失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
   
                    
                }
            }];
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







@end
