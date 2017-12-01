//
//  AppDelegate.m
//  HappyMovie
//
//  Created by lanou3g on 16/1/14.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "AppDelegate.h"
#import "StartViewController.h"
#import <AVOSCloud/AVOSCloud.h>
#import "UMSocial.h"
#import "CreationViewController.h"

#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "UMSocialSinaHandler.h"
#import "DataStore.h"
#import "GuidanceViewController.h"
@interface AppDelegate ()



@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    //leanCloud
    [AVOSCloud setApplicationId:@"NeRUU62LTbHpYkUXqpz10dQl-gzGzoHsz" clientKey:@"Yb5NeLbkCu90q8iB0hIKEAYn"];
    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    //友盟
    [UMSocialData setAppKey:@"568f5168e0f55a5aeb001443"];

    //QQ登陆
    [UMSocialQQHandler setQQWithAppId:@"1105057983" appKey:@"XuZcISAK6HlzQJqm" url:@"http://www.umeng.com/social"];
    //微信
    [UMSocialWechatHandler setWXAppId:@"wxbd408229ab0986c4" appSecret:@"df98a37c13c925d0be25679f1e472f45" url:@"http://www.umeng.com/social"];
    
    //新浪
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:@"isfirst"] == NO) {
        GuidanceViewController *guidanceVC = [[GuidanceViewController alloc] init];
        self.window.rootViewController = guidanceVC;
        [userDefaults setBool:YES forKey:@"isfirst"];
        
      //  [self cleanAtFirstOne];
        
        
    }else{
//        UIViewController *viewController = [[UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil] instantiateViewControllerWithIdentifier:@"LaunchScreen"];
//        
//        UIView *launchView = viewController.view;
//        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
//        UIWindow *mainWindow = delegate.window;
//        [mainWindow addSubview:launchView];
//        
//        [UIView animateWithDuration:1.5f delay:0.5f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//            launchView.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.5f, 1.5f, 1.0f);
//            launchView.alpha = 0.0f;
//        } completion:^(BOOL finished) {
//            [launchView removeFromSuperview];
//        }];
        
        if ([AVUser currentUser] == nil) {
            StartViewController *startVC = [[StartViewController alloc] init];
            self.window.rootViewController = startVC;
            
        }else{
            CreationViewController *cVC = [[CreationViewController alloc] init];
            self.window.rootViewController = cVC;
        }
        
    }
    
    //打开数据库表
    //创建文件夹
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    
    path = [path stringByAppendingPathComponent:@"leying"];
    
    if (![manager fileExistsAtPath:path]) {
        //创建文件夹
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //  NSLog(@"====== %@",path);
    
    //打开数据库
    [[DataStore sharedDataStore] createContext];
    
    return YES;
}
-(void)cleanAtFirstOne{

    //第一次登陆,清理数据库
    NSFileManager *file = [NSFileManager defaultManager];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:@"data"];
    if ([file fileExistsAtPath:path]) {
        [file removeItemAtPath:path error:nil];
    }
    
    //清理文件
     NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    NSString *filePath = [cachesPath stringByAppendingPathComponent:@"leying"];
    
    if (![file fileExistsAtPath:filePath]) {
        //创建文件夹
        [file removeItemAtPath:filePath error:nil];
    }


}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    if (result == FALSE) {
      
    }
    
    return result;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
