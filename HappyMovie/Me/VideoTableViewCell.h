//
//  VideoTableViewCell.h
//  HappyMovie
//
//  Created by lanou3g on 16/1/25.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayMovieView;
@class VideoTableViewCell;

@protocol VideoTableViewCellDelegate <NSObject>
@optional
//播放/暂停按钮
-(void)playAndPauseButtonWithCell:(VideoTableViewCell *)cell;
//删除按钮
-(void)deleteButtonWithCell:(VideoTableViewCell *)cell;
//分享按钮
-(void)sharedButtonWithCell:(VideoTableViewCell *)cell;
@end




@interface VideoTableViewCell : UITableViewCell

@property(nonatomic,weak)id<VideoTableViewCellDelegate>playDelegate;

//播放界面
@property (strong, nonatomic) IBOutlet UIView *playView;
//删除按钮
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
//分享按钮
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property(nonatomic,strong)AVPlayer *player;
@property(nonatomic,strong)UIButton *playAndPausebutton;

-(void)setCellWithNSUrl:(NSURL *)url;

@end
