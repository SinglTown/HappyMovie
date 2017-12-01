//
//  NikenameViewController.m
//  HappyMovie
//
//  Created by lanou3g on 16/1/22.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "NikenameViewController.h"
#import <AVOSCloud/AVOSCloud.h>
@interface NikenameViewController ()

@property (strong, nonatomic) IBOutlet UITextField *nikenameTF;

@end

@implementation NikenameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconfont-fanhui.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmAction:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.nikenameTF becomeFirstResponder];
    });
}
-(void)backAction:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)confirmAction:(UIBarButtonItem *)sender
{
    if (self.nikenameTF.text.length != 0) {
        AVQuery *nikenameQuery = [AVQuery queryWithClassName:@"UserMessage"];
        [nikenameQuery whereKey:@"name" equalTo:[AVUser currentUser].username];
        [nikenameQuery getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            if (object) {
                [object setObject:self.nikenameTF.text forKey:@"nikename"];
                [object saveInBackground];
            }else{
                //NSLog(@"------%@",error);
            }
        }];
    }
    [self.navigationController popViewControllerAnimated:YES];
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
