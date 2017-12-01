//
//  FilterScrollView.m
//  HappyMovieEditer---1
//
//  Created by lanou3g on 16/1/15.
//  Copyright © 2016年 chuanbao. All rights reserved.
//

#import "FilterScrollView.h"
@implementation FilterScrollView
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
    NSArray *filterArray = @[@"无效果",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@""];
    for (int i=0 ; i<13 ; i++) {
        UIImageView *filterImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5+(60+5)*i, 5, 60, self.frame.size.height-10)];
        filterImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"IMG_01%d.JPG",55+i]];
        filterImageView.backgroundColor = [UIColor purpleColor];
        filterImageView.userInteractionEnabled = YES;
        filterImageView.tag = i+100;
        [self addSubview:filterImageView];
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGRAction:)];
        [filterImageView addGestureRecognizer:tapGR];
        
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
        titleLabel.center = CGPointMake(30, self.frame.size.height-20);
        titleLabel.text = filterArray[i];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:12];
        [filterImageView addSubview:titleLabel];
        
    }
}
-(void)tapGRAction:(UITapGestureRecognizer *)sender
{
    NSInteger X = sender.view.tag-100;
   // NSLog(@"-------%ld",(long)X);
    self.filterBlock(X);
}
@end
