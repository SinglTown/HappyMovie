

#import "PhotoMVViewController.h"
#import "CollectionViewCell.h"
#import "LineLayout.h"
#import "PassMergeHandle.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MusicViewController.h"
#import "ZYQAssetPickerController.h"
#import <QuartzCore/QuartzCore.h>
#import "SliderSwitch.h"
#import "MBProgressHUD.h"

#import "ReleaseViewController.h"
#import "ZYQAssetViewController.h"
#import "GPUImage.h"
typedef void(^FINISH)(BOOL isFinish,NSString *path);
@interface PhotoMVViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate, ZYQAssetPickerControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,SliderSwitchDelegate>
{
//    UIButton *btn;
    
    UIScrollView *src;
    
    UIPageControl *pageControl;
}


@property (strong, nonatomic) IBOutlet UILabel *saveL;

@property (strong, nonatomic) IBOutlet UILabel *addMusicL;

@property(nonatomic,assign)NSInteger myrow;
@property (strong, nonatomic) IBOutlet UIView *durationTimeView;
@property(nonatomic,strong) SliderSwitch *slideSwitchH,*slideSwitchV;

@property (strong, nonatomic) IBOutlet UIView *musicView;

@property(nonatomic,assign)BOOL isSave;
@property(nonatomic,strong)AVPlayer*musicPlayer;
@property(nonatomic,strong)UIView *endView;
@property(nonatomic,assign)int currentIdx;
@property(nonatomic,strong)AVPlayer *player;
@property(nonatomic,strong)AVPlayer *player2;
@property(nonatomic,strong)NSString*theVideoPath2;
@property(nonatomic,strong)NSTimer * timer;

@property(nonatomic,strong)NSMutableArray *themeArr;

@property(nonatomic,assign)int urlIdx;
@property(nonatomic,strong)CALayer * playerLayer;
@property(nonatomic,strong)CALayer * playerLayer1;
@property (strong, nonatomic) IBOutlet UIView *moviePlayerView;

@property (strong, nonatomic) IBOutlet UIProgressView *playProgressView;

@property (strong, nonatomic) IBOutlet UISegmentedControl *themeSegment;

@property (strong, nonatomic) IBOutlet UICollectionView *themeCollectionView;

@property (strong, nonatomic) IBOutlet UIButton *playerButton;

@property (strong, nonatomic) IBOutlet UILabel *currentTimeLabel;

@property (strong, nonatomic) IBOutlet UILabel *totalTime;

@property (strong, nonatomic) IBOutlet UIButton *zoomButton;


@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;


@property (strong, nonatomic) IBOutlet UIBarButtonItem *gobackButton;
//存草稿按钮
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveDraftItem;

//发布按钮
@property (strong, nonatomic) IBOutlet UIBarButtonItem *issueItem;

@property (strong, nonatomic) IBOutlet UISegmentedControl *littleSegmentControl;


@property(nonatomic,strong)CollectionViewCell *costomCell;

@property (strong, nonatomic) IBOutlet UIPickerView *musicPicker;



@property (strong, nonatomic) IBOutlet UIImageView *myimageView;

@property(nonatomic,assign)NSInteger flag;



@property (strong, nonatomic) IBOutlet UIButton *songButton;
@property (strong, nonatomic) IBOutlet UIView *songView;

@property (strong, nonatomic) IBOutlet UIImageView *songImageView;
@property(nonatomic,strong)NSTimer* avtimer;

@property(nonatomic,strong)NSMutableArray *imageArr;
@property(nonatomic,copy)NSString *theVideoPath;
@property(nonatomic,strong)NSMutableArray *audioMixParams;
@property(nonatomic,strong)NSURL *mixURL;
@property(nonatomic,strong)NSURL *theEndVideoURL;
@property(nonatomic,assign)BOOL isChangeSpeed;
@property(nonatomic,strong)NSString*outputFilePath;




@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIView *durationSeg;
@property(nonatomic,strong)  ZYQAssetViewController * zyq;

@property (nonatomic, retain) GPUImageMovie *movieFile1;
@property (nonatomic, strong) GPUImageMovie *movieFile2;
@property (nonatomic, strong)GPUImageMovieWriter*movieWriter;
@property (nonatomic, retain) id filter;
@property(nonatomic,copy)FINISH finishBlock;


@property (strong, nonatomic) IBOutlet UILabel *remindL;

@end

@implementation PhotoMVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
  
//    NSArray * arr =   [string  componentsSeparatedByString:@"/"];
  
    [PassMergeHandle sharedHandle].zyqblock = ^(ZYQAssetViewController*zyq){
        _zyq =  zyq;
         self.delegate = (id)_zyq ;
    };


//    NSLog(@"++%@",_zyq);
//   _zyq = [[ZYQAssetViewController alloc]init]
    
    [self.themeSegment setTitle:@"特效" forSegmentAtIndex:0];
    [self.themeSegment setTitle:@"音乐" forSegmentAtIndex:1];
    [self.themeSegment setTitle:@"时长" forSegmentAtIndex:2];
    
  
    
   self.themeSegment.tintColor = [UIColor clearColor];//去掉颜色,现在整个segment都看不见
    NSDictionary* selectedTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:16],
                                             NSForegroundColorAttributeName: [UIColor redColor]};
    [self.themeSegment setTitleTextAttributes:selectedTextAttributes forState:UIControlStateSelected];//设置文字属性
    NSDictionary* unselectedTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:16],
                                               NSForegroundColorAttributeName: [UIColor lightTextColor]};
    [self.themeSegment setTitleTextAttributes:unselectedTextAttributes forState:UIControlStateNormal];
    
    self.themeSegment.selectedSegmentIndex = 1;
        
    [self.themeSegment  addTarget: self  action:@selector(segmentControlAction:)  forControlEvents:UIControlEventValueChanged ];
    
    self.littleSegmentControl.selectedSegmentIndex = 1;
    
   
    
   
    LineLayout * layout = [[LineLayout alloc]init];

    [self.themeCollectionView setCollectionViewLayout:layout animated:YES];
   
    
    
    [self.themeCollectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"CollectionViewCell"];
    
    self.themeCollectionView.dataSource =self;
  self.themeCollectionView.delegate =self;
    
    
    
    self.themeCollectionView.backgroundColor  = [UIColor clearColor];
    
    self.playProgressView.progress = 0.0;
     self.themeCollectionView.tintColor=[UIColor clearColor];
     self.themeCollectionView.hidden =YES;
    
    [self costomSongName];
    
    [self musicPickerlayout];
    [self durationTimeViewLayout];
}
-(void)viewDidAppear:(BOOL)animated{
    
    if ( [[PassMergeHandle sharedHandle].imageArray count]!= 0) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"图片准备完毕,请添加特效" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alertView show];
        //2秒后自动消失
        [self performSelector:@selector(removeTheAlert:) withObject:alertView afterDelay:2];
        
        
    }
    
    
}
-(void)removeTheAlert:(UIAlertView *)alertView{
   
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    
}
-(void)dealloc{

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.avtimer invalidate];
    self.avtimer = nil;


}
-(void)durationTimeViewLayout{
    
    
    _slideSwitchH=[[SliderSwitch alloc]init];
    
    [_slideSwitchH setFrameHorizontal:(CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width  -100, 40)) numberOfFields:3 withCornerRadius:4.0];
    //240/3=80
    //width of each option is 80 (It should not be a fractional value)
    _slideSwitchH.delegate = self;
    [_slideSwitchH setFrameBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:0.3]];
    [_slideSwitchH setSwitchFrameColor:[UIColor whiteColor]];
    
    [_slideSwitchH setTextColor:[UIColor grayColor]];
    
    [_slideSwitchH setText:@"Slower" forTextIndex:(NSInteger *)1];
    [_slideSwitchH setText:@"Normal" forTextIndex:(NSInteger *)2];
    [_slideSwitchH setText:@"Faster" forTextIndex:(NSInteger *)3];
    [_slideSwitchH setSwitchBorderWidth:6.0];
    
    self.durationTimeView.layer.cornerRadius = 60;
    self.durationTimeView.clipsToBounds = YES;
    self.durationTimeView.layer.cornerRadius = 25;
    self.durationTimeView.clipsToBounds = YES;
    self.durationTimeView.hidden = YES;
    [self.durationSeg addSubview:_slideSwitchH];

        
}



- (IBAction)releaseAction:(id)sender {
    
    if (self.isSave == NO || [PassMergeHandle sharedHandle].imageArray.count == 0 ) {
 UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@" 提示:未编辑完成还不能分享" message:nil preferredStyle:UIAlertControllerStyleAlert];
        

 
         UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"继续制作" style:UIAlertActionStyleCancel handler:nil];
         [alertVC addAction:cancelAction];
     
        
        [self presentViewController:alertVC animated:YES completion:nil];

        
    }
    
    
    
    
    else{
        ReleaseViewController *releaseVC = [[ReleaseViewController alloc]init];
        
        UINavigationController * nc = [[UINavigationController alloc]initWithRootViewController:releaseVC];
        [self presentViewController:nc animated:YES completion:nil];
  
    }
    
}
- (IBAction)photoalbumButton:(id)sender {
    [self removeTimer];
    ZYQAssetPickerController * phontMV = [[ZYQAssetPickerController alloc]init];
    
    [self presentViewController:phontMV animated:YES completion:nil];
}


-(void)slideView:(SliderSwitch *)slideswitch switchChangedAtIndex:(NSUInteger)index
{
    if ([self.delegate respondsToSelector:@selector(changeSpeed)]== 0) {
        return;
    }
    
    if (slideswitch == _slideSwitchH) {
          
        if (index==0 && self.isChangeSpeed == YES) {
            
            self.remindL.text = @"设置完成后,请重新添加特效进行播放";
            self.durationTimeView.backgroundColor=[UIColor colorWithRed:97/255.0 green:47/255.0 blue:18/255.0 alpha:1];
           
    [PassMergeHandle sharedHandle].speed = 3;
            
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            if ([self.delegate respondsToSelector:@selector(changeSpeed)]) {
                [self.delegate changeSpeed];
                
            }
            
        }
        else
            if (index==1) {
                  self.remindL.text = @"设置完成后,请继续添加效果";
                [PassMergeHandle sharedHandle].speed = 5;
                 [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                self.durationTimeView.backgroundColor=[UIColor colorWithRed:12/255.0 green:37/255.0 blue:34/255.0 alpha:1];
                
                
                if ([self.delegate respondsToSelector:@selector(changeSpeed)]) {
                    
                    [self.delegate changeSpeed];
                    
                }


                
            }
            else
                if (index==2) {
                    
                 
                      self.remindL.text = @"设置完成后,请继续添加效果";
                    self.durationTimeView.backgroundColor=[UIColor colorWithRed:20/255.0 green:45/255.0 blue:97/255.0 alpha:1];
                    [PassMergeHandle sharedHandle].speed = 10;
                     [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    
                    if ([self.delegate respondsToSelector:@selector(changeSpeed)]) {
                        
                        [self.delegate changeSpeed];
                        
                    }

                }
        
    }
    
   __weak typeof (self)welf = self;
    [PassMergeHandle sharedHandle].gotoChangeSpeed = ^(){
        
        self.remindL.text = nil;
        
        [MBProgressHUD hideHUDForView:welf.view animated:YES];
  
    };
    
}


-(void)musicPickerlayout{
    
    self.musicPicker.showsSelectionIndicator = YES;
    //    默认显示的行和列
    [self.musicPicker selectRow:0 inComponent:0 animated:YES];
    
    self.musicPicker.delegate = self;
    self.musicPicker.dataSource = self;
//    self.musicPicker.frame =  CGRectMake(0, 11, 100, 25);
     [self.songView addSubview:self.musicPicker];
}
//pickerView总列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    
    return 1;
    
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
   
    
    return  [PassMergeHandle sharedHandle].ownMusicArr.count;
   

}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{ UILabel *label =
    
    
    [[UILabel alloc] init];
    label.text = [[PassMergeHandle sharedHandle].ownMusicArr[row] allKeys][0];
    label.textColor = [UIColor greenColor];
    
    
    
    return label;





}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
   
    if (self.player.currentItem.duration.value ==0  ) {
        
        
        [self removeTimer];
        
        [self makeAvtimer];
        [self playAction];
        self.myrow = row;
        [self playMusicWithRor:row];
        
        
    }else if(self.player.currentItem.duration.value /self.player.currentItem.duration.timescale- self.player.currentItem.currentTime.value/self.player.currentItem.currentTime.timescale > 2.5){
        
        [self removeTimer];
        
        [self makeAvtimer];
        [self playAction];
        self.myrow = row;
        [self playMusicWithRor:row];
        
    }else{
        
        return;
    }

   
   
    
}
-(void)playMusicWithRor:(NSInteger)row{

    
    AVPlayerItem *item1 = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"%ld",(long)row+1] ofType:@"m4a"]]];
        
     [PassMergeHandle sharedHandle].musicUrlString =    [[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"%ld",(long)row+1] ofType:@"m4a"];

     self.musicPlayer = [AVPlayer playerWithPlayerItem:item1];

    
    [self.musicPlayer play];

    
}






-(void)costomSongName{
    self.musicView.layer.cornerRadius = 60;
    self.musicView.clipsToBounds = YES;
    self.songView.layer.cornerRadius = 25;
    self.songView.clipsToBounds = YES;
  
    [self moreMusicButton];
    
    UILabel * songLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 11, 100, 25)];
   
    songLabel.textColor = [UIColor whiteColor];
    
    songLabel.text = @"sadfsadfasdf";
    
    [self syntheticButtonLayout];
    

    
}

-(void)moreMusicButton{
   self.saveButton.layer.cornerRadius =12;
     self.saveButton.clipsToBounds = YES;
  

    
//    
//    [self.saveButton  setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    self.saveButton.titleLabel.font = [UIFont systemFontOfSize:12];
    //self.saveButton.font = [UIFont systemFontOfSize:12];
    [self.saveButton setTitle:@"保存" forState:UIControlStateNormal];

}

- (IBAction)saveButtonAction:(id)sender {
   
    if (self.isSave&& [PassMergeHandle sharedHandle].imageArray.count != 0 ) {
      
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.saveL.text = nil;
        });
        
        
        if (self.outputFilePath != nil  ) {
            
            
            
            UISaveVideoAtPathToSavedPhotosAlbum(self.outputFilePath,self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            
        }
        
        
 
    }else{
        
        self.saveL.text  = @"请先合成MV再进行此操作";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.saveL.text = nil;
        });
 
    }
 }


-(void)removeAlertView:(UIAlertView *)alertView{
    
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    
    
}

-(void)syntheticButtonLayout{
    
    UIButton * songButton  = [[UIButton alloc]initWithFrame:CGRectMake(8,12, 26, 26)];
    
    [songButton addTarget:self action:@selector(synthetic:) forControlEvents:UIControlEventTouchUpInside];
    
    songButton.titleLabel.font = [UIFont systemFontOfSize:12];
   // songButton.font = [UIFont systemFontOfSize:12];
    [songButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [songButton setTitle:@"合成" forState:UIControlStateNormal];
    
  [songButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    
//    [songButton setBackgroundImage:[UIImage imageNamed:@"16383_011346251_2.jpg"] forState:UIControlStateNormal];
    songButton.backgroundColor = [UIColor clearColor];
    songButton.layer.cornerRadius = 12;
    songButton.clipsToBounds = YES;
    
    [self.songView addSubview:songButton];
    
}

-(void)buttionShoudClick:(UIButton *)sender{
    

//    sender.userInteractionEnabled = YES;
    
}
-(void)synthetic:(UIButton*)sender{
    
    
    sender.userInteractionEnabled = NO;

//    [self performSelector:@selector(buttionShoudClick:) withObject:nil afterDelay:1.0f];
    
    
    if ([PassMergeHandle sharedHandle].pathString == nil ||[PassMergeHandle sharedHandle].imageArray.count == 0 ) {
         self.addMusicL.text = @"请您先选择图片";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.addMusicL.text = nil;
            sender.userInteractionEnabled = YES;
        });
  
        return;
    }
    
    self.addMusicL.text = @"音乐已编入视频";
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       self.addMusicL.text = nil;
        sender.userInteractionEnabled = YES;
        
    });
    
    [self removeTimer];
     self.theVideoPath=[PassMergeHandle sharedHandle].pathString;
        
        //抽取原视频的音频与需要的音乐混合
        //录制的视频
        AVMutableComposition *composition =[AVMutableComposition composition];
        self.audioMixParams =[NSMutableArray array];
        //视频路径
  
        NSURL *video_inputFileUrl =[NSURL fileURLWithPath:self.theVideoPath];
        
        AVURLAsset *songAsset =[AVURLAsset URLAssetWithURL:video_inputFileUrl options:nil];
        
        CMTime startTime =CMTimeMakeWithSeconds(0,songAsset.duration.timescale);
        CMTime trackDuration = songAsset.duration;
    
        
        //获取视频中的音频素材
        if (startTime.value != 0) {
            [self setUpAndAddAudioAtPath:video_inputFileUrl toComposition:composition start:startTime dura:trackDuration offset:CMTimeMake(14*44100,44100)];
        }
        
        //本地要插入的音乐
//        NSString *bundleDirectory =[[NSBundle mainBundle] bundlePath];
    
    NSString *path = [PassMergeHandle sharedHandle].musicUrlString;
     NSURL *assetURL2 =[NSURL fileURLWithPath:path];
        
        //获取设置完的本地音乐素材
        [self setUpAndAddAudioAtPath:assetURL2 toComposition:composition start:startTime dura:trackDuration offset:CMTimeMake(0*44100,44100)];
    
        //创建一个可变的音频混合
        AVMutableAudioMix *audioMix =[AVMutableAudioMix audioMix];
        audioMix.inputParameters =[NSArray arrayWithArray:self.audioMixParams];//从数组里取出处理后的音频轨道参数
        
        //创建一个输出
        AVAssetExportSession *exporter =[[AVAssetExportSession alloc]
                                         initWithAsset:composition presetName:AVAssetExportPresetAppleM4A];
    
        exporter.audioMix = audioMix;
        exporter.outputFileType = @"com.apple.m4a-audio";
        NSString* fileName =[NSString stringWithFormat:@"%@.mov",@"overMix"];
        //输出路径
        NSString *exportFile =[NSString stringWithFormat:@"%@/%@",[self getLibarayPath], fileName];
    
        
        
        if([[NSFileManager defaultManager]fileExistsAtPath:exportFile]) {
            
            [[NSFileManager defaultManager]removeItemAtPath:exportFile error:nil];//如果存在删除文件
            
        }
        
              
        NSURL *exportURL =[NSURL fileURLWithPath:exportFile];
        exporter.outputURL = exportURL;
    
    //输出地址
        self.mixURL = exportURL;
//    NSLog(@"++%@",self.mixURL);
    
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            
            int exportStatus =(int)exporter.status;//输出状态
            
            switch (exportStatus){
                case AVAssetExportSessionStatusFailed:{
                 //   NSError *exportError =exporter.error;
                 
                    break;
                }
                case AVAssetExportSessionStatusCompleted:{
           
                
                    //最终混合
                    [self theVideoWithMixMusic];
                    break;
                }
            }  
        }];
        
    

}

#pragma mark - 通过文件路径建立和添加音频素材
-(void)setUpAndAddAudioAtPath:(NSURL*)assetURL toComposition:(AVMutableComposition*)composition start:(CMTime)start dura:(CMTime)dura offset:(CMTime)offset{
    
    AVURLAsset *songAsset =[AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    //组合轨道
    AVMutableCompositionTrack *track =[composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    //创建音频轨道
    
    AVAssetTrack *sourceAudioTrack =[[songAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0];
    
    NSError *error =nil;
    BOOL ok =NO;
    
    CMTime startTime = start;//开始时间
    CMTime trackDuration = dura;//持续时长
    CMTimeRange tRange = CMTimeRangeMake(startTime,trackDuration);
    
    //设置音量
    //AVMutableAudioMixInputParameters（输入参数可变的音频混合）
    //audioMixInputParametersWithTrack（音频混音输入参数与轨道）
    AVMutableAudioMixInputParameters *trackMix =[AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
    [trackMix setVolume:0.8f atTime:startTime];//设置音量
    //素材加入数组
    [self.audioMixParams addObject:trackMix];
    
    //Insert audio into track  //offsetCMTimeMake(0, 44100)
    ok = [track insertTimeRange:tRange ofTrack:sourceAudioTrack atTime:kCMTimeInvalid error:&error];
    
}

#pragma mark - 输出路径
-(NSString *)getLibarayPath{
    
    NSFileManager *fileManager =[NSFileManager defaultManager];
    
    NSArray* paths =NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
    NSString* path = [paths objectAtIndex:0];
    
    NSString *movDirectory = [path stringByAppendingPathComponent:@"leying/tmpMovMix"];
    
    [fileManager createDirectoryAtPath:movDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    return movDirectory;
    
    
    
}
#pragma mark - 最终音频和视频混合

-(void)theVideoWithMixMusic{
    
    NSError *error =nil;
    NSFileManager *fileMgr =[NSFileManager defaultManager];
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *documentsDirectory =[cachesPath stringByAppendingPathComponent:@"leying"];
    NSString *videoOutputPath =[documentsDirectory stringByAppendingPathComponent:@"test_output.mp4"];
    
    
    if ([fileMgr removeItemAtPath:videoOutputPath error:&error]!=YES) {//删除文件不成功
      //  NSLog(@"无法删除文件，错误信息：%@",[error localizedDescription]);
    }
//    声音来源路径（最终混合的音频）
    NSURL *audio_inputFileUrl =self.mixURL;
    //视频来源路径
    NSURL  *video_inputFileUrl = [NSURL fileURLWithPath:self.theVideoPath];
    //最终合成输出路径
    NSString *outputFilePath = [[DataStore sharedDataStore] saveFileToData];
    NSURL *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
    
    [[DataStore sharedDataStore] insertUrl:outputFilePath];
    
    self.outputFilePath = outputFilePath;
  
    //  NSLog(@"%@",self.outputFilePath);
     
    if([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath]){
        [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
    }
    
    CMTime nextClipStartTime =kCMTimeZero;
    
    //创建可变的音频视频组合
   
    AVMutableComposition* mixComposition =[AVMutableComposition composition];
    
    //视频采集
    AVURLAsset* videoAsset =[[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
    CMTimeRange video_timeRange =CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo]objectAtIndex:0]atTime:nextClipStartTime error:nil];
    //声音采集
    AVURLAsset* audioAsset =[[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
    CMTimeRange audio_timeRange =CMTimeRangeMake(kCMTimeZero,videoAsset.duration);//声音长度截取范围==视频长度
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0]atTime:nextClipStartTime error:nil];
    
    //创建一个输出
    AVAssetExportSession * _assetExport =[[AVAssetExportSession alloc]initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    _assetExport.outputFileType =AVFileTypeQuickTimeMovie;//输出类型
    _assetExport.outputURL = outputFileUrl;//输出地址
    _assetExport.shouldOptimizeForNetworkUse=YES;
    self.theEndVideoURL=outputFileUrl;//最终输出路径记录
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         
         //保存合成的视频文件
         
         dispatch_async(dispatch_get_main_queue(), ^{
               [self playActionWithfile:outputFilePath];
[PassMergeHandle sharedHandle].finalMovieString = outputFilePath;
               self.isSave = YES;
           //   NSLog(@"%@",self.outputFilePath);
           
         });
         
         
     }
     ];
 
    

   
}



-(void)playActionWithfile:(NSString*)file{
    [self.player pause];
    [self removeTimer];
    [self makeAvtimer];
  
    
   
    AVPlayerItem *item=[AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath: file]];
    _player=[AVPlayer playerWithPlayerItem:item];
    
    AVPlayerLayer *layer=[AVPlayerLayer playerLayerWithPlayer:_player];
    
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    
    layer.frame=self.moviePlayerView.layer.bounds;
    
    //    layer.backgroundColor=[[UIColor redColor]CGColor];
    
    self.playerLayer = layer;
    
    [self.moviePlayerView.layer addSublayer:layer];
    
    layer.transform=CATransform3DMakeRotation(0, 0, 0, 1);
    
   
    
    [_player play];
    
    //    _player
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(action:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
  
    

    
    
    
    
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    if (error == nil) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"视频成功保存到相册" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alertView show];
        //2秒后自动消失
        [self performSelector:@selector(removeAlertView:) withObject:alertView afterDelay:2];
//        
//        unlink([self.moviePath UTF8String]);
    }else{
        
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"视频保存失败" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alertView show];
        //2秒后自动消失
        [self performSelector:@selector(removeAlertView:) withObject:alertView afterDelay:2];
        
    }
    
    
    
}



//存入本地
-(void)songButtonAction{
    
    
    
    
    
    
    
    
  }
- (IBAction)zoomButtonAction:(id)sender {


//    [self.view bringSubviewToFront:self.moviePlayerView];
    
    [_player pause];
    self.moviePlayerView.layer.frame = [UIScreen mainScreen].bounds;
    self.playerLayer1.frame =[UIScreen mainScreen].bounds;
    
    self.playerLayer.frame = [UIScreen mainScreen].bounds;
    [_player play];
    
}



-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    
    
    
    
    
   
}

//开始播放
- (IBAction)playerButtonDidClick:(id)sender {
    
//    if ( self.musicPlayer.volume < 0.2||self.player.volume < 0.2) {
//        return;
//    }
//   
    
    [self removeTimer];
    
    [self makeAvtimer];
     [self playAction];
    }


-(void)makeAvtimer
{
   
      self.avtimer =  [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(avtimerprogress) userInfo:nil repeats:YES];

    
}
-(void)removeAVTimer{
//    [self.avtimer invalidate];
//    self.avtimer = nil;
    
}

-(void)avtimerprogress{
    
    
    if (self.player.currentItem.duration.value ==  0) {
        return;
    }else{
    CMTime   a =    self.player.currentItem.currentTime;
    CMTime  b =     self.player.currentItem.duration;
//

     NSString * currentTime =  [NSString stringWithFormat:@"%02lld:%02lld",a.value/a.timescale/60,a.value/a.timescale + 1];
      NSString * sumtTime =  [NSString stringWithFormat:@"%02lld:%02lld",b.value/b.timescale/60,b.value/b.timescale];

    self.currentTimeLabel.text  = currentTime ;
    
     self.totalTime.text  =   sumtTime ;

    self.playProgressView.progress = 1.0*a.value/a.timescale/(b.value/b.timescale);
    if (b.value/b.timescale - a.value/a.timescale < 2.5) {
          [self makeSoundLow];
    }
    }
    
    }


-(void)makeSoundLow{
    
    [self doVolumeFade];
 }
-(void)doVolumeFade
{
    

    
   
        if (self.musicPlayer.volume > 0.05 ) {
            self.musicPlayer.volume = self.musicPlayer.volume - 0.0033;
            [self performSelector:@selector(doVolumeFade) withObject:nil afterDelay:0.02];
            
       
               }
    if(1.0*self.player.currentItem.currentTime.value/self.player.currentItem.currentTime.timescale == 1){
        
        [self removeTimer];
    }


}

//开始播放
-(void)playAction
{
    
//    if ( self.musicPlayer.volume < 0.2||self.player.volume < 0.2) {
//        return;
//    }
    
//    [self removeTimer];
    if ([PassMergeHandle sharedHandle].pathString == nil) {
        return;
    }
    [self.player pause];
    AVPlayerItem *item=[AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath: [PassMergeHandle sharedHandle].pathString]];
  
    
    
    
    _player=[AVPlayer playerWithPlayerItem:item];
    
    AVPlayerLayer *layer=[AVPlayerLayer playerLayerWithPlayer:_player];
    
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    
    layer.frame=self.moviePlayerView.layer.bounds;
    
    //    layer.backgroundColor=[[UIColor redColor]CGColor];
    
    self.playerLayer = layer;
    
    [self.moviePlayerView.layer addSublayer:layer];
    
    layer.transform=CATransform3DMakeRotation(0, 0, 0, 1);
    
   
    
    
    [_player play];
    
//    _player
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(action:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
   
    
    
}

-(void)update
{
    
    NSString *urlPath = nil;
    if (self.urlIdx == 5) {
        return;
    }
    
    
    if (self.flag == 0 ) {
        urlPath = [[NSBundle mainBundle]
                   pathForResource:[NSString stringWithFormat:@"%d",self.urlIdx + 11]
                   ofType:@"m4v"] ;
    }
    
   
     else if(self.flag == 1 )
      {
        
       
          urlPath = [[NSBundle mainBundle]
                     pathForResource:[NSString stringWithFormat:@"m%d",self.urlIdx + 1]
                     ofType:@"mp4"] ;

        
      }else if (self.flag == 2){
          
          
          urlPath = [[NSBundle mainBundle]
                     pathForResource:[NSString stringWithFormat:@"c%d",self.urlIdx + 1]
                     ofType:@"mp4"];

          
          
          
      }else if (self.flag == 3){
          
          
          urlPath = [[NSBundle mainBundle]
                     pathForResource:[NSString stringWithFormat:@"a%d",self.urlIdx + 1]
                     ofType:@"mp4"];
          
          
          
          
      }else if (self.flag == 4){
          
          
          urlPath = [[NSBundle mainBundle]
                     pathForResource:[NSString stringWithFormat:@"b%d",self.urlIdx + 1]
                     ofType:@"mp4"];
          
          
          
          
      }else if (self.flag == 5){
          
          
          urlPath = [[NSBundle mainBundle]
                     pathForResource:[NSString stringWithFormat:@"d%d",self.urlIdx + 1]
                     ofType:@"mp4"];
                 
      }else {
          
          urlPath = [[NSBundle mainBundle]
                     pathForResource:[NSString stringWithFormat:@"%d",self.urlIdx + 11]
                     ofType:@"m4v"] ;

          
      }



    

    
    self.urlIdx++ ;
    
    
    
    AVPlayerItem *item2=[AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:urlPath]];
   
    
    
    _player2 = [AVPlayer playerWithPlayerItem:item2];
    
    AVPlayerLayer *layer1=[AVPlayerLayer playerLayerWithPlayer:_player2];
    
    layer1.videoGravity=AVLayerVideoGravityResizeAspectFill;
    
   layer1.frame=self.moviePlayerView.layer.bounds;
    self.playerLayer1 = layer1;
    
    
    layer1.backgroundColor=(__bridge CGColorRef _Nullable)([UIColor clearColor]);
    
    [self.moviePlayerView.layer addSublayer:layer1];
    
    layer1.backgroundColor = (__bridge CGColorRef _Nullable)([UIColor clearColor]);
    
    layer1.opacity = 0.2;
    
    layer1.transform=CATransform3DMakeRotation(0, 0, 0, 1);
    
    
    
    [_player2 play];
    
  
    if (self.urlIdx == 5) {
        
        self.urlIdx = 0;
        
    }

    
    }

//存草稿点击事件
- (IBAction)saveVideo:(id)sender {

    
    
   
}








-(void)action:(NSNotification *)sender{
    
  
    //    NSString * string =sender.userInfo;
    //
    NSString *string =  [NSString stringWithFormat:@"%@", sender.object] ;
    
    
  
    
    if ([string  containsString:@"test.mov"] ||[string  containsString:@"201"] ) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self removeTimer];
        });
        
       
        
        
        self.endView = [[UIView alloc]initWithFrame:CGRectMake(0,0, self.moviePlayerView.frame.size.width, self.moviePlayerView.frame.size.height)];
        self.endView.backgroundColor =[UIColor colorWithRed:12/255.0 green:37/255.0 blue:34/255.0 alpha:1.0];
        [self.moviePlayerView addSubview:self.endView];

        
            }
    

}
   //取消定时器
-(void)removeTimer{
    


    [self.player pause];
//
      [_player replaceCurrentItemWithPlayerItem:nil];
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    
    [self.player2 pause];
    //
    [_player2 replaceCurrentItemWithPlayerItem:nil];
    [self.player2.currentItem cancelPendingSeeks];
    [self.player2.currentItem.asset cancelLoading];
    //取消定时器
    [self.timer invalidate];
    self.timer = nil;
    
    [self.avtimer invalidate];
     self.avtimer = nil;
    
    
    [self pauseMusic];
    
    
self.currentTimeLabel.text  =@"00:00";

}

-(void)pauseMusic{
    

    [self.musicPlayer pause];
//
    
    
    
    [_musicPlayer replaceCurrentItemWithPlayerItem:nil];
    [self.musicPlayer.currentItem cancelPendingSeeks];
    [self.musicPlayer.currentItem.asset cancelLoading];
}




-(void)segmentControlAction:(id)sender{
//    主题
    if ( self.themeSegment.selectedSegmentIndex == 0 ) {
        self.littleSegmentControl.selectedSegmentIndex = 0;
        
        self.musicView.hidden = YES;
        self.themeCollectionView.hidden = NO;
        self.durationTimeView.hidden= YES;
        
        
    }
//    配乐
    if ( self.themeSegment.selectedSegmentIndex == 1 ) {
        self.littleSegmentControl.selectedSegmentIndex = 1;
        
        self.musicView.hidden = NO;
        self.themeCollectionView.hidden = YES;
        self.durationTimeView.hidden= YES;
    }
    
    
//    时长
    if ( self.themeSegment.selectedSegmentIndex == 2 ) {
        self.littleSegmentControl.selectedSegmentIndex = 2;
    
        self.isChangeSpeed= YES;
        self.durationTimeView.hidden= NO;
        self.musicView.hidden = YES;
        self.themeCollectionView.hidden = YES;
        
    }
//    剪辑
    if ( self.themeSegment.selectedSegmentIndex == 3 ) {
        self.littleSegmentControl.selectedSegmentIndex = 3;
        
        
    }
    
    
}

- (IBAction)goBackButtionDIdClick:(id)sender {
    

        [[PassMergeHandle sharedHandle].imageArray removeAllObjects];
    [self removeTimer];
    

    
    [self dismissViewControllerAnimated:YES completion:nil];
}





- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return 5;
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    
    
    
    cell.cellImageView.image =[UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg",(long)indexPath.row+1]];
  
    cell.layer.cornerRadius = 10;
    cell.contentView.layer.cornerRadius = 10.0f;
    cell.contentView.layer.borderWidth = 0.5f;
    cell.contentView.layer.borderColor = [UIColor clearColor].CGColor;
    cell.contentView.layer.masksToBounds =YES;
//
    cell.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    cell.layer.shadowOffset = CGSizeMake(0, 0);
    cell.layer.shadowRadius = 4.0f;
    cell.layer.shadowOpacity = 0.5f;
    cell.layer.masksToBounds = NO;
    cell.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:cell.bounds cornerRadius:cell.contentView.layer.cornerRadius].CGPath;
//    cell.layer.masksToBounds = NO;
    if (indexPath.item == 0) {
         cell.cellLabel.text = @"浪漫烟火";
    
    }if (indexPath.item == 1) {
     cell.cellLabel.text = @"桃花盛开";
    
    }if (indexPath.item == 2) {
        cell.cellLabel.text = @"梦幻世界";
        
    }if (indexPath.item == 3) {
        cell.cellLabel.text = @"时间碎片";
        
    }if (indexPath.item == 4) {
        cell.cellLabel.text = @"孩童时代";
        
    }
   
    
            return cell;
   }





- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath

{
    
    }

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    cell.backgroundView.backgroundColor = indexPath.row % 2?[UIColor colorWithRed: 240.0/255 green: 240.0/255 blue: 240.0/255 alpha: 1.0]: [UIColor whiteColor];
    
//    cell.textLabel.backgroundColor = [UIColor clearColor];
//    
//    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    

}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
  
    if ([[PassMergeHandle sharedHandle].imageArray count]== 0) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@" 提示:请先选择图片" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:cancelAction];
        
        [self presentViewController:alertVC animated:YES completion:nil];
        
        
    }else {
    
    
    if (self.player.currentItem.duration.value ==0  ) {
    [self removeTimer];
    self.flag = indexPath.item;
    [self pause2];
    [self Timer];
    self.urlIdx = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(update) userInfo:nil repeats:YES];
   
    [self update];
    [self makeAvtimer];
    [self playAction];
            [self playMusicWithRor:self.myrow];
        
        }else if(self.player.currentItem.duration.value /self.player.currentItem.duration.timescale- self.player.currentItem.currentTime.value/self.player.currentItem.currentTime.timescale > 2.5){
                
            
            [self removeTimer];
            self.flag = indexPath.item;
            [self pause2];
            [self Timer];
            self.urlIdx = 0;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(update) userInfo:nil repeats:YES];
            
            [self update];
            [self makeAvtimer];
            [self playAction];
            [self playMusicWithRor:self.myrow];

                
        }else{
            
            return;
        }
    }
    


}
//将mov格式的视频转换成MP4
-(NSString * )conversionMp4WithPath:(NSString *)path andBlock:(FINISH)block{
    NSString *exportPath = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality])
        
    {
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetPassthrough];
        exportPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        exportPath = [exportPath stringByAppendingPathComponent:@"leying/tmp1.mp4"];
        
        exportSession.outputURL = [NSURL fileURLWithPath:exportPath];
      
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                 //   NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    
                    break;
                case AVAssetExportSessionStatusCompleted:
                  
                    
             
                    
                    break;
                default:
                    break;
            }
            
            
                  block(YES,exportPath);
            
        }];
    }
    
    return exportPath;
    
}

//添加视频效果
-(void)mergeMovieWithPath:(NSString*)pathString{
    
     // NSLog(@"--------%@",pathString);
    
    if (self.outputFilePath != nil) {
      
    [self conversionMp4WithPath:self.outputFilePath andBlock:^(BOOL isFinish, NSString *path) {
         
     //   NSLog(@"++++++%@",path);
         
         if (isFinish == YES) {
             
             _movieFile1 = [[GPUImageMovie alloc] initWithURL:[NSURL fileURLWithPath:path]];
            
             
//      _movieFile1 = [[GPUImageMovie alloc] initWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"1" ofType:@"mp4" ]]];

             
             
             _movieFile1.runBenchmark = YES;
             _movieFile1.playAtActualSpeed = NO;
             
             GPUImageDissolveBlendFilter  * d = [[GPUImageDissolveBlendFilter alloc]init];
         
             d.mix = 0.5;
             
             //    GPUImageAlphaBlendFilter  * f = [[GPUImageAlphaBlendFilter alloc]init];
             
             //  [[GPUImageMovie alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"m5" withExtension:@"mp4"]];
             _movieFile2 =    [[GPUImageMovie alloc] initWithURL:[NSURL fileURLWithPath:pathString]];
;
             
             _movieFile2.runBenchmark = YES;
             _movieFile2.playAtActualSpeed = NO;
             _filter = [[GPUImageScreenBlendFilter alloc] init];
             //    filter = [[GPUImageUnsharpMaskFilter alloc] init];
             //    [_movieFile1 addTarget:f];
             //    [_movieFile2 addTarget:f];
             [_movieFile1 addTarget:d];
             [_movieFile2 addTarget:d];
             // Only rotate the video for display, leave orientation the same for recording
             // In addition to displaying to the screen, write out a processed version of the movie to disk
             NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
             NSString *pathToMovie = [cachesPath stringByAppendingPathComponent:@"leying/last.mov"];
            // NSLog(@"视频效果路径%@",pathToMovie);
             
             
             
             unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
             
//             NSLog(@"file = %@",pathToMovie);
             NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
             
             self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 360.0)];
             
             //    [f addTarget:self.movieWriter];
             [d addTarget:self.movieWriter];
             // Configure this for video from the movie file, where we want to preserve all video frames and audio samples
             self.movieWriter.shouldPassthroughAudio = YES;
//             _movieFile2.audioEncodingTarget = self.movieWriter;
             [_movieFile1 enableSynchronizedEncodingUsingMovieWriter:self.movieWriter];
             
             [self.movieWriter startRecording];
             [_movieFile1 startProcessing];
             [_movieFile2 startProcessing];
             __block typeof(self)  sself = self;
             
             [self.movieWriter setCompletionBlock:^{
                 //        [f removeTarget:sself.movieWriter];
                 [d removeTarget:sself.movieWriter];
                 [sself.movieFile1 endProcessing];
                 [sself.movieFile2 endProcessing];
                 [sself.movieWriter finishRecording];
                 
//                 sself.outputFilePath = pathToMovie;
                 //         加入音频
//                 注意
                 dispatch_async(dispatch_get_main_queue(), ^{
                      [sself playActionWithfile:pathToMovie];
                 });
                 
                
//                 [sself syntheticWithPath:pathToMovie];
                 
             }];
         }
 
       
         
     }];
    }
  }
-(void)syntheticWithPath:(NSString *)mergeMoviePath{
    if ([PassMergeHandle sharedHandle].pathString == nil) {
        return;
    }
    
    [self removeTimer];
//    注意
    self.theVideoPath = mergeMoviePath;
//    self.theVideoPath =[[NSBundle mainBundle]pathForResource:@"last" ofType:@"mov"];
    //抽取原视频的音频与需要的音乐混合
    //录制的视频
    AVMutableComposition *composition =[AVMutableComposition composition];
    self.audioMixParams =[NSMutableArray array];
    //视频路径
    
    NSURL *video_inputFileUrl =[NSURL fileURLWithPath:self.theVideoPath];
    
    AVURLAsset *songAsset =[AVURLAsset URLAssetWithURL:video_inputFileUrl options:nil];
    
    CMTime startTime =CMTimeMakeWithSeconds(0,songAsset.duration.timescale);
    CMTime trackDuration = songAsset.duration;
    
    
    //获取视频中的音频素材
    if (startTime.value != 0) {
        [self setUpAndAddAudioAtPath:video_inputFileUrl toComposition:composition start:startTime dura:trackDuration offset:CMTimeMake(14*44100,44100)];
    }
    
    //本地要插入的音乐
    //        NSString *bundleDirectory =[[NSBundle mainBundle] bundlePath];
    
    
    
    NSString *pathS = [PassMergeHandle sharedHandle].musicUrlString;
    
    
    
    NSURL *assetURL2 =[NSURL fileURLWithPath:pathS];
    
    //获取设置完的本地音乐素材
    [self setUpAndAddAudioAtPath:assetURL2 toComposition:composition start:startTime dura:trackDuration offset:CMTimeMake(0*44100,44100)];
    
    //创建一个可变的音频混合
    AVMutableAudioMix *audioMix =[AVMutableAudioMix audioMix];
    audioMix.inputParameters =[NSArray arrayWithArray:self.audioMixParams];//从数组里取出处理后的音频轨道参数
    
    //创建一个输出
    AVAssetExportSession *exporter =[[AVAssetExportSession alloc]
                                     initWithAsset:composition presetName:AVAssetExportPresetAppleM4A];
    exporter.audioMix = audioMix;
    exporter.outputFileType = @"com.apple.m4a-audio";
    NSString* fileName =[NSString stringWithFormat:@"%@.mov",@"overMix"];
    //输出路径
    NSString *exportFile =[NSString stringWithFormat:@"%@/%@",[self getLibarayPath], fileName];
    
    
    
    if([[NSFileManager defaultManager]fileExistsAtPath:exportFile]) {
        
        [[NSFileManager defaultManager]removeItemAtPath:exportFile error:nil];//如果存在删除文件
        
    }
    
    
    NSURL *exportURL =[NSURL fileURLWithPath:exportFile];
    exporter.outputURL = exportURL;
    
    //输出地址
    self.mixURL = exportURL;
   // NSLog(@"++%@",self.mixURL);
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        
        int exportStatus =(int)exporter.status;//输出状态
        
        switch (exportStatus){
            case AVAssetExportSessionStatusFailed:{
               // NSError *exportError =exporter.error;
                
                break;
            }
            case AVAssetExportSessionStatusCompleted:{
                
                
                //最终混合
                [self theVideoWithMixMusic];
                break;
            }
        }
    }];

    
    
    
}


-(void)Timer{
    [self.timer invalidate];
    self.timer = nil;
    

}
-(void)pause2{
    [self.player2 pause];
    //
    [_player2 replaceCurrentItemWithPlayerItem:nil];
    [self.player2.currentItem cancelPendingSeeks];
    [self.player2.currentItem.asset cancelLoading];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
