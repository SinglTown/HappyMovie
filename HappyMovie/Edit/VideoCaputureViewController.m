//
//  VideoCaputureViewController.m
//  HappyMovie
//
//  Created by lanou3g on 16/1/14.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "VideoCaputureViewController.h"
#import "GPUImage.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CameraSceneController.h"
#import "CreationViewController.h"



#define k_screenWidth [UIScreen mainScreen].bounds.size.width
#define k_screenHeight [UIScreen mainScreen].bounds.size.height
#define kBottomViewHeight 50
#define kVisualBottomViewHeight 80
#define kBottomScrollViewHeight 50
#define kTopViewHeight 50
@interface VideoCaputureViewController ()<CameraSceneControllerDelegate>
{
    GPUImageVideoCamera *_videoCamera;//摄像机
    GPUImageOutput<GPUImageInput>*_filter;//滤镜对象
    GPUImageMovieWriter *_movieWriter;//视频写入
   
    GPUImagePicture *_picture;
}
@end

@interface VideoCaputureViewController ()

@property(nonatomic,strong)GPUImageView *filterView1;//显示录像
@property(nonatomic,assign)BOOL isRecordingVideo;//判断是否在录制
@property(nonatomic,copy)NSString *moviePath;
@property (strong, nonatomic) IBOutlet UIVisualEffectView *visualEffectView;
@property(nonatomic,strong)UIView *bottomView;//底层选择视图

@property(nonatomic,strong)UIView *lineView;

@property(nonatomic,strong)UIScrollView *funnyBottomScrollView;//搞笑选择视图
@property(nonatomic,strong)UIScrollView *popularBottomScrollView;//普通选择视图
@property(nonatomic,strong)UIScrollView *viewInViewBottomScrollView;//画中画选择视图
//存储搞笑组滤镜效果名称,下同
@property(nonatomic,strong)NSMutableArray *funnyNameArr;
@property(nonatomic,strong)NSMutableArray *commonNameArr;
@property(nonatomic,strong)NSMutableArray *viewInViewNameArr;
@property (strong, nonatomic) IBOutlet UILabel *cameraNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *cameraButtom;
//记录当前正在显示的镜头名
@property(nonatomic,copy)NSString *currentCameraName;

//存储各组的滤镜对象,下同
@property(nonatomic,strong)NSMutableArray *funnyFilterArr;
@property(nonatomic,strong)NSMutableArray *commonFilterArr;
@property(nonatomic,strong)NSMutableArray *viewInViewFilterArr;
//定时器,记录录制时间
@property(nonatomic,strong)NSTimer *timer;
//视频录制时间label
@property(nonatomic,strong)UILabel *timeLabel;
@property(nonatomic,assign)int count;
@property(nonatomic,strong)UIImageView *selectBgView;
@property(nonatomic,assign)NSInteger selectBgIndex;
@property(nonatomic,assign)NSInteger captureVideoBgIndex;
//上次点击的搞笑镜头的下标,下同
@property(nonatomic,assign)NSInteger lastFunnyIndex;
@property(nonatomic,strong)UILabel *lastFunnyLabel;
@property(nonatomic,assign)NSInteger lastCommonIndex;
@property(nonatomic,strong)UILabel *lastCommonLabel;

@end




@implementation VideoCaputureViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    _selectBgIndex = -1;
    self.lastCommonIndex = -1;
    self.lastFunnyIndex = -1;
    
    //调用录像机,打开镜头
    //设置录像机的方向
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _videoCamera.horizontallyMirrorFrontFacingCamera = NO;
    _videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    //初始化滤镜效果
    _filter = [self.commonFilterArr objectAtIndex:0];
    [_videoCamera addTarget:_filter];
    
    //录像显示视图
    //设置视图的充满类型
    self.filterView1  = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 50, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-50-80)];
    [_filter addTarget:self.filterView1];
    [self.view addSubview:self.filterView1];
    [self.view bringSubviewToFront:self.visualEffectView];
    //检查是否有开启摄像头的权限
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    if (authStatus == ALAuthorizationStatusDenied || authStatus == ALAuthorizationStatusRestricted) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先获取摄像头使用权限" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        //调到指导指导页面
       // [self dismissViewControllerAnimated:YES completion:nil];
        
    }else{
        
        //开始打开摄像机镜头
        [_videoCamera startCameraCapture];
        
    }
    self.isRecordingVideo = NO;
    //初始化滚动滤镜选择视图的底层视图
    [self addBottomView];
    [self addBottomScrollView];
    [self addTimeLabel];
    self.currentCameraName = self.cameraNameLabel.text;
    
}
-(void)dealloc{
    
    [[GPUImageContext sharedFramebufferCache] purgeAllUnassignedFramebuffers];

}

#pragma mark -- 关闭按钮
- (IBAction)backButtonDidClicked:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - - 视频录制
- (IBAction)recordingVideoButtonDidClicked:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    if (self.isRecordingVideo==NO) {
     
        double delayToStartTime = 0.5;
        
        //点击视频录制按钮,开始录制视频
        dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, delayToStartTime*NSEC_PER_SEC);
        dispatch_after(startTime, dispatch_get_main_queue(), ^{
            
            //NSLog(@"开始录制视频");
            
            //记录录制视频时选取的图片是哪一张
          _captureVideoBgIndex = _selectBgIndex;
            _movieWriter = nil;
            //初始化文件路径和视频写入对象
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
           NSString *moviePath  = [path stringByAppendingPathComponent:@"movie.m4v"];
           unlink([moviePath UTF8String]);
             self.moviePath = moviePath;
            NSURL *movieURL = [NSURL fileURLWithPath:self.moviePath];
            //初始化视频写入类
            _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
              _movieWriter.encodingLiveVideo = YES;
             [_filter addTarget:_movieWriter];
            //开始录制
            _videoCamera.audioEncodingTarget = _movieWriter;
            [_movieWriter startRecording];
            
            //显示计时label
            self.timeLabel.hidden = NO;
            self.count = 0;
            //开始计时
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeCount) userInfo:nil repeats:YES];

            
        });

    }else{
        
      //  NSLog(@"停止录制视频");
        
        double delayInSeconds = 0.5;
        dispatch_time_t stopTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(stopTime, dispatch_get_main_queue(), ^{
            
            //结束录制视频
            [_filter removeTarget:_movieWriter];
            _videoCamera.audioEncodingTarget = nil;
            [_movieWriter finishRecording];
            //停止计时
            [self.timer invalidate];
          });
     }
  
    self.isRecordingVideo = !self.isRecordingVideo;
    button.selected = !button.selected;
    
}
#pragma mark -------- 摄像头转换按钮---------
- (IBAction)cameraChangeButtonDidClicked:(id)sender {
    if (_videoCamera.inputCamera.position == AVCaptureDevicePositionBack) {//此时使用的是后置摄像头
        //将_videocamera上的滤镜移除
        [_videoCamera stopCameraCapture];
        [_videoCamera removeTarget:_filter];
        [_filter removeTarget:_filterView1];
        _videoCamera = nil;
        _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
        _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        [_videoCamera addTarget:_filter];
        [_filter addTarget:_filterView1];
        [_videoCamera startCameraCapture];
    }else{
    
        //将_videocamera上的滤镜移除
        [_videoCamera stopCameraCapture];
        [_videoCamera removeTarget:_filter];
        [_filter removeTarget:_filterView1];
        _videoCamera = nil;
        _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
         _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        [_videoCamera addTarget:_filter];
        [_filter addTarget:_filterView1];
        [_videoCamera startCameraCapture];
    
    
    }
    
    
}

#pragma mark --- -- 视频保存按钮
- (IBAction)saveMovieButtonDidClicked:(id)sender {
  
    self.timeLabel.hidden = YES;
    
    //判断此时沙盒中是否有文件存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.moviePath]==NO) {
        //文件不存在,沙盒中没有保存的视频
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先进行视频拍摄" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
        
    }
  
    if (_captureVideoBgIndex != -1) {//录制视频的时候屏幕上有图片
        
        [self loadAssets];
        
    }else{
    
    UISaveVideoAtPathToSavedPhotosAlbum(self.moviePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
    
}
#pragma mark - - - 将图片加入视频文件中
-(void)loadAssets{
    
    if (self.moviePath == nil) {
        return;
    }

    //先加载视频
    AVAsset *videoAssets = [AVAsset assetWithURL:[NSURL fileURLWithPath:self.moviePath]];
   
    //加载完成进行输出
     // 2 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
     AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    //3.创建videoTrack
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,videoAssets.duration)
                        ofTrack:[[videoAssets tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                         atTime:kCMTimeZero error:nil];
    
    // 3.1 - Create AVMutableVideoCompositionInstruction
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero,videoAssets.duration);
    
     // 3.2 - Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
    AVAssetTrack *videoAssetTrack = [[videoAssets tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
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
    [videolayerInstruction setOpacity:0.0 atTime:videoAssets.duration];
    
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
    
    //添加特效
    [self applyVideoEffectsToComposition:mainCompositionInst size:naturalSize];
    
    // 4 - Get path
    NSString *myPathDocs = [self  getViewInViewTempPath];
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    
    if (url == nil) {
        return;
    }
    
    else
    {
        // 5 - Create exporter
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                          presetName:AVAssetExportPresetHighestQuality];
        exporter.outputURL = url;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.shouldOptimizeForNetworkUse = YES;
        exporter.videoComposition = mainCompositionInst;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self exportDidFinish:exporter];
            });
        }];
    }
}
#pragma mark - - 画中画效果视频的临时缓存路径
-(NSString *)getViewInViewTempPath{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [cachesDirectory stringByAppendingPathComponent:@"FinalVideo.mov"];
    unlink([myPathDocs UTF8String]);
    
    return myPathDocs;

}
- (void)exportDidFinish:(AVAssetExportSession*)session {
    
    if (session.status == AVAssetExportSessionStatusCompleted) {
        NSURL *outputURL = session.outputURL;
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
            [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
                                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        
                      //删除临时缓存文件
                        
                        NSString *path = [self getViewInViewTempPath];
                        
                        unlink([path UTF8String]);
                        
                    }
                });
            }];
        }
    }
}

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
{
    // 1 - set up the overlay
    CALayer *overlayLayer = [CALayer layer];
    UIImage *overlayImage = [UIImage imageNamed:[self.viewInViewFilterArr objectAtIndex:_captureVideoBgIndex]];
    
    [overlayLayer setContents:(id)[overlayImage CGImage]];
    overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [overlayLayer setMasksToBounds:YES];
    
    // 2 - set up the parent layer
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    
    // 3 - apply magic
    composition.animationTool = [AVVideoCompositionCoreAnimationTool
                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}
#pragma mark -- 视频保存回调方法
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    if (error == nil) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"视频成功保存到相册" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alertView show];
        //2秒后自动消失
        [self performSelector:@selector(removeAlertView:) withObject:alertView afterDelay:2];
       //删除文件
        unlink([self.moviePath UTF8String]);
    }else{
    
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"视频保存失败" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alertView show];
        //2秒后自动消失
        [self performSelector:@selector(removeAlertView:) withObject:alertView afterDelay:2];
      
    }
    
    
    
}
-(void)removeAlertView:(UIAlertView *)alertView{

 [alertView dismissWithClickedButtonIndex:0 animated:YES];


}
#pragma mark --  镜头选择按钮
- (IBAction)differentFilterChoiceButtonDidClicked:(id)sender {
    
    //可以选择不同的镜头,出现不同的效果
    //点击按钮,出现内容视图,结合视图
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 20;
    flowLayout.minimumInteritemSpacing = 30;
    flowLayout.itemSize = CGSizeMake(100, 100);
    flowLayout.sectionInset = UIEdgeInsetsMake(80, ([UIScreen mainScreen].bounds.size.width-200-30)/2,40, ([UIScreen mainScreen].bounds.size.width-200-30)/2);
    CameraSceneController *cameraSceneVC = [[CameraSceneController alloc] initWithCollectionViewLayout:flowLayout];
    //为它设置代理
    cameraSceneVC.delegate = self;
    //motal出镜头选择界面
    [self presentViewController:cameraSceneVC animated:YES completion:nil];

 }
#pragma mark - 实现cameraScene列表 控制器代理方法
-(void)cameraSceneSelected:(NSDictionary *)modelDic{


    
    [self.cameraButtom setBackgroundImage:[UIImage imageNamed:[modelDic objectForKey:@"image"]] forState:UIControlStateNormal];
    self.cameraNameLabel.text = [modelDic objectForKey:@"name"];
    //刷新滚动选择视图
    
    [self updateScrollView];

}
-(void)updateScrollView{

    if (self.bottomView.hidden == NO) {//正在显示
        //移除原来的view,添加新的view
        if ([self.cameraNameLabel.text isEqualToString:self.currentCameraName]) {
            return;
        }else{
            //移除原来的
            for (UIView *view in self.bottomView.subviews) {
                [view removeFromSuperview];
            }
            //三种情况
            if ([self.cameraNameLabel.text isEqualToString:@"搞笑镜头"]) {
               
                [self.bottomView addSubview:self.funnyBottomScrollView];//添加搞笑视图
               
                
            }
            
            if ([self.cameraNameLabel.text isEqualToString:@"画中画镜头"]) {
                [self.bottomView addSubview:self.viewInViewBottomScrollView];//添加画中画视图
                
            }
            if ([self.cameraNameLabel.text isEqualToString:@"普通镜头"]) {
                [self.bottomView addSubview:self.popularBottomScrollView];//添加普通视图
             
                
            }
            //更新当前的镜头名
            self.currentCameraName = self.cameraNameLabel.text;
           
            
        }
        
    }



}
#pragma mark - -  滤镜效果显示/隐藏按钮
- (IBAction)filterShowAndHiddenButtonDidClicked:(id)sender {
    
    if (self.bottomView.hidden) {//隐藏状态
        //执行显示的操作
        self.bottomView.hidden = NO;//显示
        
        //改变bottomView上的frame
        if ([self.cameraNameLabel.text isEqualToString:@"普通镜头"]) {
            //显示普通镜头
            [self.bottomView addSubview:self.popularBottomScrollView];
        }
        if([self.cameraNameLabel.text isEqualToString:@"搞笑镜头" ]){
            //显示搞笑滚动图
            [self.bottomView addSubview:self.funnyBottomScrollView];
            
        }
        if([self.cameraNameLabel.text isEqualToString:@"画中画镜头" ]){
            //显示画中画滚动图
            [self.bottomView addSubview:self.viewInViewBottomScrollView];
            
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.bottomView.frame = CGRectMake(0, k_screenHeight - kVisualBottomViewHeight-kBottomViewHeight,k_screenWidth,kBottomViewHeight);
            
            
            
        } completion:^(BOOL finished) {
            
            
        }];
        
        
    }else{//显示状态
        
        [UIView animateWithDuration:1 animations:^{
            
            self.bottomView.frame = CGRectMake(0, k_screenHeight - kVisualBottomViewHeight,k_screenWidth, kBottomViewHeight);
            
        } completion:^(BOOL finished) {
            
            self.bottomView.hidden = YES;//隐藏
            //移除所有视图
            for (UIView *view in self.bottomView.subviews) {
                [view removeFromSuperview];
            }
            
        }];
        
    }
    
    
    
    
}
#pragma mark - - 创建时间label
-(void)addTimeLabel{
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 50, 30)];
    self.timeLabel.center = CGPointMake(CGRectGetMidX(self.filterView1.frame), 20);
    self.timeLabel.backgroundColor = [UIColor clearColor];
    // self.timeLabel.text = @"00.00";
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.textColor = [UIColor redColor];
    self.timeLabel.hidden = YES;//开始隐藏
    [self.filterView1 addSubview:self.timeLabel];
    
}

#pragma mark - - 初始化滤镜效果选择的底层视图
-(void)addBottomView{

    //初始值
    //初始不显示
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, k_screenHeight - kVisualBottomViewHeight,k_screenWidth, kBottomViewHeight)];
    self.bottomView.backgroundColor = [UIColor yellowColor];
    
    self.bottomView.hidden = YES;//隐藏
    
    [self.view insertSubview:self.bottomView belowSubview:self.visualEffectView];

}
#pragma mark - -  初始化搞笑选择视图,不添加到父视图上
-(void)addBottomScrollView{

    //初始化搞笑滚动视图
    self.funnyBottomScrollView = [[UIScrollView alloc] initWithFrame:self.bottomView.bounds];
    self.funnyBottomScrollView.backgroundColor = [UIColor blackColor];
    self.funnyBottomScrollView.contentSize = CGSizeMake(20+60+70*self.funnyNameArr.count-70,kBottomScrollViewHeight);
    self.funnyBottomScrollView.showsHorizontalScrollIndicator = NO;
   // self.funnyBottomScrollView.buttonDelegate = self;
    [self addFunnyScrollSubview];
    
    //画中画效果滚动视图
    self.viewInViewBottomScrollView =[[UIScrollView alloc] initWithFrame:self.bottomView.bounds];
    self.viewInViewBottomScrollView.backgroundColor = [UIColor blackColor];
    self.viewInViewBottomScrollView.contentSize = CGSizeMake(110+65*self.viewInViewNameArr.count-65, kBottomScrollViewHeight);
    self.viewInViewBottomScrollView.showsHorizontalScrollIndicator = NO;
    [self addViewInViewScrollSubview];
    
    //普通效果
    self.popularBottomScrollView = [[UIScrollView alloc] initWithFrame:self.bottomView.bounds];
    self.popularBottomScrollView.backgroundColor = [UIColor blackColor];
    self.popularBottomScrollView.contentSize = CGSizeMake(20+60+70*self.commonNameArr.count-70, kBottomScrollViewHeight);
    self.popularBottomScrollView.showsHorizontalScrollIndicator = NO;
    [self addPopularScrollSubview];


}
#pragma mark - -- 初始化搞笑滚动子实图,
-(void)addFunnyScrollSubview{

    for (NSInteger i = 0; i<self.funnyNameArr.count; i++) {
        
        NSString *name = [self.funnyNameArr objectAtIndex:i];
        //在搞笑滚动图上添加子实图
        [self addFilterSelectedViewWithName:name count:i superView:self.funnyBottomScrollView];
    }
}

#pragma mark -- - 添加画中画滚动子实图
-(void)addViewInViewScrollSubview{

    //画中画选择视图
    
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
        imageView.image = [UIImage imageNamed:@"chahao.png"];
         imageView.userInteractionEnabled = YES;
          [self.viewInViewBottomScrollView addSubview:imageView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clean:)];
    [imageView addGestureRecognizer:tap];
    
    
    for (NSInteger i = 0; i<self.viewInViewNameArr.count; i++) {
        
        NSString *name = [self.viewInViewNameArr objectAtIndex:i];
        //在画中画滚动图上添加子实图
        [self addFilterSelectedViewWithImageName:name count:i superView:self.viewInViewBottomScrollView];
    }

    
    

}
-(void)clean:(UITapGestureRecognizer *)tap{

    [_selectBgView  removeFromSuperview];
    _selectBgView = nil;
    _selectBgIndex = -1;


}
#pragma mark - - 添加普通滚动视图的子实图
-(void)addPopularScrollSubview{

    //普通选择视图
    for (NSInteger i = 0; i<self.commonNameArr.count; i++) {
        
        NSString *name = [self.commonNameArr objectAtIndex:i];
        //在搞笑滚动图上添加子实图
        [self addFilterSelectedViewWithName:name count:i superView:self.popularBottomScrollView];
    }

}
#pragma mark - - 添加子实图的label
-(void)addFilterSelectedViewWithName:(NSString *)name count:(NSInteger)count superView:(UIView *)view{

    //label
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+(60+10)*count, 15, 60, 20)];
    nameLabel.text = name;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont systemFontOfSize:18];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.tag = count;
    nameLabel.userInteractionEnabled = YES;
    [view addSubview:nameLabel];
    //添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addFilter:)];
    [nameLabel addGestureRecognizer:tap];




}
#pragma mark -- - - 添加图像子实图
-(void)addFilterSelectedViewWithImageName:(NSString *)name count:(NSInteger)count superView:(UIView *)view{
   
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50+(50+15)*count, 5, 50, 50)];
    imageView.image = [UIImage imageNamed:name];
    imageView.userInteractionEnabled = YES;
    imageView.tag = count;
    [view addSubview:imageView];
    
    //添加点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addFilter:)];
    [imageView addGestureRecognizer:tap];


}
#pragma mark - - 点击,改变滤镜对象
-(void)addFilter:(UITapGestureRecognizer *)tap{

    UIView *imageView = (UIView *)tap.view;
    
    //判断当前显示的是那种效果图
    if ([self.cameraNameLabel.text isEqualToString:@"搞笑镜头"]) {
        
        UILabel *currentLabel = (UILabel *)imageView;
        if (imageView.tag == self.lastFunnyIndex) {
            return;
        }
        
        //改变搞笑滤镜效果
        self.lastFunnyLabel.textColor = [UIColor whiteColor];
        currentLabel.textColor = [UIColor greenColor];
        //获取滤镜对象
        [self changeFilterWithFilterArray:self.funnyFilterArr tag:imageView.tag];
        //更新
        self.lastFunnyIndex = imageView.tag;
        self.lastFunnyLabel = currentLabel;
        
    }else if ([self.cameraNameLabel.text isEqualToString:@"普通镜头"]){
        UILabel *currentLabel = (UILabel *)imageView;
        
        if (imageView.tag == self.lastCommonIndex) {
            return;
        }
        //改变普通滤镜效果
        self.lastCommonLabel.textColor = [UIColor whiteColor];
        currentLabel.textColor = [UIColor greenColor];
        [self changeFilterWithFilterArray:self.commonFilterArr tag:imageView.tag];
        //更新
        self.lastCommonIndex = imageView.tag;
        self.lastCommonLabel = currentLabel;
        
    }else if([self.cameraNameLabel.text isEqualToString:@"画中画镜头"]){
        
        //改变gpuimageView的frame和底层图片
     
        //不相同
        [_selectBgView  removeFromSuperview];
         _selectBgView = nil;
       //初始化imageView,将其添加到filterView上
       _selectBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, k_screenWidth, k_screenHeight-kBottomViewHeight-kTopViewHeight)];
        
      NSString *imageName = [self.viewInViewFilterArr objectAtIndex:imageView.tag];
        
        _selectBgIndex = imageView.tag;//记录此时屏幕上显示的那个图片,值在这改变
        _selectBgView.image = [UIImage imageNamed:imageName];
       [self.filterView1 insertSubview:_selectBgView belowSubview:self.timeLabel];
     
        //改变普通滤镜效果
    
        [_videoCamera removeTarget:_filter];
        [_filter removeTarget:self.filterView1];
        _filter = nil;
        //获取效果对象
    
        _filter = [[GPUImageBrightnessFilter alloc] init];
        [_videoCamera addTarget:_filter];
        [_filter addTarget:self.filterView1];

    
        
 }
 
}

#pragma mark ---- 改变滤镜效果
-(void)changeFilterWithFilterArray:(NSMutableArray *)filterArr tag:(NSInteger)tag{
    
    //改变普通滤镜效果
   // [_videoCamera stopCameraCapture];
    [_videoCamera removeTarget:_filter];
    [_filter removeTarget:self.filterView1];
    _filter = nil;
    //获取效果对象
   // [_videoCamera startCameraCapture];
    _filter = [filterArr objectAtIndex:tag];
    [_videoCamera addTarget:_filter];
    [_filter addTarget:self.filterView1];
    
}
#pragma mark - 计算时间的功能
-(void)timeCount{
    
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d",self.count/60,self.count%60];
    self.count++;
    
}
#pragma mark - -- 数组懒加载
-(NSMutableArray *)funnyNameArr{
    if (_funnyNameArr == nil) {
        self.funnyNameArr = [NSMutableArray arrayWithObjects:@"鱼眼",@"卡通",@"水晶球",@"哈哈镜",@"凹面镜",@"倒立",@"素描", nil];
    }
    return _funnyNameArr;


}
//-(NSMutableArray *)funnyNameArr{
//    if (_funnyNameArr == nil) {
//        self.funnyNameArr = [NSMutableArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"emoji1f001.png",@"image",@"鱼眼",@"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"emoji1f002.png",@"image",@"卡通",@"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"emoji1f004.png",@"image",@"水晶球",@"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"emoji1f005.png",@"image",@"哈哈镜",@"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"emoji1f006.png",@"image",@"凹面镜",@"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"emoji1f007.png",@"image",@"倒立",@"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"emoji1f0011.png",@"image",@"素描",@"name", nil], nil];
//    }
//
//    return _funnyNameArr;
//
//
//}
-(NSMutableArray *)commonNameArr{
    if (_commonNameArr == nil) {
        self.commonNameArr = [NSMutableArray arrayWithObjects:@"一般",@"怀旧",@"磨皮",@"黑白",@"晕影",@"虚化",@"马赛克", nil];
    }
    return _commonNameArr;


}

-(NSMutableArray *)commonFilterArr{
    if (_commonFilterArr == nil) {
        
        //正常效果
        GPUImageBrightnessFilter *normal = [[GPUImageBrightnessFilter alloc] init];
        //怀旧效果
        GPUImageSepiaFilter *sepialFilter = [[GPUImageSepiaFilter alloc] init];
        //磨皮效果
        GPUImageBilateralFilter *bilaFilter = [[GPUImageBilateralFilter alloc] init];
        //黑白效果
        GPUImageErosionFilter *erosionFilter = [[GPUImageErosionFilter alloc] init];
        //晕影效果
        GPUImageVignetteFilter *medianFilter = [[GPUImageVignetteFilter alloc] init];
        //马赛克效果
        GPUImagePixellatePositionFilter *pixelPositonFilter = [[GPUImagePixellatePositionFilter alloc] init];
        pixelPositonFilter.center = CGPointMake(0.3, 0.2);
        pixelPositonFilter.radius = 0.2;
        //背景虚化
        GPUImageTiltShiftFilter *tiltFilter = [[GPUImageTiltShiftFilter alloc] init];
        
        
        
        self.commonFilterArr = [NSMutableArray arrayWithObjects:normal,sepialFilter,bilaFilter,erosionFilter,medianFilter,tiltFilter,pixelPositonFilter,nil];
    }
    
    return _commonFilterArr;

}
-(NSMutableArray *)funnyFilterArr{
    
    if (_funnyFilterArr == nil) {
        
        //鱼眼效果
        GPUImageBulgeDistortionFilter *bugleFilter = [[GPUImageBulgeDistortionFilter alloc] init];
        //卡通效果
        GPUImageSmoothToonFilter *toonFilter = [[GPUImageSmoothToonFilter alloc] init];
        //水晶球效果
        GPUImageGlassSphereFilter *glassFilter = [[GPUImageGlassSphereFilter alloc] init];
        glassFilter.radius = 0.4;
        //哈哈镜效果
        GPUImageStretchDistortionFilter *strechFliter = [[GPUImageStretchDistortionFilter alloc] init];
        //凹面镜
        GPUImagePinchDistortionFilter *pinchFilter = [[GPUImagePinchDistortionFilter alloc] init];
        //倒立效果
        GPUImageSphereRefractionFilter *fractionFilter = [[GPUImageSphereRefractionFilter alloc] init];
        fractionFilter.radius=0.4;
        //素描效果
        GPUImageSketchFilter *sketchFilter = [[GPUImageSketchFilter alloc] init];
        
        
        self.funnyFilterArr = [NSMutableArray arrayWithObjects:bugleFilter,toonFilter,glassFilter,strechFliter,pinchFilter,fractionFilter,sketchFilter, nil];
    }
    
    return _funnyFilterArr;
    
}
-(NSMutableArray *)viewInViewNameArr{
    
    if (_viewInViewNameArr == nil) {
        self.viewInViewNameArr = [NSMutableArray arrayWithObjects:@"free_1Direction_thumb.jpg",@"free_belieber_thumb.jpg",@"free_burst_thumb.png",@"free_desk_thumb.png",@"free_doodle_thumb.png",@"free_drawn_thumb.png",@"free_gaga_thumb.png",@"free_sari_thumb.png",@"free_scrapbook_thumb.png",@"free_swifty_thumb.png",@"frame_cute_11.jpg",@"frame_WM_6.jpg",@"frame_WM_12.jpg",@"frame_WM_11.jpg",@"frame_draw_3.jpg",@"frame_draw_12.jpg",@"frame_draw_11.jpg", nil];
    }
    
    return _viewInViewNameArr;
    
}

-(NSMutableArray *)viewInViewFilterArr{

    if (_viewInViewFilterArr == nil) {
         self.viewInViewFilterArr = [NSMutableArray arrayWithObjects:@"free_1Direction_frame.jpg",@"free_belieber_frame.jpg",@"free_burst_frame.jpg",@"free_desk_frame.jpg",@"free_doodle_frame.jpg",@"free_drawn_frame.jpg",@"free_gaga_frame.jpg",@"free_sari_frame.jpg",@"free_scrapbook_frame.jpg",@"free_swifty_frame.jpg",@"frame_cute_11_34.png",@"frame_WM_6_34.png",@"frame_WM_12_34.png",@"frame_WM_11_34.png",@"frame_draw_3_34.png",@"frame_draw_12_34.png",@"frame_draw_11_34.png", nil];
    }

    return _viewInViewFilterArr;

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
