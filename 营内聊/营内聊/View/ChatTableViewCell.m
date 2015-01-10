//
//  ChatTableViewCell.m
//  营内聊
//
//  Created by WuQiong on 14/11/15.
//  Copyright (c) 2014年 戴维营教育. All rights reserved.
//

#import "ChatTableViewCell.h"

@implementation ChatTableViewCell

- (void)awakeFromNib {
    self.avatarImageView.layer.cornerRadius = 26;
    self.avatarImageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
