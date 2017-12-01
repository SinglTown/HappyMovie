//
//  PassMergeHandle.m
//  happyMovieEditor
//
//  Created by lanou3g on 16/1/9.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "PassMergeHandle.h"
#import "ZYQAssetViewController.h"
static PassMergeHandle * handle  = nil;
@implementation PassMergeHandle
+(PassMergeHandle*)sharedHandle{
    return  [[self alloc]init];
    
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (handle == nil) {
            handle = [super allocWithZone:zone];
        }
    });
    return handle;
  
    
    
    
}
-(NSMutableArray*)passValueArray{
    
    if (_passValueArray == nil) {
        
         _passValueArray =   [[NSMutableArray alloc]init];
    }
    
    return _passValueArray;
}
-(NSMutableArray*)ownMusicArr{
    
    if (_ownMusicArr == nil) {
        
        _ownMusicArr =   [[NSMutableArray alloc]init];
        [self getMusic];
    }
    
    
    
    
    return _ownMusicArr;
    
    
}





-(NSMutableArray*)imageArray{
    
    if (_imageArray == nil) {
        
        _imageArray =   [[NSMutableArray alloc]init];
     
    }
    
    
    
    
    return _imageArray;
    
    
}



-(NSMutableArray*)releaseArr{
    
    if (_releaseArr == nil) {
        
        _releaseArr =   [[NSMutableArray alloc]init];
        
    }
    
    return _releaseArr;
    
    
}





-(void)getMusic{
    
    NSMutableDictionary * dic = nil;
    for (int i = 1 ; i< 7 ; i++) {
        NSString * musicS = [[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"%d",i] ofType:@"m4a"];
        if (i == 1) {
             dic = [NSMutableDictionary dictionaryWithObject:musicS forKey:@"慵懒时光"];
        }
        if (i == 2) {
           dic = [NSMutableDictionary dictionaryWithObject:musicS forKey:@"Freak Valse"];
        }
        if (i == 3) {
         dic = [NSMutableDictionary dictionaryWithObject:musicS forKey:@"Turkey in the Straw"];
        }    if (i == 4) {
         dic = [NSMutableDictionary dictionaryWithObject:musicS forKey:@"Jingle Bells"];
        }
        if (i == 5) {
             dic = [NSMutableDictionary dictionaryWithObject:musicS forKey:@"A French Picnic"];
        }
        if (i == 6) {
          dic = [NSMutableDictionary dictionaryWithObject:musicS forKey:@"古典"];
        }

        [_ownMusicArr addObject:dic];
        
    }
    
    
   // NSLog(@"%@",_ownMusicArr);
    
    
    
}
-(NSString*)musicUrlString{
    
    if (_musicUrlString == nil) {
        _musicUrlString =  [[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"%d",1] ofType:@"m4a"] ;
    }
    
    return _musicUrlString;
}



-(NSInteger)speed{
    
    if (_speed == 0) {
        _speed = 5;
    }
    return _speed;
}






-(ZYQAssetViewController*)ZYQAssetViewController{
    if (_zyq == 0) {
        _zyq = [[ZYQAssetViewController alloc]init];
    }
    return _zyq;
}



@end
