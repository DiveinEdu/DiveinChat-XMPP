//
//  ServerManager.m
//  营内聊
//
//  Created by WuQiong on 14/11/14.
//  Copyright (c) 2014年 戴维营教育. All rights reserved.
//

#import "ServerManager.h"
#import "AccountManager.h"

#import "RosterHandler.h"

#import "DDLog+LOGV.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface ServerManager () <XMPPStreamDelegate>
{
    XMPPStream *_xmppStream;
    
    XMPPReconnect *_xmppReconnect;              //重连模块
//    XMPPRoom *_xmppRoom;                        //多人聊天
    XMPPRoster  *_xmppRoster;                   //通讯录
    XMPPvCardAvatarModule *_xmppAvatarModule;   //头像模块
    XMPPvCardTempModule *_xmppvCardModule;      //电子身份模块
    XMPPCapabilities *_xmppCapabilities;        //
    XMPPMessageArchiving *_xmppMessageArchiving;    //消息
//    XMPPIncomingFileTransfer *_incomingFileTransfer;            //文件传输模块
//    XMPPOutgoingFileTransfer *_outgoingFileTransfer;            //文件传输模块
    
    User *_user;    //当前操作用户
    ServerState _serverState;
}
@end

@implementation ServerManager
+ (instancetype)sharedManager
{
    static ServerManager *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ServerManager alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self configureStream];
    }
    
    return self;
}

//加载常用模块
- (void)loadModules
{
    //重连模块
    _xmppReconnect = [[XMPPReconnect alloc] init];
    [_xmppReconnect activate:_xmppStream];
    
    //多人聊天，暂不添加
//    _xmppRoom = [[XMPPRoom alloc] init];
//    [_xmppRoom activate:_xmppStream];
    
    //使用CoreData管理通讯录（花名册）
    XMPPRosterCoreDataStorage *rosterStorage = [XMPPRosterCoreDataStorage sharedInstance];
    _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:rosterStorage];
    
    //重构时可以用来封装好友关系的处理，改善代码结构
//    RosterHandler *rosterhandler = [RosterHandler sharedInstance];
//    [_xmppRoster addDelegate:rosterhandler delegateQueue:dispatch_get_main_queue()];
    
    _xmppRoster.autoFetchRoster = YES;  //自动获取通讯录
    _xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    [_xmppRoster activate:_xmppStream];
    
    //使用电子名片
    XMPPvCardCoreDataStorage *vCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _xmppvCardModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:vCardStorage];
    [_xmppvCardModule activate:_xmppStream];
    
    //头像
    _xmppAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_xmppvCardModule];
    [_xmppAvatarModule activate:_xmppStream];
    
    //服务端功能
    XMPPCapabilitiesCoreDataStorage *capabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    _xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:capabilitiesStorage];
//    _xmppCapabilities.autoFetchHashedCapabilities = YES;
    [_xmppCapabilities activate:_xmppStream];
    
    //消息
    XMPPMessageArchivingCoreDataStorage *messageStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    _xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:messageStorage];
    [_xmppMessageArchiving activate:_xmppStream];
}

//卸载模块
- (void)unloadModules
{
    [_xmppReconnect deactivate];
    _xmppReconnect = nil;
    
//    [_xmppRoom deactivate];
//    _xmppRoom = nil;
    
    [_xmppRoster deactivate];
    _xmppRoster = nil;
    
    [_xmppvCardModule deactivate];
    _xmppvCardModule = nil;
    
    [_xmppAvatarModule deactivate];
    _xmppAvatarModule = nil;
    
    [_xmppCapabilities deactivate];
    _xmppCapabilities = nil;
}

- (void)configureStream
{
    //创建XMPP Stream
    _xmppStream = [[XMPPStream alloc] init];
    //设置服务器地址，如果没有设置，则通过JID获取服务器地址
    _xmppStream.hostName = kHostName;
    //设置代理，多播代理（可以设置多个代理对象）
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self loadModules];
}

- (void)startRequest:(ServerState)state
{
    if (_willStartRequest) {
        _willStartRequest(state);
    }
}

- (void)finishedRequest:(ServerState)state errorCode:(RequestErrorCode)code
{
    if (_didFinishedRequest) {
        _didFinishedRequest(state, code);
    }
}

//连接服务器
- (void)_connectWithState:(ServerState)state
{
    NSError *error;
    if(![_xmppStream connectWithTimeout:kTimeoutLength error:&error]) {
        DDLogCVerbose(@"%s: %@", __PRETTY_FUNCTION__, error);
        return;
    }
    
    //连接服务器，并设置为注册状态
    _serverState = state;
}

- (void)connect    //连接服务器
{
    _xmppStream.myJID = [XMPPJID jidWithString:[AccountManager sharedManager].user.username];
    [_xmppStream connectWithTimeout:kTimeoutLength error:nil];
}

- (void)disconnect //断开服务器连接
{
    [_xmppStream disconnect];
}

#pragma mark - 登录&注册

//用户登录
- (void)_loginWithPassword:(NSString *)password
{
    NSError *error;
    if (![_xmppStream authenticateWithPassword:password error:&error]) {
        DDLogVerbose(@"认证调用失败: %@", error);
    }
}

- (void)login:(User *)user //登录服务器
{
    [self startRequest:kLoginServerState];
    
    _user = user;
    _xmppStream.myJID = [XMPPJID jidWithString:user.username];
    
    if ([_xmppStream isConnected]) {
        [self _loginWithPassword:user.password];
    }
    else {
        [self _connectWithState:kLoginServerState];
    }
}

//发送到场状态(上线／下线)
- (void)sendPresence:(NSString *)type
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:type];
    [_xmppStream sendElement:presence];
}

- (void)logout             //退出登录
{
    [self offline];
    
    //断开服务器连接
    [self disconnect];
    
    //清理用户数据
    [[AccountManager sharedManager] resetUser];
}

- (void)online             //上线
{
    [self sendPresence:kOnlineType];
}

- (void)offline            //下线
{
    [self sendPresence:kOfflineType];
}

- (void)_registerWithPassword:(NSString *)password
{
    //服务器不支持带内注册
    if (!_xmppStream.supportsInBandRegistration) {
        DDLogVerbose(@"In Band Registration Not Supported");
        return;
    }
    
    NSError *error;
    //使用密码注册用户
    if (![_xmppStream registerWithPassword:password error:&error]) {
        DDLogCVerbose(@"%s: %@", __PRETTY_FUNCTION__, error);
    }
}

//如果服务器不支持注册、没有连接或者缺少信息，返回NO
- (void)registerUser:(User *)user   //用户注册
{
    [self startRequest:kRegisterServerState];
    
    _user = user;
    _xmppStream.myJID = [XMPPJID jidWithString:user.username];
    
    //必须先连接才能注册
    if ([_xmppStream isConnected]) {
        //注册用户
        [self _registerWithPassword:user.password];
    }
    else {
        [self _connectWithState:kRegisterServerState];
    }
}

#pragma mark - 用户信息&好友管理
- (void)refreshUserInfo:(User *)user   //更新个人信息
{
    
}

- (void)queryUserInfo:(User *)user  //请求个人信息
{
    
}

- (void)fetchFriendsList;           //获取好友列表
{
    [_xmppRoster fetchRoster];
}

- (void)addFriend:(User *)user     //添加好友
{
    XMPPJID *jid = [XMPPJID jidWithString:user.username];
    [_xmppRoster addUser:jid withNickname:nil];
}

- (void)removeFriend:(User *)user  //移除好友
{
    XMPPJID *jid = [XMPPJID jidWithString:user.username];
    [_xmppRoster removeUser:jid];
}

- (void)acceptFriend:(User *)user  //接受好友邀请
{
    
}

- (void)sendMessage:(Message *)message toUser:(User *)user     //给用户发送消息
{
    XMPPJID *jid = [XMPPJID jidWithString:user.username];
    XMPPMessage *e = [XMPPMessage messageWithType:@"chat" to:jid];
    [e addBody:message.body];
    
    [_xmppStream sendElement:e];
}

- (void)sendMessage:(Message *)message toGroup:(Group *)group  //给组发送消息
{
    
}

- (XMPPvCardAvatarModule *)avatarModule //头像模块
{
    return _xmppAvatarModule;
}

- (NSManagedObjectContext *)rosterContext
{
    XMPPRosterCoreDataStorage *storage = [XMPPRosterCoreDataStorage sharedInstance];
    return [storage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)vCardContext
{
    XMPPvCardCoreDataStorage *storage = [XMPPvCardCoreDataStorage sharedInstance];
    return [storage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)messageContext
{
    XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    return [storage mainThreadManagedObjectContext];
}

- (void)dealloc
{
    [self unloadModules];
}

#pragma mark - XMPPStreamDelegate
//服务器连接建立成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    switch (_serverState) {
        case kLoginServerState:
            [self _loginWithPassword:_user.password];
            break;
        case kRegisterServerState:
            [self _registerWithPassword:_user.password];
            break;
        default:
            break;
    }
    
    DDLogVerbose(@"服务器连接成功");
}

//连接超时
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{
    [self finishedRequest:_serverState errorCode:kRequestTimeout];
    _serverState = kDefaultServerState;
    
    DDLogVerbose(@"连接超时");
}

//断开连接
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    DDLogVerbose(@"连接断开");
}

#pragma mark - Account
//注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    //完成注册请求
    [self finishedRequest:_serverState errorCode:kRequestOK];
    _serverState = kDefaultServerState;
    
    [self online];  //上线
    
    //保存用户信息数据
    [AccountManager sharedManager].user = _user;
    
    DDLogVerbose(@"用户注册成功");
}

//注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
    _serverState = kDefaultServerState;
    [self finishedRequest:_serverState errorCode:kRequestError];
    
    DDLogVerbose(@"用户注册失败：%@", error);
}

//登录成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    [self finishedRequest:_serverState errorCode:kRequestOK];
    _serverState = kDefaultServerState;
    
    [self online];  //上线
    [AccountManager sharedManager].user = _user;
    
    DDLogVerbose(@"用户登录成功");
}

//登录失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    [self finishedRequest:_serverState errorCode:kRequestError];
    _serverState = kDefaultServerState;
    
    DDLogVerbose(@"用户登录失败: %@", error);
}

#pragma mark - Receive Message
//接收到信息请求
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    DDLogVerbose(@"Received IQ: %@", iq);
    return YES;
}

//接收到消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    DDLogVerbose(@"Received Message%@", message);
}

//接收到上线信息
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    DDLogVerbose(@"Received Presence: %@", presence);
}

//接收错误
- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement *)error
{
    DDLogVerbose(@"Receive Error: %@", error);
}

#pragma mark - Send
//发送信息请求成功
- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq
{
    DDLogVerbose(@"Send IQ: %@", iq);
}

//发送消息成功
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    DDLogVerbose(@"Send Message: %@", message);
}

//发送在线信息成功
- (void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence
{
    DDLogVerbose(@"Send Presence: %@", presence);
}

#pragma mark - Failure
//发送信息请求失败
- (void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error
{
    DDLogVerbose(@"Fail To Send IQ: %@\nError: %@", iq, error);
}

//发送消息失败
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error
{
    DDLogVerbose(@"Fail To Send Message: %@\nError: %@", message, error);
}

//发送在线信息失败
- (void)xmppStream:(XMPPStream *)sender didFailToSendPresence:(XMPPPresence *)presence error:(NSError *)error
{
    DDLogVerbose(@"Fail To Send Presence: %@\nError: %@", presence, error);
}
@end
