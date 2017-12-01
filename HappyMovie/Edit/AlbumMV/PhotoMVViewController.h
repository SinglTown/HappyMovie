//
//  PhotoMVViewController.h
//  happyMovieEditor
//
//  Created by lanou3g on 16/1/7.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PhotoMVViewControllerplayerButtonDelegate <NSObject>
@optional
-(void)playAction;

-(void)changeSpeed;
@end
@interface PhotoMVViewController : UIViewController

@property(nonatomic,weak)id<PhotoMVViewControllerplayerButtonDelegate> delegate;
@end
