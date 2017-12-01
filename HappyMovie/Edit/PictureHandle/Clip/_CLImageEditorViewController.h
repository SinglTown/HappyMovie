//
//  _CLImageEditorViewController.h
//
//  Created by sho yakushiji on 2013/11/05.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "CLImageEditor.h"

#import "UIDevice+SystemVersion.h"

typedef void(^CropImageBlock)(UIImage *image);

@interface _CLImageEditorViewController : CLImageEditor
<UIScrollViewDelegate, UIBarPositioningDelegate>
{
    IBOutlet __weak UINavigationBar *_navigationBar;
}
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIImageView  *imageView;
@property (nonatomic, weak) IBOutlet UIScrollView *menuView;

@property (nonatomic,copy)CropImageBlock cropImageBlock;

- (IBAction)pushedCloseBtn:(id)sender;
- (IBAction)pushedFinishBtn:(id)sender;




- (id)initWithImage:(UIImage*)image;

- (void)resetImageViewFrame;
- (void)resetZoomScaleWithAnimate:(BOOL)animated;

@end
