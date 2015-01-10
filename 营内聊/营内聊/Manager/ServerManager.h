//
//  ServerManager.h
//  营内聊
//
//  Created by WuQiong on 14/11/14.
//  Copyright (c) 2014年 戴维营教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreData;

#import "Config.h"

#import "User.h"
#import "Group.h"
#import "Message.h"

#import "XMPPFramework.h"

@interface ServerManager : NSObject

@property (nonatomic, copy) void (^willStartRequest)(ServerState state);
@property (nonatomic, copy) void (^didFinishedRequest)(ServerState state, RequestErrorCode code);
@property (nonatomic, copy) void (^didFetchJID)();

+ (instancetype)sharedManager;

- (void)connect;    //连接服务器
- (void)disconnect; //断开服务器连接

- (void)login:(User *)user; //登录服务器
- (void)logout;             //退出登录

- (void)online;             //上线
- (void)offline;            //下线

- (void)registerUser:(User *)user;      //用户注册
- (void)refreshUserInfo:(User *)user;   //更新个人信息
- (void)queryUserInfo:(User *)user; //请求个人信息

- (void)fetchFriendsList;           //获取好友列表
- (void)addFriend:(User *)user;     //添加好友
- (void)removeFriend:(User *)user;  //移除好友
- (void)acceptFriend:(User *)user;  //接受好友邀请

- (void)sendMessage:(Message *)message toUser:(User *)user;     //给用户发送消息
- (void)sendMessage:(Message *)message toGroup:(Group *)group;  //给组发送消息

- (XMPPvCardAvatarModule *)avatarModule;    //头像模块;
- (NSManagedObjectContext *)rosterContext;  //好友存储
- (NSManagedObjectContext *)vCardContext;   //名片存储
- (NSManagedObjectContext *)messageContext; //消息存储
@end
