//
//  XTPasterStageView.h
//  XTPasterManager
//
//  Created by apple on 15/7/8.
//  Copyright (c) 2015年 teason. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XTPasterView;
@interface XTPasterStageView : UIView

@property (nonatomic,strong) UIImage *originImage ;
@property (nonatomic,strong)NSMutableArray  *m_listPaster ;
@property (nonatomic,strong) XTPasterView   *pasterCurrent ;

- (instancetype)initWithFrame:(CGRect)frame ;
- (void)addPasterWithImg:(UIImage *)imgP ;
- (UIImage *)doneEdit ;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com