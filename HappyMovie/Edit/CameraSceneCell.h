//
//  CameraSceneCell.h
//  happyMovieEditor
//
//  Created by lanou3g on 16/1/11.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraSceneCell : UICollectionViewCell
//不同的镜头图像
@property(nonatomic,strong)UIImageView *cameraSceneImageView;
//镜头名称
@property(nonatomic,strong)UILabel *cameraSceneLabel;
//设置cell
-(void)setCellWithDic:(NSDictionary *)dic;
@end
