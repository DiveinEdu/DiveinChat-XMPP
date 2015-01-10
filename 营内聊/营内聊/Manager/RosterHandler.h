//
//  RosterHandler.h
//  营内聊
//
//  Created by WuQiong on 14/11/15.
//  Copyright (c) 2014年 戴维营教育. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

//专门用来处理好友关系的对象

@interface RosterHandler : NSObject <XMPPRosterDelegate>
+ (instancetype)sharedInstance;
@end
