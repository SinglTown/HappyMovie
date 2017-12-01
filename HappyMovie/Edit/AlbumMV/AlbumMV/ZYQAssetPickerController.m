//
//  ZYQAssetPickerController.m
//  ZYQAssetPickerControllerDemo
//
//  Created by Zhao Yiqi on 13-12-25.
//  Copyright (c) 2013年 heroims. All rights reserved.
//

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

#pragma mark -

@interface NSDate (TimeInterval)

+ (NSDateComponents *)componetsWithTimeInterval:(NSTimeInterval)timeInterval;
+ (NSString *)timeDescriptionOfTimeInterval:(NSTimeInterval)timeInterval;

@end

@implementation NSDate (TimeInterval)

+ (NSDateComponents *)componetsWithTimeInterval:(NSTimeInterval)timeInterval
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *date1 = [[NSDate alloc] init];
    NSDate *date2 = [[NSDate alloc] initWithTimeInterval:timeInterval sinceDate:date1];
    
    unsigned int unitFlags =
    NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit |
    NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    
    return [calendar components:unitFlags
                       fromDate:date1
                         toDate:date2
                        options:0];
}

+ (NSString *)timeDescriptionOfTimeInterval:(NSTimeInterval)timeInterval
{
    NSDateComponents *components = [self.class componetsWithTimeInterval:timeInterval];
    NSInteger roundedSeconds = lround(timeInterval - (components.hour * 60) - (components.minute * 60 * 60));
    
    if (components.hour > 0)
    {
        return [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)components.hour, (long)components.minute, (long)roundedSeconds];
    }
    
    else
    {
        return [NSString stringWithFormat:@"%ld:%02ld", (long)components.minute, (long)roundedSeconds];
    }
}

@end

#pragma mark - ZYQAssetPickerController

@interface ZYQAssetPickerController ()

//@property (nonatomic, copy) NSArray *indexPathsForSelectedItems;

@end

#pragma mark - ZYQVideoTitleView

@implementation ZYQVideoTitleView

-(void)drawRect:(CGRect)rect{
    CGFloat colors [] = {
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.8,
        0.0, 0.0, 0.0, 1.0
    };
    
    CGFloat locations [] = {0.0, 0.75, 1.0};
    
    CGColorSpaceRef baseSpace   = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient      = CGGradientCreateWithColorComponents(baseSpace, colors, locations, 2);
    
    CGContextRef context    = UIGraphicsGetCurrentContext();
    
    CGFloat height          = rect.size.height;
    CGPoint startPoint      = CGPointMake(CGRectGetMidX(rect), height);
    CGPoint endPoint        = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint,kCGGradientDrawsBeforeStartLocation);
    
    CGSize titleSize        = [self.text sizeWithFont:self.font];
    [self.textColor set];
    [self.text drawAtPoint:CGPointMake(rect.size.width - titleSize.width - 2 , (height - 12) / 2)
                   forWidth:kThumbnailLength
                   withFont:self.font
                   fontSize:12
              lineBreakMode:NSLineBreakByTruncatingTail
         baselineAdjustment:UIBaselineAdjustmentAlignCenters];

    UIImage *videoIcon=[UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ZYQAssetPicker.Bundle/Images/AssetsPickerVideo@2x.png"]];
    
    [videoIcon drawAtPoint:CGPointMake(2, (height - videoIcon.size.height) / 2)];
    
}

@end

#pragma mark - ZYQTapAssetView

@interface ZYQTapAssetView ()

@property(nonatomic,retain)UIImageView *selectView;

@end

@implementation ZYQTapAssetView

static UIImage *checkedIcon;
static UIColor *selectedColor;
static UIColor *disabledColor;

+ (void)initialize
{
    checkedIcon     = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"ZYQAssetPicker.Bundle/Images/%@@2x.png",(!IS_IOS7) ? @"AssetsPickerChecked~iOS6" : @"AssetsPickerChecked"]]];
    selectedColor   = [UIColor colorWithWhite:1 alpha:0.3];
    disabledColor   = [UIColor colorWithWhite:1 alpha:0.9];
}

-(id)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        _selectView=[[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width-checkedIcon.size.width, frame.size.height-checkedIcon.size.height, checkedIcon.size.width, checkedIcon.size.height)];
        [self addSubview:_selectView];
    }
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_disabled) {
        return;
    }
    
    if (_delegate!=nil&&[_delegate respondsToSelector:@selector(shouldTap)]) {
        if (![_delegate shouldTap]&&!_selected) {
            return;
        }
    }

    if ((_selected=!_selected)) {
        self.backgroundColor=selectedColor;
        [_selectView setImage:checkedIcon];
    }
    else{
        self.backgroundColor=[UIColor clearColor];
        [_selectView setImage:nil];
    }
    if (_delegate!=nil&&[_delegate respondsToSelector:@selector(touchSelect:)]) {
        [_delegate touchSelect:_selected];
    }
}

-(void)setDisabled:(BOOL)disabled{
    _disabled=disabled;
    if (_disabled) {
        self.backgroundColor=disabledColor;
    }
    else{
        self.backgroundColor=[UIColor clearColor];
    }
}

-(void)setSelected:(BOOL)selected{
    if (_disabled) {
        self.backgroundColor=disabledColor;
        [_selectView setImage:nil];
        return;
    }

    _selected=selected;
    if (_selected) {
        self.backgroundColor=selectedColor;
        [_selectView setImage:checkedIcon];
    }
    else{
        self.backgroundColor=[UIColor clearColor];
        [_selectView setImage:nil];
    }
}

@end

#pragma mark - ZYQAssetView

@interface ZYQAssetView ()<ZYQTapAssetViewDelegate>

@property (nonatomic, strong) ALAsset *asset;

@property (nonatomic, weak) id<ZYQAssetViewDelegate> delegate;

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) ZYQVideoTitleView *videoTitle;
@property (nonatomic, retain) ZYQTapAssetView *tapAssetView;

@end

@implementation ZYQAssetView

static UIFont *titleFont = nil;

static CGFloat titleHeight;
static UIColor *titleColor;

+ (void)initialize
{
    titleFont       = [UIFont systemFontOfSize:12];
    titleHeight     = 20.0f;
    titleColor      = [UIColor whiteColor];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.opaque                     = YES;
        self.isAccessibilityElement     = YES;
        self.accessibilityTraits        = UIAccessibilityTraitImage;
        
        _imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kThumbnailSize.width, kThumbnailSize.height)];
        [self addSubview:_imageView];
        
        _videoTitle=[[ZYQVideoTitleView alloc] initWithFrame:CGRectMake(0, kThumbnailSize.height-20, kThumbnailSize.width, titleHeight)];
        _videoTitle.hidden=YES;
        _videoTitle.font=titleFont;
        _videoTitle.textColor=titleColor;
        _videoTitle.textAlignment=NSTextAlignmentRight;
        _videoTitle.backgroundColor=[UIColor clearColor];
        [self addSubview:_videoTitle];
        
        _tapAssetView=[[ZYQTapAssetView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _tapAssetView.delegate=self;
        [self addSubview:_tapAssetView];
    }
    
    return self;
}

- (void)bind:(ALAsset *)asset selectionFilter:(NSPredicate*)selectionFilter isSeleced:(BOOL)isSeleced
{
    self.asset=asset;
    
    [_imageView setImage:[UIImage imageWithCGImage:asset.thumbnail]];
    
    if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
        _videoTitle.hidden=NO;
        _videoTitle.text=[NSDate timeDescriptionOfTimeInterval:[[asset valueForProperty:ALAssetPropertyDuration] doubleValue]];
    }
    else{
        _videoTitle.hidden=YES;
    }
    
    _tapAssetView.disabled=! [selectionFilter evaluateWithObject:asset];
    
    _tapAssetView.selected=isSeleced;
}

#pragma mark - ZYQTapAssetView Delegate

-(BOOL)shouldTap{
    if (_delegate!=nil&&[_delegate respondsToSelector:@selector(shouldSelectAsset:)]) {
        return [_delegate shouldSelectAsset:_asset];
    }
    return YES;
}

-(void)touchSelect:(BOOL)select{
    if (_delegate!=nil&&[_delegate respondsToSelector:@selector(tapSelectHandle:asset:)]) {
        [_delegate tapSelectHandle:select asset:_asset];
    }
}

@end

#pragma mark - ZYQAssetViewCell

@interface ZYQAssetViewCell ()<ZYQAssetViewDelegate>

@end

@class ZYQAssetViewController;



@implementation ZYQAssetViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void)bind:(NSArray *)assets selectionFilter:(NSPredicate*)selectionFilter minimumInteritemSpacing:(float)minimumInteritemSpacing minimumLineSpacing:(float)minimumLineSpacing columns:(int)columns assetViewX:(float)assetViewX{
    
    if (self.contentView.subviews.count<assets.count) {
        for (int i=0; i<assets.count; i++) {
            if (i>((NSInteger)self.contentView.subviews.count-1)) {
                ZYQAssetView *assetView=[[ZYQAssetView alloc] initWithFrame:CGRectMake(assetViewX+(kThumbnailSize.width+minimumInteritemSpacing)*i, minimumLineSpacing-1, kThumbnailSize.width, kThumbnailSize.height)];
                [assetView bind:assets[i] selectionFilter:selectionFilter isSeleced:[((ZYQAssetViewController*)_delegate).indexPathsForSelectedItems containsObject:assets[i]]];
                assetView.delegate=self;
                [self.contentView addSubview:assetView];
            }
            else{
                ((ZYQAssetView*)self.contentView.subviews[i]).frame=CGRectMake(assetViewX+(kThumbnailSize.width+minimumInteritemSpacing)*(i), minimumLineSpacing-1, kThumbnailSize.width, kThumbnailSize.height);
                [(ZYQAssetView*)self.contentView.subviews[i] bind:assets[i] selectionFilter:selectionFilter isSeleced:[((ZYQAssetViewController*)_delegate).indexPathsForSelectedItems containsObject:assets[i]]];
            }

        }
        
    }
    else{
        for (int i=(int)self.contentView.subviews.count; i>0; i--) {
            if (i>assets.count) {
                [((ZYQAssetView*)self.contentView.subviews[i-1]) removeFromSuperview];
            }
            else{
                ((ZYQAssetView*)self.contentView.subviews[i-1]).frame=CGRectMake(assetViewX+(kThumbnailSize.width+minimumInteritemSpacing)*(i-1), minimumLineSpacing-1, kThumbnailSize.width, kThumbnailSize.height);
                [(ZYQAssetView*)self.contentView.subviews[i-1] bind:assets[i-1] selectionFilter:selectionFilter isSeleced:[((ZYQAssetViewController*)_delegate).indexPathsForSelectedItems containsObject:assets[i-1]]];
            }
        }
    }
    
  
    
    
    
}

#pragma mark - ZYQAssetView Delegate

-(BOOL)shouldSelectAsset:(ALAsset *)asset{
    if (_delegate!=nil&&[_delegate respondsToSelector:@selector(shouldSelectAsset:)]) {
        return [_delegate shouldSelectAsset:asset];
    }
    return YES;
}

-(void)tapSelectHandle:(BOOL)select asset:(ALAsset *)asset{
    if (select) {
        if (_delegate!=nil&&[_delegate respondsToSelector:@selector(didSelectAsset:)]) {
            [_delegate didSelectAsset:asset];
        }
    }
    else{
        if (_delegate!=nil&&[_delegate respondsToSelector:@selector(didDeselectAsset:)]) {
            [_delegate didDeselectAsset:asset];
        }
    }
}

@end

//#pragma mark - ZYQAssetViewController
//
//@interface ZYQAssetViewController ()<ZYQAssetViewCellDelegate,PhotoMVViewControllerplayerButtonDelegate>{
//    int columns;
//    
//    float minimumInteritemSpacing;
//    float minimumLineSpacing;
//    
//    BOOL unFirst;
//  
//        UIButton *btn;
//        
//        UIScrollView *src;
//        
//        UIPageControl *pageControl;
//  
//}
//
//@property (nonatomic, strong) NSMutableArray *assets;
//@property (nonatomic, assign) NSInteger numberOfPhotos;
//@property (nonatomic, assign) NSInteger numberOfVideos;
//
//@property(nonatomic,strong)NSString*theVideoPath;
//@property(nonatomic,strong)NSMutableArray*imageArr;
//@property(nonatomic,strong)AVMutableVideoComposition*composition;
//@property(nonatomic,assign)CGRect currentRect1;
//@property(nonatomic,assign)CGRect currentRect2;
//@property(nonatomic,assign)CGRect currentRect3;
//@property(nonatomic,assign)CGRect currentRect4;
//@property(nonatomic,assign)CGRect currentRect5;
//@property(nonatomic,assign)CGRect changeRect;
//@property(nonatomic,assign)int currentIdx;
//@property(nonatomic,strong)AVPlayer *player;
//@property(nonatomic,strong)AVPlayer *player2;
//@property(nonatomic,strong)NSString*theVideoPath2;
//@property(nonatomic,strong)NSTimer * timer;
//
//@property(nonatomic,strong)NSMutableArray *themeArr;
//
//@property(nonatomic,assign)int urlIdx;
//
//@property(nonatomic,strong)ZYQAssetViewController * ZYQAVC;
//@end
//
//#define kAssetViewCellIdentifier           @"AssetViewCellIdentifier"
//
//@implementation ZYQAssetViewController
//
//- (id)init
//{
//    _indexPathsForSelectedItems=[[NSMutableArray alloc] init];
//    
//    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
//    {
//        self.tableView.contentInset=UIEdgeInsetsMake(9.0, 2.0, 0, 2.0);
//        
//        minimumInteritemSpacing=3;
//        minimumLineSpacing=3;
//        
//    }
//    else
//    {
//        self.tableView.contentInset=UIEdgeInsetsMake(9.0, 0, 0, 0);
//        
//        minimumInteritemSpacing=2;
//        minimumLineSpacing=2;
//    }
//    
//    if (self = [super init])
//    {
//        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
//            [self setEdgesForExtendedLayout:UIRectEdgeNone];
//        
//        if ([self respondsToSelector:@selector(setContentSizeForViewInPopover:)])
//            [self setContentSizeForViewInPopover:kPopoverContentSize];
//    }
//    
//    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//    return self;
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
////合成视频需要的数据数据
//    
//    
//    self.urlIdx = 0;
//    self.currentRect1 = CGRectMake(90, 0,280, 300);
//    self.currentRect2 = CGRectMake(120, 30,220, 250);
//    self.currentRect3 = CGRectMake(160,80,320, 350);
//    self.currentRect4 = CGRectMake(90, 0,300, 350);
//    
//    
////   相片传入数组
//   
//
//    
//    
//    
////    ZYQAssetViewController将要出现
//    
//  
//    self.tableView.separatorStyle= UITableViewCellSeparatorStyleSingleLine;
//    [self setupViews];
//    [self setupButtons];
//    
//       
//}
//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    if (!unFirst) {
//        columns=floor(self.view.frame.size.width/(kThumbnailSize.width+minimumInteritemSpacing));
//        
//        [self setupAssets];
//        
//        unFirst=YES;
//    }
//}
//-(void)showZYQAssetViewController{
//    
//    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    [window addSubview:self.view];
//    // window.rootViewController = self;
//    //使用延展的方法的方法修改frame
//    self.view.y = window.height;
//    //开始动画之前,关闭用户交互
//    window.userInteractionEnabled = NO;
//    
//    __weak typeof(self)weakSelf = self;
//    [UIView animateWithDuration:1 animations:^{
//        
//        weakSelf.view.y = 300;
//        
//    } completion:^(BOOL finished) {
// 
//        window.userInteractionEnabled = YES;
//     
//        
//    }];
//
//    
//    
//    
//    
//    
//    
//}
//
//
//#pragma mark - Rotation
//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
//    {
//        self.tableView.contentInset=UIEdgeInsetsMake(9.0, 0, 0, 0);
//        
//        minimumInteritemSpacing=3;
//        minimumLineSpacing=3;
//    }
//    else
//    {
//        self.tableView.contentInset=UIEdgeInsetsMake(9.0, 0, 0, 0);
//        
//        minimumInteritemSpacing=2;
//        minimumLineSpacing=2;
//    }
//    
//    columns=floor(self.view.frame.size.width/(kThumbnailSize.width+minimumInteritemSpacing));
//
//    [self.tableView reloadData];
//}
//
//#pragma mark - Setup
//
//- (void)setupViews
//{
//
//    self.tableView.backgroundColor = [UIColor blackColor];
//    
//    
//    
//}
//
//- (void)setupButtons
//{
//    self.navigationItem.rightBarButtonItem =
//    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"完成", nil)
//                                     style:UIBarButtonItemStylePlain
//                                    target:self
//                                    action:@selector(finishPickingAssets:)];
//}
//
//- (void)setupAssets
//{
//    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
//    self.numberOfPhotos = 0;
//    self.numberOfVideos = 0;
//    
//    if (!self.assets)
//        self.assets = [[NSMutableArray alloc] init];
//    else
//        [self.assets removeAllObjects];
//    
//    ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
//        
//        
//        
////        此处可改
//        if (asset && [[asset valueForProperty:ALAssetPropertyType]isEqual:ALAssetTypePhoto])
//        {
//            [self.assets addObject:asset];
//            
//            NSString *type = [asset valueForProperty:ALAssetPropertyType];
//            
//            if ([type isEqual:ALAssetTypePhoto])
//                self.numberOfPhotos ++;
//            if ([type isEqual:ALAssetTypeVideo])
//                self.numberOfVideos ++;
//        }
//        
//        else if (self.assets.count > 0)
//        {
//            [self.tableView reloadData];
//
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:ceil(self.assets.count*1.0/columns)  inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//        }
//    };
//    
//    [self.assetsGroup enumerateAssetsUsingBlock:resultsBlock];
//}
//
//#pragma mark - UITableView DataSource
//-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    if (indexPath.row==ceil(self.assets.count*1.0/columns)) {
//        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cellFooter"];
//        
//        if (cell==nil) {
//            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellFooter"];
//            cell.textLabel.font=[UIFont systemFontOfSize:18];
//            cell.textLabel.backgroundColor=[UIColor clearColor];
//            cell.textLabel.textAlignment=NSTextAlignmentCenter;
//            cell.textLabel.textColor=[UIColor blackColor];
//            cell.backgroundColor=[UIColor clearColor];
//            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//        }
//        
//        NSString *title;
//        
//        if (_numberOfVideos == 0)
//            title = [NSString stringWithFormat:NSLocalizedString(@"%ld 张照片", nil), (long)_numberOfPhotos];
//        else if (_numberOfPhotos == 0)
//            title = [NSString stringWithFormat:NSLocalizedString(@"%ld 部视频", nil), (long)_numberOfVideos];
//        else
//            title = [NSString stringWithFormat:NSLocalizedString(@"%ld 张照片, %ld 部视频", nil), (long)_numberOfPhotos, (long)_numberOfVideos];
//        cell.backgroundView.backgroundColor =  [UIColor colorWithRed:4/255.0 green:45/255.0 blue:8/255.0 alpha:1];
//        
//        
////        [UIColor colorWithRed:4/255.0 green:45/255.0 blue:8/255.0 alpha:1];
//        cell.textLabel.text=title;
//        return cell;
//    }
//    
//    
//    NSMutableArray *tempAssets=[[NSMutableArray alloc] init];
//    for (int i=0; i<columns; i++) {
//        if ((indexPath.row*columns+i)<self.assets.count) {
//            [tempAssets addObject:[self.assets objectAtIndex:indexPath.row*columns+i]];
//        }
//    }
//    
//    static NSString *CellIdentifier = kAssetViewCellIdentifier;
//    ZYQAssetPickerController *picker = (ZYQAssetPickerController *)self.navigationController;
//    
//    ZYQAssetViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell==nil) {
//        cell=[[ZYQAssetViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
//    cell.delegate=self;
//
//    [cell bind:tempAssets selectionFilter:picker.selectionFilter minimumInteritemSpacing:minimumInteritemSpacing minimumLineSpacing:minimumLineSpacing columns:columns assetViewX:(self.tableView.frame.size.width-kThumbnailSize.width*tempAssets.count-minimumInteritemSpacing*(tempAssets.count-1))/2];
//    return cell;
//}
//
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return ceil(self.assets.count*1.0/columns)+1;
//}
//
//#pragma mark - UITableView Delegate
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.row==ceil(self.assets.count*1.0/columns)) {
//        return 44;
//    }
//    return kThumbnailSize.height+minimumLineSpacing;
//}
//
//
//#pragma mark - ZYQAssetViewCell Delegate
//
//- (BOOL)shouldSelectAsset:(ALAsset *)asset
//{
//    ZYQAssetPickerController *vc = (ZYQAssetPickerController *)self.navigationController;
//    BOOL selectable = [vc.selectionFilter evaluateWithObject:asset];
//    if (_indexPathsForSelectedItems.count > vc.maximumNumberOfSelection) {
//        if (vc.delegate!=nil&&[vc.delegate respondsToSelector:@selector(assetPickerControllerDidMaximum:)]) {
//            [vc.delegate assetPickerControllerDidMaximum:vc];
//        }
//    }
//    
//    return (selectable && _indexPathsForSelectedItems.count < vc.maximumNumberOfSelection);
//}
//
//- (void)didSelectAsset:(ALAsset *)asset
//{
//    [_indexPathsForSelectedItems addObject:asset];
//    
//    ZYQAssetPickerController *vc = (ZYQAssetPickerController *)self.navigationController;
//    vc.indexPathsForSelectedItems = _indexPathsForSelectedItems;
//    
//    if (vc.delegate!=nil&&[vc.delegate respondsToSelector:@selector(assetPickerController:didSelectAsset:)])
//        [vc.delegate assetPickerController:vc didSelectAsset:asset];
//    
//    [self setTitleWithSelectedIndexPaths:_indexPathsForSelectedItems];
//}
//
//- (void)didDeselectAsset:(ALAsset *)asset
//{
//    [_indexPathsForSelectedItems removeObject:asset];
//    
//    ZYQAssetPickerController *vc = (ZYQAssetPickerController *)self.navigationController;
//    vc.indexPathsForSelectedItems = _indexPathsForSelectedItems;
//    
//    if (vc.delegate!=nil&&[vc.delegate respondsToSelector:@selector(assetPickerController:didDeselectAsset:)])
//        [vc.delegate assetPickerController:vc didDeselectAsset:asset];
//    
//    [self setTitleWithSelectedIndexPaths:_indexPathsForSelectedItems];
//}
//
//
//#pragma mark - Title
//
//- (void)setTitleWithSelectedIndexPaths:(NSArray *)indexPaths
//{
//    // Reset title to group name
//    if (indexPaths.count == 0)
//    {
//        self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
//        return;
//    }
//    
//    BOOL photosSelected = NO;
//    BOOL videoSelected  = NO;
//    
//    for (int i=0; i<indexPaths.count; i++) {
//        ALAsset *asset = indexPaths[i];
//        
//        if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypePhoto])
//            photosSelected  = YES;
//        
//        if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
//            videoSelected   = YES;
//        
//        if (photosSelected && videoSelected)
//            break;
//
//    }
//    
//    NSString *format;
//    
//    if (photosSelected && videoSelected)
//        format = NSLocalizedString(@"已选择 %ld 个项目", nil);
//    
//    else if (photosSelected)
//        format = (indexPaths.count > 1) ? NSLocalizedString(@"已选择 %ld 张照片", nil) : NSLocalizedString(@"已选择 %ld 张照片 ", nil);
//    
//    else if (videoSelected)
//        format = (indexPaths.count > 1) ? NSLocalizedString(@"已选择 %ld 部视频", nil) : NSLocalizedString(@"已选择 %ld 部视频 ", nil);
//    
//    self.title = [NSString stringWithFormat:format, (long)indexPaths.count];
//}
//
//
//#pragma mark - Actions
////=====================================================
//
//
//
//
//// 获取到选择的照片放到数组中
////-(void)getImageArray{
////    
////    _imageArr =[[NSMutableArray alloc]initWithObjects:
////                [UIImage imageNamed:@"v6_guide_1"]
////                ,[UIImage imageNamed:@"v6_guide_2"],[UIImage imageNamed:@"v6_guide_3"],[UIImage imageNamed:@"v6_guide_4"],[UIImage imageNamed:@"v6_guide_5"],[UIImage imageNamed:@"v6_guide_6"],nil];
////}
//
////通过相片的地址将相片转换为image添加到数组
//-(void)transformArrayWithblock:(GoBack)back{
//   
//    
//  
//    NSMutableArray * arr = [NSMutableArray new];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//     
//      
//        for (int i=0; i<_indexPathsForSelectedItems.count; i++) {
//            ALAsset *asset=_indexPathsForSelectedItems[i];
//         
//         
//         
//            UIImage *tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
//            
//                [arr addObject:tempImg];
//            
//            
//                 }
//      
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [PassMergeHandle sharedHandle].imageArray = arr;
//            
//            back(arr);
//        });
//        
//        
//         });
//    
//    
//    
//}
//
//
//
//-(void)reformArrayWithblock:(ReGoBack)back{
//    
//    
//    
//    NSMutableArray * arr = [NSMutableArray new];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        
//        for (int i=0; i<_indexPathsForSelectedItems.count; i++) {
//            ALAsset *asset=_indexPathsForSelectedItems[i];
//            
//            
//            
//            UIImage *tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
//            
//            [arr addObject:tempImg];
//            
//            
//        }
//        
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            
//            back(arr);
//        });
//        
//        
//    });
//    
//    
//    
//}
//
////改变速度从新合成合成
//-(void)changeSpeed{
//    
//   
//    
//    [self reformArrayWithblock:^(NSMutableArray* finish) {
//        
//        if (finish) {
//            
//            
//            [self reMergeWithArr:finish andBlock:^(BOOL finish) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                   
//                    [PassMergeHandle sharedHandle].gotoChangeSpeed();
//                    
//                });
//                         }];
//               }
//        
//    }];
//}
//
//
/////选择相册完成
//- (void)finishPickingAssets:(id)sender
//{
//    
//    
//    
//    
////          [self getImageArray];
//    
//    ZYQAssetPickerController *picker = (ZYQAssetPickerController *)self.navigationController;
//     PhotoMVViewController  * phothMV = [[PhotoMVViewController alloc]init];
//    
//    
//    picker.delegate = phothMV;
//    
//    if (_indexPathsForSelectedItems.count < picker.minimumNumberOfSelection) {
//        if (picker.delegate!=nil&&[picker.delegate respondsToSelector:@selector(assetPickerControllerDidMaximum:)]) {
//            [picker.delegate assetPickerControllerDidMaximum:picker];
//        }
//    }
//   
//    if ([picker.delegate respondsToSelector:@selector(assetPickerController:didFinishPickingAssets:)])
//      
//    {
//        
////
//        
//        [picker.delegate assetPickerController:picker didFinishPickingAssets:_indexPathsForSelectedItems];
//    }
//    if (picker.isFinishDismissViewController) {
//        
//        
////        [PassMergeHandle sharedHandle].passValueArray = _indexPathsForSelectedItems;
//         [picker.delegate assetPickerController:picker didFinishPickingAssets:_indexPathsForSelectedItems];
//       
//        
//
//         [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        
//        [self transformArrayWithblock:^(NSMutableArray* finish) {
//            
//            if (finish) {
//                
//                
//                [self movieMergeWithArr:finish andBlock:^(BOOL finish) {
//               dispatch_async(dispatch_get_main_queue(), ^{
//                   
//                   
//                   
////                   
//                   if (self.presentedViewController == nil)
//                       
//                   {
//                       
//                       __weak typeof (self)welf = self;
//                    
//                           [MBProgressHUD hideHUDForView:welf.view animated:YES];
//
//
//                     [self  dismissViewControllerAnimated:YES completion:nil];
//        
//                   }
//
//               });
//
//                }];
//
//            }
//
//        }];
//           }
//
//}
//
//
//
//
//
////开始合成视频
//
//-(void)movieMergeWithArr:(NSMutableArray* )imgArray andBlock:(GoBackWithBool)back{
//  
//
//    
////    NSLog(@"开始");
//    //NSString *moviePath = [[NSBundle mainBundle]pathForResource:@"Movie" ofType:@"mov"];
//    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
//    NSString *moviePath =[[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",@"test"]];
//    self.theVideoPath = moviePath;
////    完成之后删除之前的
////        if([[NSFileManager defaultManager] fileExistsAtPath:moviePath]){
////            [[NSFileManager defaultManager] removeItemAtPath:moviePath error:nil];
////        }
//    
//    [PassMergeHandle sharedHandle].pathString = self.theVideoPath;
//    
////    self.themeArr = [[NSMutableArray alloc]init];
////
////    for (int i = 0; i < 5 ; i++) {
////        
////        NSString *Path =[[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"mask%d.mp4",i+1]];
////        
////        
////        
////        
////        [self.themeArr addObject:Path];
////        
////        NSLog(@"阿斯顿发生大是大非%@",Path);
////    }
//    
//    
//    
//    __block CGSize size =CGSizeMake(480, 320);//定义视频的大小
//    //
//    //    [selfwriteImages:imageArr ToMovieAtPath:moviePath withSize:sizeinDuration:4 byFPS:30];//第2中方法
//    
//    NSError *error = nil;
//    
//    unlink([moviePath UTF8String]);
////    NSLog(@"path->%@",moviePath);
//    //—-initialize compression engine
//    AVAssetWriter *videoWriter =[[AVAssetWriter alloc]initWithURL:[NSURL fileURLWithPath:moviePath]
//                                                         fileType:AVFileTypeQuickTimeMovie
//                                                            error:&error];
//    NSParameterAssert(videoWriter);
//    if(error)
//        NSLog(@"error =%@", [error localizedDescription]);
//    
//    NSDictionary *videoSettings =[NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264,AVVideoCodecKey,
//                                  [NSNumber numberWithInt:size.width],AVVideoWidthKey,
//                                  [NSNumber numberWithInt:size.height],AVVideoHeightKey,nil];
//    AVAssetWriterInput *writerInput =[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
//    
//    NSDictionary*sourcePixelBufferAttributesDictionary =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB],kCVPixelBufferPixelFormatTypeKey,nil];
//    
//    AVAssetWriterInputPixelBufferAdaptor *adaptor =[AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
//    //                                                    assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInputsourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
//    NSParameterAssert(writerInput);
//    NSParameterAssert([videoWriter canAddInput:writerInput]);
//    
//    if ([videoWriter canAddInput:writerInput])
//        NSLog(@"");
//    else
//        NSLog(@"");
//    
//    [videoWriter addInput:writerInput];
//    
//    [videoWriter startWriting];
//    [videoWriter startSessionAtSourceTime:kCMTimeZero];
//    
//    //合成多张图片为一个视频文件
//    dispatch_queue_t dispatchQueue =dispatch_queue_create("mediaInputQueue",NULL);
//    int __block frame =0;
//    
//    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
//        
//        
//        while([writerInput isReadyForMoreMediaData])
//        {
//            
//            
//            if(++frame >=[imgArray count]*10)
//            {
//                [writerInput markAsFinished];
//                
//                [videoWriter finishWriting];
//                
//        //                              [videoWriterfinishWritingWithCompletionHandler:nil];
//                break;
//            }
//            
//            CVPixelBufferRef buffer = NULL;
//            
//            int idx =frame/10;
//
//            self.currentIdx = idx;
//            if (idx % 4 ==  0 && frame % 10 == 0) {
//                self.changeRect = self.currentRect1;
//                
//            }
//            if (idx ==  0 && frame % 10 == 1) {
//                
//                self.changeRect = self.currentRect1;
//                
//            }
//            if (idx % 4 ==  1 && frame % 10 == 0) {
//                
//                self.changeRect = self.currentRect2;
//                
//            }
//            if (idx % 4 ==  2 && frame % 10 == 0) {
//                
//                self.changeRect = self.currentRect3;
//                
//            }
//            
//            if (idx % 4 ==  3 && frame % 10 == 0) {
//                
//                self.changeRect = self.currentRect4;
//                
//            }
//            
//            if (frame % 10 == 9) {
//                
//                
//                self.changeRect = self.currentRect5;
//                
//            }
//            
//            
//            buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[[imgArray objectAtIndex:idx]CGImage]:size];
//            
//            
//            if (buffer)
//            {
//                
//            if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame,(int)[PassMergeHandle sharedHandle].speed)])
//                    NSLog(@"");
//                else
//                    NSLog(@"");
//                CFRelease(buffer);
//            }
//        }
//    
//        back(YES);
//        
//       }];
//    
//}
//-(void)reMergeWithArr:(NSMutableArray* )imgArray andBlock:(ReGoBackWithBool)back{
//
//    //NSString *moviePath = [[NSBundle mainBundle]pathForResource:@"Movie" ofType:@"mov"];
//    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
//    NSString *moviePath =[[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",@"test"]];
//    self.theVideoPath = moviePath;
//    
//
//
//    [PassMergeHandle sharedHandle].pathString = self.theVideoPath;
//    
//    self.themeArr = [[NSMutableArray alloc]init];
//    
//    for (int i = 0; i < 5 ; i++) {
//        
//        NSString *Path =[[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"m%d.mp4",i+1]];
//
//        [self.themeArr addObject:Path];
//        
// 
//    }
//    
//    
//    
//    NSString *moviePath2 =[[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",@"mask3"]];
//    
//    self.theVideoPath2 =moviePath2;
// 
//    
//    __block CGSize size =CGSizeMake(480, 320);//定义视频的大小
//    //
//    //    [selfwriteImages:imageArr ToMovieAtPath:moviePath withSize:sizeinDuration:4 byFPS:30];//第2中方法
//    
//    NSError *error = nil;
//    
//    unlink([moviePath UTF8String]);
//    
//    //—-initialize compression engine
//    AVAssetWriter *videoWriter =[[AVAssetWriter alloc]initWithURL:[NSURL fileURLWithPath:moviePath]
//                                                         fileType:AVFileTypeQuickTimeMovie
//                                                            error:&error];
//    NSParameterAssert(videoWriter);
////    if(error)
////        NSLog(@"error =%@", [error localizedDescription]);
//    
//    NSDictionary *videoSettings =[NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264,AVVideoCodecKey,
//                                  [NSNumber numberWithInt:size.width],AVVideoWidthKey,
//                                  [NSNumber numberWithInt:size.height],AVVideoHeightKey,nil];
//    AVAssetWriterInput *writerInput =[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
//    
//    NSDictionary*sourcePixelBufferAttributesDictionary =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB],kCVPixelBufferPixelFormatTypeKey,nil];
//    
//    AVAssetWriterInputPixelBufferAdaptor *adaptor =[AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
//    //                                                    assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInputsourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
//    NSParameterAssert(writerInput);
//    NSParameterAssert([videoWriter canAddInput:writerInput]);
//    
//    if ([videoWriter canAddInput:writerInput])
//        NSLog(@"");
//    else
//        NSLog(@"");
//    
//    [videoWriter addInput:writerInput];
//    
//    [videoWriter startWriting];
//    [videoWriter startSessionAtSourceTime:kCMTimeZero];
//    
//    //合成多张图片为一个视频文件
//    dispatch_queue_t dispatchQueue =dispatch_queue_create("mediaInputQueue",NULL);
//    int __block frame =0;
//    
//    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
//        
//        
//        while([writerInput isReadyForMoreMediaData])
//        {
//            
//            
//            if(++frame >=[imgArray count]*10)
//            {
//                [writerInput markAsFinished];
//                
//                [videoWriter finishWriting];
//                
//                
//                
//                //                              [videoWriterfinishWritingWithCompletionHandler:nil];
//                break;
//            }
//            
//            CVPixelBufferRef buffer =NULL;
//            
//            int idx =frame/10;
//            
//           
//            
//            
//            self.currentIdx = idx;
//            if (idx % 4 ==  0 && frame % 10 == 0) {
//                self.changeRect = self.currentRect1;
//                
//            }
//            if (idx ==  0 && frame % 10 == 1) {
//                
//                self.changeRect = self.currentRect1;
//                
//            }
//            if (idx % 4 ==  1 && frame % 10 == 0) {
//                
//                self.changeRect = self.currentRect2;
//                
//            }
//            if (idx % 4 ==  2 && frame % 10 == 0) {
//                
//                self.changeRect = self.currentRect3;
//                
//            }
//            
//            if (idx % 4 ==  3 && frame % 10 == 0) {
//                
//                self.changeRect = self.currentRect4;
//                
//            }
//            
//            if (frame % 10 == 9) {
//                
//                
//                self.changeRect = self.currentRect5;
//                
//            }
//            
//            
//            
//            
//            
//            buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[[imgArray objectAtIndex:idx]CGImage]:size];
//            
//            
//            
//            if (buffer)
//            {
//                
//                
//                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame,(int)[PassMergeHandle sharedHandle].speed)])
//                    NSLog(@"");
//                
//                else
//                    NSLog(@"");
//                CFRelease(buffer);
//                
//            }
//        }
//        
//        
//        back(YES);
//        
//        
//    }];
//    
//    
//    
//}
//
//- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)imagesize:(CGSize)size
//{
//    NSDictionary *options =[NSDictionary dictionaryWithObjectsAndKeys:
//                            [NSNumber numberWithBool:YES],kCVPixelBufferCGImageCompatibilityKey,
//                            [NSNumber numberWithBool:YES],kCVPixelBufferCGBitmapContextCompatibilityKey,nil];
//    CVPixelBufferRef pxbuffer =NULL;
//    
//    
//    
//    CVReturn status =CVPixelBufferCreate(kCFAllocatorDefault,size.width,size.height,kCVPixelFormatType_32ARGB,(__bridge CFDictionaryRef) options,&pxbuffer);
//    
//    
//    
//    NSParameterAssert(status ==kCVReturnSuccess && pxbuffer !=NULL);
//    
//    
//    
//    CVPixelBufferLockBaseAddress(pxbuffer,0);
//    
//    void *pxdata =CVPixelBufferGetBaseAddress(pxbuffer);
//    
//    
//    NSParameterAssert(pxdata != NULL);
//    
//    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
//    //    CGContextRef context =CGBitmapContextCreate(pxdata,size.width,size.height,8,4*size.width,rgbColorSpace,kCGImageAlphaPremultipliedFirst);
//    
//    
//    
//    CGContextRef context =CGBitmapContextCreate(pxdata,size.width,size.height,8,4*size.width,rgbColorSpace,kCGImageAlphaPremultipliedFirst);
//    
//    NSParameterAssert(context);
//    
//    
//    
//    CGContextDrawImage(context, self.changeRect, imagesize);
//    
//    if (self.currentIdx % 4 ==  0 ) {
//        _changeRect.origin.x =   _changeRect.origin.x + 1;
//        
//        
//        
//        _changeRect.origin.y =   _changeRect.origin.y + 1;
//        _changeRect.size.height =    _changeRect.size.height + 1;
//        
//        _changeRect.size.width =    _changeRect.size.width + 1;
//        
//        
//    }
//    
//    
//    if (self.currentIdx % 4 ==  1  ) {
//        _changeRect.origin.x =   _changeRect.origin.x - 1;
//        _changeRect.origin.y =   _changeRect.origin.y + 1;
//        _changeRect.size.height =    _changeRect.size.height + 1;
//        
//        _changeRect.size.width =    _changeRect.size.width + 1;
//        
//        
//    }
//    
//    
//    if (self.currentIdx % 4 ==  2 ) {
//        _changeRect.origin.x =   _changeRect.origin.x - 10;
//        _changeRect.origin.y =   _changeRect.origin.y - 10;
//        _changeRect.size.height =    _changeRect.size.height + 1;
//        _changeRect.size.width =    _changeRect.size.width + 1;
//        
//        
//    }
//    
//    
//    
//    if (self.currentIdx % 4 ==  3) {
//        _changeRect.origin.x =   _changeRect.origin.x + 1;
//        _changeRect.origin.y =   _changeRect.origin.y + 1;
//        _changeRect.size.height =  _changeRect.size.height + 1;
//        
//        _changeRect.size.width = _changeRect.size.width + 1;
//        
//        
//    }
//    
//    
//    CGColorSpaceRelease(rgbColorSpace);
//    CGContextRelease(context);
//    
//    CVPixelBufferUnlockBaseAddress(pxbuffer,0);
//    
//    
//    
//    return pxbuffer;
//}
//
//
//
//
//@end

#pragma mark - ZYQAssetGroupViewCell

@interface ZYQAssetGroupViewCell ()

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@end

@implementation ZYQAssetGroupViewCell


- (void)bind:(ALAssetsGroup *)assetsGroup
{
    self.assetsGroup            = assetsGroup;
    
    CGImageRef posterImage      = assetsGroup.posterImage;
    size_t height               = CGImageGetHeight(posterImage);
    float scale                 = height / kThumbnailLength;
    
    self.imageView.image        = [UIImage imageWithCGImage:posterImage scale:scale orientation:UIImageOrientationUp];
    self.textLabel.text         = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    self.detailTextLabel.text   = [NSString stringWithFormat:@"%ld", (long)[assetsGroup numberOfAssets]];
    self.accessoryType          = UITableViewCellAccessoryDisclosureIndicator;
}

- (NSString *)accessibilityLabel
{
    NSString *label = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    return [label stringByAppendingFormat:NSLocalizedString(@"%ld 张照片", nil), (long)[self.assetsGroup numberOfAssets]];
}

@end


#pragma mark - ZYQAssetGroupViewController

@interface ZYQAssetGroupViewController()

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *groups;











@end

@implementation ZYQAssetGroupViewController

- (id)init
{
    if (self = [super initWithStyle:UITableViewStylePlain])
    {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
        self.preferredContentSize=kPopoverContentSize;
#else
        if ([self respondsToSelector:@selector(setContentSizeForViewInPopover:)])
            [self setContentSizeForViewInPopover:kPopoverContentSize];
#endif
    }
    
    return self;
}

- (void)viewDidLoad
{
    
    
    [super viewDidLoad];
    [self setupViews];
    [self setupButtons];
    [self localize];
    [self setupGroup];
}


#pragma mark - Rotation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


#pragma mark - Setup

- (void)setupViews
{   self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:4/255.0 green:45/255.0 blue:8/255.0 alpha:1];
    self.tableView.rowHeight = kThumbnailLength + 12;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor blackColor];
}

- (void)setupButtons
{
    ZYQAssetPickerController *picker = (ZYQAssetPickerController *)self.navigationController;
    
    if (picker.showCancelButton)
    {
        self.navigationItem.leftBarButtonItem =
//        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"取消", nil)
//                                         style:UIBarButtonItemStylePlain
//                                        target:self
//                                        action:@selector(dismiss:)];
//        
        
        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconfont-fanhui(1).png"] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
        
        
    }
}

- (void)localize
{
    self.title = NSLocalizedString(@"本地相册", nil);
}

- (void)setupGroup
{
    if (!self.assetsLibrary)
        self.assetsLibrary = [self.class defaultAssetsLibrary];
    
    if (!self.groups)
        self.groups = [[NSMutableArray alloc] init];
    else
        [self.groups removeAllObjects];
    
    ZYQAssetPickerController *picker = (ZYQAssetPickerController *)self.navigationController;
    ALAssetsFilter *assetsFilter = picker.assetsFilter;
    
    ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        if (group)
        {
            [group setAssetsFilter:assetsFilter];
           
            if (group.numberOfAssets > 0 || picker.showEmptyGroups)
                [self.groups addObject:group];
            
            
            
            
            
            
            
            
        }
        else
        {
            [self reloadData];
        }
    };
    
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
        [self showNotAllowed];
        
    };
    
    // Enumerate Camera roll first
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                      usingBlock:resultsBlock
                                    failureBlock:failureBlock];
    
    // Then all other groups
    NSUInteger type =
    ALAssetsGroupLibrary | ALAssetsGroupAlbum | ALAssetsGroupEvent |
    ALAssetsGroupFaces | ALAssetsGroupPhotoStream;
    
    [self.assetsLibrary enumerateGroupsWithTypes:type
                                      usingBlock:resultsBlock
                                    failureBlock:failureBlock];
}


#pragma mark - Reload Data

- (void)reloadData
{
    if (self.groups.count == 0)
        [self showNoAssets];
    
    [self.tableView reloadData];
}


#pragma mark - ALAssetsLibrary

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}


#pragma mark - Not allowed / No assets

- (void)showNotAllowed
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        [self setEdgesForExtendedLayout:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom];
    
    self.title              = nil;
    
    UIImageView *padlock    = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ZYQAssetPicker.Bundle/Images/AssetsPickerLocked@2x.png"]]];
    padlock.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *title          = [UILabel new];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.preferredMaxLayoutWidth = 304.0f;
    
    UILabel *message        = [UILabel new];
    message.translatesAutoresizingMaskIntoConstraints = NO;
    message.preferredMaxLayoutWidth = 304.0f;
    
    title.text              = NSLocalizedString(@"此应用无法使用您的照片或视频。", nil);
    title.font              = [UIFont boldSystemFontOfSize:17.0];
    title.textColor         = [UIColor colorWithRed:129.0/255.0 green:136.0/255.0 blue:148.0/255.0 alpha:1];
    title.textAlignment     = NSTextAlignmentCenter;
    title.numberOfLines     = 5;
    
    message.text            = NSLocalizedString(@"你可以在「隐私设置」中启用存取。", nil);
    message.font            = [UIFont systemFontOfSize:14.0];
    message.textColor       = [UIColor colorWithRed:129.0/255.0 green:136.0/255.0 blue:148.0/255.0 alpha:1];
    message.textAlignment   = NSTextAlignmentCenter;
    message.numberOfLines   = 5;
    
    [title sizeToFit];
    [message sizeToFit];
    
    UIView *centerView = [UIView new];
    centerView.translatesAutoresizingMaskIntoConstraints = NO;
    [centerView addSubview:padlock];
    [centerView addSubview:title];
    [centerView addSubview:message];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(padlock, title, message);
    
    [centerView addConstraint:[NSLayoutConstraint constraintWithItem:padlock attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:centerView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [centerView addConstraint:[NSLayoutConstraint constraintWithItem:title attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:padlock attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [centerView addConstraint:[NSLayoutConstraint constraintWithItem:message attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:padlock attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [centerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[padlock]-[title]-[message]|" options:0 metrics:nil views:viewsDictionary]];
    
    UIView *backgroundView = [UIView new];
    [backgroundView addSubview:centerView];
    [backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:centerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:centerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    
    self.tableView.backgroundView = backgroundView;
}

- (void)showNoAssets
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        [self setEdgesForExtendedLayout:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom];
    
    UILabel *title          = [UILabel new];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.preferredMaxLayoutWidth = 304.0f;
    UILabel *message        = [UILabel new];
    message.translatesAutoresizingMaskIntoConstraints = NO;
    message.preferredMaxLayoutWidth = 304.0f;
    
    title.text              = NSLocalizedString(@"没有照片或视频。", nil);
    title.font              = [UIFont systemFontOfSize:26.0];
    title.textColor         = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    title.textAlignment     = NSTextAlignmentCenter;
    title.numberOfLines     = 5;
    
    message.text            = NSLocalizedString(@"您可以使用 iTunes 将照片和视频\n同步到 iPhone。", nil);
    message.font            = [UIFont systemFontOfSize:18.0];
    message.textColor       = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    message.textAlignment   = NSTextAlignmentCenter;
    message.numberOfLines   = 5;
    
    [title sizeToFit];
    [message sizeToFit];
    
    UIView *centerView = [UIView new];
    centerView.translatesAutoresizingMaskIntoConstraints = NO;
    [centerView addSubview:title];
    [centerView addSubview:message];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(title, message);
    
    [centerView addConstraint:[NSLayoutConstraint constraintWithItem:title attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:centerView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [centerView addConstraint:[NSLayoutConstraint constraintWithItem:message attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:title attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [centerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title]-[message]|" options:0 metrics:nil views:viewsDictionary]];
    
    UIView *backgroundView = [UIView new];
    [backgroundView addSubview:centerView];
    [backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:centerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:centerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    
    self.tableView.backgroundView = backgroundView;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    ZYQAssetGroupViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[ZYQAssetGroupViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [cell bind:[self.groups objectAtIndex:indexPath.row]];
    
    return cell;
}


#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kThumbnailLength + 12;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZYQAssetViewController *vc = [[ZYQAssetViewController alloc] init];
    [PassMergeHandle sharedHandle].zyq = vc;
    
    vc.assetsGroup = [self.groups objectAtIndex:indexPath.row];
//    原来的方法
    [self.navigationController pushViewController:vc animated:YES];
    

    
    
}



#pragma mark - Actions

- (void)dismiss:(id)sender
{
    ZYQAssetPickerController *picker = (ZYQAssetPickerController *)self.navigationController;
 
//    [PassMergeHandle sharedHandle].zyqblock([PassMergeHandle sharedHandle].zyq);
    
    if ([picker.delegate respondsToSelector:@selector(assetPickerControllerDidCancel:)])
        [picker.delegate assetPickerControllerDidCancel:picker];
    
  
    
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end

#pragma mark - ZYQAssetPickerController

@implementation ZYQAssetPickerController

- (id)init
{
    ZYQAssetGroupViewController *groupViewController = [[ZYQAssetGroupViewController alloc] init];
    
    if (self = [super initWithRootViewController:groupViewController])
    {
        _maximumNumberOfSelection      = 10;
        _minimumNumberOfSelection      = 0;
        //        此处可改
        _assetsFilter                  = [ALAssetsFilter allPhotos];
        
        

        _showCancelButton              = YES;
        _showEmptyGroups               = NO;
        _selectionFilter               = [NSPredicate predicateWithValue:YES];
        _isFinishDismissViewController = YES;
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
        self.preferredContentSize=kPopoverContentSize;
#else
        if ([self respondsToSelector:@selector(setContentSizeForViewInPopover:)])
            [self setContentSizeForViewInPopover:kPopoverContentSize];
#endif
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
