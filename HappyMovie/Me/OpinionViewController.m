//
//  OpinionViewController.m
//  HappyMovie
//
//  Created by lanou3g on 16/1/23.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "OpinionViewController.h"
#import <AVOSCloud/AVOSCloud.h>
@interface OpinionViewController ()
@property (strong, nonatomic) IBOutlet UITextView *opinionTextView;
@property (strong, nonatomic) IBOutlet UIButton *opinionSendButton;

@end

@implementation OpinionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(opinionSendButtonEnableAction:) name:UITextViewTextDidChangeNotification object:nil];
    self.opinionSendButton.enabled = NO;
}
-(void)opinionSendButtonEnableAction:(UIButton *)sender
{
    if (self.opinionTextView.text.length >= 1) {
        self.opinionSendButton.enabled = YES;
    }else{
        self.opinionSendButton.enabled = NO;
    }
}
- (IBAction)sendOpinionButtonAction:(id)sender {
    
    AVObject *opinionObject = [AVObject objectWithClassName:@"Opinions"];
    [opinionObject setObject:[AVUser currentUser].username forKey:@"name"];
    [opinionObject setObject:self.opinionTextView.text forKey:@"opinions"];
    [opinionObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
       
        if (succeeded) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"发送成功" preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alertVC animated:YES completion:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }
    }];
    
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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
