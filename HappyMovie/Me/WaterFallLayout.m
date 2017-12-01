//
//  WaterFallLayout.m
//  Lesson-UI-22-3
//
//  Created by lanou3g on 15/11/30.
//  Copyright (c) 2015年 传保. All rights reserved.
//

#import "WaterFallLayout.h"

@interface WaterFallLayout ()

//item的数量
@property (nonatomic,assign)NSInteger numberOfItems;
//保存每列的高度
@property (nonatomic,strong)NSMutableArray *columnsHeights;
//存放item属性的数组
@property (nonatomic,strong)NSMutableArray *itemAttributes;


//获取最长列的索引
-(NSInteger)p_indexForLongestColumn;
//获取最短列的索引
-(NSInteger)p_indexForShortestColumn;

@end

@implementation WaterFallLayout

//懒加载
-(NSMutableArray *)columnsHeights
{
    if (!_columnsHeights) {
        self.columnsHeights = [NSMutableArray array];
    }
    return _columnsHeights;
}
-(NSMutableArray *)itemAttributes
{
    if (!_itemAttributes) {
        self.itemAttributes = [NSMutableArray array];
    }
    return _itemAttributes;
}
//获取最长列的索引
-(NSInteger)p_indexForLongestColumn
{
    //记录哪个是最长的
    NSInteger longestHeight = 0;
    //记录当前最长的item的下标
    NSInteger longestItemIndex = 0;
    //循环,选出最长的item的索引
    for (int i=0; i<self.numberOfColumns; i++) {
        CGFloat currentHeight = [self.columnsHeights[i] floatValue];
        if (longestHeight < currentHeight) {
            longestHeight = currentHeight;
            longestItemIndex = i;
        }
    }
    //返回
    return longestItemIndex;
}
//获取最短列的索引
-(NSInteger)p_indexForShortestColumn
{
    //记录最短列的索引
    NSInteger shortestItemIndex = 0;
    //记录最短高度
    CGFloat shortestHeight = MAXFLOAT;//浮点型最大值
    for (int i = 0; i<self.numberOfColumns; i++) {
        CGFloat currentHeight = [self.columnsHeights[i] floatValue];
        if (currentHeight < shortestHeight) {
            shortestHeight = currentHeight;
            shortestItemIndex = i;
        }
    }
    return shortestItemIndex;
}
-(void)prepareLayout
{
    //执行父类的方法
    [super prepareLayout];
    //给高度数组赋值(top的高度)
    for (int i=0; i<self.numberOfColumns; i++) {
        self.columnsHeights[i] = @(self.sectionInsets.top);//@(4)转化为数值类型
    }
    //获取到item得个数
    self.numberOfItems = [self.collectionView numberOfItemsInSection:0];
    //为每一个item设置frame
    for (int i=0; i<self.numberOfItems; i++) {
        //获取到高度最小的列
        NSInteger shortestIndex = [self p_indexForShortestColumn];
        //获取到最小得高度
        CGFloat shortestH = [self.columnsHeights[shortestIndex] floatValue];
        //设置x值 内边距 left +(item宽+item间距)*列的索引
        CGFloat detalX = self.sectionInsets.left +(self.itemSize.width+self.insertItemSpacing)*shortestIndex;
        //设置y值 最短的高 + 间距
        CGFloat detalY = shortestH+self.insertItemSpacing;
        //设置indexPath
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        //创建LayoutAttributes
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        //获取到item的高度
        CGFloat itemHeight = 0;
        if ([self.delegate respondsToSelector:@selector(heightForItemIndexPath:)]) {
            itemHeight = [self.delegate heightForItemIndexPath:indexPath];
        }
        //设置frame
        attributes.frame = CGRectMake(detalX, detalY, self.itemSize.width, itemHeight);
        //添加到itemAttributes数组中,用作layoutAttributesForElementsInRect:方法的返回值,从而根据数组设置来设置每个item
        [self.itemAttributes addObject:attributes];
        //更新高度数组
        self.columnsHeights[shortestIndex] = @(detalY +itemHeight);
    }
}
-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    
    
    return self.itemAttributes;
    
    
}
-(CGSize)collectionViewContentSize
{
    //获取最长的高度的索引
    NSInteger longestIndex = [self p_indexForLongestColumn];
    //通过索引获取最长列的长度
    CGFloat longestH = [self.columnsHeights[longestIndex] floatValue];
    //最长的高度 + 距下得距离
    CGFloat height = longestH + self.sectionInsets.bottom;
    //修改contentSize
    CGSize contentSize = self.collectionView.frame.size;
    //将修改之后的contentSize进行返回
    contentSize.height = height;
    return contentSize;
}

@end
