//
//  BaseView.m
//  HappyMovie
//
//  Created by lanou3g on 16/1/26.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "BaseView.h"

@implementation BaseView

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
    self.baseImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.baseImageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2-50);
    self.baseImageView.image = [UIImage imageNamed:@"iconfont-shipin-Me.png"];
    [self addSubview:self.baseImageView];
    
    UILabel *baseLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    baseLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2+30);
    baseLabel.textAlignment = NSTextAlignmentCenter;
    baseLabel.text = @"暂无作品";
    [self addSubview:baseLabel];
    
}
@end
