//
//  AnnimationViewController.h
//  HappyMovie
//
//  Created by lanou3g on 16/1/23.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import <UIKit/UIKit.h>

//返回视频保存的地址
typedef void(^RetureURLBlock)(NSString *url);


@interface AnnimationViewController : UIViewController

@property(nonatomic,copy)RetureURLBlock returnUrlBlock;

//接收上个界面传第的视频地址
-(void)setCurrentMovieUrl:(NSURL *)movieUrl;



@end
