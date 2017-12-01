//
//  DrawerScrollView.m
//  HappyMovieEditer---1
//
//  Created by lanou3g on 16/1/19.
//  Copyright © 2016年 chuanbao. All rights reserved.
//

#import "DrawerScrollView.h"

@implementation DrawerScrollView
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
    NSArray *drawImage = @[@"iconfont-bi.png",@"iconfont-diaosepan.png",@"iconfont-xiangpica.png",@"iconfont-zhongxinkaishi.png"];
    NSArray *drawTitle = @[@"开始",@"配色",@"橡皮擦",@"重绘"];
    for (int i=0; i<4; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];;
        button.frame = CGRectMake(0, 0, 50, 40);
        button.center = CGPointMake(20+30*i+50*i+25, self.frame.size.height/2-10);
        [button setImage:[UIImage imageNamed:drawImage[i]] forState:UIControlStateNormal];
        button.tag = 500+i;
        [button addTarget:self action:@selector(drawClickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 25)];
        label.center = CGPointMake(20+30*i+50*i+25, self.frame.size.height/2+20);
        label.text = drawTitle[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:13];
        [self addSubview:label];

    }
}
-(void)drawClickButtonAction:(UIButton *)sender
{
    self.drawerBlcok(sender.tag);
}
@end
