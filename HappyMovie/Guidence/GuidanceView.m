//
//  GuidanceView.m
//  HappyMovie
//
//  Created by lanou3g on 16/1/28.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "GuidanceView.h"

@implementation GuidanceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self allViews];
    }
    return self;
}
-(void)allViews
{
    self.guidanceScrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.guidanceScrollView.contentSize = CGSizeMake(kScreenWidth*3, kScreenHeight);
    self.guidanceScrollView.pagingEnabled = YES;
    self.guidanceScrollView.showsHorizontalScrollIndicator = NO;
    self.guidanceScrollView.showsVerticalScrollIndicator = NO;
    NSArray *imageArray = @[@"076b0d8d2ed4d83e916a12c5a182dd79.png",@"onBoardingBackgrounsImage1.png",@"Login_Welcome_Image1.png"];
    for (int i=0 ; i<3; i++) {
        UIImageView *guidanceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth * i, 0, kScreenWidth, kScreenHeight)];
        guidanceImageView.userInteractionEnabled = YES;
        guidanceImageView.image = [UIImage imageNamed:imageArray[i]];
        if (i == 2) {
            self.startButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 35)];
            self.startButton.center = CGPointMake(kScreenWidth/2, kScreenHeight-80);
            
            self.startButton.titleLabel.font = [UIFont systemFontOfSize:15];
            //self.startButton.backgroundColor = [UIColor whiteColor];
            [self.startButton setTitle:@"立即开启" forState:UIControlStateNormal];
            self.startButton.titleLabel.font = [UIFont systemFontOfSize:20];
            self.startButton.layer.borderColor = [[UIColor whiteColor] CGColor];
            self.startButton.layer.borderWidth = 0.6;
            self.startButton.layer.cornerRadius = 5;
            [guidanceImageView addSubview:self.startButton];
        }
        [self.guidanceScrollView addSubview:guidanceImageView];
    }
    [self addSubview:self.guidanceScrollView];
    self.guidancePageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    self.guidancePageControl.center = CGPointMake(kScreenWidth/2, kScreenHeight-40);
    self.guidancePageControl.enabled = NO;
    self.guidancePageControl.numberOfPages = 3;
    [self addSubview:self.guidancePageControl];

}

@end
