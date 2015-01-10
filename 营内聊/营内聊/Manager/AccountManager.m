//
//  AccountManager.m
//  营内聊
//
//  Created by WuQiong on 14/11/13.
//  Copyright (c) 2014年 戴维营教育. All rights reserved.
//

#import "AccountManager.h"

#import "Config.h"
#import "KeychainItemWrapper.h"

@implementation AccountManager
+ (instancetype)sharedManager
{
    static AccountManager *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AccountManager alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _user = [[User alloc] init];
        
        KeychainItemWrapper *itemWrapper = [self keychainItemWrapper];
        _user.username = [itemWrapper objectForKey:(__bridge id)(kSecAttrAccount)];
        _user.password = [itemWrapper objectForKey:(__bridge id)(kSecValueData)];
    }
    
    return self;
}

- (void)setUser:(User *)user
{
    _user = user;
    KeychainItemWrapper *itemWrapper = [self keychainItemWrapper];
    [itemWrapper setObject:user.username forKey:(__bridge id)(kSecAttrAccount)];
    [itemWrapper setObject:user.password forKey:(__bridge id)(kSecValueData)];
}

- (void)resetUser
{
    _user = nil;
    KeychainItemWrapper *itemWrapper = [self keychainItemWrapper];
    [itemWrapper resetKeychainItem];
}

- (KeychainItemWrapper *)keychainItemWrapper
{
    return [[KeychainItemWrapper alloc] initWithIdentifier:kKeyChainIdentifier accessGroup:nil];
}

- (BOOL)isLogin
{
    if (_user.username.length && _user.password.length) {
        return YES;
    }
    
    return NO;
}
@end
