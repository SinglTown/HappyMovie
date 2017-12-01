//
//  ToolScrollView.m
//  HappyMovieEditer---1
//
//  Created by lanou3g on 16/1/15.
//  Copyright © 2016年 chuanbao. All rights reserved.
//

#import "ToolScrollView.h"

@implementation ToolScrollView
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
    NSArray *nameArray = @[@"滤镜",@"贴纸",@"文字",@"画笔",@"裁剪"];
    NSArray *imageNameArray = @[@"iconfont-hua.png",@"iconfont-tiezhi.png",@"iconfont-wenzi.png",@"iconfont-mianxingtubiao1huabiyanse.png",@"iconfont-caijian.png"];
    for (int i=0; i<5; i++) {
        self.toolButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.toolButton.frame = CGRectMake(0, 0, 50, 40);
        self.toolButton.center = CGPointMake(10+30*i+50*i+25, self.frame.size.height/2-10);
        [self.toolButton setImage:[UIImage imageNamed:imageNameArray[i]] forState:UIControlStateNormal];
        self.toolButton.tag = 100+i;
        [self.toolButton addTarget:self action:@selector(clickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.toolButton];
        
        self.toolLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 25)];
        self.toolLabel.center = CGPointMake(10+30*i+50*i+25, self.frame.size.height/2+20);
        self.toolLabel.text = nameArray[i];
        self.toolLabel.textAlignment = NSTextAlignmentCenter;
        self.toolLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:self.toolLabel];
    }
}
-(void)clickButtonAction:(UIButton *)sender
{
    self.toolScrollViewBlock(sender.tag);
}
@end
