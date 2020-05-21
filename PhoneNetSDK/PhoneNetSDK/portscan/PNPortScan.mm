//
//  PNPortScan.m
//  PhoneNetSDK
//
//  Created by mediaios on 2019/2/28.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "PNPortScan.h"
#import "PhoneNetSDKConst.h"
#include "log4cplus_pn.h"
#import "PhoneNetDiagnosisHelper.h"
#import "PNetQueue.h"
@interface PNPortScan()
{
    int socket_client;
}

@property (nonatomic,assign) BOOL isStopPortScan;

@end

@implementation PNPortScan

- (instancetype)init
{
    if (self = [super init]) {
        _isStopPortScan = YES;
    }
    return self;
}

+ (instancetype)shareInstance {
    static PNPortScan *instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[PNPortScan alloc] init];
    });
    return instance;
}

- (void)startPortScan:(NSString *)host beginPort:(NSUInteger)beginPort endPort:(NSUInteger)endPort completeHandler:(NetPortScanHandler)handler
{
    // 获取 IP 地址
    struct hostent * remoteHostEnt = gethostbyname([host UTF8String]);
    if (NULL == remoteHostEnt) {
        log4cplus_warn("PhoneNetSDKPortScan", "Unable to parse host");
        handler(nil,NO,[PNError errorWithInvalidCondition:@"Unable to parse host"]);
        return;
    }
    struct in_addr * remoteInAddr = (struct in_addr *)remoteHostEnt->h_addr_list[0];
    self.isStopPortScan = NO;
    NSUInteger port = beginPort;
    do {
        if (port > endPort) {
            break;
        }
        socket_client = socket(AF_INET, SOCK_STREAM, 0);
        if (-1 == socket_client) {
            return;
        }
        // 设置 socket 参数
        struct sockaddr_in socketParameters;
        socketParameters.sin_family = AF_INET;
        socketParameters.sin_addr = *remoteInAddr;
        socketParameters.sin_port = htons(port);
        int ret = connect(socket_client, (struct sockaddr *) &socketParameters, sizeof(socketParameters));
        if (-1 == ret) {
            close(socket_client);
            handler([NSString stringWithFormat:@"%lu",port],NO,nil);
            continue;
        }
        handler([NSString stringWithFormat:@"%lu",port],YES,nil);
        close(socket_client);
    } while (!self.isStopPortScan && port++ <= endPort);
    
    self.isStopPortScan = YES;
}

- (void)portScan:(NSString *)host beginPort:(NSUInteger)beginPort endPort:(NSUInteger)endPort completeHandler:(NetPortScanHandler)handler
{
    [PNetQueue pnet_async:^{
        [self  startPortScan:host beginPort:beginPort endPort:endPort completeHandler:handler];
    }];
}

- (BOOL)isDoingScanPort
{
    return !self.isStopPortScan;
}

- (void)stopPortScan
{
    self.isStopPortScan = YES;
}
@end
