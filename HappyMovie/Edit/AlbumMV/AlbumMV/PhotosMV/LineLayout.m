//
//  LineLayout.m
//  UiCollectionViewCell2
//
//  Created by lanou3g on 15/11/30.
//  Copyright (c) 2015年 陈强. All rights reserved.
//

#import "LineLayout.h"
#define kItemX  100
#define kItemY  100
@implementation LineLayout
//配置layout基本设置的一些方法  准备布局
-(void)prepareLayout{
    [super prepareLayout];
    
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 0;
    self.itemSize = CGSizeMake(115, 130);
    
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
   // CGFloat top = (self.collectionView.frame.size.height - kItemY) * 0.5;

   // CGFloat left = (self.collectionView.frame.size.width - kItemX) * 0.5;
   
    self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    
}
//是否时刻改变布局
-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    
 
    return YES;
    
}

//配置一个item的相关属性
-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{

    
    
    self.collectionView.backgroundColor = [UIColor blackColor];
    NSArray * array = [super layoutAttributesForElementsInRect:rect];
  
    
   
    for (UICollectionViewLayoutAttributes *sttributes in array) {
//        设置偏移量
        CGFloat centerX =  self.collectionView.contentOffset.x+self.collectionView.frame.size.width*0.5;//词句表示的含义 是  无论屏
    
        CGFloat itemCenterX= sttributes.center.x;//这个点其实是每一个图片固有的的中心坐标 它其实不是变化的
   
       
//        缩放比例
        CGFloat scale = 1 + 0.5*(1 -ABS(centerX - itemCenterX))/180;//这
       
        
        
//        设置transform3D
        sttributes.transform3D = CATransform3DMakeScale(scale, scale, 1);
        
        
    }
    
    
    return array;
    
}
@end
