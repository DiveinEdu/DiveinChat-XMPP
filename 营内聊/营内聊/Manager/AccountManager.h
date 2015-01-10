//
//  AccountManager.h
//  营内聊
//
//  Created by WuQiong on 14/11/13.
//  Copyright (c) 2014年 戴维营教育. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "User.h"

@interface AccountManager : NSObject
@property (nonatomic, strong) User *user;

+ (instancetype)sharedManager;

- (void)resetUser;
- (BOOL)isLogin;
@end
