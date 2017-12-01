//
//  WaterFallLayout.h
//  Lesson-UI-22-3
//
//  Created by lanou3g on 15/11/30.
//  Copyright (c) 2015年 传保. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WaterFallLayoutDelegate <NSObject>

//获取到图片,设置高度返回(用于设置item的frame)
-(CGFloat)heightForItemIndexPath:(NSIndexPath *)indexPath;

@end



@interface WaterFallLayout : UICollectionViewLayout

@property(nonatomic,assign)NSInteger numberOfSections;

//item的大小
@property (nonatomic,assign)CGSize itemSize;
//内边距(距屏幕边缘的距离)
@property (nonatomic,assign)UIEdgeInsets sectionInsets;
//item的间距
@property (nonatomic,assign)CGFloat insertItemSpacing;
//列数
@property (nonatomic,assign)NSInteger numberOfColumns;
//
@property (nonatomic,weak)id<WaterFallLayoutDelegate> delegate;

@end
