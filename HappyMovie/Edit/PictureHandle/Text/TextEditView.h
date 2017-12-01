//
//  TextEditView.h
//  Movie---Ceshi
//
//  Created by lanou3g on 16/1/18.
//  Copyright © 2016年 chuanbao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextEditView : UIView



@property (nonatomic)           BOOL    isOnFirst ;

@property (nonatomic,strong)UIColor *currentColor;

@property (nonatomic,strong) UITextField    *myTextField ;

-(instancetype)initWithMyFrame:(CGRect)frame;
- (void)remove ;

@end
