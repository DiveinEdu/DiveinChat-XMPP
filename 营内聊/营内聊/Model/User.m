//
//  User.m
//  营内聊
//
//  Created by WuQiong on 14/11/13.
//  Copyright (c) 2014年 戴维营教育. All rights reserved.
//

#import "User.h"

#import "Config.h"

@implementation User
//检查用户名是否完整（包含服务器地址）
- (NSString *)username
{
    if ([_username hasSuffix:kHostName]) {
        return _username;
    }
    else {
        return [_username stringByAppendingFormat:@"@%@", kHostName];
    }
}
@end
