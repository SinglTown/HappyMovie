

#import "StartViewController.h"
#import "StartView.h"
#import "ImageViewCell.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "CreationViewController.h"
@interface StartViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,strong)StartView *startView;

@property (nonatomic,strong)UICollectionView *leftCollectionView;
@property (nonatomic,strong)UICollectionView *rightCollectionView;
//图片数组
@property (nonatomic,strong)NSMutableArray *imageArray;


@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    layout.itemSize = CGSizeMake(kScreenWidth/2, kScreenWidth/2);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.leftCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth/2, kScreenHeight-50) collectionViewLayout:layout];
    self.leftCollectionView.backgroundColor = [UIColor purpleColor];
    self.leftCollectionView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.leftCollectionView];
    
    self.leftCollectionView.dataSource = self;
    self.leftCollectionView.delegate = self;
    
    self.rightCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(kScreenWidth/2, 0, kScreenWidth/2, kScreenHeight-50) collectionViewLayout:layout];
    self.rightCollectionView.backgroundColor = [UIColor grayColor];
    self.rightCollectionView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.rightCollectionView];
    
    self.rightCollectionView.dataSource = self;
    self.rightCollectionView.delegate = self;
    
    
    
    //注册标记
    [self.leftCollectionView registerClass:[ImageViewCell class] forCellWithReuseIdentifier:@"ImageViewCell"];
    [self.rightCollectionView registerClass:[ImageViewCell class] forCellWithReuseIdentifier:@"ImageViewCell"];
    
    [self centerLine];
    
//    self.startView.userInteractionEnabled = YES;
//    rightCollectionView.userInteractionEnabled = YES;
//    leftCollectionView.userInteractionEnabled = YES;
    self.startView = [[StartView alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
    [self.view addSubview:self.startView];
    
    //把所有图片加入数组
    self.imageArray = [NSMutableArray array];
    for (int i = 0; i< 9 ; i++) {
        

        [self.imageArray addObject:[NSString stringWithFormat:@"login_material_%d.png",i+1]];
    }
    
    
    //添加定时器
    
    NSTimer *leftTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(leftNextPage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:leftTimer forMode:NSRunLoopCommonModes];
    
    NSTimer *rightTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
        target:self selector:@selector(rightNextPage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:rightTimer forMode:NSRunLoopCommonModes];
    self.rightCollectionView.contentOffset = CGPointMake(kScreenWidth/2, 9*kScreenHeight/2-kScreenHeight-50);
    
    //模糊效果以及Button
    [self allViews];
    
    
    //登陆注册的点击方法
    [self.startView.loginButton addTarget:self action:@selector(loginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.startView.registerButton addTarget:self action:@selector(registerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark - 登陆
-(void)loginButtonAction:(UIButton *)sender
{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self presentViewController:loginNC animated:YES completion:nil];
}
#pragma mark - 注册
-(void)registerButtonAction:(UIButton *)sender
{
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    UINavigationController *registerNC = [[UINavigationController alloc] initWithRootViewController:registerVC];
    [self presentViewController:registerNC animated:YES completion:nil];
}
-(void)leftNextPage
{
    CGPoint point = self.leftCollectionView.contentOffset;
    
    point.y = point.y+0.5;
    
    if (point.y == 9*(kScreenWidth/2)-kScreenHeight+50) {
        point.y = 0;
    }
    self.leftCollectionView.contentOffset = point;
}
-(void)rightNextPage
{
    CGPoint point = self.rightCollectionView.contentOffset;
    
    point.y = point.y-0.5;
    
    if (point.y == 0) {
        point.y = 9*kScreenHeight/2-kScreenHeight-50-kScreenHeight-kScreenHeight+100;
    }
    self.rightCollectionView.contentOffset = point;
    
}
-(void)allViews
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-50)];
    view.backgroundColor = [UIColor grayColor];
    view.alpha = 0.3;
    [self.view addSubview:view];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = [UIFont systemFontOfSize:30];
    nameLabel.center = CGPointMake(kScreenWidth/2, kScreenHeight-350);
    nameLabel.text = @"乐影.快乐你的生活";
    nameLabel.numberOfLines = 0;
    nameLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:nameLabel];
    
    UIButton *otherButton = [UIButton buttonWithType:UIButtonTypeSystem];
    otherButton.frame = CGRectMake(0,0,100,30);
    otherButton.center = CGPointMake(kScreenWidth/2, kScreenHeight-80);
    [otherButton setTitle:@"暂不登陆" forState:UIControlStateNormal];
    [otherButton addTarget:self action:@selector(mainViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:otherButton];
    
    UIView *buttonLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 1)];
    buttonLineView.center = CGPointMake(kScreenWidth/2, kScreenHeight-70);
    buttonLineView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:buttonLineView];
}
#pragma mark - 暂不登陆,进入主页面
-(void)mainViewAction:(UIButton *)sender
{
    CreationViewController *rootVC = [[CreationViewController alloc] init];
    [self presentViewController:rootVC animated:YES completion:nil];
}
-(void)centerLine
{
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth/2, 0, 0.5, kScreenHeight)];
    lineView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:lineView];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageViewCell" forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:self.imageArray[indexPath.item]];
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
