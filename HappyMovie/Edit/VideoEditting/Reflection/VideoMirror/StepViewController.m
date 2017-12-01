

#import "StepViewController.h"
#import "UIImage+ImageEffects.h"
#import "AudioViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
typedef NS_ENUM(NSInteger, SelectedMediaType)
{
    kNone = -1,
    kBackgroundVideo = 0,
    kEmbededGif,
    kEmbededVideo,
};

@interface StepViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(nonatomic,strong)NSMutableArray *dataArr;
@property(nonatomic,strong)NSArray *sectionArr;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (nonatomic, assign) SelectedMediaType mediaType;
@property (nonatomic, copy) NSURL* videoBackgroundPickURL;

@property (strong, nonatomic) IBOutlet UIButton *exportButton;

@end

@implementation StepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.exportButton.clipsToBounds = YES;
  //  _videoBackgroundPickURL = nil;
    
    
    //背景效果
    if (IS_IOS_8) {
       
        self.backgroundImage.image = [UIImage imageNamed:@"xingkong2.jpg"];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = _backgroundImage.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        vibrancyEffectView.frame = _backgroundImage.bounds;
        vibrancyEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [blurEffectView.contentView addSubview:vibrancyEffectView];
        [_backgroundImage addSubview:blurEffectView];
        
    }else{
    
        _backgroundImage.image = [[self snapshot] applyLightEffect];
    
    }
    
    
    
}

#pragma mark - -- 退出按钮
- (IBAction)backButtonDidClick:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark---- 选择背景视频按钮
- (IBAction)selectBackgroundVideoButtonDidClicked:(id)sender {
    
    //进入相册
    _mediaType = kBackgroundVideo;
    [self pickBackgroundVideoPhotoAlbum];
    
    
}
-(void)setCurrentVideoUrl:(NSURL *)url{

    _videoBackgroundPickURL = url;

}
#pragma mark ---- 选择gif动画和边框按钮
- (IBAction)selectGifAndBorderButtonDidClicked:(id)sender {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
   BOOL exist = [fileManager fileExistsAtPath:[_videoBackgroundPickURL path]];
    if (_videoBackgroundPickURL== nil || exist == NO)//没有选择视频
    {
        NSString *message = @"选择一个视频";
        showAlertMessage(message, nil);
        return;
    }
    //边框和gif动画
    if (self.delegate && [self.delegate respondsToSelector:@selector(stepViewControllerPickGifFromCustom)]) {
        
        _mediaType = kEmbededGif;
        
        [self.delegate stepViewControllerPickGifFromCustom];
        
      //  [self.navigationController popToRootViewControllerAnimated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
 
    
   
    
}
#pragma mark -- 选择背景音乐按钮
- (IBAction)selectBackgroundMusic:(id)sender {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL exist = [fileManager fileExistsAtPath:[_videoBackgroundPickURL path]];
    if (_videoBackgroundPickURL== nil || exist == NO)//没有选择视频
    {
        NSString *message = @"选择一个视频";
        showAlertMessage(message, nil);
        return;
    }

    //选择背景音乐,出现音乐界面
    [self performSelector:@selector(pickMusicFromCustom) withObject:nil];
    
    
    
}
#pragma mark -- 合成视频按钮
- (IBAction)exporterVideoButtonDidClicked:(id)sender {
    
    //合成视频
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL exist = [fileManager fileExistsAtPath:[_videoBackgroundPickURL path]];
    if (_videoBackgroundPickURL== nil || exist == NO)//没有选择视频
    {
        NSString *message = @"选择一个视频";
        showAlertMessage(message, nil);
        return;
    }

    //选择视频不能为空
    [self performSelector:@selector(handleConvert) withObject:nil afterDelay:0.1];
    
}


#pragma mark -- -  去相册选择视频
-(void)pickBackgroundVideoPhotoAlbum{

    
    //确认设备可以使用
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        {
        return;
    }
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 200);
    
    //获取系统相册
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    //展示所有的视频文件
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
    
    mediaUI.allowsEditing = YES;
    
    mediaUI.delegate = self;
    
    [self presentViewController:mediaUI animated:YES completion:nil];

 
}
#pragma mark - UImagePickerController代理
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
 
   // NSLog(@"--------%@",info);
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
     if ([mediaType isEqualToString:@"public.movie"]) {//选择库的视频
         
         NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
         
         if (_mediaType == kBackgroundVideo) {//背景视频
             //移除上次的视频文件
             if (self.videoBackgroundPickURL && [self.videoBackgroundPickURL isFileURL]) {
                 //移除????????????????????
                 if ([[NSFileManager defaultManager] removeItemAtURL:self.videoBackgroundPickURL error:nil]) {
                    // NSLog(@"移除上次的视频成功");
                 }else{
                // NSLog(@"移除上次的视频失败");
                 
                 }
             }
             self.videoBackgroundPickURL = url;
            // NSLog(@"选择背景视频成功");
             
             //返回界面,进行播放
             if (self.block!=nil) {
               
                 self.block(self.videoBackgroundPickURL);
                 
             }
         }
   }
  //  [self.navigationController popToRootViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];

}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
 
    [picker dismissViewControllerAnimated:YES completion:nil];

}
#pragma mark - - 音乐方法
-(void)pickMusicFromCustom{
  
    AudioViewController *audioController = [[AudioViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *audioNC = [[UINavigationController alloc] initWithRootViewController:audioController];
    //点击save键,执行block
    __block typeof(audioController)weakAudioController = audioController;
    
    audioController.seletedRowBlock = ^(BOOL success,id result){
      
         if (success && [result isKindOfClass:[NSNumber class]]) {
            
             NSInteger index = [result integerValue];
             NSDictionary *dic = [weakAudioController.allAudios objectAtIndex:index];
        //     NSLog(@"%@",dic);
             //执行代理方法,传值
            
             if (self.delegate && [self.delegate respondsToSelector:@selector(stepViewControllerPassSongInfo:)]) {
                 [self.delegate stepViewControllerPassSongInfo:dic];
                 
             }
             //返回播放界面
         // [self.navigationController popToRootViewControllerAnimated:YES];
            // [self dismissViewControllerAnimated:YES completion:nil];
    
         }
       };
     // [self.navigationController pushViewController:audioController animated:YES];
    [self presentViewController:audioNC animated:YES completion:nil];
}

#pragma mark - -- 合成视频文件
-(void)handleConvert{

      //找代理执行
    if (self.delegate && [self.delegate respondsToSelector:@selector(stepViewControllerCompositionVideo)]) {
       
        [self.delegate stepViewControllerCompositionVideo];
    }
    
  //  [self.navigationController popToRootViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    
 }

- (UIImage *)snapshot
{
    id <UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
    UIGraphicsBeginImageContextWithOptions(appDelegate.window.bounds.size, NO, appDelegate.window.screen.scale);
    [appDelegate.window drawViewHierarchyInRect:appDelegate.window.bounds afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshotImage;
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
