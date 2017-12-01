//
//  MusicViewController.m
//  happyMovieEditor
//
//  Created by lanou3g on 16/1/12.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "MusicViewController.h"
#import "MyViewCell.h"
@interface MusicViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UISegmentedControl *musicSegment;
@property (strong, nonatomic) IBOutlet UITableView *musicListView;

@end

@implementation MusicViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutView];
    
}



//布局视图
-(void)layoutView{
    [self.musicListView registerNib:[UINib nibWithNibName:@"MyViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MyViewCell"];
    self.musicListView.delegate = self;
    self.musicListView.dataSource = self;
}


//返回
- (IBAction)gobackAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MyViewCell * cell  =[tableView dequeueReusableCellWithIdentifier:@"MyViewCell"forIndexPath:indexPath];
    cell.timeLabel.text = @"sdfasdf";
    cell.nameLabel.text = @"sdf";
    return cell;
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
