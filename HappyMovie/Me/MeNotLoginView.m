//
//  MeNotLoginView.m
//  happyMovieEditor
//
//  Created by chuanbao on 16/1/10.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "MeNotLoginView.h"

@implementation MeNotLoginView

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
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    self.label.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2-30);
    self.label.text = @"亲!还没有登录呢";
    self.label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.label];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.loginButton.frame = CGRectMake(0, 0, 100, 30);
    self.loginButton.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self.loginButton setTitle:@"立即登录" forState:UIControlStateNormal];
    [self addSubview:self.loginButton];
}
@end
