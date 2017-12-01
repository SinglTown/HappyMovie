

#import "ReflectionViewController.h"

#import "StepViewController.h"
#import "PBJVideoPlayerController.h"
#import <CoreMedia/CoreMedia.h>
#import "ScrollSelectView.h"
#import "StickerView.h"
#import "SRScreenRecorder.h"
#import "MIMovieVideoSampleAccessor.h"
#import "UIImage+Reflection.h"
#import "UIAlertView+Blocks.h"
#import "KGModal.h"
#import "CommonDefine.h"


@interface ReflectionViewController ()<PBJVideoPlayerControllerDelegate,StepViewControllerDelegate,ScrollSelectViewDelegate>

@property (nonatomic, strong) PBJVideoPlayerController *videoPlayerController1;
@property (nonatomic, strong) UIScrollView *captureContentView;
@property (nonatomic, strong) UIScrollView *videoContentView;
@property (nonatomic, strong) UIImageView *videoView1;
@property (nonatomic, strong) UIImageView *videoView2;
@property (nonatomic, strong) UILabel *videoReadyLabel;
@property (nonatomic, strong) UILabel *audioReadyLabel;
@property (nonatomic, strong) UIImageView *playButton1;
@property (nonatomic, strong) UIButton *closeVideoPlayerButton1;

@property (nonatomic, strong) UIScrollView *bottomControlView;
@property (nonatomic, strong) ScrollSelectView *borderView;
@property (nonatomic, strong) ScrollSelectView *gifScrollView;
@property (nonatomic, strong) UIImageView *borderImageView;//边框展示图片

@property (nonatomic, strong) NSMutableArray *gifArray;
@property (nonatomic, strong) MIMovieVideoSampleAccessor *sampleAccessor;
@property (nonatomic, assign) long long videoFileSize;
@property (nonatomic, assign) CMTime captureVideoSampleTime;

@property (nonatomic, strong) UIView *demoVideoContentView;
@property (nonatomic, strong) PBJVideoPlayerController *demoDestinationVideoPlayerController;
@property (nonatomic, strong) UIImageView *playDemoButton;

@property(nonatomic,strong)NSURL *videoBackgroundURL;




@end


@implementation ReflectionViewController
-(id)init{
    
    self = [super init];
    
    if (self)
    {
        [ScrollSelectView getDefaultFilelist];
    }
    return self;
    
    
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _captureVideoSampleTime = kCMTimeInvalid;
  //  _videoBackgroundURL = nil;
    _videoFileSize = 0;
    _gifArray = nil;
    
    //初始化view,相册 gif动画和边框 背景音乐 生成视频倒影
   // [self createSelectView];
    [self createNavigationBar];
    [self createNavigationItem];
    
    [self createSplit2View];
    [self createVideoPlayView];
  //  [self createLabelHint];
    
    [self createBottomControlView];
    [self createVideoBorderScrollView];
    [self createGifScrollView];
    
    //删除临时缓存文件
    [self deleteTempDirectory];
    
    //播放配置
    [self defaultVideoSetting:self.videoBackgroundURL];
    
}
-(void)setCurrentUrlWithUrl:(NSURL *)url{

    self.videoBackgroundURL = url;

}

-(void)deleteTempDirectory{
    
    NSString *dir = NSTemporaryDirectory();
    deleteFilesAt(dir, @"mov");
    
    
}
#pragma mark - -- 点击开始按钮实现的操作
-(void)showStep:(UIBarButtonItem *)sender{
    
    
    StepViewController * stepVC = [[StepViewController alloc] init];
    
    stepVC.delegate = self;
      
    [stepVC setCurrentVideoUrl:self.videoBackgroundURL];
    
    __weak typeof(self)weakSelf = self;
    
    stepVC.block = ^(NSURL *url){
        
        //选取的视频地址,进行播放
        [weakSelf defaultVideoSetting:url];
        weakSelf.videoBackgroundURL = url;
        
        
    };
    
  //  [self.navigationController pushViewController:stepVC animated:YES];
    [self presentViewController:stepVC animated:YES completion:nil];
    self.modalTransitionStyle = UIModalTransitionStylePartialCurl;
}

- (void)playDemoVideo:(NSString*)inputVideoPath withinVideoPlayerController:(PBJVideoPlayerController*)videoPlayerController
{
    videoPlayerController.videoPath = inputVideoPath;
    [videoPlayerController playFromBeginning];
}


#pragma mark - - - 播放配置
-(void)defaultVideoSetting:(NSURL *)url{
    
    [self playDemoVideo:[url absoluteString] withinVideoPlayerController:_videoPlayerController1];
    NSString *videoReadyHint = [NSString stringWithFormat:@"%@:%@", @"视频内容", @"就绪"];
    _videoReadyLabel.text = videoReadyHint;
    
    //显示出播放view
    [self showVideoPlayView:TRUE];
    
    UIImage *imageVideoFrame = getImageFromVideoFrame(url, kCMTimeZero);
    
    if (imageVideoFrame)
    {
        if (imageVideoFrame.size.width <= imageVideoFrame.size.height)
        {   //适应宽高
            [_videoView1 setContentMode:UIViewContentModeScaleAspectFit];
            [_videoView2 setContentMode:UIViewContentModeScaleAspectFit];
        }
        else
        {
            [_videoView1 setContentMode:UIViewContentModeScaleAspectFill];
            [_videoView2 setContentMode:UIViewContentModeScaleAspectFill];
        }
    }
    
}
- (void)showVideoPlayView:(BOOL)show
{
    if (show)
    {
        _videoContentView.hidden = NO;
        _closeVideoPlayerButton1.hidden = NO;
    }
    else//
    {
        if (_videoPlayerController1.playbackState == PBJVideoPlayerPlaybackStatePlaying)
        {
            [_videoPlayerController1 stop];
        }
        
        _videoContentView.hidden = YES;//隐藏
        _closeVideoPlayerButton1.hidden = YES;
    }
}
#pragma mark - PBJVideoPlayerControllerDelegate
- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer
{
    //NSLog(@"Max duration of the video: %f", videoPlayer.maxDuration);
}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
    
    
}

-(void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer{//播放刚完成
    
    // NSLog(@"播放刚完成");
    
    if (videoPlayer == _videoPlayerController1) {
        //显示
        _playButton1.alpha = 1.0f;
        _playButton1.hidden = NO;
        
        [UIView animateWithDuration:0.1f animations:^{
            _playButton1.alpha = 0.0f;
        } completion:^(BOOL finished)
         {
             _playButton1.hidden = YES;
         }];
        
    }else if(videoPlayer == _demoDestinationVideoPlayerController){
        //显示
        _playDemoButton.alpha = 1.0f;
        _playDemoButton.hidden = NO;
        
        [UIView animateWithDuration:0.1f animations:^{
            _playDemoButton.alpha = 0.0f;
        } completion:^(BOOL finished) {
            
            _playDemoButton.hidden = YES;
        }];
    }
}

-(void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer{
    
    if (videoPlayer == _videoPlayerController1) {
        
        _playButton1.hidden = NO;
        
        [UIView animateWithDuration:0.1f animations:^{
            
            _playButton1.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            
        }];
    }else if (videoPlayer == _demoDestinationVideoPlayerController){
        //显示button
        _playDemoButton.hidden = NO;
        [UIView animateWithDuration:0.1f animations:^{
            _playDemoButton.alpha = 1.0f;
        } completion:^(BOOL finished) {
            
        }];
        
    }
    
}
#pragma mark - - 点击边缘,实现的方法
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [super touchesBegan:touches withEvent:event];
    
    //取消
    [StickerView setActiveStickerView:nil];
    
    //隐藏底部栏
    [self hiddenBottomControlView];
    
    
}



-(void)hiddenBottomControlView{
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.bottomControlView.frame =  CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), 1);
                         self.borderView.frame = CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), 1);
                     } completion:^(BOOL finished) {
                         
                         [self.bottomControlView setHidden:YES];
                         [_borderView setHidden:YES];
                     }];
    
    
    
    
}
#pragma mark - stepViewController代理方法
#pragma mark - -展示动画的代理方法
-(void)stepViewControllerPickGifFromCustom{
    
    self.bottomControlView.contentOffset = CGPointMake(0, 0);
    [self showBottomControlView];
 
}


-(void)showBottomControlView{
    
    
    CGFloat height = 50;
    [_bottomControlView setHidden:NO];
    [_borderView setHidden:NO];//出现border上的内容
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.bottomControlView.frame =  CGRectMake(0, CGRectGetHeight(self.view.frame) - height, CGRectGetWidth(self.view.frame), height);
                         self.borderView.frame = CGRectMake(0, CGRectGetMinY(_bottomControlView.frame) - height, CGRectGetWidth(self.view.frame), height);
                     } completion:^(BOOL finished) {
                         
                     }];
}


#pragma mark ---- 点击gif和border实现的代理方法
-(void)didSelectedBorderIndex:(NSInteger)styleIndex{
    
    //  NSLog(@"didSelectedBorderIndex: %lu", (long)styleIndex);
    
    if (styleIndex == 0)
    {
        [_borderImageView setImage:nil];
        return;
    }
    
    
    NSString *imageName = [NSString stringWithFormat:@"border_%lu.png", (long)styleIndex];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    image = scaleImage(image, _borderImageView.bounds.size);
    [_borderImageView setImage:image];
}


-(void)didSelectedGifIndex:(NSInteger)styleIndex{
    [self initEmbededGifView:styleIndex];
}


-(void)initEmbededGifView:(NSInteger)styleIndex{
    
    NSString *imageName = [NSString stringWithFormat:@"gif_%lu.gif", (long)styleIndex];
    StickerView *view = [[StickerView alloc] initWithFilePath:getFilePath(imageName)];
    CGFloat ratio = MIN( (0.3 * self.videoContentView.width) / view.width, (0.3 * self.videoContentView.height) / view.height);
    [view setScale:ratio];
    CGFloat gap = 50;
    view.center = CGPointMake(self.videoContentView.width/2 - gap, self.videoContentView.height/2 - gap);
    [_captureContentView addSubview:view];
    
    [StickerView setActiveStickerView:view];
    
    //初始化gif动画数组
    if (!_gifArray)
    {
        _gifArray = [NSMutableArray arrayWithCapacity:1];
    }
    
    if (self.gifArray.count < 1) {
        return;
    }
    [_gifArray addObject:view];
    
    [view setDeleteFinishBlock:^(BOOL success, id result) {
        if (success)
        {
            if (_gifArray && [_gifArray count] > 0)
            {
                if ([_gifArray containsObject:result])
                {
                    [_gifArray removeObject:result];
                }
            }
        }
    }];
    
    [[SRScreenRecorder sharedInstance] setGifArray:_gifArray];
}



#pragma mark -- -- 添加背景音乐的代理方法
-(void)stepViewControllerPassSongInfo:(NSDictionary *)dic{
    
    //NSLog(@"********%@",dic);
    NSString *file = [dic objectForKey:@"url"];
    //  NSLog(@"=====%@",file);
    [[SRScreenRecorder sharedInstance] setAudioOutPath:file];
    
    NSString *audioReadyHint = [NSString stringWithFormat:@"%@:%@(%@)", @"音乐内容",@"就绪", [dic objectForKey:@"song"]];
    _audioReadyLabel.text = audioReadyHint;
    
}


#pragma mark - - - 合成视频的代理
-(void)stepViewControllerCompositionVideo{
    
    if (!_videoBackgroundURL) {
        NSString *message = @"选择一个背景视频";
        showAlertMessage(message, nil);
        return;
    }
    
    [self prepareBeforeScreenRecording];
    [self screenRecording];
}


-(void)prepareBeforeScreenRecording{
    
    [StickerView setActiveStickerView:nil];
    if (_gifArray && [_gifArray count]>0) {
        //处理gif动画
        for (StickerView *view in _gifArray) {
            
            [_captureContentView bringSubviewToFront:view];
            [view replayGif];
            
        }
    }
}

-(void)screenRecording{
    
    ProgressBarShowLoading(@"正在处理");
    
    [self showVideoPlayView:FALSE];
    
    //初始化播放sample
    [self initVideoSample:_videoBackgroundURL];
    _videoFileSize = fileSizeAtPath([_videoBackgroundURL relativePath]);
    
    
    [SRScreenRecorder sharedInstance].captureViewBlock = ^{
        
        return [self captureVideoView:_captureContentView];
    };
    

    [[SRScreenRecorder sharedInstance] setCaptureVideoSampleTimeBlock:^(void){
        return _captureVideoSampleTime;
    }];
    [[SRScreenRecorder sharedInstance] startRecording:_captureContentView.bounds.size];
    [[SRScreenRecorder sharedInstance] setExportProgressBlock:^(NSNumber *percentage){
        
        [self retrievingProgress:percentage title:@"保存视频"];
        
    }];
    
    [[SRScreenRecorder sharedInstance] setFinishRecordingBlock:^(BOOL success,id result){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success) {
                ProgressBarDismissLoading(@"成功");
            }else{
                ProgressBarDismissLoading(@"失败");
            }
            //alert
            [UIAlertView showWithTitle:nil message:result cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
                
                if (buttonIndex == [alertView cancelButtonIndex]) {
                    
                    [NSThread sleepForTimeInterval:0.5];
                    
                    //播放demo
                    NSString *outputPath = [SRScreenRecorder sharedInstance].filenameBlock();
                    [self showDemoVideo:outputPath];
                    
                }
            }];
            
            [self defaultImageSetting];
            [self showVideoPlayView:TRUE];
            
            
        });
        
    }];
}


#pragma mark - -展示Video
-(void)showDemoVideo:(NSString *)videoPath{
    //视频播放View
    CGFloat statusBarHeight = iOS7AddStatusHeight;
    CGFloat navHeight = CGRectGetHeight(self.navigationController.navigationBar.bounds);
    CGSize size = [self reCalcVideoViewSize:videoPath];
    _demoVideoContentView =  [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - size.width/2, CGRectGetMidY(self.view.frame) - size.height/2 - navHeight - statusBarHeight, size.width, size.height)];
    [self.view addSubview:_demoVideoContentView];
    //播放器
    _demoDestinationVideoPlayerController = [[PBJVideoPlayerController alloc] init];
    _demoDestinationVideoPlayerController.view.frame = _demoVideoContentView.bounds;
    _demoDestinationVideoPlayerController.view.clipsToBounds = YES;
    _demoDestinationVideoPlayerController.videoView.videoFillMode = AVLayerVideoGravityResizeAspect;
    _demoDestinationVideoPlayerController.delegate = self;
    
    [_demoVideoContentView addSubview:_demoDestinationVideoPlayerController.view];
    //播放按钮
    _playDemoButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play_button"]];
    _playDemoButton.center = _demoDestinationVideoPlayerController.view.center;
    [_demoDestinationVideoPlayerController.view addSubview:_playDemoButton];
    
    //motal出view
    [[KGModal sharedInstance] setCloseButtonType:KGModalCloseButtonTypeLeft];
    [[KGModal sharedInstance] showWithContentView:_demoVideoContentView andAnimated:YES];
    
    [self playDemoVideo:videoPath withinVideoPlayerController:_demoDestinationVideoPlayerController];
}

#pragma mark - reCalc on the basis of video size & view size
- (CGSize)reCalcVideoViewSize:(NSString *)videoPath
{
    CGSize resultSize = CGSizeZero;
    if (isStringEmpty(videoPath))
    {
        return resultSize;
    }
    
    UIImage *videoFrame = getImageFromVideoFrame(getFileURL(videoPath), kCMTimeZero);
    if (!videoFrame || videoFrame.size.height < 1 || videoFrame.size.width < 1)
    {
        return resultSize;
    }
    
  //  NSLog(@"reCalcVideoViewSize: %@, width: %f, height: %f", videoPath, videoFrame.size.width, videoFrame.size.height);
    
    CGFloat statusBarHeight = iOS7AddStatusHeight;
    CGFloat navHeight = CGRectGetHeight(self.navigationController.navigationBar.bounds);
    CGFloat gap = 10, bottomScrollViewHeight = 50;
    CGFloat height = CGRectGetHeight(self.view.frame) - navHeight - statusBarHeight - bottomScrollViewHeight - 2*gap;
    CGFloat width = CGRectGetWidth(self.view.frame) - 2*gap;
    if (height < width)
    {
        width = height;
    }
    else if (height > width)
    {
        height = width;
    }
    CGFloat videoHeight = videoFrame.size.height, videoWidth = videoFrame.size.width;
    CGFloat scaleRatio = videoHeight/videoWidth;
    CGFloat resultHeight = 0, resultWidth = 0;
    if (videoHeight <= height && videoWidth <= width)
    {
        resultHeight = videoHeight;
        resultWidth = videoWidth;
    }
    else if (videoHeight <= height && videoWidth > width)
    {
        resultWidth = width;
        resultHeight = height*scaleRatio;
    }
    else if (videoHeight > height && videoWidth <= width)
    {
        resultHeight = height;
        resultWidth = width/scaleRatio;
    }
    else
    {
        if (videoHeight < videoWidth)
        {
            resultWidth = width;
            resultHeight = height*scaleRatio;
        }
        else if (videoHeight == videoWidth)
        {
            resultWidth = width;
            resultHeight = height;
        }
        else
        {
            resultHeight = height;
            resultWidth = width/scaleRatio;
        }
    }
    
    resultSize = CGSizeMake(resultWidth, resultHeight);
    return resultSize;
}

#pragma mark - -- pregress callback
-(void)retrievingProgress:(id)progress title:(NSString *)text
{
    if (progress && [progress isKindOfClass:[NSNumber class]])
    {
        NSString *title = text ?text :@"SavingVideo";
        NSString *currentPrecentage = [NSString stringWithFormat:@"%d%%", (int)([progress floatValue] * 100)];
        ProgressBarUpdateLoading(title, currentPrecentage);
    }
}

-(UIImage *)captureVideoView:(UIView *)view{
    
    if (![self captureVideoSample]) {
        return nil;
        
    }
    
    return [self captureView:view];
    
}

-(UIImage *)captureView:(UIView *)view{
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    UIImage *screenshot = nil;
    
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, scale);
    {
        if(UIGraphicsGetCurrentContext() == nil)
        {
          //  NSLog(@"UIGraphicsGetCurrentContext is nil. You may have a UIView (%@) with no really frame (%@)", [self class], NSStringFromCGRect(view.frame));
        }
        else
        {
            [view.layer renderInContext:UIGraphicsGetCurrentContext()];
            
            screenshot = UIGraphicsGetImageFromCurrentImageContext();
        }
    }
    UIGraphicsEndImageContext();
    
    return screenshot;
    
    
    
}
-(BOOL)captureVideoSample{
    
    MICMSampleBuffer *buffer = [_sampleAccessor nextSampleBuffer];
    if (!buffer)
    {
        _captureVideoSampleTime = kCMTimeInvalid;
        [[SRScreenRecorder sharedInstance] stopRecording];
        return FALSE;
    }
    //show percentage
    CGFloat currentSeconds = _sampleAccessor.currentTime.value / _sampleAccessor.currentTime.timescale;
    CGFloat totalSeconds = _sampleAccessor.assetDuration.value / _sampleAccessor.assetDuration.timescale;
    NSString *currentPrecentage = [NSString stringWithFormat:@"%d%%", (int)(currentSeconds/totalSeconds * 100)];
    ProgressBarUpdateLoading(@"Processing", currentPrecentage);
    
    //获取帧图片
    CMSampleBufferRef sampleBuffer = buffer.CMSampleBuffer;
    _captureVideoSampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    UIImage *uiImage = imageFromSampleBuffer(sampleBuffer);
    
    if (uiImage.size.width != uiImage.size.height && _videoFileSize >= 3*(1024.0*1024.0))
    {
        _videoView1.image = imageFixOrientation(squareImageFromImage(uiImage));
    }
    else
    {
        _videoView1.image = imageFixOrientation(uiImage);
    }
    
    _videoView1.image = [self captureViewHalfTop:_captureContentView];
    _videoView2.image = [_videoView1.image reflectionWithAlpha:0.5];
    
    uiImage = nil;
    
    return TRUE;
    
}
-(UIImage *)captureViewHalfTop:(UIView *)view{
    
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    UIImage *screenshot = nil;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds)/2), NO, scale);
    {
        if (UIGraphicsGetCurrentContext()== nil) {
            
            //NSLog(@"UIGraphicsGetCurrentContext is nil. You may have a UIView (%@) with no really frame (%@)", [self class], NSStringFromCGRect(view.frame));
            
        }else{
            
            [view.layer renderInContext:UIGraphicsGetCurrentContext()];
            screenshot = UIGraphicsGetImageFromCurrentImageContext();
        }
        
    }
    
    UIGraphicsEndImageContext();
    
    return screenshot;
    
    
    
    
    
}
- (void)initVideoSample:(NSURL *)videoURL{
    
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    _sampleAccessor = [[MIMovieVideoSampleAccessor alloc]
                       initWithMovie:videoAsset firstSampleTime:kCMTimeZero tracks:nil videoSettings:nil videoComposition:nil];
    
    
}

#pragma mark -- - viewDidLoad中的方法
-(void)createSplit2View{
    
    CGFloat statusBarHeight = iOS7AddStatusHeight;
    CGFloat navHeight = CGRectGetHeight(self.navigationController.navigationBar.bounds);
    CGFloat gap = 20, len = MIN(((CGRectGetHeight(self.view.frame) - navHeight - statusBarHeight - 2*gap)/2), (CGRectGetWidth(self.view.frame) - navHeight - statusBarHeight - 2*gap));
    self.captureContentView =  [[UIScrollView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - len/2, CGRectGetMidY(self.view.frame) - len - gap/2, len, 2*len)];
    [self.captureContentView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_captureContentView];
    
    //videoView2
    _videoView1 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_captureContentView.bounds), CGRectGetMinY(_captureContentView.bounds), len, len)];
    [_videoView1 setBackgroundColor:[UIColor clearColor]];
    [_videoView1 setContentMode:UIViewContentModeScaleAspectFit];
    [_captureContentView addSubview:_videoView1];
    
    //videoView1
    _videoView2 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_videoView1.bounds), CGRectGetMidY(_captureContentView.bounds), len, len)];
    [_videoView2 setBackgroundColor:[UIColor clearColor]];
    [_videoView2 setContentMode:UIViewContentModeScaleAspectFit];
    [_captureContentView addSubview:_videoView2];
    
    
    [self defaultImageSetting];
    
    
}
-(void)defaultImageSetting{
    
    _videoView1.image = nil;
    _videoView2.image = nil;
    
    
}
-(void)createVideoPlayView{
    
    _videoContentView =  [[UIScrollView alloc] initWithFrame:_captureContentView.bounds];
    [_videoContentView setBackgroundColor:[UIColor clearColor]];
    [_captureContentView addSubview:_videoContentView];
    
    // Video player 1
    _videoPlayerController1 = [[PBJVideoPlayerController alloc] init];
    _videoPlayerController1.delegate = self;
    _videoPlayerController1.view.frame = _videoView1.bounds;
    _videoPlayerController1.view.clipsToBounds = YES;
    [self addChildViewController:_videoPlayerController1];
    [_videoContentView addSubview:_videoPlayerController1.view];
    //播放按钮
    _playButton1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play_button@2x.png"]];
    _playButton1.center = _videoPlayerController1.view.center;
    [_videoPlayerController1.view addSubview:_playButton1];
    //关闭播放器
    UIImage *imageClose = [UIImage imageNamed:@"close.png"];
    CGFloat width = 50;
    _closeVideoPlayerButton1 = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(_videoContentView.frame) - width/2, CGRectGetMinY(_videoContentView.frame) - width/2, width, width)];
    _closeVideoPlayerButton1.center = _captureContentView.frame.origin;
    [_closeVideoPlayerButton1 setImage:imageClose forState:UIControlStateNormal];
    [_closeVideoPlayerButton1 addTarget:self action:@selector(handleCloseVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeVideoPlayerButton1];
    _closeVideoPlayerButton1.hidden = YES;
    
    //border
    _borderImageView = [[UIImageView alloc] initWithFrame:_videoPlayerController1.view.frame];
    [_borderImageView setBackgroundColor:[UIColor clearColor]];
    [_captureContentView addSubview:_borderImageView];
    
    
}
- (void)handleCloseVideo
{
    //NSLog(@"handleCloseVideo");
    
    [self showVideoPlayView:FALSE];
    //    [self hiddenBottomControlView];
    //
    //    self.videoBackgroundPickURL = nil;
    //    self.videoEmbededPickURL = nil;
    //    [self.borderImageView setImage:nil];
    //
    //    [self clearEmbeddedGifArray];
    //    [self clearEmbeddedVideoArray];
    //    [self clearEmbeddedVideoImageViewArray];
    
//    NSString *videoReadyHint = [NSString stringWithFormat:@"%@:%@", @"视频内容", @"未就绪"];
//    _videoReadyLabel.text = videoReadyHint;
}

//-(void)createLabelHint{
//    
//    CGFloat gap = 5, heightLabel = 18;
//    
//    if (!LargeScreen)
//    {
//        gap = 0;
//    }

//    _videoReadyLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_captureContentView.frame),64, CGRectGetWidth(self.view.frame) - CGRectGetMinX(_captureContentView.frame), heightLabel)];
//    //颜色
//    // _videoReadyLabel.backgroundColor = [UIColor redColor];
//    _videoReadyLabel.textColor = kBrightBlue;
//    _videoReadyLabel.textAlignment = NSTextAlignmentLeft;
//    _videoReadyLabel.numberOfLines = 0;
//    _videoReadyLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    [self.view addSubview:_videoReadyLabel];
    
//    _audioReadyLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_captureContentView.frame),64, CGRectGetWidth(self.view.frame) - CGRectGetMinX(_captureContentView.frame), heightLabel)];
//    _audioReadyLabel.backgroundColor = [UIColor clearColor];
//    _audioReadyLabel.textColor = [UIColor whiteColor];
//    _audioReadyLabel.textAlignment = NSTextAlignmentLeft;
//    _audioReadyLabel.numberOfLines = 0;
//    //_audioReadyLabel.backgroundColor = [UIColor yellowColor];
//    _audioReadyLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    NSString *audioReadyHint = [NSString stringWithFormat:@"%@:%@", @"音频内容", @"未就绪"];
//    _audioReadyLabel.text = audioReadyHint;
//    
//    [self.view addSubview:_audioReadyLabel];
    
//    NSString *videoReadyHint = [NSString stringWithFormat:@"%@:%@",@"视频内容", @"未就绪"];
   // _videoReadyLabel.text = videoReadyHint;

    
//}
//-(void)createSelectView{
//    
//  //初始化view
//    self.selectView = [[UIView alloc] initWithFrame:CGRectMake(0, 200, kScreenWidth, 300)];
//    self.selectView.backgroundColor = [UIColor yellowColor];
//   [self.view addSubview:self.selectView];
//    //添加子实图
//    
//    
//}
-(void)createNavigationBar{
    
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    
//    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil]];
    [[UINavigationBar appearance] setTranslucent:YES];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    self.title = @"视频倒影";


}


-(void)createNavigationItem{
    
    //UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(showStep:)];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"iconfont-shenglvehao.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(showStep:)];
    [rightItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //返回
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"chahao.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backButton)];

   
    
}

#pragma mark 返回
-(void)backButton
{
  
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)createBottomControlView{
    
    CGFloat height = 50;
    CGFloat navHeight = CGRectGetHeight(self.navigationController.navigationBar.bounds);
    self.bottomControlView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - navHeight - iOS7AddStatusHeight - height, CGRectGetWidth(self.view.frame), height)];
    
    [self.view addSubview:_bottomControlView];
    
    [self.bottomControlView setContentSize:CGSizeMake(CGRectGetWidth(self.bottomControlView.frame) * 2, CGRectGetHeight(self.bottomControlView.frame))];
    [self.bottomControlView setPagingEnabled:YES];
    [self.bottomControlView setScrollEnabled:NO];
    [_bottomControlView setHidden:YES];//初始隐藏
    
    
    
}

-(void)createVideoBorderScrollView{
    
    
    CGFloat height = 50;
    _borderView = [[ScrollSelectView alloc] initWithFrameFromBorder:CGRectMake(0, CGRectGetMinY(self.bottomControlView.frame) - height, CGRectGetWidth(self.bottomControlView.frame), CGRectGetHeight(self.bottomControlView.frame))];
    [_borderView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
    _borderView.delegateSelect = self;
    [self.view addSubview:_borderView];
    [self createFrameLine:_borderView];
    [_borderView setHidden:YES];
    
}
- (void)createFrameLine:(UIView *)view
{
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(view.bounds), CGRectGetMaxY(view.bounds) - 0.5, CGRectGetWidth(view.bounds), 1)];
    [lineView setBackgroundColor:[UIColor orangeColor]];
    [view addSubview:lineView];
}
-(void)createGifScrollView{
    
    _gifScrollView = [[ScrollSelectView alloc] initWithFrameFromGif:CGRectMake(0, 0, CGRectGetWidth(self.bottomControlView.frame), CGRectGetHeight(self.bottomControlView.frame))];
    [_gifScrollView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
    _gifScrollView.delegateSelect = self;
    [_bottomControlView addSubview:_gifScrollView];
    
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
