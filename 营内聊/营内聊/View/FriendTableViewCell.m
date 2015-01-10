//
//  FriendTableViewCell.m
//  营内聊
//
//  Created by WuQiong on 14/11/15.
//  Copyright (c) 2014年 戴维营教育. All rights reserved.
//

#import "FriendTableViewCell.h"

#import "Utils.h"

@implementation FriendTableViewCell

- (void)awakeFromNib {
    self.imageView.frame = CGRectMake(52 + 10, 10, 52, 52);
    self.imageView.layer.cornerRadius = 26;
    self.imageView.layer.masksToBounds = YES;
    
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.textColor = [UIColor whiteColor];
    
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        self.contentView.backgroundColor = UIColor(0xF2, 0x74, 0x73);
    }
    else {
        //252, 100, 104
        self.contentView.backgroundColor = UIColor(0xFC, 0x64, 0x68);
        
//        NSLog(@"S: %@", self.contentView.backgroundColor);
//        NSLog(@"C: %@", UIColor(0xFF, 0x7C, 0x7B));
    }
}

@end
