//
//  PassMergeHandle.h
//  happyMovieEditor
//
//  Created by lanou3g on 16/1/9.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZYQAssetViewController;
typedef void(^ZYQASSETVCBLOCK)(ZYQAssetViewController*zyq) ;
typedef void (^GoToChangeSpeed) ();
@interface PassMergeHandle : NSObject
@property(nonatomic,strong)NSString * pathString;
@property(nonatomic,strong)NSMutableArray * passValueArray;
@property(nonatomic,strong)NSString *musicUrlString;
@property(nonatomic,strong)NSMutableArray * ownMusicArr;
@property(nonatomic,assign)NSInteger speed;
@property(nonatomic,copy)GoToChangeSpeed gotoChangeSpeed;
@property(nonatomic,strong)NSMutableArray * imageArray;
@property(nonatomic,strong)NSString * finalMovieString;
@property(nonatomic,strong)NSMutableArray * releaseArr;

@property(nonatomic,strong)ZYQAssetViewController*zyq;

@property(nonatomic,copy)ZYQASSETVCBLOCK zyqblock;
+(PassMergeHandle*)sharedHandle;

@end
