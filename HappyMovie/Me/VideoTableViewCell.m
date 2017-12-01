//
//  VideoTableViewCell.m
//  HappyMovie
//
//  Created by lanou3g on 16/1/25.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "VideoTableViewCell.h"
#import "PlayMovieView.h"
@implementation VideoTableViewCell

- (void)awakeFromNib {
 
    //初始化player
    self.player = [[AVPlayer alloc] init];
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    layer.frame = self.playView.layer.bounds;
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.playView.layer addSublayer:layer];
    //button
    self.playAndPausebutton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playAndPausebutton.frame = CGRectMake(0,0,40,40 );
    self.playAndPausebutton.center = CGPointMake(kScreenWidth/2, CGRectGetMidY(self.playView.frame));
    [self.playAndPausebutton setBackgroundImage:[UIImage imageNamed:@"start.png"] forState:UIControlStateNormal];
    [self.playAndPausebutton setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateSelected];
    [self.playAndPausebutton addTarget:self action:@selector(playAndPauseAction:) forControlEvents:UIControlEventTouchUpInside];
     [self.playView addSubview:self.playAndPausebutton];
    //删除按钮
    [self.deleteButton addTarget:self action:@selector(deleteCell:) forControlEvents:UIControlEventTouchUpInside];
    //分享按钮
    [self.shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
    
    
    
}
-(void)setCellWithNSUrl:(NSURL *)url{

    
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
    [self.player replaceCurrentItemWithPlayerItem:item];
    
  
}
//播放/暂停按钮
-(void)playAndPauseAction:(UIButton *)sender{
   
    if (self.playDelegate && [self.playDelegate respondsToSelector:@selector(playAndPauseButtonWithCell:)]) {
        
        [self.playDelegate playAndPauseButtonWithCell:self];
    }

}
//删除按钮
-(void)deleteCell:(UIButton *)sender{

    if (self.playDelegate && [self.playDelegate respondsToSelector:@selector(deleteButtonWithCell:)]) {
        [self.playDelegate deleteButtonWithCell:self];
    }


}
//分享按钮
-(void)shareButtonAction:(UIButton *)sender{

    if (self.playDelegate && [self.playDelegate respondsToSelector:@selector(sharedButtonWithCell:)]) {
       
        [self.playDelegate sharedButtonWithCell:self];
    }


}
@end
