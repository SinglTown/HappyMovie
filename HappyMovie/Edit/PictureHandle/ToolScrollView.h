//
//  ToolScrollView.h
//  HappyMovieEditer---1
//
//  Created by lanou3g on 16/1/15.
//  Copyright © 2016年 chuanbao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ToolScrollViewTagBlock)(NSInteger toolButtonTag);

@interface ToolScrollView : UIScrollView


@property (nonatomic,copy)ToolScrollViewTagBlock toolScrollViewBlock;

@property (nonatomic,strong)UIButton *toolButton;

@property (nonatomic,strong)UILabel *toolLabel;

@end
