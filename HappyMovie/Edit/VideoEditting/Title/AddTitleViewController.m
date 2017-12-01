//
//  AddTitleViewController.m
//  HappyMovie
//
//  Created by lanou3g on 16/1/22.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "AddTitleViewController.h"
#import "PlayMovieView.h"
#import "TextView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "HorizontalPicker.h"
@interface AddTitleViewController ()<HorizontalColorPickerDelegate,UIAlertViewDelegate>

@property(nonatomic,strong)NSURL *movieUrl;
@property (strong, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UIView *playBottomView;
@property (strong, nonatomic) IBOutlet UIButton *playAndPauseButton;

@property(nonatomic,strong)NSTimer *timer;//计时器
@property(nonatomic,assign)long long totalTime;
@property(nonatomic,strong)PlayMovieView *playMovieView;

@property (strong, nonatomic) IBOutlet HorizontalPicker *horizontalViewPicker;


@end

@implementation AddTitleViewController

- (void)viewDidLoad {
   
    [super viewDidLoad];
 
    //初始化播放界面
    self.playMovieView = [[PlayMovieView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-200)];
    self.playMovieView.backgroundColor = [UIColor grayColor];
    [self.playBottomView addSubview:self.playMovieView];
  
    //添加播放项目
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
    //设置颜色条的代理
    self.horizontalViewPicker.delegate = self;
    
}
-(void)dealloc{
    
    [self.timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playMovieView.player replaceCurrentItemWithPlayerItem:nil];
    self.playMovieView.player = nil;
    [self.playMovieView removeFromSuperview];
    self.playMovieView = nil;
   // self.horizontalViewPicker = nil;
    

}
#pragma mark -- - 播放完成之后
-(void)replay{

    self.playAndPauseButton.selected = YES;
    [self.playMovieView.player seekToTime:CMTimeMake(0, 1)];
    


}
#pragma mark - - -  计时器更新
-(void)progressUpdate{

 long long currentTime = self.playMovieView.player.currentTime.value/self.playMovieView.player.currentTime.timescale;
    //更新进度条
    self.progressView.progress = currentTime*1.0/self.totalTime;
    //更新当前时间
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%lld:%02lld",currentTime/60,currentTime%60];
 
}
#pragma mark - -  外部接口路径
-(void)setCurrentMovieUrl:(NSURL *)movieUrl{

    self.movieUrl = movieUrl;

}
#pragma mark - - 添加字幕点击按钮
- (IBAction)addSubtitleButtonDidClick:(id)sender {
   
    //点击添加字幕的按钮,添加字幕信息
    //添加textView
    TextView *textView = [[TextView alloc] initWithFrame:CGRectMake(50, 200, 200, 80)];
    textView.backgroundColor = [UIColor clearColor];
    [self.playMovieView addSubview:textView];

     //设置行为
    __weak typeof(textView)weakSelf = textView;

   
    
    //删除
     textView.block = ^{
   
         [weakSelf removeFromSuperview];
      
        
      };
    //平移
     textView.panBlock = ^(UIPanGestureRecognizer *pan){
     CGPoint point = [pan translationInView:self.playMovieView];
        weakSelf.center = CGPointMake(weakSelf.center.x+point.x, weakSelf.center.y+point.y);
        [pan setTranslation:CGPointMake(0, 0) inView:self.playMovieView];
        
    };
    //缩放
    textView.pinchBlock = ^(UIPanGestureRecognizer *pinch){
      
        CGPoint point = [pinch translationInView:self.playMovieView];
        
        weakSelf.frame = CGRectMake(weakSelf.frame.origin.x, weakSelf.frame.origin.y, weakSelf.frame.size.width+point.x, weakSelf.frame.size.height+point.y);
        
        [pinch setTranslation:CGPointMake(0, 0) inView:self.playMovieView];
     };
    
}
#pragma mark - - 暂停/播放按钮点击按钮
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
#pragma mark - - 返回按钮
- (IBAction)backButtonDidClicked:(id)sender {
  
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否要放弃当前操作" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alertView show];
   // [self dismissViewControllerAnimated:YES completion:nil];
  }

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex == 0) {
        //确定,退出当前界面,取消,留在当前界面,不进行任何操作
        [self dismissViewControllerAnimated:YES completion:nil];
        
     }

}
#pragma mark - - 保存按钮
- (IBAction)saveButtonDidClicked:(id)sender {
  
    NSArray *arr  =  [self.playMovieView subviews];
    if (arr.count<1) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    //点击保存时,可以检索playMovie的子实图
    //判断此时是否有视频
    if (self.movieUrl != nil) {
        AVAsset *asset = [AVAsset assetWithURL:self.movieUrl];
        if (!asset) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请先选择一个视频" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [alertView show];
            [self performSelector:@selector(dismissAlertView:) withObject:alertView afterDelay:2];
            return;
            
        }else{
            
            //将文字效果加入到当前视频中
            AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
            //videoTrack
            AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
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
           
            //添加效果文字
            CALayer *overlayLayer = [CALayer layer];
            overlayLayer.frame = CGRectMake(0, 0, naturalSize.width, naturalSize.height);
            [overlayLayer setMasksToBounds:YES];
            
            NSArray *textArray = [self.playMovieView subviews];
            for (UIView *view in textArray) {
                if ([view isKindOfClass:[TextView class]]) {
                    //创建多个layer文本层
                    //说明此时的父视图上添加的文字视图
                    TextView *textView = (TextView *)view;
                    //将他添加到视频中
                    //先判断text字符串的长度=-=======,>0才添加效果
                    CATextLayer *textLayer = [[CATextLayer alloc] init];
                    [textLayer setFont:@"Helvetica-Bold"];
                    textLayer.anchorPoint = CGPointMake(0, 0);
                    textLayer.position = CGPointMake((naturalSize.width-[UIScreen mainScreen].bounds.size.width)/2+textView.frame.origin.x, (naturalSize.height-[UIScreen mainScreen].bounds.size.height)/2+textView.frame.origin.y);
                    textLayer.bounds = CGRectMake(0, 0, textView.bounds.size.width,textView.bounds.size.height);
                  //  NSLog(@"=====%@",NSStringFromCGRect(textLayer.frame));
                    [textLayer setFontSize:30];
                    [textLayer setWrapped:YES];
                    //字体颜色可以在外面设置
                    [textLayer setString:textView.textView.text];
                    [textLayer setAlignmentMode:kCAAlignmentLeft];
                    [textLayer setForegroundColor:textView.textView.textColor.CGColor];
                    [textLayer setBackgroundColor:[UIColor clearColor].CGColor];
                    //添加到overLayer层上
                    [overlayLayer addSublayer:textLayer];
                     }
            }
           
            
            //父视图
            CALayer *parentLayer = [CALayer layer];
            CALayer *videoLayer = [CALayer layer];
            parentLayer.frame =CGRectMake(0, 0, naturalSize.width, naturalSize.height);
            videoLayer.frame = CGRectMake(0, 0, naturalSize.width, naturalSize.height);

            [parentLayer addSublayer:videoLayer];
            [parentLayer addSublayer:overlayLayer];
            
            mainCompositionInst.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
            
            //设置路径,进行输出

            NSString *path = [[DataStore sharedDataStore] saveFileToData];
            
            NSURL *url = [NSURL fileURLWithPath:path];
            
            //插入到数据库
            [[DataStore sharedDataStore] insertUrl:path];
                          
            //输出
            AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
            exporter.outputURL = url;
            exporter.outputFileType = AVFileTypeQuickTimeMovie;
            exporter.shouldOptimizeForNetworkUse = YES;
            exporter.videoComposition = mainCompositionInst;
            
            [self.playMovieView.player pause];
            [MBProgressHUD showHUDAddedTo:self.playMovieView animated:YES];
            
            [exporter exportAsynchronouslyWithCompletionHandler:^{
               
                dispatch_async(dispatch_get_main_queue(), ^{
                  
                    //写入完成,初始化一个加载progress,保存完成,进入下一界面进行播放
                   if (self.block!= nil) {
                      self.block(path);
                   }
                    
                  [self dismissViewControllerAnimated:YES completion:nil];
                    
                  [MBProgressHUD hideHUDForView:self.playMovieView animated:YES];
                    
                });
            }];
        }
    }
}

#pragma mark ---- 代理实现
-(void)colorPicked:(UIColor *)color{

  //  NSLog(@"-------%@",color);
    NSArray *titleArray = [self.playMovieView subviews];
    for (UIView *view in titleArray) {
        if ([view isKindOfClass:[TextView class]]) {
            TextView *textView = (TextView *)view;
            if ([textView.textView isFirstResponder]) {
                textView.textView.textColor = color;
                
            }
        }
    }


}

-(void)dismissAlertView:(UIAlertView *)alertView{

    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    /////////////////////////////////////////
     [self dismissViewControllerAnimated:YES completion:nil];

}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    //取消第一响应者的状态
    
    //点击保存时,可以检索playMovie的子实图
    NSArray *textArray = [self.playMovieView subviews];
    for (UIView *view in textArray) {
        if ([view isKindOfClass:[TextView class]]) {
            //说明此时的父视图上添加的文字视图
            TextView *textView = (TextView *)view;
            [textView.textView resignFirstResponder];
            
        }
    }


}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
