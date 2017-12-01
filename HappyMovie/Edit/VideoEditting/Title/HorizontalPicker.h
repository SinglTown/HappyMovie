//
//  HorizontalPicker.h
//  HappyMovie
//
//  Created by lanou3g on 16/1/23.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HorizontalColorPickerDelegate <NSObject>

@optional
-(void)colorPicked:(UIColor *)color;

@end

@interface HorizontalPicker : UIView
//代理,将颜色传出
@property(nonatomic,weak)id<HorizontalColorPickerDelegate>delegate;

@property (nonatomic) IBInspectable UIColor *selectedColor;  //setting this will update the UI & notify the delegate


@end




