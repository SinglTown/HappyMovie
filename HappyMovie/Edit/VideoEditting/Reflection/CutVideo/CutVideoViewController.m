//
//  CutVideoViewController.m
//  HappyMovie
//
//  Created by lanou3g on 16/1/23.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "CutVideoViewController.h"
#import "SAVideoRangeSlider.h"
#import "PlayMovieView.h"
#import "ExportEffects.h"
@interface CutVideoViewController ()<SAVideoRangeSliderDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *movieView;

@property (strong, nonatomic) IBOutlet UIView *sliderView;

@property (strong, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) IBOutlet UILabel *startLB;
@property (strong, nonatomic) IBOutlet UILabel *endingLabel;
@property (strong, nonatomic) IBOutlet UIButton *playButton;

@property (nonatomic,strong) PlayMovieView *playMovieView;
@property (strong, nonatomic) SAVideoRangeSlider *mySAVideoRangeSlider;

@property (strong, nonatomic) AVAssetExportSession *exportSession;
@property (strong, nonatomic) NSString *originalVideoPath;
@property (strong, nonatomic) NSString *tmpVideoPath;
@property (nonatomic) CGFloat startTime;
@property (nonatomic) CGFloat stopTime;

@property(nonatomic,assign)long long seconds;

@end

@implementation CutVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"视频剪辑";
    NSDictionary *dic = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.navigationController.navigationBar setTitleTextAttributes:dic];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"chahao.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"baocun.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    
    if (self.videoUrl == nil) {
        return;
    }
    
    else
    {
        [self addMovieWindowFromUrl:self.videoUrl];
    }
    
    

        
         [self loadEditView];


    
}
#pragma mark 添加剪辑的视图
-(void)loadEditView
{
    
    
    NSString *tmpPath = [[DataStore sharedDataStore] saveFileToData];
    self.tmpVideoPath = tmpPath;
    NSURL *originalUrl = self.videoUrl;
       
    self.mySAVideoRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(0, self.sliderView.bounds.origin.y + 40, kScreenWidth , 40) videoUrl:originalUrl];
    
    [self.mySAVideoRangeSlider setPopoverBubbleSize:200 height:80];
    self.mySAVideoRangeSlider.bubleText.textColor = [UIColor whiteColor];
    
    self.mySAVideoRangeSlider.topBorder.backgroundColor = [UIColor colorWithRed: 0.768 green: 0.665 blue: 0.853 alpha: 1];
    self.mySAVideoRangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed: 0.535 green: 0.329 blue: 0.707 alpha: 1];
    
    self.mySAVideoRangeSlider.delegate = self;
    [self.sliderView addSubview:self.mySAVideoRangeSlider];
    
}


- (IBAction)playVideoButtonDidClickAction:(id)sender {
    
    
    [self deleteTmpFile];
    
    NSURL *videoFileUrl = self.videoUrl;
    
    AVAsset *anAsset = [[AVURLAsset alloc] initWithURL:videoFileUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:anAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        
        self.exportSession = [[AVAssetExportSession alloc]
                              initWithAsset:anAsset presetName:AVAssetExportPresetPassthrough];
        
        
        NSURL *furl = [NSURL fileURLWithPath:self.tmpVideoPath];
     //   NSLog(@"furl ====== %@",furl);
        
        if (furl == nil) {
            return;
        }
        
        else
        {
        self.exportSession.outputURL = furl;
        self.exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        
        CMTime start = CMTimeMakeWithSeconds(self.startTime, anAsset.duration.timescale);
        CMTime duration = CMTimeMakeWithSeconds(self.stopTime-self.startTime, anAsset.duration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        self.exportSession.timeRange = range;
        
        [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([self.exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                  //  NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                   // NSLog(@"Export canceled");
                    break;
                default:
                   // NSLog(@"NONE");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self addMovieWindowFromUrl:[NSURL fileURLWithPath:self.tmpVideoPath]];
                    });
                    
                    break;
            }
        }];
    }
  }
}


#pragma mark 返回
-(void)back
{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否要放弃当前操作" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alertView show];
   
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
  //确定
    if (buttonIndex == 0) {
         [self dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark 保存
-(void)save
{
    
    NSURL *url = [NSURL fileURLWithPath:self.tmpVideoPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exist = [fm fileExistsAtPath:url.path];
  
    if (!exist) {
        //文件不存在的情况下
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先进行播放" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
      __weak typeof (self) weakSelf = self;
    //将文件路径传回
    weakSelf.finishBlock(weakSelf.tmpVideoPath);
    //插入数据到数据库
    [[DataStore sharedDataStore] insertUrl:self.tmpVideoPath];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 删除缓存文件
-(void)deleteTmpFile
{
    NSURL *url = [NSURL fileURLWithPath:self.tmpVideoPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exist = [fm fileExistsAtPath:url.path];
    NSError *err = nil;
    if (exist) {
        [fm removeItemAtURL:url error:&err];
      //  NSLog(@"文件删除");
    }
    
    if (err) {
       // NSLog(@"文件删除失败 %@",err);
    }
    
    else
    {
        //NSLog(@"没有要删除的文件");
    }
}



#pragma mark - SAVideoRangeSliderDelegate
- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition
{
    self.startTime = leftPosition;
    self.stopTime = rightPosition;
    self.startLB.text = [NSString stringWithFormat:@"开始时间:%.2f", leftPosition];
    self.endingLabel.text = [NSString stringWithFormat:@"结束时间:%.2f",rightPosition];
}


#pragma mark 加载视频
-(void)addMovieWindowFromUrl:(NSURL *)url{
    
    //设置播放图像
    self.playMovieView = [[PlayMovieView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.movieView.bounds.size.height)];
    
    self.playMovieView.backgroundColor = [UIColor blackColor];
    [self.movieView addSubview:self.playMovieView];
    self.seconds = [self.playMovieView loadVideoWithUrl:url];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
