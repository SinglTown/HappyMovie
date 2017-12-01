//
//  TextView.m
//  HappyMovie
//
//  Created by lanou3g on 16/1/22.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "TextView.h"

@implementation TextView

-(instancetype)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    if (self) {
       
        [self addSubViews];
    }

    return self;



}
-(void)addSubViews{

   //textView
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 15, self.bounds.size.width-30, self.bounds.size.height-30)];
    self.textView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.textView.layer.borderWidth = 1;
   self.textView.textColor = [UIColor whiteColor];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.font = [UIFont systemFontOfSize:30];
    [self addSubview:self.textView];
    //添加平移手势
    self.textView.userInteractionEnabled = YES;
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.textView addGestureRecognizer:panGR];
   //删除button
    UIImageView *deleteButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    deleteButton.center = self.textView.frame.origin;
    deleteButton.image = [UIImage imageNamed:@"iconfont-shanchu.png"];
    [self addSubview:deleteButton];
    deleteButton.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteTextView:)];
    [deleteButton addGestureRecognizer:tapGR];
    
    //旋转button
    self.rotateButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
   self.rotateButton.image = [UIImage imageNamed:@"iconfont-xuanzhuan.png"];
    self.rotateButton.center = CGPointMake(CGRectGetMaxX(self.textView.frame), CGRectGetMaxY(self.textView.frame));
    [self addSubview:self.rotateButton];
    self.rotateButton.userInteractionEnabled = YES;
    UIPanGestureRecognizer *pinchGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [self.rotateButton addGestureRecognizer:pinchGR];
    
}
//平移
-(void)pan:(UIPanGestureRecognizer *)pan{

    if (self.panBlock != nil) {
       
        self.panBlock(pan);
    }

}
//删除
-(void)deleteTextView:(UITapGestureRecognizer *)tap{

    if (self.block!=nil) {
       
        self.block();
        
    }


}
//缩放
-(void)pinch:(UIPanGestureRecognizer *)pinch{

    if (self.pinchBlock != nil) {
       
        self.pinchBlock(pinch);
    }



}
-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    self.textView.frame = CGRectMake(15, 15, self.frame.size.width-30, self.frame.size.height-30);
    self.rotateButton.center = CGPointMake(CGRectGetMaxX(self.textView.frame), CGRectGetMaxY(self.textView.frame));

}

@end
