//
//  SetViewController.m
//  happyMovieEditor
//
//  Created by lanou3g on 16/1/9.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "SetViewController.h"
#import <AVOSCloud/AVOSCloud.h>
#import "SetTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "UMSocial.h"
#import "NikenameViewController.h"
#import "MBProgressHUD.h"
#import "OpinionViewController.h"
#import "SDImageCache.h"
#import "NewHelperViewController.h"
#import "VersionViewController.h"
#import "DataStore.h"
@interface SetViewController ()<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *setTableView;

@property (nonatomic,strong)NSArray *setContentArray;

@property (nonatomic,strong)SetTableViewCell *setTableViewCell;

@property (nonatomic,strong)AVFile *avatarFile;

@end

@implementation SetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.27 green:0.24 blue:0.22 alpha:1];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconfont-fanhui.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.setTableView.dataSource = self;
    self.setTableView.delegate = self;
    
    self.setContentArray = @[@[@"个人信息"],@[@"清除缓存",@"意见反馈",@"帮助",@"关于"],@[@"退出登陆"]];
    
    [self.setTableView registerNib:[UINib nibWithNibName:@"SetTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SetTableViewCell"];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self setImageForAvatarImageViewAndName];
    [self.setTableView reloadData];
}
#pragma mark - 回收键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
#pragma mark - 返回
-(void)backAction:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 设置row
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.setContentArray[section] count];
}
#pragma mark - 设置cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        self.setTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"SetTableViewCell"];
        [self setImageForAvatarImageViewAndName];
        return self.setTableViewCell;
    }else{
        static NSString *cell_id = @"cell_id";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
        }
        if (indexPath.section == 1) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text = self.setContentArray[indexPath.section][indexPath.row];
        if (indexPath.section == 2) {
            //cell.backgroundColor = [UIColor redColor];
            cell.textLabel.font = [UIFont systemFontOfSize:20];
            //cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
        return cell;
    }
}
#pragma mark - 设置section
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
#pragma mark - 设置row的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        return 80;
    }else{
        return 50;
    }
}
#pragma mark - 点击
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2) {
        
        if ([AVUser currentUser] != nil) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定退出?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [AVUser logOut];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"loginOut" object:nil];
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            [alertVC addAction:confirmAction];
            [alertVC addAction:cancelAction];
            [self presentViewController:alertVC animated:YES completion:nil];
        }else{
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请先登录!" preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alertVC animated:YES completion:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }
    }
    if (indexPath.section == 0) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] && [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
                //打开相机拍照
                UIImagePickerController *pickerVC = [[UIImagePickerController alloc] init];
                pickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
                pickerVC.allowsEditing = YES;
                pickerVC.delegate = self;
                [self presentViewController:pickerVC animated:YES completion:nil];
                
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"相机不可用" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
                [alert show];
            }
        }];
        UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"从相册选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //从相册选择照片添加为头像
            
            UIImagePickerController *pickerVC = [[UIImagePickerController alloc] init];
            pickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            pickerVC.allowsEditing = YES;
            pickerVC.delegate = self;
            
            [self presentViewController:pickerVC animated:YES completion:nil];
            
        }];
        UIAlertAction *nikeNameAction = [UIAlertAction actionWithTitle:@"设置昵称" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NikenameViewController *nikenameVC = [[NikenameViewController alloc] init];
            [self.navigationController pushViewController:nikenameVC animated:YES];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVC addAction:nikeNameAction];
        [alertVC addAction:cameraAction];
        [alertVC addAction:photoAction];
        [alertVC addAction:cancelAction];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
    if (indexPath.section == 1 && indexPath.row == 1) {
        OpinionViewController *opinionVC = [[OpinionViewController alloc] init];
        [self.navigationController pushViewController:opinionVC animated:YES];
    }
    if (indexPath.section == 1 && indexPath.row == 0) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"清除缓存将删除掉所有作品,是否继续?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            NSString *leyingPath = [cachesPath stringByAppendingPathComponent:@"leying"];
            [[DataStore sharedDataStore] deleteAllVideoData];
            [[DataStore sharedDataStore] deleteAllImageData];
            [fileManager removeItemAtPath:leyingPath error:nil];
            
            //创建文件夹
            if (![fileManager fileExistsAtPath:leyingPath]) {
                //创建文件夹
                [fileManager createDirectoryAtPath:leyingPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"清除缓存成功!" preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alertVC animated:YES completion:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });

            
        }];
        [alertVC addAction:confirmAction];
        [alertVC addAction:cancelAction];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
    if (indexPath.section == 1 && indexPath.row == 2) {
        NewHelperViewController *helpVC = [[NewHelperViewController alloc] init];
        [self presentViewController:helpVC animated:YES completion:nil];
    }
    if (indexPath.section == 1 && indexPath.row == 3) {
        VersionViewController *versionVC = [[VersionViewController alloc] init];
        [self.navigationController pushViewController:versionVC animated:YES];
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    UIImage *scaleImage = [self scaleImage:image toScale:0.1];
    NSData *data = UIImagePNGRepresentation(scaleImage);
    AVQuery *avatarQuery = [AVQuery queryWithClassName:@"_File"];
    [avatarQuery whereKey:@"name" equalTo:[NSString stringWithFormat:@"%@.png",[AVUser currentUser].username]];
    [avatarQuery getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        if (!object) {
            [self setSaveImageWithData:data];
        }else{
            [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [self setSaveImageWithData:data];
                }else{
                 //   NSLog(@"删除失败 %@",error);
                }
            }];
            //NSLog(@"----查找重复 %@",error);
        }
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 查找存图片的方法
-(void)setSaveImageWithData:(NSData *)data
{
    [MBProgressHUD showHUDAddedTo:self.setTableView animated:YES];
    AVQuery *messageQuery = [AVQuery queryWithClassName:@"UserMessage"];
    [messageQuery whereKey:@"name" equalTo:[AVUser currentUser].username];
    [messageQuery getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        AVFile *file = [AVFile fileWithName:[NSString stringWithFormat:@"%@.png",[AVUser currentUser].username] data:data];
        [object setObject:file forKey:@"avatarImage"];
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self setImageForAvatarImageViewAndName];
            }else{
                NSLog(@"赋值失败 %@",error);
            }
        }];
    }];
}
#pragma mark - 给图片赋值的方法
-(void)setImageForAvatarImageViewAndName
{
    AVQuery *query = [AVQuery queryWithClassName:@"UserMessage"];
    [query whereKey:@"name" equalTo:[AVUser currentUser].username];
    [query getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        if (object != nil) {
            if ([object objectForKey:@"nikename"] != nil) {
                NSString *nikename = [object objectForKey:@"nikename"];
                self.setTableViewCell.userNameLabel.text = [NSString stringWithFormat:@"昵称: %@",nikename];
            }else{
                NSString *name = [object objectForKey:@"name"];
                self.setTableViewCell.userNameLabel.text = [NSString stringWithFormat:@"昵称: %@",name];
            }
            AVFile *avatarFile = [object objectForKey:@"avatarImage"];
            if (avatarFile != nil) {
                NSData *avatarData = [avatarFile getData];
                UIImage *avatarImage = [UIImage imageWithData:avatarData];
                self.setTableViewCell.userAvatarImageView.image = avatarImage;
                if ([AVUser currentUser] != nil) {
                    [self.setTableView reloadData];
                }
            }
        }else{
          //  NSLog(@"%@",error);
        }
    }];
    [MBProgressHUD hideAllHUDsForView:self.setTableView animated:YES];
}
#pragma mark - 缩小图片的尺寸
-(UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
