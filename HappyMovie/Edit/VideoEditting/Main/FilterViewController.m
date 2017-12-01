//
//  FilterViewController.m
//  HappyMovie
//
//  Created by lanou3g on 16/1/21.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "FilterViewController.h"
#import "ImageAndLabelScrollView.h"
#import "GPUImage.h"
@interface FilterViewController ()<ImageAndLabelScrollViewDelegate>

@property(nonatomic,strong)GPUImageMovie *movieFile;
@property(nonatomic,strong)GPUImageMovieWriter *movieWriter;
@property(nonatomic,strong)GPUImageOutput<GPUImageInput>*filter;
@property(nonatomic,strong)GPUImageView *filterView;
//存储滚动视图信息
@property(nonatomic,strong)NSMutableArray *bottomDataArr;
@property(nonatomic,strong)ImageAndLabelScrollView *bottomSelectedView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
//显示视图的底图
@property (strong, nonatomic) IBOutlet UIView *FilterBottomView;
@property (strong, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;
@property (strong, nonatomic) IBOutlet UIButton *playAndPauseButton;

//当前视频的播放地址
@property(nonatomic,strong)NSString *moviePath;
//保存滤镜对象
@property(nonatomic,strong)NSMutableArray *filterArray;
@property(nonatomic,strong)AVPlayer *player;
//计时器
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,assign)long long totalSeconds;

@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    //初始化选择框
    [self addBottomSelectedView];
    
    //获取要更改的视频文件地址
   // NSURL *url = [[NSBundle mainBundle] URLForResource:@"abc" withExtension:@"mp4"];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:self.moviePath]];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    
    self.movieFile = [[GPUImageMovie alloc] initWithPlayerItem:playerItem];
    self.movieFile.runBenchmark = YES;
    self.movieFile.playAtActualSpeed = YES;
    
    //添加滤镜
   // self.filter = [[GPUImageBrightnessFilter alloc] init];

    //添加显示view
    self.filterView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-200)];
    self.filterView.fillMode =  kGPUImageFillModePreserveAspectRatioAndFill;
    self.filterView.backgroundColor = [UIColor grayColor];
    //添加滤镜
    [self.FilterBottomView addSubview:self.filterView];
    //添加输出
    [self.movieFile addTarget:self.filterView];
  //  [self.filter addTarget:self.filterView];
    
    [self.movieFile startProcessing];
    [self.player play];
    
    //设置totalTimeLabel上的内容
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:self.moviePath]];
    self.totalSeconds = asset.duration.value/asset.duration.timescale;
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%lld:%02lld",self.totalSeconds/60,self.totalSeconds%60];
   //添加计时器,记录播放时间
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(progressUpdate) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    //注册播放完成的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replay) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
}
#pragma mark--- 播放完成执行的方法
-(void)replay{

    //按钮改变界面
    self.playAndPauseButton.selected = YES;
    //回到第一帧
    [self.player seekToTime:CMTimeMake(0, 1)];


}
-(void)setCurrentMoviePath:(NSString *)path{
   
    self.moviePath = path;

}
-(void)dealloc{
   
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.timer invalidate];
    self.timer = nil;
    [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
    [[GPUImageContext sharedFramebufferCache] purgeAllUnassignedFramebuffers];
    [self.bottomSelectedView removeFromSuperview];
    self.bottomSelectedView = nil;
    self.movieFile = nil;
    self.filter = nil;
    self.filterView = nil;
    self.player = nil;
    
}
#pragma mark -- - 更新计时器
-(void)progressUpdate{

   //更新进度条
    long long seconds = self.player.currentTime.value/self.player.currentTime.timescale;
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%lld:%02lld",seconds/60,seconds%60];
    self.progressBar.progress = seconds*1.0/self.totalSeconds;

}

#pragma mark - - - 保存视频按钮(将当前视频传到下一界面)
- (IBAction)saveMovieButtonDIdClicked:(id)sender {
    
   
    //添加保存按钮
    [self.movieFile cancelProcessing];
    [self.player pause];
    [self.player seekToTime:CMTimeMake(0, 1)];
    self.playAndPauseButton.selected = NO;
    [self.player play];
    [self.movieFile startProcessing];
    
    //判断是否添加了滤镜效果
    if (self.filter != nil) {
    //将当前视频传到上一界面,同时返回上一界面
        
    self.movieWriter = nil;
    NSString *videoPath = [[DataStore sharedDataStore] saveFileToData];
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:[NSURL fileURLWithPath:videoPath] size:CGSizeMake(640, 480) fileType:AVFileTypeQuickTimeMovie outputSettings:nil];
    [self.filter addTarget:self.movieWriter];
        
    self.movieWriter.shouldPassthroughAudio = YES;
    self.movieFile.audioEncodingTarget = self.movieWriter;
    [self.movieFile enableSynchronizedEncodingUsingMovieWriter:self.movieWriter];
    
    [self.movieWriter startRecording];
    
    //保存完成
       __weak typeof(self)weakSelf = self;
        [self.movieWriter setCompletionBlock:^{
        [weakSelf.filter removeTarget:weakSelf.movieWriter];
        [weakSelf.movieWriter finishRecording];
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
         UISaveVideoAtPathToSavedPhotosAlbum(videoPath, weakSelf, @selector(video:didFinishSavingWithError:contextInfo:), nil);
          
        });
        
    }];
        
    }

}
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{

    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"保存完成" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];


}

#pragma mark - - 返回按钮
- (IBAction)backButtonDidClicked:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -- - 播放/暂停按钮
- (IBAction)playAndPauseButtonDidClicked:(id)sender {
   
    UIButton *button = (UIButton *)sender;
    if (button.selected == NO) {
        //实现暂停的功能
        [self.player pause];
        
    }else{
       //实现播放的功能
        [self.player play];
    
    }
    
    button.selected = !button.selected;
    
}

#pragma mark - -- - 添加底部选择
-(void)addBottomSelectedView{

    self.bottomSelectedView = [[ImageAndLabelScrollView alloc] initWithFrame:self.bottomView.bounds dataArr:self.bottomDataArr distance:12];
    self.bottomSelectedView.buttonDelegate = self;
    self.bottomSelectedView.contentSize = CGSizeMake(40+(35+30)*self.bottomDataArr.count+200, self.bottomView.bounds.size.height);
    [self.bottomView addSubview:self.bottomSelectedView];


}
#pragma mark - -- 底部button点击方法的代理
-(void)imageAndLabelScrollViewButtonDidClick:(NSInteger)tag{
  
     //改变滤镜的对象
    //移除原来的滤镜对象
    [self.movieFile removeAllTargets];
    [self.filter removeAllTargets];
   // [self.movieFile endProcessing];
      self.filter = nil;
    [self.player seekToTime:CMTimeMake(0, 1)];
    
    if (tag == 0) {
        
        [self.movieFile addTarget:self.filterView];
       // [self.movieFile startProcessing];
        return;
     }
    
    //获取当前的滤镜对象
     self.filter = [self.filterArray objectAtIndex:tag];
    
     //加到当前的对象上
    [self.movieFile addTarget:self.filter];
    [self.filter addTarget:self.filterView];
   // [self.movieFile startProcessing];
}


-(NSMutableArray *)bottomDataArr{

    if (_bottomDataArr == nil) {
        self.bottomDataArr = [NSMutableArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"wulvjing.png",@"image",@"无滤镜",@"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"lizi_1.jpg",@"image",@"怀旧",@"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"lizi_2.jpg",@"image",@"黑白",@"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"lizi_3.jpg",@"image",@"素描",@"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"lizi_4.jpg",@"image",@"晕影",@"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"lizi_5.jpg",@"image",@"鱼眼",@"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"lizi_6.jpg",@"image",@"凹面镜",@"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"lizi_7.jpg",@"image",@"哈哈镜",@"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"lizi_8.jpg",@"image",@"水晶球",@"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"word_0.jpg",@"image",@"倒立",@"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"lizi_9.jpg",@"image",@"马赛克",@"name", nil], nil];
        
    }

    return _bottomDataArr;

}


-(NSMutableArray *)filterArray{
    if (_filterArray == nil) {
        
        GPUImageBrightnessFilter *brightFilter = [[GPUImageBrightnessFilter alloc] init];
        GPUImageSepiaFilter *sepiaFilter = [[GPUImageSepiaFilter alloc] init];
        //黑白
        GPUImageAverageLuminanceThresholdFilter *averageFilter = [[GPUImageAverageLuminanceThresholdFilter alloc] init];
        //素描
        GPUImageSketchFilter *sketchFilter = [[GPUImageSketchFilter alloc] init];
        //晕影
        GPUImageVignetteFilter *vignetteFilter = [[GPUImageVignetteFilter alloc] init];
        //鱼眼
        GPUImageBulgeDistortionFilter *bulgeFilter = [[GPUImageBulgeDistortionFilter alloc] init];
        //凹面镜
        GPUImagePinchDistortionFilter *pinchFilter = [[GPUImagePinchDistortionFilter alloc] init];
        //哈哈镜
        GPUImageStretchDistortionFilter *strenchFilter = [[GPUImageStretchDistortionFilter alloc] init];
        //水晶球
        GPUImageGlassSphereFilter *glassFilter = [[GPUImageGlassSphereFilter alloc] init];
        //倒立
        GPUImageSphereRefractionFilter *sphereFiter = [[GPUImageSphereRefractionFilter alloc] init];
        //马赛克
        GPUImagePixellatePositionFilter *moasicFilter = [[GPUImagePixellatePositionFilter alloc] init];
       
         self.filterArray = [NSMutableArray arrayWithObjects:brightFilter,sepiaFilter,averageFilter,sketchFilter,vignetteFilter,bulgeFilter,pinchFilter,strenchFilter,glassFilter,sphereFiter,moasicFilter,nil];
    }
    return _filterArray;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
