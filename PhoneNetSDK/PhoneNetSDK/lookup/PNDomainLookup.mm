//
//  PNDomainLook.m
//  PhoneNetSDK
//
//  Created by mediaios on 2019/2/28.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "PNDomainLookup.h"
#import "PhoneNetSDKConst.h"
#include "log4cplus_pn.h"
#import "PhoneNetDiagnosisHelper.h"
#import "PNetTools.h"

@interface PNDomainLookup()
{
    int socket_client;
    struct sockaddr_in remote_addr;
}

@end

@implementation PNDomainLookup

- (instancetype)init
{
    if (self = [super init]) {}
    return self;
}

+ (instancetype)shareInstance {
    static PNDomainLookup *instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[PNDomainLookup alloc] init];
    });
    return instance;
}

- (void)lookupDomain:(NSString * _Nonnull)domain completeHandler:(NetLookupResultHandler _Nonnull)handler;
{
    if (![PNetTools validDomain:domain]) {
        log4cplus_warn("PhoneNetSDKLookup", "your setting domain invalid..\n");
        handler(nil,[PNError errorWithInvalidArgument:@"domain invalid"]);
        return;
    }
    const char *hostaddr = [domain UTF8String];
    memset(&remote_addr, 0, sizeof(remote_addr));
    remote_addr.sin_addr.s_addr = inet_addr(hostaddr);
    
    if (remote_addr.sin_addr.s_addr == INADDR_NONE) {
        struct hostent *remoteHost = gethostbyname(hostaddr);
        if (remoteHost == NULL || remoteHost->h_addr == NULL) {
            log4cplus_warn("PhoneNetSDKLookup", "DNS parsing error...\n");
            handler(nil,[PNError errorWithInvalidCondition:[NSString stringWithFormat:@"DNS Parsing failure"]]);
            return;
        }
        
        NSMutableArray *mutArray = [NSMutableArray array];
        for (int i = 0; remoteHost->h_addr_list[i]; i++) {
            log4cplus_debug("PhoneNetSDKLookup", "IP addr %d , name: %s , addr:%s  \n",i+1,remoteHost->h_name,inet_ntoa(*(struct in_addr*)remoteHost->h_addr_list[i]));
            [mutArray addObject:[DomainLookUpRes  instanceWithName:[NSString stringWithUTF8String:remoteHost->h_name]  address:[NSString stringWithUTF8String:inet_ntoa(*(struct in_addr*)remoteHost->h_addr_list[i])]]];
        }
        handler(mutArray,nil);
        return;
    }
    
    log4cplus_warn("PhoneNetSDKLookup", "your setting domain error..\n");
    handler(nil,[PNError errorWithInvalidCondition:@"domain error"]);
    return;
}
@end
