//
//  WorkingViewController.m
//  HappyMovieEditer---1
//
//  Created by lanou3g on 16/1/14.
//  Copyright © 2016年 chuanbao. All rights reserved.
//

#import "WorkingViewController.h"
#import "ToolScrollView.h"
#import "FilterScrollView.h"
#import "MBProgressHUD.h"
#import "PasterScrollView.h"
#import "XTPasterStageView.h"
#import "XTPasterView.h"
#import "TextEditView.h"
#import "DrawerColorPickerController.h"
#import "PIDrawerView.h"
#import "DrawerScrollView.h"
#import "_CLImageEditorViewController.h"
#import "UMSocial.h"
#import "TextEditScrollView.h"
#import "DataStore.h"
#import "Image.h"
#define APPFRAME        [UIScreen mainScreen].bounds


@interface WorkingViewController ()<UIScrollViewDelegate,DrawerColorPickerControllerDelegate,UMSocialUIDelegate,UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIView *workingTopView;
@property (strong, nonatomic) IBOutlet UIView *workingBottomView;



@property (nonatomic,strong)ToolScrollView *toolScrollView;

@property (nonatomic,strong)FilterScrollView *filterScrollView;

@property (nonatomic,strong)PasterScrollView *pasterScrollView;

@property (nonatomic,strong)UIImageView *workingImageView;

@property (nonatomic,strong)NSArray *filterArray;

@property (nonatomic,strong)XTPasterStageView *stageView;

@property (nonatomic,strong)NSMutableArray *pasterList;

@property (nonatomic,strong)UIImage *workingShowImage;

@property (nonatomic,assign)NSInteger workingTag;

@property (nonatomic,assign)CGImageRef cgImage;


@property (nonatomic,strong)TextEditView *textEditView;

@property (nonatomic,strong)PIDrawerView *drawerView;

@property (nonatomic,strong)UIColor *selectedColor;

@property (nonatomic,strong)DrawerScrollView *drawerScrollView;

@property (nonatomic,strong)TextEditScrollView *textEditScrollView;

@property (nonatomic,strong)NSMutableArray *textEditViewArray;

@property (nonatomic,strong)NSArray *textEditColorArray;

@property (nonatomic,assign)BOOL isSave;

@end

@implementation WorkingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //把传过来的图片存入属性Image
    self.workingShowImage = self.tempImage;
    
    
    self.workingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 130, self.workingShowImage.size.width, self.workingShowImage.size.height)];
    self.workingImageView.center = CGPointMake(kScreenWidth/2, kScreenHeight/2-30);
    [self.workingImageView setImage:self.workingShowImage];
    [self.view addSubview:self.workingImageView];
    [self.view insertSubview:self.filterScrollView belowSubview:self.toolScrollView];
    
    //图片滤镜
    self.filterArray = @[@"",@"CILinearToSRGBToneCurve",
                          @"CIPhotoEffectChrome",
                          @"CIPhotoEffectFade",
                          @"CIPhotoEffectInstant",
                          @"CIPhotoEffectMono",
                          @"CIPhotoEffectNoir",
                          @"CIPhotoEffectProcess",
                          @"CIPhotoEffectTonal",
                          @"CIPhotoEffectTransfer",
                          @"CISRGBToneCurveToLinear",
                          @"CISepiaTone",
                          @"CIDotScreen",];
    
    //绘图
    self.selectedColor = [UIColor redColor];
    self.drawerView.selectedColor = self.selectedColor;
    //文字初始化数组
    self.textEditViewArray = [NSMutableArray array];
    
    //加载底部工具栏
    [self addScrollView];
}
#pragma mark - 滤镜处理
-(void)imageFilterHandle:(NSString *)filter
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:self.workingShowImage];
    CIFilter *imageFilter = [CIFilter filterWithName:filter keysAndValues:kCIInputImageKey,ciImage, nil];
    [imageFilter setDefaults];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [imageFilter outputImage];
    self.cgImage = [context createCGImage:outputImage fromRect:outputImage.extent];
    self.workingImageView.image = [UIImage imageWithCGImage:self.cgImage];
    CGImageRelease(self.cgImage);
}
#pragma mark - 底部工具栏
-(void)addScrollView
{
    //工具
    self.toolScrollView = [[ToolScrollView alloc] initWithFrame:CGRectMake(0, kScreenHeight-60, kScreenWidth, 60)];
    self.toolScrollView.backgroundColor = [UIColor lightGrayColor];
    self.toolScrollView.contentSize = CGSizeMake(10+50*5+30*4+10, 60);
    [self.view addSubview:self.toolScrollView];
    self.toolScrollView.showsHorizontalScrollIndicator = NO;
    self.toolScrollView.showsVerticalScrollIndicator = NO;
    //根据点击的Button来响应方法
    __weak typeof(self) weakSelf = self;
    self.toolScrollView.toolScrollViewBlock = ^(NSInteger toolButtonTag){
        if (toolButtonTag == 100) {
            weakSelf.workingTag = toolButtonTag;
            [weakSelf showDetailFilterAction];
        }else if (toolButtonTag == 101){
            weakSelf.workingTag = toolButtonTag;
            [weakSelf showDetailPasterAction];
        }else if (toolButtonTag == 102){
            weakSelf.workingTag = toolButtonTag;
            [weakSelf addTextAction];
        }else if (toolButtonTag == 103){
            weakSelf.workingTag = toolButtonTag;
            [weakSelf showDetailDrawAction];
        }else if(toolButtonTag == 104){
            weakSelf.workingTag = toolButtonTag;
            _CLImageEditorViewController *editor = [[_CLImageEditorViewController alloc] initWithImage:weakSelf.workingShowImage];
            editor.cropImageBlock = ^(UIImage *image){
                weakSelf.workingShowImage = image;
                weakSelf.workingImageView.image = image;
            };
            editor.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [weakSelf presentViewController:editor animated:YES completion:nil];
        }
    };
    //滤镜
    self.filterScrollView = [[FilterScrollView alloc] initWithFrame:CGRectMake(0, kScreenHeight-60, kScreenWidth, 70)];
    self.filterScrollView.backgroundColor = [UIColor grayColor];
    self.filterScrollView.contentSize = CGSizeMake(60*13+5*13, 70);
    self.filterScrollView.hidden = YES;
    self.filterScrollView.showsHorizontalScrollIndicator = NO;
    self.filterScrollView.showsVerticalScrollIndicator = NO;
    [self.view insertSubview:self.filterScrollView belowSubview:self.toolScrollView];
    self.filterScrollView.filterBlock = ^(NSInteger filterTag){
        if (filterTag==0) {
            [weakSelf.workingImageView setImage:weakSelf.workingShowImage];
        }else{
            [weakSelf imageFilterHandle:weakSelf.filterArray[filterTag]];
        }
    };
    //贴纸
    self.pasterScrollView = [[PasterScrollView alloc] initWithFrame:CGRectMake(0, kScreenHeight-60, kScreenWidth, 70)];
    self.pasterList = self.pasterScrollView.imageArray;
    self.pasterScrollView.backgroundColor = [UIColor grayColor];
    self.pasterScrollView.contentSize = CGSizeMake(60*21+5*21, 70);
    self.pasterScrollView.hidden = YES;
    self.pasterScrollView.showsHorizontalScrollIndicator = NO;
    self.pasterScrollView.showsVerticalScrollIndicator = NO;
    [self.view insertSubview:self.pasterScrollView belowSubview:self.toolScrollView];
    //点击图片的block
    self.pasterScrollView.pasterBlock = ^(NSInteger pasterTag){
        [weakSelf.stageView addPasterWithImg:[UIImage imageNamed:weakSelf.pasterList[pasterTag]]];
    };
    //文字
    self.textEditScrollView = [[TextEditScrollView alloc] initWithFrame:CGRectMake(0, kScreenHeight-60-60, kScreenWidth, 60)];
    self.textEditColorArray = [NSArray arrayWithArray:self.textEditScrollView.colorArray];
    self.textEditScrollView.contentSize = CGSizeMake(50*8+20*8, 60);
    self.textEditScrollView.backgroundColor = [UIColor grayColor];
    self.textEditScrollView.hidden = YES;
    self.textEditScrollView.showsHorizontalScrollIndicator = NO;
    self.textEditScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.textEditScrollView];
    self.textEditScrollView.textScrollViewBlock = ^(NSInteger textTag){
        if (textTag == 1000) {
            if (self.isSave == YES) {
                weakSelf.textEditView = [[TextEditView alloc] initWithMyFrame:weakSelf.workingImageView.frame];
                [weakSelf.workingImageView addSubview:weakSelf.textEditView];
                [weakSelf.textEditViewArray addObject:weakSelf.textEditView];
                weakSelf.isSave = NO;
            }else{
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请先保存" preferredStyle:UIAlertControllerStyleAlert];
                [weakSelf presentViewController:alertVC animated:YES completion:nil];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                });
            }
        }
        for (int i= 1001; i<1007; i++) {
            if (textTag == i) {
                weakSelf.textEditView.myTextField.textColor = weakSelf.textEditColorArray[i-1001];
            }
        }
    };
    //画笔
    self.drawerScrollView = [[DrawerScrollView alloc] initWithFrame:CGRectMake(0, kScreenHeight-60-60, kScreenWidth, 60)];
    self.drawerScrollView.backgroundColor = [UIColor grayColor];
    self.drawerScrollView.hidden = YES;
    self.drawerScrollView.showsHorizontalScrollIndicator = NO;
    self.drawerScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.drawerScrollView];
    self.drawerScrollView.drawerBlcok = ^(NSInteger drawerTag){
        if (drawerTag == 500) {
            [weakSelf.drawerView setDrawingMode:DrawingModePaint];
        }else if (drawerTag == 501){
            DrawerColorPickerController *colorPicker = [[DrawerColorPickerController alloc] init];
            colorPicker.delegate = weakSelf;
            [colorPicker setCurrentSelectedColor:weakSelf.selectedColor];
            colorPicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [weakSelf presentViewController:colorPicker animated:YES completion:nil];
        }else if (drawerTag == 502){
            [weakSelf.drawerView setDrawingMode:DrawingModeErase];
        }else if (drawerTag == 503){
            [weakSelf.drawerView removeFromSuperview];
            weakSelf.workingImageView.image = weakSelf.workingShowImage;
            weakSelf.drawerView = [[PIDrawerView alloc] initWithFrame:weakSelf.workingImageView.bounds];
            weakSelf.drawerView.backgroundColor = [UIColor clearColor];
            [weakSelf.workingImageView addSubview:weakSelf.drawerView];
            [weakSelf.drawerView setDrawingMode:DrawingModePaint];
        }
    };
}
- (void)colorSelected:(UIColor *)selectedColor
{
    self.selectedColor = selectedColor;
    [self.drawerView setSelectedColor:selectedColor];
}
#pragma mark - 滤镜点击事件
-(void)showDetailFilterAction
{
    [self.stageView removeFromSuperview];
    
    [self.textEditView removeFromSuperview];
    
    
    self.stageView = nil;
    
    [self.view bringSubviewToFront:self.workingBottomView];
    self.workingBottomView.hidden = NO;
    self.workingTopView.hidden = YES;
    

    self.workingImageView.center = CGPointMake(kScreenWidth/2, kScreenHeight/2-30);
    [self.workingImageView setImage:self.workingShowImage];
    [self.view addSubview:self.workingImageView];
    [self.view insertSubview:self.filterScrollView belowSubview:self.toolScrollView];
    
    if (self.filterScrollView.hidden == YES) {
        self.filterScrollView.hidden = NO;
        [self.view insertSubview:self.filterScrollView belowSubview:self.toolScrollView];
        [UIView animateWithDuration:0.1 animations:^{
            CGRect rect = self.filterScrollView.frame;
            rect.origin.y = kScreenHeight-60-70;
            self.filterScrollView.frame = rect;
        } completion:^(BOOL finished) {
            
        }];
    }else if (self.filterScrollView.hidden == NO){
        self.filterScrollView.hidden = YES;
        [self.filterScrollView removeFromSuperview];

        [UIView animateWithDuration:0.1 animations:^{
            CGRect rect = self.filterScrollView.frame;
            rect.origin.y = kScreenHeight-60;
            self.filterScrollView.frame = rect;
        } completion:^(BOOL finished) {
        }];
    }
}
#pragma mark - 贴纸点击
-(void)showDetailPasterAction
{
    
    [self.view bringSubviewToFront:self.workingBottomView];
    self.workingBottomView.hidden = NO;
    self.workingTopView.hidden = YES;
    
    [self.workingImageView removeFromSuperview];
    [self.stageView doneEdit];
    
    self.stageView = [[XTPasterStageView alloc] initWithFrame:self.workingImageView.bounds];
    self.stageView.center = CGPointMake(kScreenWidth/2, kScreenHeight/2-30);
    _stageView.originImage = self.workingShowImage;
    [self.view addSubview:self.stageView];
    self.stageView.userInteractionEnabled = YES;
    if (self.pasterScrollView.hidden == YES) {
        self.pasterScrollView.hidden = NO;
        [UIView animateWithDuration:0.1 animations:^{
            CGRect rect = self.pasterScrollView.frame;
            rect.origin.y = kScreenHeight-60-70;
            self.pasterScrollView.frame = rect;
        } completion:^(BOOL finished) {
            
        }];
    }else if (self.pasterScrollView.hidden == NO){
        self.pasterScrollView.hidden = YES;
        [UIView animateWithDuration:0.1 animations:^{
            CGRect rect = self.pasterScrollView.frame;
            rect.origin.y = kScreenHeight-60;
            self.pasterScrollView.frame = rect;
        } completion:^(BOOL finished) {
        }];
    }
}
#pragma mark - 文字点击事件
-(void)addTextAction
{
    self.stageView = nil;
    
    UIButton *textEditButton = [UIButton buttonWithType:UIButtonTypeSystem];
    textEditButton.frame = self.workingImageView.bounds;
    textEditButton.backgroundColor = [UIColor clearColor];
    [textEditButton addTarget:self action:@selector(textEditButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.workingImageView addSubview:textEditButton];
    
    self.textEditScrollView.hidden = NO;
    self.workingTopView.hidden = YES;
    self.workingBottomView.hidden = NO;
    
    [self.workingImageView setImage:self.workingShowImage];
    self.workingImageView.userInteractionEnabled = YES;
    [self.view bringSubviewToFront:self.workingBottomView];
    
    self.textEditView = [[TextEditView alloc] initWithMyFrame:self.workingImageView.frame];
    [self.workingImageView addSubview:self.textEditView];
    [self.textEditViewArray addObject:self.textEditView];
    [self.stageView addSubview:self.textEditView];
}
-(void)textEditButtonAction:(UIButton *)sender
{
    [self clearAllOnFirst];
    [self.workingImageView endEditing:YES];
}
- (void)clearAllOnFirst
{
    self.textEditView.isOnFirst = NO ;
    [self.textEditViewArray enumerateObjectsUsingBlock:^(XTPasterView *pasterV, NSUInteger idx, BOOL * _Nonnull stop) {
        pasterV.isOnFirst = NO;
    }];
}
#pragma mark - 绘图点击方法
-(void)showDetailDrawAction
{
    self.workingImageView.image = self.workingShowImage;
    self.workingTopView.hidden = YES;
    self.workingBottomView.hidden = NO;
    self.drawerScrollView.hidden = NO;
    [self.view bringSubviewToFront:self.workingBottomView];
    
    self.drawerView = [[PIDrawerView alloc] initWithFrame:CGRectMake(0, 0, self.workingShowImage.size.width, self.workingShowImage.size.height)];
    self.drawerView.backgroundColor = [UIColor clearColor];
    [self.workingImageView addSubview:self.drawerView];
    self.workingImageView.userInteractionEnabled = YES;
    [self.drawerView setDrawingMode:DrawingModePaint];
}
#pragma mark - 返回
- (IBAction)backButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 保存
- (IBAction)saveButtonAction:(id)sender {
    
    UIImageWriteToSavedPhotosAlbum(self.workingShowImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *nextPath = [cachesPath stringByAppendingPathComponent:@"leying"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:nextPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    NSData *imageData = UIImagePNGRepresentation(self.workingShowImage);
    NSString *writeName = [nextPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",dateTime]];
    [imageData writeToFile:writeName atomically:YES];
    //NSLog(@"-----%@",writeName);
    [[DataStore sharedDataStore] insertImagePathUrl:writeName];
}
-(void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    if (!error) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"成功保存到相册" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertVC animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
      //  NSLog(@"失败 %@",error);
    }
}
#pragma mark - 返回
- (IBAction)bottomBackButtonAction:(id)sender {
    
    if (self.workingTag == 102) {
        [self backButtonAction];
    }else{
        [self alertActionWithDelete];
    }
}
#pragma mark - 保存
- (IBAction)bottomSaveButtonAction:(id)sender {
    [self saveButtonAction];
}
-(void)alertActionWithSave
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"保存成功!" preferredStyle:UIAlertControllerStyleAlert];
    if (!(self.workingTag == 102)) {
        [self backButtonAction];
    }else{
        self.isSave = YES;
    }
    [self presentViewController:alertVC animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    self.stageView.userInteractionEnabled = NO;
    self.textEditView.userInteractionEnabled = NO;
}
-(void)alertActionWithDelete
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"还未保存,是否退出?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self backButtonAction];
    }];
    [alertVC addAction:confirmAction];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];

}
-(void)backButtonAction
{
    self.workingImageView = [[UIImageView alloc] initWithFrame:self.workingImageView.bounds];
    self.workingImageView.contentMode = UIViewContentModeRedraw;
    self.workingImageView.center = CGPointMake(kScreenWidth/2, kScreenHeight/2-30);
    [self.workingImageView setImage:self.workingShowImage];
    [self.view addSubview:self.workingImageView];
    
    
    self.workingBottomView.hidden = YES;
    self.filterScrollView.hidden = YES;
    self.pasterScrollView.hidden = YES;
    self.workingTopView.hidden = NO;
    self.drawerScrollView.hidden = YES;
    self.textEditScrollView.hidden = YES;
    [self.textEditView removeFromSuperview];
    [self.drawerView removeFromSuperview];
    self.workingImageView.image = self.workingShowImage;
}
-(void)saveButtonAction
{
    if (self.workingTag == 100) {
        if (self.cgImage == nil) {
            self.workingImageView.image = self.tempImage;
            [self alertActionWithSave];
        }else{
            self.workingShowImage = [UIImage imageWithCGImage:self.cgImage];
            self.workingImageView.image = self.workingShowImage;
            [self alertActionWithSave];
        }
    }else if(self.workingTag == 101){
        UIImage *imageResult = [self.stageView doneEdit];
        self.workingShowImage = nil;
        self.workingShowImage = imageResult;
        [self alertActionWithSave];
    }else if (self.workingTag == 102){
        UIImage *imageTemp = [self getImageFromView:self.workingImageView];
        self.workingShowImage = imageTemp;
        [self alertActionWithSave];
    }else if (self.workingTag == 103){
        UIImage *drawImage = [self getImageFromView:self.workingImageView];
        self.workingShowImage = drawImage;
        [self alertActionWithSave];
    }
}
-(UIImage *)getImageFromView:(UIView *)theView
{
    CGSize orgSize = theView.bounds.size ;
    UIGraphicsBeginImageContextWithOptions(orgSize, YES, 5);
    [theView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext() ;
    
    return image ;
}


//提示
-(void)alertViewWithString:(NSString *)string
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:string delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [alertView show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
    });
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
