//
//  StartView.m
//  happyMovieEditor
//
//  Created by lanou3g on 16/1/8.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "StartView.h"

@implementation StartView
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
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.loginButton.frame = CGRectMake(0, 0, self.frame.size.width/2, self.frame.size.height);
    [self.loginButton setTitle:@"登陆" forState:UIControlStateNormal];
    self.loginButton.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.loginButton];
    
    self.registerButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.registerButton.frame = CGRectMake(self.frame.size.width/2, 0,self.frame.size.width/2, self.frame.size.height);
    [self.registerButton setTitle:@"注册" forState:UIControlStateNormal];
    self.registerButton.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.registerButton];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 10, 0.5, 30)];
    lineView.backgroundColor = [UIColor redColor];
    [self addSubview:lineView];
    
}

@end
