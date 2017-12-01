//
//  Video+CoreDataProperties.h
//  HappyMovie
//
//  Created by chuanbao on 16/1/25.
//  Copyright © 2016年 刘培培. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Video.h"

NS_ASSUME_NONNULL_BEGIN

@interface Video (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *url;

@end

NS_ASSUME_NONNULL_END
