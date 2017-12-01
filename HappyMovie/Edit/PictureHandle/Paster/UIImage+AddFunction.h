//
//  UIImage+AddFunction.h
//
//  Created by mini1 on 14-6-13.
//  Copyright (c) 2014年 TEASON. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (AddFunction)

+ (UIImage *)squareImageFromImage:(UIImage *)image
                     scaledToSize:(CGFloat)newSize ;

+ (UIImage *)getImageFromView:(UIView *)theView ;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com