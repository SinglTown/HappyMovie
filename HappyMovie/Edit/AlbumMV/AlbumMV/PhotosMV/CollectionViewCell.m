//
//  CollectionViewCell.m
//  happyMovieEditor
//
//  Created by lanou3g on 16/1/8.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (void)awakeFromNib {
   
    self.cellImageView.layer.cornerRadius =45;
    self.cellImageView.clipsToBounds = YES;
    self.cellImageView.image = [UIImage imageNamed:@"3.jpg"];
    
}













@end
