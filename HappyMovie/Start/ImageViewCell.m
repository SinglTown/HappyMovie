//
//  ImageViewCell.m
//  happyMovieEditor
//
//  Created by lanou3g on 16/1/8.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "ImageViewCell.h"

@implementation ImageViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self allViews];
    }
    return self;
}
#pragma mark - 添加子视图
-(void)allViews
{
    self.imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    self.imageView.backgroundColor = [UIColor redColor];
    self.imageView.userInteractionEnabled = YES;
    [self.contentView addSubview:self.imageView];
}
//bouns改变时
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
}

@end
