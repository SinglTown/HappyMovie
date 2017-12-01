//
//  _CLImageEditorViewController.m
//
//  Created by sho yakushiji on 2013/11/05.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "_CLImageEditorViewController.h"


#import "CLImageTools.h"
#import "UIView+Frame.h"
#import "UIImage+Utility.h"
#import "CLClippingTool.h"

@interface CLMenuPanel : UIView
{
    
}
@property (nonatomic, strong) Class toolClass;
@property (nonatomic, strong) NSString *title;

@end

@implementation CLMenuPanel

@end






@interface _CLImageEditorViewController ()
@property (nonatomic, strong) CLImageToolBase *currentTool;
@end

@implementation _CLImageEditorViewController
{
    UIImage *_originalImage;
}
- (id)initWithImage:(UIImage *)image
{
    self = [self init];
    if (self){
        _originalImage = [image deepCopy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    if([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    _menuView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    
    if(self.navigationController!=nil){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pushedFinishBtn:)];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
        _navigationBar.hidden = YES;
        [_navigationBar popNavigationItemAnimated:NO];
    }
    else{
        _navigationBar.topItem.title = self.title;
    }
    
    if([UIDevice iosVersion] < 7){
        _navigationBar.barStyle = UIBarStyleBlackTranslucent;
    }
    [self refreshImageView];
}
- (void)resetImageViewFrame
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect rct = _imageView.frame;
        rct.size = CGSizeMake(_scrollView.zoomScale*_imageView.image.size.width, _scrollView.zoomScale*_imageView.image.size.height);
        _imageView.frame = rct;
    });
}

- (void)resetZoomScaleWithAnimate:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat Rw = _scrollView.frame.size.width/_imageView.image.size.width;
        CGFloat Rh = _scrollView.frame.size.height/_imageView.image.size.height;
        CGFloat ratio = MIN(Rw, Rh);
        
        _scrollView.contentSize = _imageView.frame.size;
        _scrollView.minimumZoomScale = ratio;
        _scrollView.maximumZoomScale = MAX(ratio/240, 1/ratio);
        
        [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
    });
}

- (void)refreshImageView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _imageView.image = _originalImage;
        
        [self resetImageViewFrame];
        [self resetZoomScaleWithAnimate:NO];
    });
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark- Tool actions

- (void)setCurrentTool:(CLImageToolBase *)currentTool
{
    if(currentTool != _currentTool){
        [_currentTool cleanup];
        _currentTool = currentTool;
        [_currentTool setup];
        
        [self swapToolBarWithEditting:(_currentTool!=nil)];
    }
}

#pragma mark- Menu actions

- (void)swapMenuViewWithEditting:(BOOL)editting
{
    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                         if(editting){
                             _menuView.transform = CGAffineTransformMakeTranslation(0, self.view.height-_menuView.top);
                         }
                         else{
                             _menuView.transform = CGAffineTransformIdentity;
                         }
                     }
     ];
}

- (void)swapNavigationBarWithEditting:(BOOL)editting
{
    if(self.navigationController==nil){
        return;
    }
    
    [self.navigationController setNavigationBarHidden:editting animated:YES];
    
    if(editting){
        _navigationBar.hidden = NO;
        _navigationBar.transform = CGAffineTransformMakeTranslation(0, -_navigationBar.height);
        
        [UIView animateWithDuration:kCLImageToolAnimationDuration
                         animations:^{
                             _navigationBar.transform = CGAffineTransformIdentity;
                         }
         ];
    }
    else{
        [UIView animateWithDuration:kCLImageToolAnimationDuration
                         animations:^{
                             _navigationBar.transform = CGAffineTransformMakeTranslation(0, -_navigationBar.height);
                         }
                         completion:^(BOOL finished) {
                             _navigationBar.hidden = YES;
                             _navigationBar.transform = CGAffineTransformIdentity;
                         }
         ];
    }
}

- (void)swapToolBarWithEditting:(BOOL)editting
{
    [self swapMenuViewWithEditting:editting];
    [self swapNavigationBarWithEditting:editting];
    
    if(self.currentTool){
        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:[[self.currentTool class] title]];
        item.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStyleDone target:self action:@selector(pushedDoneBtn:)];
        item.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(pushedCancelBtn:)];
        [_navigationBar pushNavigationItem:item animated:(self.navigationController==nil)];
    }
    else{
        [_navigationBar popNavigationItemAnimated:(self.navigationController==nil)];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [self setupToolWithToolClass:[CLClippingTool class]];
}
- (IBAction)pushedCancelBtn:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pushedDoneBtn:(id)sender
{
    self.view.userInteractionEnabled = NO;
    
    
    [self.currentTool executeWithCompletionBlock:^(UIImage *image, NSError *error, NSDictionary *userInfo) {
        
        self.cropImageBlock(image);
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }];
}

- (void)setupToolWithToolClass:(Class)toolClass
{
    if(self.currentTool){ return; }
    
    if(toolClass){
        id instance = [toolClass alloc];
        if(instance!=nil && [instance isKindOfClass:[CLImageToolBase class]]){
            instance = [instance initWithImageEditor:self];
            self.currentTool = instance;
        }
    }
}

- (void)pushedCloseBtn:(id)sender
{
    if([self.delegate respondsToSelector:@selector(imageEditorDidCancel:)]){
        [self.delegate imageEditorDidCancel:self];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)pushedFinishBtn:(id)sender
{
    if([self.delegate respondsToSelector:@selector(imageEditor:didFinishEdittingWithImage:)]){
        [self.delegate imageEditor:self didFinishEdittingWithImage:_originalImage];
    }
}

#pragma mark- ScrollView delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat Ws = _scrollView.frame.size.width;
    CGFloat Hs = _scrollView.frame.size.height - _scrollView.contentInset.top - _scrollView.contentInset.bottom;
    CGFloat W = _originalImage.size.width*_scrollView.zoomScale;
    CGFloat H = _originalImage.size.height*_scrollView.zoomScale;
    
    CGRect rct = _imageView.frame;
    rct.origin.x = MAX((Ws-W)/2, 0);
    rct.origin.y = MAX((Hs-H)/2, 0);
    _imageView.frame = rct;
}

@end
