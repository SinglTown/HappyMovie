//
//  ZYQAssetViewController.m
//  HappyMovie
//
//  Created by lanou3g on 16/1/23.
//  Copyright © 2016年 刘培培. All rights reserved.
//

//#pragma mark - ZYQAssetViewController


#import "ZYQAssetViewController.h"
#import "ZYQAssetPickerController.h"
#import "PhotoMVViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UIView+HB.h"
#import "PassMergeHandle.h"
#import "MBProgressHUD.h"
#define IS_IOS7             ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)
#define kThumbnailLength    78.0f
#define kThumbnailSize      CGSizeMake(kThumbnailLength, kThumbnailLength)
#define kPopoverContentSize CGSizeMake(320, 480)

@interface ZYQAssetViewController ()<ZYQAssetViewCellDelegate,PhotoMVViewControllerplayerButtonDelegate>{
    int columns;

    float minimumInteritemSpacing;
    float minimumLineSpacing;

    BOOL unFirst;

        UIButton *btn;

        UIScrollView *src;

        UIPageControl *pageControl;

}

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, assign) NSInteger numberOfPhotos;
@property (nonatomic, assign) NSInteger numberOfVideos;

@property(nonatomic,strong)NSString*theVideoPath;
@property(nonatomic,strong)NSMutableArray*imageArr;
@property(nonatomic,strong)AVMutableVideoComposition*composition;
@property(nonatomic,assign)CGRect currentRect1;
@property(nonatomic,assign)CGRect currentRect2;
@property(nonatomic,assign)CGRect currentRect3;
@property(nonatomic,assign)CGRect currentRect4;
@property(nonatomic,assign)CGRect currentRect5;
@property(nonatomic,assign)CGRect changeRect;
@property(nonatomic,assign)int currentIdx;
@property(nonatomic,strong)AVPlayer *player;
@property(nonatomic,strong)AVPlayer *player2;
@property(nonatomic,strong)NSString*theVideoPath2;
@property(nonatomic,strong)NSTimer * timer;

@property(nonatomic,strong)NSMutableArray *themeArr;

@property(nonatomic,assign)int urlIdx;

@property(nonatomic,strong)ZYQAssetViewController * ZYQAVC;
@end

#define kAssetViewCellIdentifier           @"AssetViewCellIdentifier"

@implementation ZYQAssetViewController

- (id)init
{
    _indexPathsForSelectedItems=[[NSMutableArray alloc] init];

    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        self.tableView.contentInset=UIEdgeInsetsMake(9.0, 2.0, 0, 2.0);

        minimumInteritemSpacing=3;
        minimumLineSpacing=3;

    }
    else
    {
        self.tableView.contentInset=UIEdgeInsetsMake(9.0, 0, 0, 0);

        minimumInteritemSpacing=2;
        minimumLineSpacing=2;
    }

    if (self = [super init])
    {
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
            [self setEdgesForExtendedLayout:UIRectEdgeNone];

        if ([self respondsToSelector:@selector(setContentSizeForViewInPopover:)])
            [self setContentSizeForViewInPopover:kPopoverContentSize];
    }

    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//合成视频需要的数据数据


    self.urlIdx = 0;
    self.currentRect1 = CGRectMake(90, 0,280, 300);
    self.currentRect2 = CGRectMake(120, 30,220, 250);
    self.currentRect3 = CGRectMake(160,80,320, 350);
    self.currentRect4 = CGRectMake(90, 0,300, 350);


//   相片传入数组





//    ZYQAssetViewController将要出现


    self.tableView.separatorStyle= UITableViewCellSeparatorStyleSingleLine;
    [self setupViews];
    [self setupButtons];


}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!unFirst) {
        columns=floor(self.view.frame.size.width/(kThumbnailSize.width+minimumInteritemSpacing));

        [self setupAssets];

        unFirst=YES;
    }
}
-(void)showZYQAssetViewController{

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    // window.rootViewController = self;
    //使用延展的方法的方法修改frame
    self.view.y = window.height;
    //开始动画之前,关闭用户交互
    window.userInteractionEnabled = NO;

    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:1 animations:^{

        weakSelf.view.y = 300;

    } completion:^(BOOL finished) {

        window.userInteractionEnabled = YES;


    }];







}


#pragma mark - Rotation
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        self.tableView.contentInset=UIEdgeInsetsMake(9.0, 0, 0, 0);

        minimumInteritemSpacing=3;
        minimumLineSpacing=3;
    }
    else
    {
        self.tableView.contentInset=UIEdgeInsetsMake(9.0, 0, 0, 0);

        minimumInteritemSpacing=2;
        minimumLineSpacing=2;
    }

    columns=floor(self.view.frame.size.width/(kThumbnailSize.width+minimumInteritemSpacing));

    [self.tableView reloadData];
}

#pragma mark - Setup

- (void)setupViews
{

    self.tableView.backgroundColor = [UIColor blackColor];



}

- (void)setupButtons
{
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"完成", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(finishPickingAssets:)];
}

- (void)setupAssets
{
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    self.numberOfPhotos = 0;
    self.numberOfVideos = 0;

    if (!self.assets)
        self.assets = [[NSMutableArray alloc] init];
    else
        [self.assets removeAllObjects];

    ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {



//        此处可改
        if (asset && [[asset valueForProperty:ALAssetPropertyType]isEqual:ALAssetTypePhoto])
        {
            [self.assets addObject:asset];

            NSString *type = [asset valueForProperty:ALAssetPropertyType];

            if ([type isEqual:ALAssetTypePhoto])
                self.numberOfPhotos ++;
            if ([type isEqual:ALAssetTypeVideo])
                self.numberOfVideos ++;
        }

        else if (self.assets.count > 0)
        {
            [self.tableView reloadData];

            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:ceil(self.assets.count*1.0/columns)  inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    };

    [self.assetsGroup enumerateAssetsUsingBlock:resultsBlock];
}

#pragma mark - UITableView DataSource
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.row==ceil(self.assets.count*1.0/columns)) {
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cellFooter"];

        if (cell==nil) {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellFooter"];
            cell.textLabel.font=[UIFont systemFontOfSize:18];
            cell.textLabel.backgroundColor=[UIColor clearColor];
            cell.textLabel.textAlignment=NSTextAlignmentCenter;
            cell.textLabel.textColor=[UIColor blackColor];
            cell.backgroundColor=[UIColor clearColor];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }

        NSString *title;

        if (_numberOfVideos == 0)
            title = [NSString stringWithFormat:NSLocalizedString(@"%ld 张照片", nil), (long)_numberOfPhotos];
        else if (_numberOfPhotos == 0)
            title = [NSString stringWithFormat:NSLocalizedString(@"%ld 部视频", nil), (long)_numberOfVideos];
        else
            title = [NSString stringWithFormat:NSLocalizedString(@"%ld 张照片, %ld 部视频", nil), (long)_numberOfPhotos, (long)_numberOfVideos];
        cell.backgroundView.backgroundColor =  [UIColor colorWithRed:4/255.0 green:45/255.0 blue:8/255.0 alpha:1];


//        [UIColor colorWithRed:4/255.0 green:45/255.0 blue:8/255.0 alpha:1];
        cell.textLabel.text=title;
        return cell;
    }


    NSMutableArray *tempAssets=[[NSMutableArray alloc] init];
    for (int i=0; i<columns; i++) {
        if ((indexPath.row*columns+i)<self.assets.count) {
            [tempAssets addObject:[self.assets objectAtIndex:indexPath.row*columns+i]];
        }
    }

    static NSString *CellIdentifier = kAssetViewCellIdentifier;
    ZYQAssetPickerController *picker = (ZYQAssetPickerController *)self.navigationController;

    ZYQAssetViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell=[[ZYQAssetViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.delegate=self;

    [cell bind:tempAssets selectionFilter:picker.selectionFilter minimumInteritemSpacing:minimumInteritemSpacing minimumLineSpacing:minimumLineSpacing columns:columns assetViewX:(self.tableView.frame.size.width-kThumbnailSize.width*tempAssets.count-minimumInteritemSpacing*(tempAssets.count-1))/2];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ceil(self.assets.count*1.0/columns)+1;
}

#pragma mark - UITableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==ceil(self.assets.count*1.0/columns)) {
        return 44;
    }
    return kThumbnailSize.height+minimumLineSpacing;
}


#pragma mark - ZYQAssetViewCell Delegate

- (BOOL)shouldSelectAsset:(ALAsset *)asset
{
    ZYQAssetPickerController *vc = (ZYQAssetPickerController *)self.navigationController;
    BOOL selectable = [vc.selectionFilter evaluateWithObject:asset];
    if (_indexPathsForSelectedItems.count > vc.maximumNumberOfSelection) {
        if (vc.delegate!=nil&&[vc.delegate respondsToSelector:@selector(assetPickerControllerDidMaximum:)]) {
            [vc.delegate assetPickerControllerDidMaximum:vc];
        }
    }

    return (selectable && _indexPathsForSelectedItems.count < vc.maximumNumberOfSelection);
}

- (void)didSelectAsset:(ALAsset *)asset
{
    [_indexPathsForSelectedItems addObject:asset];
    
    ZYQAssetPickerController *vc = (ZYQAssetPickerController *)self.navigationController;
    vc.indexPathsForSelectedItems = _indexPathsForSelectedItems;

    if (vc.delegate!=nil&&[vc.delegate respondsToSelector:@selector(assetPickerController:didSelectAsset:)])
        [vc.delegate assetPickerController:vc didSelectAsset:asset];

    [self setTitleWithSelectedIndexPaths:_indexPathsForSelectedItems];
    
   // NSLog(@"%lu",(unsigned long)_indexPathsForSelectedItems.count);
}

- (void)didDeselectAsset:(ALAsset *)asset
{
    [_indexPathsForSelectedItems removeObject:asset];

    ZYQAssetPickerController *vc = (ZYQAssetPickerController *)self.navigationController;
    vc.indexPathsForSelectedItems = _indexPathsForSelectedItems;

    if (vc.delegate!=nil&&[vc.delegate respondsToSelector:@selector(assetPickerController:didDeselectAsset:)])
        [vc.delegate assetPickerController:vc didDeselectAsset:asset];

    [self setTitleWithSelectedIndexPaths:_indexPathsForSelectedItems];
}


#pragma mark - Title

- (void)setTitleWithSelectedIndexPaths:(NSArray *)indexPaths
{
    // Reset title to group name
    if (indexPaths.count == 0)
    {
        self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
        return;
    }

    BOOL photosSelected = NO;
    BOOL videoSelected  = NO;

    for (int i=0; i<indexPaths.count; i++) {
        ALAsset *asset = indexPaths[i];

        if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypePhoto])
            photosSelected  = YES;

        if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
            videoSelected   = YES;

        if (photosSelected && videoSelected)
            break;

    }

    NSString *format;

    if (photosSelected && videoSelected)
        format = NSLocalizedString(@"已选择 %ld 个项目", nil);

    else if (photosSelected)
        format = (indexPaths.count > 1) ? NSLocalizedString(@"已选择 %ld 张照片", nil) : NSLocalizedString(@"已选择 %ld 张照片 ", nil);

    else if (videoSelected)
        format = (indexPaths.count > 1) ? NSLocalizedString(@"已选择 %ld 部视频", nil) : NSLocalizedString(@"已选择 %ld 部视频 ", nil);

    self.title = [NSString stringWithFormat:format, (long)indexPaths.count];
}


#pragma mark - Actions
//=====================================================




// 获取到选择的照片放到数组中
//-(void)getImageArray{
//
//    _imageArr =[[NSMutableArray alloc]initWithObjects:
//                [UIImage imageNamed:@"v6_guide_1"]
//                ,[UIImage imageNamed:@"v6_guide_2"],[UIImage imageNamed:@"v6_guide_3"],[UIImage imageNamed:@"v6_guide_4"],[UIImage imageNamed:@"v6_guide_5"],[UIImage imageNamed:@"v6_guide_6"],nil];
//}

//通过相片的地址将相片转换为image添加到数组
-(void)transformArrayWithblock:(GoBack)back{



    NSMutableArray * arr = [NSMutableArray new];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{


        for (int i=0; i<_indexPathsForSelectedItems.count; i++) {
            ALAsset *asset=_indexPathsForSelectedItems[i];



            UIImage *tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];

                [arr addObject:tempImg];


                 }


        dispatch_async(dispatch_get_main_queue(), ^{
            [PassMergeHandle sharedHandle].imageArray = arr;

            back(arr);
        });


         });



}



-(void)reformArrayWithblock:(ReGoBack)back{



    NSMutableArray * arr = [NSMutableArray new];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

      //  NSLog(@"  呵呵呵呵%lu",(unsigned long)_indexPathsForSelectedItems.count);
        for (int i=0; i<_indexPathsForSelectedItems.count; i++) {
            ALAsset *asset=_indexPathsForSelectedItems[i];



            UIImage *tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];

            [arr addObject:tempImg];


        }


        dispatch_async(dispatch_get_main_queue(), ^{


            back(arr);
        });


    });



}

//改变速度从新合成合成
-(void)changeSpeed{



    [self reformArrayWithblock:^(NSMutableArray* finish) {

        if (finish) {


            [self reMergeWithArr:finish andBlock:^(BOOL finish) {
                dispatch_async(dispatch_get_main_queue(), ^{

                    [PassMergeHandle sharedHandle].gotoChangeSpeed();

                });
                         }];
               }

    }];
}


///选择相册完成
- (void)finishPickingAssets:(id)sender
{




//          [self getImageArray];

    ZYQAssetPickerController *picker = (ZYQAssetPickerController *)self.navigationController;
     PhotoMVViewController  * phothMV = [[PhotoMVViewController alloc]init];


    picker.delegate = (id)phothMV;

    if (_indexPathsForSelectedItems.count < picker.minimumNumberOfSelection) {
        if (picker.delegate!=nil&&[picker.delegate respondsToSelector:@selector(assetPickerControllerDidMaximum:)]) {
            [picker.delegate assetPickerControllerDidMaximum:picker];
        }
    }

    if ([picker.delegate respondsToSelector:@selector(assetPickerController:didFinishPickingAssets:)])

    {

//

        [picker.delegate assetPickerController:picker didFinishPickingAssets:_indexPathsForSelectedItems];
    }
    if (picker.isFinishDismissViewController) {


//        [PassMergeHandle sharedHandle].passValueArray = _indexPathsForSelectedItems;
         [picker.delegate assetPickerController:picker didFinishPickingAssets:_indexPathsForSelectedItems];



         [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        [self transformArrayWithblock:^(NSMutableArray* finish) {

            if (finish) {


                [self movieMergeWithArr:finish andBlock:^(BOOL finish) {
               dispatch_async(dispatch_get_main_queue(), ^{



//
                   if (self.presentedViewController == nil)

                   {

                       __weak typeof (self)welf = self;

                           [MBProgressHUD hideHUDForView:welf.view animated:YES];
                [PassMergeHandle sharedHandle].zyqblock( [PassMergeHandle sharedHandle].zyq);

                     [self  dismissViewControllerAnimated:YES completion:nil];

                   }

               });

                }];

            }

        }];
           }

}





//开始合成视频

-(void)movieMergeWithArr:(NSMutableArray* )imgArray andBlock:(GoBackWithBool)back{



//    NSLog(@"开始");
    //NSString *moviePath = [[NSBundle mainBundle]pathForResource:@"Movie" ofType:@"mov"];
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *moviePath =[[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",@"test"]];
    self.theVideoPath = moviePath;
//    完成之后删除之前的
//        if([[NSFileManager defaultManager] fileExistsAtPath:moviePath]){
//            [[NSFileManager defaultManager] removeItemAtPath:moviePath error:nil];
//        }

    [PassMergeHandle sharedHandle].pathString = self.theVideoPath;

//    self.themeArr = [[NSMutableArray alloc]init];
//
//    for (int i = 0; i < 5 ; i++) {
//
//        NSString *Path =[[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"mask%d.mp4",i+1]];
//
//
//
//
//        [self.themeArr addObject:Path];
//
//        NSLog(@"阿斯顿发生大是大非%@",Path);
//    }



    __block CGSize size =CGSizeMake(480, 320);//定义视频的大小
    //
    //    [selfwriteImages:imageArr ToMovieAtPath:moviePath withSize:sizeinDuration:4 byFPS:30];//第2中方法

    NSError *error = nil;

    unlink([moviePath UTF8String]);
//    NSLog(@"path->%@",moviePath);
    //—-initialize compression engine
    AVAssetWriter *videoWriter =[[AVAssetWriter alloc]initWithURL:[NSURL fileURLWithPath:moviePath]
                                                         fileType:AVFileTypeQuickTimeMovie
                                                            error:&error];
    NSParameterAssert(videoWriter);
    if(error)
        NSLog(@"error =%@", [error localizedDescription]);

    NSDictionary *videoSettings =[NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264,AVVideoCodecKey,
                                  [NSNumber numberWithInt:size.width],AVVideoWidthKey,
                                  [NSNumber numberWithInt:size.height],AVVideoHeightKey,nil];
    AVAssetWriterInput *writerInput =[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];

    NSDictionary*sourcePixelBufferAttributesDictionary =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB],kCVPixelBufferPixelFormatTypeKey,nil];

    AVAssetWriterInputPixelBufferAdaptor *adaptor =[AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    //                                                    assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInputsourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);

    if ([videoWriter canAddInput:writerInput])
         NSLog(@"");
    else
        NSLog(@"");

    [videoWriter addInput:writerInput];

    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];

    //合成多张图片为一个视频文件
    dispatch_queue_t dispatchQueue =dispatch_queue_create("mediaInputQueue",NULL);
    int __block frame =0;

    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{


        while([writerInput isReadyForMoreMediaData])
        {


            if(++frame >=[imgArray count]*10)
            {
                [writerInput markAsFinished];

                [videoWriter finishWritingWithCompletionHandler:^{
                    
                }];

        //                              [videoWriterfinishWritingWithCompletionHandler:nil];
                break;
            }

            CVPixelBufferRef buffer = NULL;

            int idx =frame/10;

            self.currentIdx = idx;
            if (idx % 4 ==  0 && frame % 10 == 0) {
                self.changeRect = self.currentRect1;

            }
            if (idx ==  0 && frame % 10 == 1) {

                self.changeRect = self.currentRect1;

            }
            if (idx % 4 ==  1 && frame % 10 == 0) {

                self.changeRect = self.currentRect2;

            }
            if (idx % 4 ==  2 && frame % 10 == 0) {

                self.changeRect = self.currentRect3;

            }

            if (idx % 4 ==  3 && frame % 10 == 0) {

                self.changeRect = self.currentRect4;

            }

            if (frame % 10 == 9) {


                self.changeRect = self.currentRect5;

            }

            buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[[imgArray objectAtIndex:idx]CGImage] size:size];
            


            if (buffer)
            {

            if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame,(int)[PassMergeHandle sharedHandle].speed)])
                    NSLog(@"");
                else
                    NSLog(@"");
                CFRelease(buffer);
            }
        }

        back(YES);

       }];

}
-(void)reMergeWithArr:(NSMutableArray* )imgArray andBlock:(ReGoBackWithBool)back{

    //NSString *moviePath = [[NSBundle mainBundle]pathForResource:@"Movie" ofType:@"mov"];
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *moviePath =[[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",@"test"]];
    self.theVideoPath = moviePath;



    [PassMergeHandle sharedHandle].pathString = self.theVideoPath;

    self.themeArr = [[NSMutableArray alloc]init];

    for (int i = 0; i < 5 ; i++) {

        NSString *Path =[[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"m%d.mp4",i+1]];

        [self.themeArr addObject:Path];


    }



    NSString *moviePath2 =[[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",@"mask3"]];

    self.theVideoPath2 =moviePath2;


    __block CGSize size =CGSizeMake(480, 320);//定义视频的大小
    //
    //    [selfwriteImages:imageArr ToMovieAtPath:moviePath withSize:sizeinDuration:4 byFPS:30];//第2中方法

    NSError *error = nil;

    unlink([moviePath UTF8String]);

    //—-initialize compression engine
    AVAssetWriter *videoWriter =[[AVAssetWriter alloc]initWithURL:[NSURL fileURLWithPath:moviePath]
                                                         fileType:AVFileTypeQuickTimeMovie
                                                            error:&error];
    NSParameterAssert(videoWriter);
//    if(error)
//        NSLog(@"error =%@", [error localizedDescription]);

    NSDictionary *videoSettings =[NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264,AVVideoCodecKey,
                                  [NSNumber numberWithInt:size.width],AVVideoWidthKey,
                                  [NSNumber numberWithInt:size.height],AVVideoHeightKey,nil];
    AVAssetWriterInput *writerInput =[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];

    NSDictionary*sourcePixelBufferAttributesDictionary =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB],kCVPixelBufferPixelFormatTypeKey,nil];

    AVAssetWriterInputPixelBufferAdaptor *adaptor =[AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    //                                                    assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInputsourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);

    if ([videoWriter canAddInput:writerInput])
        NSLog(@"");
    else
        NSLog(@"");

    [videoWriter addInput:writerInput];

    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];

    //合成多张图片为一个视频文件
    dispatch_queue_t dispatchQueue =dispatch_queue_create("mediaInputQueue",NULL);
    int __block frame =0;

    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{


        while([writerInput isReadyForMoreMediaData])
        {


            if(++frame >=[imgArray count]*10)
            {
                [writerInput markAsFinished];

                [videoWriter finishWritingWithCompletionHandler:^{
                  
                }];



                //                              [videoWriterfinishWritingWithCompletionHandler:nil];
                break;
            }

            CVPixelBufferRef buffer =NULL;

            int idx =frame/10;




            self.currentIdx = idx;
            if (idx % 4 ==  0 && frame % 10 == 0) {
                self.changeRect = self.currentRect1;

            }
            if (idx ==  0 && frame % 10 == 1) {

                self.changeRect = self.currentRect1;

            }
            if (idx % 4 ==  1 && frame % 10 == 0) {

                self.changeRect = self.currentRect2;

            }
            if (idx % 4 ==  2 && frame % 10 == 0) {

                self.changeRect = self.currentRect3;

            }

            if (idx % 4 ==  3 && frame % 10 == 0) {

                self.changeRect = self.currentRect4;

            }

            if (frame % 10 == 9) {


                self.changeRect = self.currentRect5;

            }





            buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[[imgArray objectAtIndex:idx]CGImage] size:size];



            if (buffer)
            {


                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame,(int)[PassMergeHandle sharedHandle].speed)])
                    NSLog(@"");

                else
                    NSLog(@"");
                CFRelease(buffer);

            }
        }


        back(YES);


    }];



}

- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size
{
    NSDictionary *options =[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGImageCompatibilityKey,
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGBitmapContextCompatibilityKey,nil];
    CVPixelBufferRef pxbuffer =NULL;



    CVReturn status =CVPixelBufferCreate(kCFAllocatorDefault,size.width,size.height,kCVPixelFormatType_32ARGB,(__bridge CFDictionaryRef) options,&pxbuffer);



    NSParameterAssert(status == kCVReturnSuccess && pxbuffer !=NULL);



    CVPixelBufferLockBaseAddress(pxbuffer,0);

    void *pxdata =CVPixelBufferGetBaseAddress(pxbuffer);


    NSParameterAssert(pxdata != NULL);

    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    //    CGContextRef context =CGBitmapContextCreate(pxdata,size.width,size.height,8,4*size.width,rgbColorSpace,kCGImageAlphaPremultipliedFirst);



    CGContextRef context =CGBitmapContextCreate(pxdata,size.width,size.height,8,4*size.width,rgbColorSpace,kCGImageAlphaPremultipliedFirst);

    NSParameterAssert(context);



    CGContextDrawImage(context, self.changeRect, image);

    if (self.currentIdx % 4 ==  0 ) {
        _changeRect.origin.x =   _changeRect.origin.x + 1;



        _changeRect.origin.y =   _changeRect.origin.y + 1;
        _changeRect.size.height =    _changeRect.size.height + 1;

        _changeRect.size.width =    _changeRect.size.width + 1;


    }


    if (self.currentIdx % 4 ==  1  ) {
        _changeRect.origin.x =   _changeRect.origin.x - 1;
        _changeRect.origin.y =   _changeRect.origin.y + 1;
        _changeRect.size.height =    _changeRect.size.height + 1;

        _changeRect.size.width =    _changeRect.size.width + 1;


    }


    if (self.currentIdx % 4 ==  2 ) {
        _changeRect.origin.x =   _changeRect.origin.x - 10;
        _changeRect.origin.y =   _changeRect.origin.y - 10;
        _changeRect.size.height =    _changeRect.size.height + 1;
        _changeRect.size.width =    _changeRect.size.width + 1;


    }



    if (self.currentIdx % 4 ==  3) {
        _changeRect.origin.x =   _changeRect.origin.x + 1;
        _changeRect.origin.y =   _changeRect.origin.y + 1;
        _changeRect.size.height =  _changeRect.size.height + 1;

        _changeRect.size.width = _changeRect.size.width + 1;


    }


    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);

    CVPixelBufferUnlockBaseAddress(pxbuffer,0);



    return pxbuffer;
}




@end
