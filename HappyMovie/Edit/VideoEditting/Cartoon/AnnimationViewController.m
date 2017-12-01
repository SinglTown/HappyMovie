//
//  AnnimationViewController.m
//  HappyMovie
//
//  Created by lanou3g on 16/1/23.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "AnnimationViewController.h"
#import "ImageCell.h"
#import "XTPasterStageView.h"
#import "PlayMovieView.h"
#import "XTPasterView.h"
@interface AnnimationViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIView *playBottomView;//播放底图
@property (strong, nonatomic) IBOutlet UIButton *playAndPauseButton;
@property (strong, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;

//存储collectionView的数据
@property(nonatomic,strong)NSMutableArray *dataArr;
@property(nonatomic,strong)XTPasterStageView *paster;

//播放图
@property(nonatomic,strong)PlayMovieView *playMovieView;
@property(nonatomic,strong)NSURL *movieUrl;
@property(nonatomic,assign)long long totalTime;
@property(nonatomic,strong)NSTimer *timer;//计时器
@property(nonatomic,strong)UIImage *image;//poaster上的文件


@end

@implementation AnnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    //添加bottomView上的东西
    [self addBottomView];
    [self addCollectionView];
    
    //添加播放视图
    self.playMovieView = [[PlayMovieView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-200)];
    self.playMovieView.backgroundColor = [UIColor grayColor];
    [self.playBottomView addSubview:self.playMovieView];
    //进行播放配置
    if (self.movieUrl != nil) {
        self.totalTime = [self.playMovieView loadVideoWithUrl:self.movieUrl];
        //创建一个NStimer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(progressUpdate) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    //添加总时长
        self.totalTimeLabel.text = [NSString stringWithFormat:@"%lld:%02lld",self.totalTime/60,self.totalTime%60];
    }
    
    //注册一个播放完成的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replay) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    
}
-(void)dealloc{

    [self.timer invalidate];
    [self.playMovieView.player replaceCurrentItemWithPlayerItem:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playMovieView removeFromSuperview];
    self.playMovieView = nil;
    self.totalTimeLabel = nil;
    



}
//接收上个界面传第的视频地址
-(void)setCurrentMovieUrl:(NSURL *)movieUrl{

    self.movieUrl = movieUrl;

}
#pragma mark - - 更新计时器
-(void)progressUpdate{

    long long currentTime = self.playMovieView.player.currentTime.value/self.playMovieView.player.currentTime.timescale;
    //更新进度条
    self.progressView.progress = currentTime*1.0/self.totalTime;
    //更新当前时间
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%lld:%02lld",currentTime/60,currentTime%60];



}
#pragma mark ---- 播放完成要实现的行为
-(void)replay{

    self.playAndPauseButton.selected = YES;
    [self.playMovieView.player seekToTime:CMTimeMake(0, 1)];

}
#pragma mark -- - 播放/暂停按钮
- (IBAction)playAndPauseButtonDidClicked:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    if (button.selected == NO) {
        //点击暂停,计时器停止检测
        [self.playMovieView.player pause];
        [self.timer setFireDate:[NSDate distantFuture]];
    }else{
        //点击播放,同时开启定时器检测
        [self.playMovieView.player play];
        [self.timer setFireDate:[NSDate distantPast]];
    }
    
    button.selected = !button.selected;
    
    
    
}

#pragma mark -- -- 保存按钮
- (IBAction)saveButtonDidClicked:(id)sender {
 
    //屏幕上没有添加图片,所有不需要保存
    NSArray *arr = [self.playMovieView subviews];
    if (arr.count<1) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    
    //保存效果
    if (self.movieUrl != nil) {
        AVAsset *asset = [AVAsset assetWithURL:self.movieUrl];
        if (!asset) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请先选择一个视频" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [alertView show];
            [self performSelector:@selector(dismissAlertViewDelay:) withObject:alertView afterDelay:2];
            return;
        }else{
        
            AVMutableComposition *mixComposition = [AVMutableComposition composition];
            
             //创建videoTrack
            AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] firstObject] atTime:kCMTimeZero error:nil];
            // 3.1 - Create AVMutableVideoCompositionInstruction
            AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero,asset.duration);
            // 3.2 - Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
            AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
            BOOL isVideoAssetPortrait_  = NO;
            CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
            
            if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
                videoAssetOrientation_ = UIImageOrientationRight;
                isVideoAssetPortrait_ = YES;
            }
            
            if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
                videoAssetOrientation_ =  UIImageOrientationLeft;
                isVideoAssetPortrait_ = YES;
            }
            
            if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
                videoAssetOrientation_ =  UIImageOrientationUp;
            }
            
            if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
                videoAssetOrientation_ = UIImageOrientationDown;
            }
            
            [videolayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
            [videolayerInstruction setOpacity:0.0 atTime:asset.duration];

            // 3.3 - Add instructions
            mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
            
            AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
            
            CGSize naturalSize;
            if(isVideoAssetPortrait_){
                naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
            } else {
                naturalSize = videoAssetTrack.naturalSize;
            }
            
            float renderWidth, renderHeight;
            renderWidth = naturalSize.width;
            renderHeight = naturalSize.height;
            mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
            mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
            mainCompositionInst.frameDuration = CMTimeMake(1, 30);
            
            //在layer层上添加特效
            [self applyVideoEffectsToComposition:mainCompositionInst size:naturalSize];
            
            //指定输出路径
            NSString *path = [[DataStore sharedDataStore] saveFileToData];
            NSURL *url = [NSURL fileURLWithPath:path];
        
            //插入到数据库
            [[DataStore sharedDataStore] insertUrl:path];
            
            //输出类
            AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
            exporter.outputURL = url;
            exporter.outputFileType = AVFileTypeQuickTimeMovie;
            exporter.shouldOptimizeForNetworkUse = YES;
            exporter.videoComposition = mainCompositionInst;
            
            [self.playMovieView.player pause];
            [MBProgressHUD showHUDAddedTo:self.playMovieView animated:YES];
            
           [exporter exportAsynchronouslyWithCompletionHandler:^{
                
               dispatch_async(dispatch_get_main_queue(), ^{
                   
                   //将链接传到上一界面,进行播放
                   //用block将视频保存的地址传到上个界面,同时推出当前页面
                   
                   if (self.returnUrlBlock != nil) {
                       
                       self.returnUrlBlock(path);
                       
                   }
   
                   [self dismissViewControllerAnimated:YES completion:nil];
                   
                  });
             }];
         }
}
   }

#pragma mark ---- 添加动画特效
- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size{
    
    //添加特效
    //
    NSArray *viewArr = [self.playMovieView subviews];
    if (viewArr && viewArr.count>0) {
        for (UIView *view in viewArr) {
            if ([view isKindOfClass:[XTPasterStageView class]]) {
                XTPasterStageView *paster = (XTPasterStageView *)view;
                
                //至多有一个
                 //layer1
                UIImage *animation = self.image;
                CALayer *overlayLayer1 = [CALayer layer];
                [overlayLayer1 setContents:(id)animation.CGImage];
                overlayLayer1.frame = CGRectMake(size.width/2-64-[UIScreen mainScreen].bounds.size.width/2+paster.pasterCurrent.center.x, size.height/2 + 249, 120, 120);
                [overlayLayer1 setMasksToBounds:YES];
                
                //layer2
                CALayer *overlayLayer2 = [CALayer layer];
                [overlayLayer2 setContents:(id)animation.CGImage];
                overlayLayer2.frame = CGRectMake(size.width/2-64-[UIScreen mainScreen].bounds.size.width/2+paster.pasterCurrent.center.x, size.height/2 - 249, 120, 120);
                [overlayLayer2 setMasksToBounds:YES];

            
                if (self.segmentControl.selectedSegmentIndex == 0) {
                    //fade
                    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
                    animation.duration = 3.0;
                    animation.repeatCount = 5;
                    animation.autoreverses = YES;
                    animation.fromValue = [NSNumber numberWithFloat:1.0];
                    animation.toValue = [NSNumber numberWithFloat:0.0];
                    animation.beginTime = AVCoreAnimationBeginTimeAtZero;
                    [overlayLayer1 addAnimation:animation forKey:@"animateOpacity"];
                    
                }else if(self.segmentControl.selectedSegmentIndex == 1){
                //twinkle
                    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                    animation.duration = 5;
                    animation.repeatCount = 10;
                    animation.autoreverses = YES;
                    // animate from half size to full size
                    animation.fromValue=[NSNumber numberWithFloat:0.5];
                    animation.toValue=[NSNumber numberWithFloat:1.0];
                    animation.beginTime = AVCoreAnimationBeginTimeAtZero;
                    [overlayLayer1 addAnimation:animation forKey:@"scale"];
                
                    animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                    animation.duration=1.0;
                    animation.repeatCount=5;
                    animation.autoreverses=YES;
                    // animate from half size to full size
                    animation.fromValue=[NSNumber numberWithFloat:0.5];
                    animation.toValue=[NSNumber numberWithFloat:1.0];
                    animation.beginTime = AVCoreAnimationBeginTimeAtZero;
                    [overlayLayer2 addAnimation:animation forKey:@"scale"];
                    
                }else if (self.segmentControl.selectedSegmentIndex == 2){
                
                   //rotate
                    CABasicAnimation *animation =
                    [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
                    animation.duration=2.0;
                    animation.repeatCount=5;
                    animation.autoreverses=YES;
                    // rotate from 0 to 360
                    animation.fromValue=[NSNumber numberWithFloat:0.0];
                    animation.toValue=[NSNumber numberWithFloat:(2.0 * M_PI)];
                    animation.beginTime = AVCoreAnimationBeginTimeAtZero;
                    [overlayLayer1 addAnimation:animation forKey:@"rotation"];
   
                    animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
                    animation.duration=2.0;
                    animation.repeatCount=5;
                    animation.autoreverses=YES;
                    // rotate from 0 to 360
                    animation.fromValue=[NSNumber numberWithFloat:0.0];
                    animation.toValue=[NSNumber numberWithFloat:(2.0 * M_PI)];
                    animation.beginTime = AVCoreAnimationBeginTimeAtZero;
                    [overlayLayer2 addAnimation:animation forKey:@"rotation"];
                    
                }
                
                CALayer *parentLayer = [CALayer layer];
                CALayer *videoLayer = [CALayer layer];
                parentLayer.frame = CGRectMake(0, 0,size.width, size.height);
                videoLayer.frame =CGRectMake(0, 0,size.width, size.height);
                [parentLayer addSublayer:videoLayer];
                [parentLayer addSublayer:overlayLayer1];
                [parentLayer addSublayer:overlayLayer2];
                
                composition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
                  }
        }
    }
    
    
    
    
}
-(void)dismissAlertViewDelay:(UIAlertView *)alertView{
    
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    //////////退出当前页面
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
#pragma mark -- - 返回按钮
- (IBAction)backButtonDidClicked:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否要放弃当前操作" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alertView show];
   
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
  
    if (buttonIndex == 0) {
         [self dismissViewControllerAnimated:YES completion:nil];
    }

}
-(void)addBottomView{

    NSDictionary *selectedTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor orangeColor]};
    [self.segmentControl setTitleTextAttributes:selectedTextAttributes forState:UIControlStateSelected];
    
    NSDictionary *unSelectedTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.segmentControl setTitleTextAttributes:unSelectedTextAttributes forState:UIControlStateNormal];
    
   


}
-(void)addCollectionView{

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(50, 50);
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(10, 10,10, 10);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bottomView.bounds collectionViewLayout:layout];
   // collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
     collectionView.bounces = NO;
    [self.bottomView addSubview:collectionView];

     //注册cell
    [collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:@"image"];


}
#pragma mark---- collectionView代理方法
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  
    return self.dataArr.count;

}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"image" forIndexPath:indexPath];
    NSString *imageName = [self.dataArr objectAtIndex:indexPath.item];
    cell.imageView.image = [UIImage imageNamed:imageName];
    
    return cell;


}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

       //点击贴纸,图画上出现一个贴纸
    if (self.paster != nil) {
        [self.paster removeFromSuperview];
        self.paster = nil;
        self.image = nil;
    }
        self.paster = [[XTPasterStageView alloc] initWithFrame:self.playMovieView.bounds];
        NSString *imageName = [self.dataArr objectAtIndex:indexPath.item];
        self.image = [UIImage imageNamed:imageName];
        [self.paster addPasterWithImg:self.image];
        [self.playMovieView addSubview:self.paster];
    
   
}
-(NSMutableArray *)dataArr{

    if (_dataArr == nil) {
        self.dataArr = [NSMutableArray arrayWithObjects:@"donghua_1.jpg",@"donghua_2.jpg",@"donghua_3.jpg",@"donghua_4.jpg",@"donghua_5.jpg",@"donghua_6.jpg",@"donghua_7.jpg",@"donghua_8.jpg",@"donghua_9.jpg",@"donghua_10.jpg",@"donghua_11.jpg",@"donghua_12.jpg",@"donghua_13.jpg",@"donghua_14.jpg", nil];
        
    }

    return _dataArr;

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
