//
//  CameraSceneController.m
//  happyMovieEditor
//
//  Created by lanou3g on 16/1/11.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "CameraSceneController.h"
#import "CameraSceneCell.h"
@interface CameraSceneController ()

//存放数据
@property(nonatomic,strong)NSMutableArray *dataArray;

@end

@implementation CameraSceneController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.9];

    //创建数据
    self.dataArray = [NSMutableArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"putongjingtou.png",@"image",@"普通镜头",@"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"goxiaojingtou.png",@"image",@"搞笑镜头",@"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"huazhonghuajingtou.png",@"image",@"画中画镜头",@"name", nil], nil];
    
    // 注册 cell
    [self.collectionView registerClass:[CameraSceneCell class] forCellWithReuseIdentifier:reuseIdentifier];
    //添加关闭button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(20, [UIScreen mainScreen].bounds.size.height - 50, 30, 30);
    [button setBackgroundImage:[UIImage imageNamed:@"chahao.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.collectionView addSubview:button];
    
   
}
#pragma mark - 添加button
-(void)back:(UIButton *)button{
   
    //返回
    [self dismissViewControllerAnimated:YES completion:nil];


}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CameraSceneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    
    // 设置cell
    NSDictionary *dic = self.dataArray[indexPath.row];
    
    [cell setCellWithDic:dic];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

   //点击某个镜头,返回相同滤镜效果中的第一个滤镜镜头
    //将选择的镜头传到上个界面
    NSDictionary *dic = [self.dataArray objectAtIndex:indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraSceneSelected:)]) {
        [self.delegate cameraSceneSelected:dic];
    }
    [self dismissViewControllerAnimated:YES completion:nil];



}




@end
