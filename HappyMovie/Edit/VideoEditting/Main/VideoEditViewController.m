//
//  VideoEditViewController.m
//  HappyMovie
//
//  Created by lanou3g on 16/1/19.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "VideoEditViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PlayMovieView.h"
#import "ImageAndLabelScrollView.h"
#import "FilterViewController.h"
#import "MontageVideoViewController.h"
#import "ReflectionViewController.h"
#import "AddTitleViewController.h"
#import "CutVideoViewController.h"
#import "AnnimationViewController.h"
#import "ExportEffects.h"
@interface VideoEditViewController ()<ImageAndLabelScrollViewDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *bottomSelectedView;

@property (strong, nonatomic) IBOutlet UIView *playView;//播放底图
//进度条
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
//添加滚动选择图
@property(nonatomic,strong)ImageAndLabelScrollView *bottomScrollView;
//播放当前时间label
@property (strong, nonatomic) IBOutlet UILabel *currentTimeLabel;
//当前视频总时间
@property (strong, nonatomic) IBOutlet UILabel *totalLabel;
//播放暂停按钮
@property (strong, nonatomic) IBOutlet UIButton *playButton;
//存储滚动视图信息
@property(nonatomic,strong)NSMutableArray *selectedArray;
//获取到的播放路径
@property(nonatomic,strong)NSString *playPath;
@property(nonatomic,strong)PlayMovieView *playMovieView;
//创建播放时的nstimer
@property(nonatomic,assign)long long seconds;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,assign)NSInteger time;
@end

@implementation VideoEditViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self prepareToPlay];
     self.playButton.selected = NO;
}

-(void)viewDidDisappear:(BOOL)animated
{
    
    [super viewDidDisappear:animated];

  //  self.playButton.selected = YES;
    [self.playMovieView removeFromSuperview];
    [self.playMovieView.player replaceCurrentItemWithPlayerItem:nil];
    self.playMovieView = nil;
    [self.timer invalidate];
    self.timer = nil;
    self.playMovieView.player = nil;
    
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.time = 0;
    //添加底部滚动图像
    [self addBottomScrollView];
  
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replay) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    

    
   }

#pragma mark --  播放配置
-(void)prepareToPlay{

    //设置播放图像
    self.playMovieView = [[PlayMovieView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 200)];
    self.playMovieView.backgroundColor = [UIColor blackColor];
    [self.playView addSubview:self.playMovieView];
    
    //设置播放项目
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"abc" ofType:@"mp4"];
    
    NSURL *url = [NSURL fileURLWithPath:self.playPath];
    
    self.seconds = [self.playMovieView loadVideoWithUrl:url];
    
   // NSLog(@"------%@",self.videoUrl);
    
    //设置播放项目的总时长
    self.totalLabel.text = [NSString stringWithFormat:@"%lld:%02lld",self.seconds/60,self.seconds%60];
    
    //创建一个NStimer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(progressUpdate) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];


}



-(void)dealloc{

    [self.playMovieView.player replaceCurrentItemWithPlayerItem:nil];
    [self.timer invalidate];
    self.timer = nil;
    self.playMovieView.player = nil;
    [self.playMovieView removeFromSuperview];
    self.playMovieView = nil;
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];



}

#pragma mark - - 定时器
-(void)progressUpdate{

    //获取当前的播放进度
    long long currentTime = self.playMovieView.player.currentTime.value/self.playMovieView.player.currentTime.timescale;
    self.progressView.progress = currentTime*1.0f/self.seconds;
    
    //设置时间更新
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%lld:%02lld",currentTime/60,currentTime%60];
}

#pragma mark --  播放完成之后的通知
-(void)replay{

    //将视频的播放进度重新置为0
    [self.playMovieView.player seekToTime:CMTimeMake(0, 1)];
    self.playButton.selected = YES;
    
    
}

#pragma mark - --  播放/暂停按钮
- (IBAction)playAndPauseButtonDidClicked:(id)sender {
    
    if (self.playButton.selected==NO) {//点击进行播放
      
        [self.playMovieView.player pause];
        
    }else{
    
        [self.playMovieView.player play];
    
    }
    
    self.playButton.selected = !self.playButton.selected;
    
}


#pragma mark - - 获取要播放的路径
-(void)setCurrentPath:(NSString *)path{
    self.playPath = path;
}

#pragma mark - - 推出的方法
- (IBAction)backbuttonDidClicked:(id)sender {
    
   [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - -  保存按钮
- (IBAction)saveButtonDidClicked:(id)sender {
    
    //先判断该文件是否保存过
       if (self.time == 1) {
           
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该视频已经保存过" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    [[ExportEffects sharedInstance] writeExportedVideoToAssetsLibrary:self.playPath];
    
    [ExportEffects sharedInstance].finishVideoBlock = ^(BOOL success,id result){
        if (success) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存相册成功" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [alertView show];
            self.time = 1;
            [self performSelector:@selector(dismissAlertView:) withObject:alertView afterDelay:2.0];
        }else{
        
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存相册失败" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [alertView show];
            [self performSelector:@selector(dismissAlertView:) withObject:alertView afterDelay:2.0];
        
        }
    
    };
    
}

-(void)dismissAlertView:(UIAlertView *)alertView{

    [alertView dismissWithClickedButtonIndex:0 animated:YES];

}
#pragma mark - - - scrollView的代理方法
-(void)imageAndLabelScrollViewButtonDidClick:(NSInteger)tag{
   
    [self.playMovieView.player pause];
     self.playButton.selected = YES;
    [self.playMovieView.player seekToTime:CMTimeMake(0, 1)];
   
         switch (tag) {
            case 0:{//视频拼接
          MontageVideoViewController *mVC = [[MontageVideoViewController alloc] init];
        
                [self addNavigationWithView:mVC];
                
                break;
            }
            case 1:{//视频倒影
            
                ReflectionViewController *rVC = [[ReflectionViewController alloc] init];
                [rVC setCurrentUrlWithUrl:[NSURL fileURLWithPath:self.playPath]];
                
                  [self addNavigationWithView:rVC];
                
                break;
            }
            case 2:{//视频修剪
                
                CutVideoViewController *cVC = [[CutVideoViewController alloc] init];
                cVC.videoUrl = [NSURL fileURLWithPath:self.playPath];
                cVC.finishBlock = ^(NSString *string){
                    
                    if (string == nil) {
                        
                        self.playPath = self.playPath;
                    }
                    else
                    {
                        self.playPath = string;
                    }
                };
                
                [self addNavigationWithView:cVC];
                
                break;
                
            }
            case 3:{//添加滤镜
               
                //点击出现滤镜的界面
                FilterViewController *filterVC = [[FilterViewController alloc] init];
                //传递电影路径
                [filterVC setCurrentMoviePath:self.playPath];
                [self presentViewController:filterVC animated:YES completion:nil];
                
                break;
            }
            case 4:{//添加字幕
                
                AddTitleViewController *aVC = [[AddTitleViewController alloc] init];
                
                [aVC setCurrentMovieUrl:[NSURL fileURLWithPath:self.playPath]];
                
                aVC.block = ^(NSString *url){
                
                    if (url == nil) {
                        self.playPath = self.playPath;
                    }
                    
                    else
                    {
                        self.playPath = url;
                    }
                };
                
                [self presentViewController:aVC animated:YES completion:nil];
                break;
            }
            case 5:{//添加动画
                
                AnnimationViewController *aVC = [[AnnimationViewController alloc] init];
                [aVC setCurrentMovieUrl:[NSURL fileURLWithPath:self.playPath]];
                aVC.returnUrlBlock = ^(NSString *url)
                {
                    if (url == nil) {
                        self.playPath = self.playPath;
                    }
                    
                    else
                    {
                        self.playPath = url;
                       // NSLog(@" ++++++++++++ %@",self.playPath);
                    }
                };
                [self presentViewController:aVC animated:YES completion:nil];
                
                break;
            }
            default:
                break;
        }
}


#pragma mark - - - 添加底部选择视图
-(void)addBottomScrollView{
    
//设置
    self.bottomScrollView = [[ImageAndLabelScrollView alloc] initWithFrame:self.bottomSelectedView.bounds dataArr:self.selectedArray distance:15];
    self.bottomScrollView.buttonDelegate = self;
//    self.bottomScrollView.alwaysBounceHorizontal = YES;
    self.bottomScrollView.contentSize = CGSizeMake(680 , self.bottomSelectedView.bounds.size.height);
    [self.bottomSelectedView addSubview:self.bottomScrollView];
    
}


- (NSMutableArray *)selectedArray{
    if (_selectedArray == nil) {
        self.selectedArray = [NSMutableArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"iconfont-shipinguanli.png",@"image",@"视频拼接",@"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"iconfont-daojishi.png",@"image",@"视频倒影",@"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"jiandao.png",@"image",@"视频修剪",@"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"iconfont-texiao.png",@"image",@"观看滤镜",@"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"zimu.jpg",@"image",@"添加字幕",@"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"iconfont-donghua.png",@"image",@"添加动画",@"name", nil], nil];
    }
    return _selectedArray;
}



#pragma mark 添加导航控制器 
-(void)addNavigationWithView:(UIViewController *)controller
{
    UINavigationController *nVC = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:nVC animated:YES completion:nil];
}


#pragma mark 更新self.playpath
-(void)updateItem
{

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
    
}


@end
