//
//  FilterScrollView.h
//  HappyMovieEditer---1
//
//  Created by lanou3g on 16/1/15.
//  Copyright © 2016年 chuanbao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FilterBlock)(NSInteger filterTag);

@interface FilterScrollView : UIScrollView

@property (nonatomic,copy)FilterBlock filterBlock;

@end
