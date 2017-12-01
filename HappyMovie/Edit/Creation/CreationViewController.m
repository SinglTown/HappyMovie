//
//  CreationViewController.m
//  HappyMovie
//
//  Created by lanou3g on 16/1/21.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "CreationViewController.h"
#import "VideoCaputureViewController.h"
#import "PhotoMVViewController.h"
#import "ZYQAssetPickerController.h"
#import "VideoEditViewController.h"
#import "CTAssetsPickerController.h"
#import "WorkingViewController.h"
#import "MeViewController.h"
#import <AVOSCloud/AVOSCloud.h>
#import "Video.h"
#define kWeight   [UIScreen mainScreen].bounds.size.width
#define kHeight   [UIScreen mainScreen].bounds.size.height
@interface CreationViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,CTAssetsPickerControllerDelegate,MBProgressHUDDelegate>

@property (strong, nonatomic) IBOutlet UIView *backVideo;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerItem *playerItem;


@property (nonatomic,assign) BOOL isSelectingAssetOne;

@property(nonatomic,strong)NSTimer*Timer;//定时器

@property (nonatomic,strong)UIImagePickerController *pickerVC;


@property (nonatomic,strong) MBProgressHUD *HUD;

@property (nonatomic,strong) AVAssetExportSession *exporter;

@end


@implementation CreationViewController

-(void)dealloc
{
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;
    self.playerItem = nil;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    //视频播放
    [self setAudioWithName:@"explore_video"];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.frame = self.backVideo.bounds;
    
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor clearColor] CGColor], (id)[[UIColor clearColor] CGColor],nil];
    
    [self.backVideo.layer insertSublayer:gradient atIndex:0];
    
    
    //设置主题
    UILabel * helpLabel = [[UILabel alloc] initWithFrame:CGRectMake(kWeight / 2.0 - 150, 60, 300, 50)];
    
    helpLabel.text = NSLocalizedString(@"Happy && Movie", @"乐影");
    helpLabel.textAlignment = NSTextAlignmentCenter;
    helpLabel.font = [UIFont systemFontOfSize:40.0];
    helpLabel.textColor = [UIColor whiteColor];
    [self.backVideo addSubview:helpLabel];
    
    //视频拍摄
    UIButton *videoRecording = [UIButton buttonWithType:1];
    videoRecording.frame = CGRectMake(kWeight / 2.0 - 60, 140, 120, 40);
    [videoRecording setTitle:@"视频拍摄" forState:UIControlStateNormal];
    [videoRecording setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    videoRecording.layer.borderWidth = 0.7;
    videoRecording.layer.borderColor = [[UIColor whiteColor] CGColor];
    videoRecording.titleLabel.font = [UIFont systemFontOfSize:17];
    [videoRecording addTarget:self action:@selector(videoRecordingAction:) forControlEvents: UIControlEventTouchUpInside];
    [self.backVideo addSubview:videoRecording];
    
    //视频剪辑
    UIButton *videoEdit = [UIButton buttonWithType:1];
    videoEdit.frame = CGRectMake(kWeight / 2.0 - 60, 190, 120, 40);
    [videoEdit setTitle:@"视频剪辑" forState:UIControlStateNormal];
    [videoEdit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    videoEdit.layer.borderWidth = 0.7;
    videoEdit.layer.borderColor = [[UIColor whiteColor] CGColor];
    videoEdit.titleLabel.font = [UIFont systemFontOfSize:17];
    [videoEdit addTarget:self action:@selector(videoEditAction:) forControlEvents: UIControlEventTouchUpInside];
    [self.backVideo addSubview:videoEdit];
    
    
    //照片美化
    UIButton *beautyPhoto = [UIButton buttonWithType:1];
    beautyPhoto.frame = CGRectMake(kWeight / 2.0 - 60, 240, 120, 40);
    [beautyPhoto setTitle:@"照片美化" forState:UIControlStateNormal];
    [beautyPhoto setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    beautyPhoto.layer.borderWidth = 0.7;
    beautyPhoto.layer.borderColor = [[UIColor whiteColor] CGColor];
    beautyPhoto.titleLabel.font = [UIFont systemFontOfSize:17];
    [beautyPhoto addTarget:self action:@selector(beautyPhotoAction:) forControlEvents: UIControlEventTouchUpInside];
    
    [self.backVideo addSubview:beautyPhoto];
    
    //相册MV
    UIButton *photoMV = [UIButton buttonWithType:1];
    
    photoMV.frame = CGRectMake(kWeight / 2.0 - 60, 290, 120, 40);
    
    [photoMV setTitle:@"相册MV" forState:UIControlStateNormal];
    
    [photoMV setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    photoMV.layer.borderWidth = 0.7;
    
    photoMV.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    photoMV.titleLabel.font = [UIFont systemFontOfSize:17];
    
    [photoMV addTarget:self action:@selector(photoMVAction:) forControlEvents: UIControlEventTouchUpInside];
    
    [self.backVideo addSubview:photoMV];
    
    //我的
    //相册MV
    UIButton *mine = [UIButton buttonWithType:1];
    
    mine.frame = CGRectMake(kWeight / 2.0 - 60, 340, 120, 40);
    
    [mine setTitle:@"我的" forState:UIControlStateNormal];
    
    [mine setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    mine.layer.borderWidth = 0.7;
    
    mine.layer.borderColor = [[UIColor whiteColor] CGColor];
    mine.titleLabel.font = [UIFont systemFontOfSize:17];
    
    
    [mine addTarget:self action:@selector(mineAction:) forControlEvents: UIControlEventTouchUpInside];
    
    [self.backVideo addSubview:mine];
    
    
}



-(void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
  
    [self.player play];
    
}


-(void)viewDidDisappear:(BOOL)animated
{
    
    [super viewDidDisappear:animated];
    
    [self.player pause];
    
  //  self.playerItem = nil;
    
    
}


#pragma mark 视频拍摄
-(void)videoRecordingAction:(UIButton *)sender
{
    //进入拍摄界面
    VideoCaputureViewController *videoCaptureVC = [[VideoCaputureViewController alloc] init];
    videoCaptureVC.modalTransitionStyle =  UIModalTransitionStyleCoverVertical;
    [self presentViewController:videoCaptureVC animated:YES completion:nil];

}


#pragma mark 视频剪辑
-(void)videoEditAction:(UIButton *)sender
{
    
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.assetsFilter = [ALAssetsFilter allVideos];
    
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
    
}

#pragma mark 照片美化
-(void)beautyPhotoAction:(UIButton *)sender
{
    self.pickerVC = [[UIImagePickerController alloc] init];
    self.pickerVC.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    self.pickerVC.allowsEditing = NO;
    self.pickerVC.delegate = self;
    [self presentViewController:self.pickerVC animated:YES completion:nil];

}


#pragma mark 相册MV
-(void)photoMVAction:(UIButton *)sender
{
    PhotoMVViewController * phontMV = [[PhotoMVViewController alloc]init];
    [self presentViewController:phontMV animated:YES completion:nil];

}


#pragma mark 我的 
-(void)mineAction:(UIButton *)sender
{
    MeViewController *meVC = [[MeViewController alloc] init];
    UINavigationController *meNaVC = [[UINavigationController alloc] initWithRootViewController:meVC];
    meNaVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:meNaVC animated:YES completion:nil];
    if ([AVUser currentUser] != nil) {
        //登陆成功赋值
        AVQuery *query = [AVQuery queryWithClassName:@"UserMessage"];
        [query whereKey:@"name" equalTo:[AVUser currentUser].username];
        [query getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            if (object != nil) {
                if ([object objectForKey:@"nikename"] != nil) {
                    NSString *nikename = [object objectForKey:@"nikename"];
                    meVC.userNameLabel.text = nikename;
                }else{
                    NSString *name = [object objectForKey:@"name"];
                    meVC.userNameLabel.text = name;
                }
                AVFile *avatarFile = [object objectForKey:@"avatarImage"];
                if (avatarFile != nil) {
                    NSData *avatarData = [avatarFile getData];
                    UIImage *avatarImage = [UIImage imageWithData:avatarData];
                    meVC.meSelfImageView.image = avatarImage;
                }else{
                     meVC.meSelfImageView.image = [UIImage imageNamed:@"3724d6e9fb0b28d51344b5ef30ba27aa.jpg"];
                }
            }else{
                
              //  NSLog(@"%@",error);
                
            }
        }];
    }

}



#pragma mark 给视图添加导航控制器
-(void)addNavigationControllerWithController:(UIViewController *)controller
{
    
    UINavigationController *nVC = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:nVC animated:YES completion:nil];
    
}

#pragma mark 播放器设置以及播放的方法
-(void)setAudioWithName:(NSString *)name
{
    NSString *str = [[NSBundle mainBundle] pathForResource:name ofType:@"mp4"];
    
    NSURL *url = [NSURL fileURLWithPath:str];
    
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    //设置播放界面的大小
    layer.frame = [UIScreen mainScreen].bounds;
    
    //设置适应player的方式
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.backVideo.layer addSublayer:layer];
    
  //  [self.player play];
    
}

#pragma mark 进入编辑界面且合成视频

#pragma mark 选取视频的代理方法
-(void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
   // NSLog(@"选取的视频 %@",assets);
    
    if (assets.count > 0 && assets) {
        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
        
        AVMutableCompositionTrack *track = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        for (int i = 0;  i < assets.count; i++) {
            
            ALAsset *alAsset = [assets objectAtIndex:i];
            //获取url
            NSURL *url = [alAsset valueForProperty:@"ALAssetPropertyAssetURL"];
            
            //将url封装成AVAsset 对象
            AVAsset *asset = [AVAsset assetWithURL:url];
            
            //将选中的视频依次合成
            [track insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
            
        }
        

        
        NSString *myPathDocs = [[DataStore sharedDataStore] saveFileToData];
        
        [[DataStore sharedDataStore] insertUrl:myPathDocs];
        
        
//        查询所有的数据
//        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Video"];
//        NSArray *arr = [NSArray array];
//        arr = [[DataStore sharedDataStore].context executeFetchRequest:request error:nil];
//        for (Video *video in arr) {
//             NSLog(@"查询数据库--------- %@",video.url);
//        }
        //输出设置
        self.exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
        
        //输出视频 url
        _exporter.outputURL = [NSURL fileURLWithPath:myPathDocs];
        
        //输出文件类型设置
        _exporter.outputFileType = AVFileTypeQuickTimeMovie;
        
        //输出最优化设置
        _exporter.shouldOptimizeForNetworkUse = YES;
        
        [self loadIndictionToView:picker.view];

        [_exporter exportAsynchronouslyWithCompletionHandler:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{

                if (_exporter.outputURL == nil) {
                    
                }
                
                else
                {
                    
                VideoEditViewController *vEC = [[VideoEditViewController alloc] init];
                [vEC setCurrentPath:myPathDocs];
                    
                    //模态出视频编辑界面
                    [picker presentViewController:vEC animated:YES completion:^{
                        
                        [MBProgressHUD hideHUDForView:picker.view animated:YES];
                        
                    }];
                    
                }
                

            
        });
            
    }];
        
}
    
    else
    {
        return;
    }
    
}




#pragma mark 输出完成调用的方法
-(void)exportDidFinish:(AVAssetExportSession *)session
{
    //判断session是否执行完成
    if (session.status == AVAssetExportSessionStatusCompleted) {
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:session.outputURL])
        {
            
            [library writeVideoAtPathToSavedPhotosAlbum:session.outputURL completionBlock:^(NSURL *assetURL, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (!error) {
                        
                     //   NSLog(@"失败");
//                        [self displayAlertControllerWithMessage:@"视频成功保存到相册"];
                        
                    }
                    
                    else
                    {
                        
                       // NSLog(@"成功");
//                        [self displayAlertControllerWithMessage:@"视频保存到相册失败"];
//                        
                    }
                    
                });
                
            }];
            
        }
        
    }
    
}


#pragma mark AlertController 的展示
//-(void)displayAlertControllerWithMessage:(NSString *)message
//{
//    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"nil" message:message preferredStyle:1];
//    
//    [self presentViewController:alertVC animated:YES completion:^{
//        
//        [self dismissViewControllerAnimated:YES completion:nil];
//        
//    }];
//    
//}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    CGFloat ratio = image.size.width/image.size.height;
    CGFloat screenRatio = kScreenWidth/kScreenHeight;
    CGSize size = CGSizeZero;
    if (screenRatio == (320.0/568)) {
        size = CGSizeMake(ratio*350, 350);
    }else if (screenRatio == (375.0/667)){
        size = CGSizeMake(ratio*400, 400);
    }else if(screenRatio == (414.0/736)){
        size = CGSizeMake(ratio*500, 500);
    }
    UIImage *resultImage = [self scaleToSize:image size:size];
    WorkingViewController *workVC = [[WorkingViewController alloc] init];
    workVC.tempImage = resultImage;
    //    workVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.pickerVC presentViewController:workVC animated:YES completion:nil];
}
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
//    if (size.width > kScreenWidth+100) {
//        UIGraphicsBeginImageContextWithOptions(size, YES, 1.5);
//    }else{
//        UIGraphicsBeginImageContextWithOptions(size, YES, 2);
//    }
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    //返回新的改变大小后的图片
    return scaledImage;
}



#pragma mark 添加转圈在视图上 
-(void)loadIndictionToView:(UIView *)view
{
    //圆形进度条
  self.HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:self.HUD];
    self.HUD.mode = MBProgressHUDModeAnnularDeterminate;
   self.HUD.delegate = self;
    self.HUD.labelText = @"Loading";
    [self.HUD showWhileExecuting:@selector(myProgressTask) onTarget:self withObject:nil animated:YES];
    
}


- (void) myProgressTask{
    float progress = 0.0f;
    while (progress < 1.0f) {
        progress += 0.001f;
        self.HUD.progress = progress;
        usleep(10000);
    }
}

-(void)hudWasHidden:(MBProgressHUD *)hud
{
    [self.HUD removeFromSuperview];
    self.HUD = nil;
}



@end