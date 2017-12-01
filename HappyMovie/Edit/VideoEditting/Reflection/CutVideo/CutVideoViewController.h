//
//  CutVideoViewController.h
//  HappyMovie
//
//  Created by lanou3g on 16/1/23.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>


typedef void(^BACKVIDEOURLBLOCK)(NSString *path);
@interface CutVideoViewController : UIViewController


{
    BOOL isSelectingAssetOne;
}

///记录本地选取视频的url
@property (nonatomic,strong) NSURL *videoUrl;

@property (nonatomic,strong) AVAsset *firstAsset;

@property (nonatomic,strong) BACKVIDEOURLBLOCK finishBlock;

//将本地视频保存到相册
//-(void)exportDidFinish:(AVAssetExportSession*)session;

@end
