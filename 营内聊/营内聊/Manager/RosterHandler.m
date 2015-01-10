//
//  RosterHandler.m
//  营内聊
//
//  Created by WuQiong on 14/11/15.
//  Copyright (c) 2014年 戴维营教育. All rights reserved.
//

#import "RosterHandler.h"

#import "DDLog+LOGV.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation RosterHandler

+ (instancetype)sharedInstance
{
    static RosterHandler *sharedHandler = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHandler = [[RosterHandler alloc] init];
    });
    
    return sharedHandler;
}

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterPush:(XMPPIQ *)iq
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
}

- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
}
@end
