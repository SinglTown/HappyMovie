//
//  AddTitleViewController.h
//  HappyMovie
//
//  Created by lanou3g on 16/1/22.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ReturnTitleVideoBlock)(NSString *url);



@interface AddTitleViewController : UIViewController
//返回合成的视频地址
@property(nonatomic,copy)ReturnTitleVideoBlock block;

-(void)setCurrentMovieUrl:(NSURL *)movieUrl;


@end
