//
//  ImageAndLabelScrollView.h
//  HappyMovie
//
//  Created by lanou3g on 16/1/21.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageAndLabelScrollViewDelegate <NSObject>

-(void)imageAndLabelScrollViewButtonDidClick:(NSInteger)tag;

@end


@interface ImageAndLabelScrollView : UIScrollView

//设置代理
@property(nonatomic,strong)id<ImageAndLabelScrollViewDelegate>buttonDelegate;

//初始化
-(instancetype)initWithFrame:(CGRect)frame dataArr:(NSArray *)dataArr distance:(NSInteger)distance;




@end
