//
//  DrawerColorPickerController.h
//  Drawing-Ceshi
//
//  Created by lanou3g on 16/1/19.
//  Copyright © 2016年 chuanbao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DrawerColorPickerControllerDelegate <NSObject>

- (void)colorSelected:(UIColor *)selectedColor;

@end

@interface DrawerColorPickerController : UIViewController

@property (nonatomic, weak) id <DrawerColorPickerControllerDelegate>delegate;
@property (nonatomic, strong) UIColor *currentSelectedColor;

@end
