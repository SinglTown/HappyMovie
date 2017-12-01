//
//  SetTableViewCell.m
//  HappyMovie
//
//  Created by lanou3g on 16/1/20.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "SetTableViewCell.h"

@implementation SetTableViewCell

- (void)awakeFromNib {
    
    self.userAvatarImageView.layer.cornerRadius = 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
