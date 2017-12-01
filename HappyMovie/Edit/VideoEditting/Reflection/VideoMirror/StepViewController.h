

#import <UIKit/UIKit.h>

typedef void(^ReturnVideoURLBlock)(NSURL *videoURL);

@protocol StepViewControllerDelegate <NSObject>

//gif动画代理
-(void)stepViewControllerPickGifFromCustom;

//将点击的音乐信息传到前一界面
-(void)stepViewControllerPassSongInfo:(NSDictionary *)dic;

//点击合成按钮,合成视频文件
-(void)stepViewControllerCompositionVideo;
@end



@interface StepViewController : UIViewController

@property(nonatomic,copy)ReturnVideoURLBlock block;
@property(nonatomic,weak)id<StepViewControllerDelegate>delegate;

-(void)setCurrentVideoUrl:(NSURL *)url;

@end
