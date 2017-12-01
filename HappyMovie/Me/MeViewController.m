//
//  MeViewController.m
//  happyMovieEditor
//
//  Created by lanou3g on 16/1/6.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "MeViewController.h"
#import "LoginViewController.h"
#import <AVOSCloud/AVOSCloud.h>
#import "UIImageView+WebCache.h"
#import "SetViewController.h"
#import "MeNotLoginView.h"
#import "DataStore.h"
#import "VideoTableViewCell.h"
#import "PlayMovieView.h"
#import "Video.h"
#import "Image.h"
#import "WaterFallLayout.h"
#import "ImageCollectionViewCell.h"
#import "UMSocial.h"
#import "BaseView.h"
@interface MeViewController ()<UITableViewDataSource,UITableViewDelegate,VideoTableViewCellDelegate,UICollectionViewDataSource,UICollectionViewDelegate,WaterFallLayoutDelegate,UIScrollViewDelegate,UMSocialUIDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *headerImageView;

@property (strong, nonatomic) IBOutlet UISegmentedControl *meSegmentControl;

@property(nonatomic,strong)UIScrollView *scrollView;

@property(nonatomic,strong)UITableView *tableView;

@property (nonatomic,strong)UICollectionView *imageCollectionView;

@property (nonatomic,strong)MeNotLoginView *meNotLoginView;
@property(nonatomic,assign)BOOL isShowingScrollView;//判断scrollView是否在显示
@property(nonatomic,strong)NSArray *videoDataArr;
@property (nonatomic,strong)NSArray *imageArray;

@property (nonatomic,strong)ImageCollectionViewCell *imageCell;

@property (nonatomic,strong)UIImage *resultImage;

@property (nonatomic,strong)BaseView *baseView;
@property(nonatomic,strong)NSString *videoUrl;
@property (nonatomic,strong)NSString *imageUrl;
@end

@implementation MeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   
    //获取tableView上的数据
    self.videoDataArr = [[DataStore sharedDataStore] searchAllVideos];
    self.imageArray = [[DataStore sharedDataStore] searchAllImageData];
    
    
    //初始化scrollView
    [self initScrollView];
    
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.27 green:0.24 blue:0.22 alpha:1];
    self.headerImageView.backgroundColor = [UIColor colorWithRed:0.27 green:0.24 blue:0.22 alpha:1];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"iconfont-fanhui.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIBarButtonItem *rightItem =[[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"iconfont-shezhi.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(rightItemButtonAction:)];
   
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //去掉边框
    [self deleteBorderOfMeSegmentControl];
    
    self.meSelfImageView.layer.cornerRadius = 30;
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOutAction:) name:@"loginOut" object:nil];
    //--------------播放完成的通知---------
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replay:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [self.meSegmentControl addTarget:self action:@selector(meSegmentControlAction:) forControlEvents:UIControlEventValueChanged];
    
}
-(void)meSegmentControlAction:(UISegmentedControl *)sender
{
    for (int i=0; i < 2; i++) {
        if (self.meSegmentControl.selectedSegmentIndex == i) {
            self.scrollView.contentOffset = CGPointMake(kScreenWidth*i, 0);
        }
    }

}
-(void)rightItemButtonAction:(UIBarButtonItem *)sender
{
    if ([AVUser currentUser] == nil) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请先登录!" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertVC animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }else{
        SetViewController *setVC = [[SetViewController alloc] init];
        UINavigationController *setNC = [[UINavigationController alloc] initWithRootViewController:setVC];
        [self presentViewController:setNC animated:YES completion:nil];
    }

}
#pragma mark - 返回
-(void)backAction:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 通知方法
-(void)loginOutAction:(NSNotification *)sender
{
    self.meSelfImageView.image = nil;
    self.userNameLabel.text = nil;
}
#pragma mark - 判断登陆状态,更改View
-(void)viewWillAppear:(BOOL)animated
{
    //此时处于登录状态
    if ([AVUser currentUser] != nil) {
        [self.meNotLoginView removeFromSuperview];
        //登陆成功赋值
        AVQuery *query = [AVQuery queryWithClassName:@"UserMessage"];
        [query whereKey:@"name" equalTo:[AVUser currentUser].username];
        [query getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            if (object != nil) {
                if ([object objectForKey:@"nikename"] != nil) {
                    NSString *nikename = [object objectForKey:@"nikename"];
                    self.userNameLabel.text = nikename;
                }else{
                    NSString *name = [object objectForKey:@"name"];
                    self.userNameLabel.text = name;
                }
                AVFile *avatarFile = [object objectForKey:@"avatarImage"];
                if (avatarFile != nil) {
                    NSData *avatarData = [avatarFile getData];
                    UIImage *avatarImage = [UIImage imageWithData:avatarData];
                    self.meSelfImageView.image = avatarImage;
                }else
                {
                    self.meSelfImageView.image = [UIImage imageNamed:@"3724d6e9fb0b28d51344b5ef30ba27aa.jpg"];
                }
            }else{
              //  NSLog(@"%@",error);
            }
        }];
        
        if (self.isShowingScrollView == NO) {//不再视图上
            //scrollView不在父视图上
            [self.view addSubview:self.scrollView];//添加界面
            self.isShowingScrollView = YES;
            [self baseViewWithNoWorks];
    }
    }else{
        self.meSelfImageView.image = [UIImage imageNamed:@"3724d6e9fb0b28d51344b5ef30ba27aa.jpg"];
        self.meNotLoginView = [[MeNotLoginView alloc] initWithFrame:CGRectMake(0, 224, kScreenWidth, kScreenHeight-224)];
        [self.meNotLoginView.loginButton addTarget:self action:@selector(loginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
      
        if (self.isShowingScrollView == YES) {
            //scrollView在父视图上
            self.isShowingScrollView = NO;
            [self.scrollView removeFromSuperview];
        }
        [self.view addSubview:self.meNotLoginView];
    }
    
    //添加图片的collectionView
    
    if (self.imageArray.count>0) {
        
        WaterFallLayout *flowLayout = [[WaterFallLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(kScreenWidth/2-15, 50);
        flowLayout.insertItemSpacing = 10;
        flowLayout.sectionInsets = UIEdgeInsetsMake(0, 10, 10, 10);
        flowLayout.numberOfColumns = 2;
        //设置代理
        flowLayout.delegate = self;
        self.imageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(kScreenWidth, 0,kScreenWidth, kScreenHeight - CGRectGetMaxY(self.meSegmentControl.frame)) collectionViewLayout:flowLayout];
        self.imageCollectionView.backgroundColor = [UIColor whiteColor];
        //添加到父视图
        [self.scrollView addSubview:self.imageCollectionView];
        
        self.imageCollectionView.dataSource = self;
        self.imageCollectionView.delegate = self;
        //设置标记
        [self.imageCollectionView registerNib:[UINib nibWithNibName:@"ImageCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"ImageCollectionViewCell"];
    }

    if (self.isShowingScrollView == YES) {//正在展示
       //刷新数据
        self.videoDataArr = [[DataStore sharedDataStore] searchAllVideos];
        self.imageArray = [[DataStore sharedDataStore] searchAllImageData];
        [self.tableView reloadData];
        [self.imageCollectionView reloadData];
        [self baseViewWithNoWorks];
    }
}
-(void)viewDidDisappear:(BOOL)animated{

    self.meNotLoginView = nil;
    self.imageCollectionView = nil;
    [self.baseView removeFromSuperview];
    self.baseView = nil;
}
-(void)baseViewWithNoWorks
{
    if (self.videoDataArr.count == 0) {
        self.baseView = [[BaseView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - CGRectGetMaxY(self.meSegmentControl.frame))];
        [self.scrollView addSubview:self.baseView];
    }
    if (self.imageArray.count == 0) {
        self.baseView = [[BaseView alloc] initWithFrame:CGRectMake(kScreenWidth, 0, kScreenWidth, kScreenHeight - CGRectGetMaxY(self.meSegmentControl.frame))];
        self.baseView.baseImageView.image = [UIImage imageNamed:@"iconfont-tupian-Me.png"];
        [self.scrollView addSubview:self.baseView];
    }
}
-(void)loginButtonAction:(UIButton *)sender
{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self presentViewController:loginNC animated:YES completion:nil];
    
}
#pragma mark - 去掉meSegmentControl边框
-(void)deleteBorderOfMeSegmentControl
{
    self.meSegmentControl.tintColor = [UIColor clearColor];//去掉颜色,现在整个segment都看不见
    NSDictionary* selectedTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],NSForegroundColorAttributeName: [UIColor orangeColor]};
    [self.meSegmentControl setTitleTextAttributes:selectedTextAttributes forState:UIControlStateSelected];//设置文字属性
    NSDictionary* unselectedTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:16],NSForegroundColorAttributeName: [UIColor grayColor]};
    [self.meSegmentControl setTitleTextAttributes:unselectedTextAttributes forState:UIControlStateNormal];
}
-(void)initScrollView{

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(self.meSegmentControl.frame),kScreenWidth, kScreenHeight - CGRectGetMaxY(self.meSegmentControl.frame))];
    self.scrollView.contentSize = CGSizeMake(kScreenWidth*2, kScreenHeight - CGRectGetMaxY(self.meSegmentControl.frame));
    self.scrollView.pagingEnabled = YES;
    self.isShowingScrollView = NO;
    self.scrollView.delegate = self;
    //添加子实图    视频tableView
    self.tableView  = [[UITableView alloc] initWithFrame:CGRectMake(0, 10,kScreenWidth, self.scrollView.bounds.size.height) style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.scrollView addSubview:self.tableView];  
    
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat X = self.scrollView.contentOffset.x;
    NSInteger i = X/kScreenWidth;
    self.meSegmentControl.selectedSegmentIndex = i;
}
#pragma mark - 瀑布流的代理方法

-(CGFloat)heightForItemIndexPath:(NSIndexPath *)indexPath
{
    if (self.imageArray.count>0) {
        Image *imagesData = self.imageArray[indexPath.item];
       // NSLog(@"*****%@",imagesData);
        NSString *imagePath = imagesData.imageUrl;
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        CGFloat w = image.size.width;
        CGFloat h = image.size.height;
        CGFloat ratio = w/h;
        CGFloat resultHeight = (kScreenWidth/2)/ratio;
        return resultHeight;

    }
    return 0;
}

#pragma mark - collectionView的代理方法
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.imageArray.count>0) {
        return self.imageArray.count;
    }
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //创建
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCollectionViewCell" forIndexPath:indexPath];
    
    if (self.imageArray.count>0) {
        Image *imageUrl = self.imageArray[indexPath.item];
        NSString *imagePath = imageUrl.imageUrl;
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        cell.myImageCollectionImageView.image = image;

    }
       return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *shareAction = [UIAlertAction actionWithTitle:@"分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self checkNetWorkWithAFNetWorkingWith:indexPath];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:shareAction];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];

}
-(void)checkNetWorkWithAFNetWorkingWith:(NSIndexPath *)imageIndexPath
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                [self alertViewWithString:@"当前网络不可用,请检测网络连接"];
                break;
            case AFNetworkReachabilityStatusNotReachable:
                [self alertViewWithString:@"当前网络不可用,请检测网络连接"];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                [self shareActionWith:imageIndexPath];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [self shareActionWith:imageIndexPath];
                break;
            default:
                break;
        }
    }];
    
}
-(void)shareActionWith:(NSIndexPath *)imageIndexPath
{
    __block MBProgressHUD *mb = [[MBProgressHUD alloc] initWithView:self.view];
    mb.labelText = @"分享中";
    [mb show:YES];
    [self.view addSubview:mb];
    Image *image = self.imageArray[imageIndexPath.item];
    NSString *imagePath = image.imageUrl;
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    //分享
    AVQuery *judgeQuery = [AVQuery queryWithClassName:@"_File"];
    [judgeQuery whereKey:@"name" equalTo:imagePath];
    [judgeQuery getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        if (!object) {
            AVFile *videoFile = [AVFile fileWithName:imagePath data:imageData];
            [videoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [mb removeFromSuperview];
                    mb = nil;
                    AVQuery *videoQuery = [AVQuery queryWithClassName:@"_File"];
                    [videoQuery whereKey:@"name" equalTo:imagePath];
                    [videoQuery getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                        self.imageUrl = [object objectForKey:@"url"];
                        //分享
                        [self thirdPingTaiShare];
                    }];
                }
            }];
        }else{
            [mb removeFromSuperview];
            mb = nil;
            self.imageUrl = [object valueForKey:@"url"];
            //分享
            [self thirdPingTaiShare];
        }
    }];
    
}
-(void)thirdPingTaiShare
{
    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:self.imageUrl];
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"568f5168e0f55a5aeb001443"
                                      shareText:@"欢乐摄影"
                                     shareImage:[UIImage imageNamed:@"tubiao.jpg"]
                                shareToSnsNames:@[UMShareToSina,UMShareToQQ,UMShareToQzone,UMShareToWechatTimeline,UMShareToWechatSession,UMShareToRenren,UMShareToDouban]
                                       delegate:self];
    
}
#pragma mark----- tableView代理方法
-(void)dealloc{
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}
-(void)replay:(NSNotification *)notification{
   
  //通过网址获取当前cell的位置,获取到cell

    NSInteger count = -1;
    NSURL *url =[notification.object valueForKey:@"URL"];
    if (self.videoDataArr.count>0) {
        //遍历数组查询
        for (NSInteger i = 0; i<self.videoDataArr.count; i++) {
            Video *video = [self.videoDataArr objectAtIndex:i];
            NSURL *videoUrl = [NSURL fileURLWithPath:video.url];
            if ([url isEqual:videoUrl]) {
                count = i;
                break;
            }
        }
        //通过count找到对应的cell
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:count inSection:0];
        VideoTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell.player seekToTime:CMTimeMake(0, 1)];
        cell.playAndPausebutton.selected = NO;
        cell.playAndPausebutton.alpha = 1;
    }
    
   
}
#pragma mark -- - tableView代理方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    if (self.videoDataArr.count>0) {
        
        return self.videoDataArr.count;
    }
    
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

   NSString *cell_id = @"VideoTableViewCell";
   VideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    
    if (!cell) {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"VideoTableViewCell" owner:self options:nil] firstObject];
    }
    
    //设置代理
    cell.playDelegate = self;
    
   //设置cell
    if (self.videoDataArr.count>0) {
        //获取video对象
        Video *video = [self.videoDataArr objectAtIndex:indexPath.item];
        NSURL *url = [NSURL fileURLWithPath:video.url];
        [cell setCellWithNSUrl:url];
    }
   

    
    return cell;

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
     
    return 250;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}
#pragma mark - -- cell代理方法
-(void)playAndPauseButtonWithCell:(VideoTableViewCell *)cell{

    if (cell.playAndPausebutton.selected == NO) {
       
        [cell.player play];
        
        cell.playAndPausebutton.alpha = 0;//播放并隐藏
        
    }else{
    
        [cell.player pause];
       // cell.playAndPausebutton.alpha = 1;
     }

    cell.playAndPausebutton.selected = !cell.playAndPausebutton.selected;

}

//删除按钮
-(void)deleteButtonWithCell:(VideoTableViewCell *)cell{
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    //通过indexPath获取url
    Video *video = [self.videoDataArr objectAtIndex:indexPath.item];
    //删除数据库中的数据
    [[DataStore sharedDataStore] deleteSomeOneWithUrl:video.url];
    //更新数据源
    self.videoDataArr = [[DataStore sharedDataStore] searchAllVideos];
    //同时删除视频文件
    unlink([video.url UTF8String]);
    
    [self.tableView reloadData];
}
//分享
-(void)sharedButtonWithCell:(VideoTableViewCell *)cell
{
    //判断网络
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                [self alertViewWithString:@"当前网络不可用,请检测网络连接"];
                break;
            case AFNetworkReachabilityStatusNotReachable:
                [self alertViewWithString:@"当前网络不可用,请检测网络连接"];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                //当前连接的是3G网络
                [self sendToLeanCloudWith:cell];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                //当前连接的是wifi
                [self sendToLeanCloudWith:cell];
                break;
            default:
                break;
        }
    }];
    
    
}
//上传到leanCloud
-(void)sendToLeanCloudWith:(VideoTableViewCell *)cell
{
    __block MBProgressHUD *mb = [[MBProgressHUD alloc] initWithView:self.view];
    mb.labelText = @"分享中";
    [mb show:YES];
    [self.view addSubview:mb];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Video *video = [self.videoDataArr objectAtIndex:indexPath.item];
    NSString *videoPath = video.url;
   // NSLog(@"视频路径---%@",videoPath);
    NSData *videoData = [NSData dataWithContentsOfFile:videoPath];
    AVQuery *judgeQuery = [AVQuery queryWithClassName:@"_File"];
    [judgeQuery whereKey:@"name" equalTo:videoPath];
    [judgeQuery getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        if (!object) {
            AVFile *videoFile = [AVFile fileWithName:videoPath data:videoData];
            [videoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [mb removeFromSuperview];
                    mb = nil;
                    AVQuery *videoQuery = [AVQuery queryWithClassName:@"_File"];
                    [videoQuery whereKey:@"name" equalTo:videoPath];
                    [videoQuery getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                        
                        if (error == nil) {
                            self.videoUrl = [object objectForKey:@"url"];
                            // NSLog(@"链接---%@",self.videoUrl);
                            //分享
                            [self shareToAction];
                        }else{
                        
                             [self alertViewWithString:@"分享失败"];
                          
                        }
                      
                    }];
                }
            }];
        }else{
            [mb removeFromSuperview];
            mb = nil;
            self.videoUrl = [object valueForKey:@"url"];
            //NSLog(@"---%@",self.videoUrl);
            [self shareToAction];
        }
    }];
    
}
//分享到友盟
-(void)shareToAction
{
    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeVideo url:self.videoUrl];
    [UMSocialSnsService presentSnsIconSheetView:self
                                     appKey:@"568f5168e0f55a5aeb001443"
                                      shareText:@"@乐影,快乐你的生活"
                                     shareImage:nil
                                shareToSnsNames:@[UMShareToSina,UMShareToQQ,UMShareToQzone,UMShareToWechatTimeline,UMShareToWechatSession,UMShareToRenren,UMShareToDouban]
                                       delegate:self];
    
}
//友盟分享回调方法
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"分享成功" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertVC animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
   
}
-(void)alertViewWithString:(NSString *)string
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:string delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [alertView show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
    });
    
}
@end
