//
//  GuidanceViewController.m
//  HappyMovie
//
//  Created by lanou3g on 16/1/28.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "GuidanceViewController.h"
#import "GuidanceView.h"
#import "StartViewController.h"
@interface GuidanceViewController ()<UIScrollViewDelegate>

@property (nonatomic,strong)GuidanceView *guidanceView;

@end

@implementation GuidanceViewController
-(void)loadView
{
    self.guidanceView = [[GuidanceView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view = self.guidanceView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.guidanceView.guidanceScrollView.delegate = self;
    
    [self.guidanceView.startButton addTarget:self action:@selector(startButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)startButtonAction:(UIButton *)sender
{
    StartViewController *startVC = [[StartViewController alloc] init];
    startVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:startVC animated:YES completion:nil];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger i = self.guidanceView.guidanceScrollView.contentOffset.x/kScreenWidth;
    self.guidanceView.guidancePageControl.currentPage = i;
}
@end
