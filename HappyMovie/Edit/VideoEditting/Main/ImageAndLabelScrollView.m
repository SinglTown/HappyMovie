//
//  ImageAndLabelScrollView.m
//  HappyMovie
//
//  Created by lanou3g on 16/1/21.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "ImageAndLabelScrollView.h"

@implementation ImageAndLabelScrollView

-(instancetype)initWithFrame:(CGRect)frame dataArr:(NSArray *)dataArr distance:(NSInteger)distance{
    self = [super initWithFrame:frame];
    if (self) {
       
    
        [self addSubviews:dataArr distance:distance];
        
        
    }
    return self;




}
-(void)addSubviews:(NSArray *)dataArr distance:(NSInteger)distance{

     
    for (NSInteger i = 0; i<dataArr.count; i++) {
        
        NSDictionary *dic = [dataArr objectAtIndex:i];
        
        //添加子实图
        [self addSubviewWithName:[dic valueForKey:@"image"] labelName:[dic valueForKey:@"name"] count:i distance:distance];
        
    }
    
    
}
-(void)addSubviewWithName:(NSString *)imageName labelName:(NSString *)labelName count:(NSInteger)count distance:(NSInteger)distance{
    
    //button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(20+(35+30)*count, 5, 35, 35);
    [button setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    button.tag = count;
   // button.clipsToBounds = YES;
    [button addTarget:self action:@selector(selectResult:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    //label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(distance+(35+30)*count, CGRectGetMaxY(button.frame)+5, 50, 20)];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.text = labelName;
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    
    
}
-(void)selectResult:(UIButton *)sender{
    if (self.buttonDelegate && [self.buttonDelegate respondsToSelector:@selector(imageAndLabelScrollViewButtonDidClick:)]) {
        //执行代理方法
        [self.buttonDelegate imageAndLabelScrollViewButtonDidClick:sender.tag];
    }



}
@end
