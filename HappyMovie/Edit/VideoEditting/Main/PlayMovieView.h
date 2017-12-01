//
//  PlayMovieView.h
//  HappyMovie
//
//  Created by lanou3g on 16/1/20.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface PlayMovieView : UIView

@property(nonatomic,strong)AVPlayer *player;

-(long long)loadVideoWithUrl:(NSURL *)url;

@end
