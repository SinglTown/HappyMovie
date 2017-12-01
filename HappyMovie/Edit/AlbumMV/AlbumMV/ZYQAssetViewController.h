//
//  ZYQAssetViewController.h
//  HappyMovie
//
//  Created by lanou3g on 16/1/23.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYQAssetPickerController.h"
#import "PhotoMVViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UIView+HB.h"
#import "PassMergeHandle.h"
#import "MBProgressHUD.h"
@interface ZYQAssetViewController : UITableViewController

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property (nonatomic, strong) NSMutableArray *indexPathsForSelectedItems;
-(void)showZYQAssetViewController;
@end
