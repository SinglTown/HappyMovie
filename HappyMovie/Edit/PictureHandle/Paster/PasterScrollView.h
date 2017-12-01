//
//  PasterScrollView.h
//  HappyMovieEditer---1
//
//  Created by lanou3g on 16/1/15.
//  Copyright © 2016年 chuanbao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PasterBlock)(NSInteger pasterTag);

@interface PasterScrollView : UIScrollView

@property (nonatomic,strong)NSMutableArray *imageArray;
@property (nonatomic,copy)PasterBlock pasterBlock;

@end
