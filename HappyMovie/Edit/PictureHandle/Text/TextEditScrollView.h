//
//  TextEditScrollView.h
//  HappyMovieEditer---1
//
//  Created by lanou3g on 16/1/18.
//  Copyright © 2016年 chuanbao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TextScrollViewBlock)(NSInteger textTag);


@interface TextEditScrollView : UIScrollView

@property (nonatomic,copy)TextScrollViewBlock textScrollViewBlock;

@property (nonatomic,strong)NSArray *colorArray;

@end
