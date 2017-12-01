//
//  TextView.h
//  HappyMovie
//
//  Created by lanou3g on 16/1/22.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DeleteViewBlock)();
typedef void(^PanViewBlock)(UIPanGestureRecognizer *pan);
typedef void(^PinchViewBlock)(UIPanGestureRecognizer *pinch);

@interface TextView : UIView

@property(nonatomic,copy)DeleteViewBlock block;//deleteButton
@property(nonatomic,copy)PanViewBlock panBlock;//平移
@property(nonatomic,copy)PinchViewBlock pinchBlock;//缩放

@property(nonatomic,strong)UITextView *textView;
@property(nonatomic,strong)UIImageView *rotateButton;
@end
