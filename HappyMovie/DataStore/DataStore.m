//
//  DataStore.m
//  HappyMovie
//
//  Created by lanou3g on 16/1/25.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "DataStore.h"
#import <CoreData/CoreData.h>
#import "Video.h"
#import "Image.h"
static DataStore *tool = nil;
@implementation DataStore
//实例化存储对象
+(instancetype)sharedDataStore{
   
    return [[self alloc] init];

}
+(instancetype)allocWithZone:(struct _NSZone *)zone{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (tool == nil) {
            tool = [super allocWithZone:zone];
        }
        
    });
    return tool;
}

//初始化管理上下文
-(void)createContext{

    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    //存储路径
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:@"data"];
    
    //存储方式
    NSDictionary *dict = @{NSMigratePersistentStoresAutomaticallyOption:[NSNumber numberWithBool:YES],NSInferMappingModelAutomaticallyOption:[NSNumber numberWithBool:YES]};
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:path] options:dict error:nil];
    
    //初始化管理上下文
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.context.persistentStoreCoordinator = coordinator;
    
}

#pragma mark 插入数据到数据库
-(void)insertUrl:(NSString *)str
{
    Video *video = [NSEntityDescription insertNewObjectForEntityForName:@"Video" inManagedObjectContext:self.context];
    video.url = str;
    if ([self.context hasChanges]) {
        [self.context save:nil];
    }
}

#pragma mark 保存文件的路径
-(NSString *)saveFileToData
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:@"leying"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    formatter.dateFormat = @"yyyy-MM-dd-HHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString  *myPathDocs = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".mp4"];
    return myPathDocs;
}
#pragma mark - - 取出video中的所有的值
-(NSArray *)searchAllVideos{
    
    //创建搜索请求对象,并且指明所有的数据类型
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Video"];
    NSArray *objcArr =  [self.context executeFetchRequest:request error:nil];
  
    
    return objcArr;
}

#pragma mark -- - 删除数据库中的某条数据
-(void)deleteSomeOneWithUrl:(NSString *)url{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Video"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url = %@",url];
    request.predicate = predicate;
    NSArray *videoArr = [self.context executeFetchRequest:request error:nil];
    //查询到得对象存放在context中,进行删除
    if (videoArr.count>0) {
        
        for (Video *video in videoArr) {
            //self.context删除对象
            [self.context deleteObject:video];
            
        }
    }
    //保存结果
    if ([self.context hasChanges]) {
        [self.context save:nil];
    }
    
    
}
//图片路径
-(void)insertImagePathUrl:(NSString *)pathURL
{
    Image *image = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:self.context];
    image.imageUrl = pathURL;
    if ([self.context hasChanges]) {
        [self.context save:nil];
    }
}
//取出数据库数据的方法
-(NSArray *)searchAllImageData
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Image"];
    NSArray *imagePathArray = [self.context executeFetchRequest:request error:nil];
  
    return imagePathArray;
}
//删除数据库图片
-(void)deleteImageUrlWithUrl:(NSString *)url
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Image"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imageUrl = %@",url];
    request.predicate = predicate;
    NSArray *imageArray = [self.context executeFetchRequest:request error:nil];
    if (imageArray.count > 0) {
        for (Image *image in imageArray) {
            [self.context deleteObject:image];
        }
    }
}
#pragma mark - 删除所有数据
-(void)deleteAllImageData
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Image"];
    NSArray *allImageArr = [self.context executeFetchRequest:request error:nil];
    if (allImageArr.count > 0) {
        for (Image *image in allImageArr) {
            [self.context deleteObject:image];
        }
    }
    if ([self.context hasChanges]) {
        [self.context save:nil];
    }
}
-(void)deleteAllVideoData
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Video"];
    NSArray *allVideoArr = [self.context executeFetchRequest:request error:nil];
    if (allVideoArr.count > 0) {
        for (Video *video in allVideoArr) {
            [self.context deleteObject:video];
        }
    }
    if ([self.context hasChanges]) {
        [self.context save:nil];
    }
}

@end
