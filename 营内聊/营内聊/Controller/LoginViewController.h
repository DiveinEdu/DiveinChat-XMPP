//
//  LoginViewController.h
//  营内聊
//
//  Created by WuQiong on 14/11/13.
//  Copyright (c) 2014年 戴维营教育. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AccountViewController.h"

@interface LoginViewController : AccountViewController
- (IBAction)didLoginClicked:(UIButton *)sender;
- (IBAction)unwindFromRegister:(UIStoryboardSegue *)sender;
@end
