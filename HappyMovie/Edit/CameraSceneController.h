//

//可以选择镜头列表

#import <UIKit/UIKit.h>

@protocol CameraSceneControllerDelegate <NSObject>

-(void)cameraSceneSelected:(NSDictionary *)modelDic;

@end



@interface CameraSceneController : UICollectionViewController

@property(nonatomic,weak)id<CameraSceneControllerDelegate>delegate;


@end
