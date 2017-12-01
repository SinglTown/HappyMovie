//
//  DataStore.h
//  HappyMovie
//
//  Created by lanou3g on 16/1/25.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataStore : NSObject
//实例化存储对象
+(instancetype)sharedDataStore;
//初始化管理上下文
-(void)createContext;
//管理上下文
@property(nonatomic,strong)NSManagedObjectContext *context;

#pragma mark 插入数据到数据库
-(void)insertUrl:(NSString *)str;

#pragma mark 保存文件的路径
-(NSString *)saveFileToData;

#pragma mark - - 取出video中的所有的值
-(NSArray *)searchAllVideos;
#pragma mark -- - 删除数据库中的某条数据
-(void)deleteSomeOneWithUrl:(NSString *)url;
#pragma mark - 删除所有数据
-(void)deleteAllImageData;
-(void)deleteAllVideoData;

//图片路径
-(void)insertImagePathUrl:(NSString *)pathURL;

//取出数据库数据的方法
-(NSArray *)searchAllImageData;

//删除数据库图片
-(void)deleteImageUrlWithUrl:(NSString *)url;

@end
