//
//  PasterScrollView.m
//  HappyMovieEditer---1
//
//  Created by lanou3g on 16/1/15.
//  Copyright © 2016年 chuanbao. All rights reserved.
//

#import "PasterScrollView.h"

@implementation PasterScrollView

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
    //贴纸图片放入数组方便操作
    NSArray *array = @[@"54b5cfcf09af51235.png",@"54b5d0385e1822843.png",@"54b5d0f59785c9919.png",@"54b5d171b922f7428.png",@"gee_11@2x.png",@"gee_14@2x.png",@"gee_1@2x.png",@"gee_3@2x.png",@"gee_7@2x.png",@"926713b0c36f13dd3d4aa3882d2217f9.jpg",@"e0547497f53b688fcc440b644007d7bb.jpg"];
    self.imageArray = [NSMutableArray array];
    for (int i=0; i<11; i++) {
        [self.imageArray addObject:array[i]];
    }
    for (int i=0; i<10; i++) {
        
        [self.imageArray addObject:[NSString stringWithFormat:@"login_material_%d.png",i+1]];
    }
    for (int i=0; i<21; i++) {
        UIImageView *pasterImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5+(60+5)*i, 5, 60, self.frame.size.height-10)];
        pasterImageView.image = [UIImage imageNamed:self.imageArray[i]];
        pasterImageView.userInteractionEnabled = YES;
        pasterImageView.tag = i+200;
        [self addSubview:pasterImageView];
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGRPasterAction:)];
        [pasterImageView addGestureRecognizer:tapGR];
    }
}
-(void)tapGRPasterAction:(UITapGestureRecognizer *)sender
{
    NSInteger X = sender.view.tag-200;
    self.pasterBlock(X);
}

@end
