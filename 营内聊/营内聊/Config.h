//
//  Config.h
//  营内聊
//
//  Created by WuQiong on 14/11/14.
//  Copyright (c) 2014年 戴维营教育. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ServerState) {
    kDefaultServerState = 0,    //默认状态
    kLoginServerState,          //登录状态
    kRegisterServerState,       //注册状态
    kMessageServerState,        //消息状态
};

typedef NS_ENUM(NSUInteger, RequestErrorCode) {
    kRequestOK = 0,
    kRequestTimeout,
    kRequestError,
};

extern const NSInteger kTimeoutLength;

extern NSString * const kKeyChainIdentifier;

extern NSString * const kHostName;
extern NSString * const kOnlineType;
extern NSString * const kOfflineType;

extern NSString * const kLoginControllerID;
extern NSString * const kRegisterControllerID;
