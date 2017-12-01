//
//  DrawerScrollView.h
//  HappyMovieEditer---1
//
//  Created by lanou3g on 16/1/19.
//  Copyright © 2016年 chuanbao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DrawerBackValueBlock)(NSInteger drawerTag);

@interface DrawerScrollView : UIScrollView

@property (nonatomic,copy)DrawerBackValueBlock drawerBlcok;

@end
