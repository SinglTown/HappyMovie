//
//  CameraSceneCell.m
//  happyMovieEditor
//
//  Created by lanou3g on 16/1/11.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "CameraSceneCell.h"

@implementation CameraSceneCell

-(instancetype)initWithFrame:(CGRect)frame{
  
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
      
       //布局子实图
        [self addSubViews];
        
    }
    return self;

}

-(void)addSubViews{
//图像
    self.cameraSceneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    self.cameraSceneImageView.center = CGPointMake(CGRectGetMidX(self.contentView.frame), 30);
 //  self.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:self.cameraSceneImageView];
    
   //label
    self.cameraSceneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.cameraSceneImageView.frame)+2, 100, 30)];
   // self.cameraSceneLabel.backgroundColor = [UIColor redColor];
    self.cameraSceneLabel.textAlignment = NSTextAlignmentCenter;
    self.cameraSceneLabel.textColor = [UIColor whiteColor];
    self.cameraSceneLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:self.cameraSceneLabel];





}
//设置cell
-(void)setCellWithDic:(NSDictionary *)dic{

    self.cameraSceneLabel.text = [dic valueForKey:@"name"];
    self.cameraSceneImageView.image = [UIImage imageNamed:[dic valueForKey:@"image"]];


}



@end
