//
//  NewHelperViewController.m
//  HappyMovie
//
//  Created by lanou3g on 16/1/25.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "NewHelperViewController.h"

@interface NewHelperViewController ()

@property (strong, nonatomic) IBOutlet UITextView *textView;



@end

@implementation NewHelperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
 self.textView.text = @"1.如何使用相机进行实时滤镜?\n点击你想用的镜头,包括普通镜头、搞笑镜头、画中画镜头,在录制按钮的右侧为滤镜选择按钮，点击它，出现相应镜头下的各种滤镜效果，选择你想要的某种滤镜效果，点击录制按钮，开始进行实时滤镜拍摄。\n\n2.关于如何进行视频拼接？\n点击视频拼接按钮，进行视频拼接界面，先进行视频选择操作，选择完成，回到原来界面，界面下方有一排样式选择按钮，有拼接样式选择按钮、Gif动画贴纸选择按钮、背景颜色选择按钮、边框样式选择按钮，点击你想实现的效果按钮，添加相应的效果，然后点击导航栏上的'下一步'按钮,进入音乐列表界面,点击你想插入的某个音乐,点击save按钮,将该拼接的视频文件保存到相册。\n\n3.关于如何生成倒影视频?\n点击视频倒影按钮，进入视频倒影的界面,点击导航栏上的'开始'按钮,进入选择列表，点击相册,选择相应的视频文件,同时返回视频倒影界面,再次点击开始按钮,选取gif动画效果边框以及背景音乐（可选）,选好所有的效果之后，点击生成倒影倒影视频之后，开始生成视频倒影文件。\n\n4.关于视频修剪功能？\n点击视频剪辑按钮，进入视频剪辑界面,操作视频剪辑条,滑到你想剪辑的部分,点击播放按钮,查看剪辑的视频(注意：一定要播放完成，才可以进行保存)，点击保存,返回编辑界面，点击保存按钮，将视频文件保存到相册。\n\n5.关于如何添加视频滤镜？\n点击添加滤镜按钮，进入滤镜界面，选择下面某种滤镜效果的图标,为视频添加滤镜，点击保存，生成滤镜视频文件，同时进入视频编辑界面，点击导航栏保存按钮，将视频保存到相册。\n\n6.关于如何添加视频字幕？\n点击添加字幕按钮，进入添加字幕界面，点击添加图标，出现弹出框,点击弹出框，是文字处于编辑状态，选择颜色选择条，选取自己想要的文字颜色,点击导航栏保存按钮，生成视频文件，同时返回编辑界面，点击保存按钮,将视频保存到相册。\n\n7.关于如何生成视频文件?\n点击添加动画按钮,进入生成动画的界面,选择自己想要的图片，同时点击想要实现的动画效果（包括渐隐、一闪一闪，旋转效果),然后点击保存按钮,保存文件，同时返回编辑界面,点击保存按钮,将视频文件保存到相册。\n\n  8.关于如何美化图片？\n在主界面选择照片美化按钮，进入相册选择图片,进入图片美化界面,包括添加滤镜效果、添加贴纸、添加文字、添加画笔、裁剪等功能，点击保存按钮，保存加工的图片。\n\n9.关于如何使用相册mv功能？\n点击相册mv按钮，进入相册,选择自己想要生成mv的图片,进入相册mv界面，选中相应的主体图标,进行mv效果播放，同时还可以选择添加配乐，文件的生成帧速率功能，生成自己想要的视频效果。\n\n10.关于我的界面？\n点击进入我的界面，进行登录，（可以使用三方登录),可以查看该手机上乐影编辑的所有未删除的视频及图片文件，同时可以对该文件进行删除，及分享操作。\n\n";
    self.textView.editable = NO;
    
    
  
}
- (IBAction)backButtonDidClicked:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
