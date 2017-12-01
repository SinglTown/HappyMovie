//
//  VideoEditViewController.h
//  HappyMovie
//
//  Created by lanou3g on 16/1/19.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoEditViewController : UIViewController

@property (nonatomic,strong) NSURL *videoUrl;

-(void)setCurrentPath:(NSString *)path;

@end
