//
//  TextEditScrollView.m
//  HappyMovieEditer---1
//
//  Created by lanou3g on 16/1/18.
//  Copyright © 2016年 chuanbao. All rights reserved.
//

#import "TextEditScrollView.h"

@implementation TextEditScrollView
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
    self.colorArray = @[[UIColor blackColor],[UIColor greenColor],[UIColor blueColor],[UIColor redColor],[UIColor purpleColor],[UIColor orangeColor]];
    for (int i=0; i<7; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        if (i == 0) {
            button.frame = CGRectMake(0, 0, 50, 50);
            [button setImage:[UIImage imageNamed:@"iconfont-wenbenshuru.png"] forState:UIControlStateNormal];
        }else{
            button.frame = CGRectMake(0, 0, 50, 20);
            button.backgroundColor = self.colorArray[i-1];
        }
        button.center = CGPointMake(10+30*i+50*i+25, self.frame.size.height/2);
        button.tag = 1000+i;
        [button addTarget:self action:@selector(drawClickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
}
-(void)drawClickButtonAction:(UIButton *)sender
{
    self.textScrollViewBlock(sender.tag);
}
@end
