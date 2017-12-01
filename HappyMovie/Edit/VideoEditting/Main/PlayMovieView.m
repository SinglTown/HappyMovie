//
//  PlayMovieView.m
//  HappyMovie
//
//  Created by lanou3g on 16/1/20.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "PlayMovieView.h"

@implementation PlayMovieView

#pragma mark 加载视频
-(long long)loadVideoWithUrl:(NSURL *)url{
    
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
  
    self.player = [AVPlayer playerWithPlayerItem:item];
 
    //确定avplayer的frame
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    layer.frame = self.layer.bounds;
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:layer];
    
     //播放
    [self.player play];
    
    //播放的时候开启定时器
    //返回播放时长
    AVAsset *asset = [AVAsset assetWithURL:url];
    long long seconds = asset.duration.value/asset.duration.timescale;
    return seconds;


}
@end
