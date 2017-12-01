//
//  RegisterViewController.m
//  happyMovieEditor
//
//  Created by lanou3g on 16/1/8.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "RegisterViewController.h"
#import <AVOSCloud/AVOSCloud.h>

@interface RegisterViewController ()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *registerNameTFConstraint;

@property (strong, nonatomic) IBOutlet UITextField *phoneNumberTF;
@property (strong, nonatomic) IBOutlet UITextField *passwordTF;
@property (strong, nonatomic) IBOutlet UITextField *securityCodeTF;

@property (strong, nonatomic) IBOutlet UIButton *registerButton;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.27 green:0.24 blue:0.22 alpha:1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbFrameWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconfont-fanhui.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.registerButton.enabled = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerButtonEnableAction:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveKeyboardAction:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    //自动弹出键盘
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.phoneNumberTF becomeFirstResponder];
    });


}
#pragma mark - 注册按钮状态
-(void)registerButtonEnableAction:(NSNotification *)sender
{
    if (self.securityCodeTF.text.length < 6) {
        self.registerButton.enabled = NO;
    }else{
        self.registerButton.enabled = YES;
    }
}

#pragma mark - 改变键盘
-(void)moveKeyboardAction:(NSNotification *)sender
{
    CGFloat registerButtonBot = kScreenHeight - self.registerButton.frame.origin.y+50-90;
    CGRect rect = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat kvHeight = rect.size.height;
    if (registerButtonBot < kvHeight) {
        CGFloat phoneNumberTFHeight = self.phoneNumberTF.frame.origin.y;
        self.registerNameTFConstraint.constant = phoneNumberTFHeight - (kvHeight - registerButtonBot);
    }
}
#pragma mark - 回收键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
#pragma mark - leftItem事件
-(void)backAction:(UIBarButtonItem *)sender
{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 通知键盘方法
-(void)kbFrameWillHidden:(NSNotification *)sender
{
    [UIView animateWithDuration:2 animations:^{
        self.registerNameTFConstraint.constant = 130;
    }];
}
#pragma mark - 发送,重新发送验证码
- (IBAction)sendAgainButtonAction:(id)sender {
    
    if (self.phoneNumberTF.text.length != 0 && self.passwordTF.text.length != 0) {
        AVQuery *query = [AVQuery queryWithClassName:@"_User"];
        [query whereKey:@"username" equalTo:self.phoneNumberTF.text];
        [query getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            if (!object) {
                [self registerUser];
            }else{
                showAlertMessage([error.userInfo valueForKey:@"error"], @"提示");
            }
        }];
    }else{
        showAlertMessage(@"手机号和密码不能为空", @"提示");
    }
}
#pragma mark - 注册按钮
- (IBAction)registerButtonAction:(id)sender {
    
    [AVUser verifyMobilePhone:self.securityCodeTF.text withBlock:^(BOOL succeeded, NSError *error) {
        //验证结果
        if (succeeded) {
            
            showAlertMessage(@"注册成功", @"提示");
            AVObject *userMessage = [AVObject objectWithClassName:@"UserMessage"];
            [userMessage setObject:self.phoneNumberTF.text forKey:@"name"];
            [userMessage setObject:nil forKey:@"nikename"];
            [userMessage setObject:nil forKey:@"avatarImage"];
            [userMessage saveInBackground];
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            showAlertMessage([error.userInfo valueForKey:@"error"], @"提示");
        
        }
    }];
}

-(void)registerUser
{
    
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
                [self registerEvents];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [self registerEvents];
                break;
            default:
                break;
        }
    }];
}


-(void)registerEvents
{

    AVUser *user = [AVUser user];
    user.username = self.phoneNumberTF.text;
    user.password = self.passwordTF.text;
    user.mobilePhoneNumber = self.phoneNumberTF.text;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            showAlertMessage(@"验证码发送成功", @"提示");
        }else{
            showAlertMessage([error.userInfo valueForKey:@"error"], @"提示");
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
