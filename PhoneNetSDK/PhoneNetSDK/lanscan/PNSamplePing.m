//
//  PNSamplePing.h
//  PhoneNetSDK
//
//  Created by mediaios on 2019/6/5.
//  Copyright © 2019年 mediaios. All rights reserved.
//

#import "PNSamplePing.h"
#import "PhoneNetSDKConst.h"
#include "log4cplus_pn.h"
#import "PNetQueue.h"


@interface PNSamplePing()
{
    int socket_client;
    struct sockaddr_in remote_addr;
}
@property (nonatomic,assign) BOOL isPing;

@property (nonatomic,assign) BOOL isStopPingThread;
@property (nonatomic,strong) NSString *host;
@property (nonatomic,assign) int pingPacketCount;
@end

@implementation PNSamplePing

- (instancetype)init
{
    if ([super init]) {
        
        _isStopPingThread = NO;
    }
    return self;
}

- (void)stopPing
{
    self.isStopPingThread = YES;
    shutdown(socket_client, SHUT_RDWR);
    close(socket_client);
    [self.delegate simplePing:self finished:self.host];
    log4cplus_debug("PhoneNetSDK-LanScanner", "scan ip %s end...",[self.host UTF8String]);
}

- (BOOL)isPing
{
    return !self.isStopPingThread;
}

- (BOOL)settingUHostSocketAddressWithIp:(NSString *)host
{
    const char *hostaddr = [host UTF8String];
    memset(&remote_addr, 0, sizeof(remote_addr));
    remote_addr.sin_addr.s_addr = inet_addr(hostaddr);
    struct timeval timeout;
    timeout.tv_sec = 0;
    timeout.tv_usec = 1000*200;
    socket_client = socket(AF_INET,SOCK_DGRAM,IPPROTO_ICMP);
    int nZero=0;
    setsockopt(socket_client,SOL_SOCKET,SO_SNDBUF,(char *)&nZero,sizeof(nZero));
    int res = setsockopt(socket_client, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
    if (res < 0) {
        log4cplus_warn("PhoneNetSimplePing", "ping %s , set timeout error..\n",[host UTF8String]);
        return YES;
    }
    remote_addr.sin_family = AF_INET;
    
    return YES;
}

- (void)startPingIp:(NSString *)ip packetCount:(int)count
{
    log4cplus_debug("PhoneNetSDK-LanScanner", "scan ip %s begin...",[ip UTF8String]);
    if ([self settingUHostSocketAddressWithIp:ip]) {
        self.host = ip;
    }
    
    if (self.host == NULL) {
        self.isStopPingThread = YES;
        log4cplus_warn("PhoneNetSDK-LanScanner", "There is no valid ip...\n");
        return;
    }
    
    if (count > 0) {
        _pingPacketCount = count;
    }
    [PNetQueue pnet_quick_ping_async:^{
        [self sendAndrecevPingPacket];
    }];
}

- (void)sendAndrecevPingPacket
{
    int index = 0;
    do {
        if (self.isStopPingThread) {
            return;
        }
        uint16_t identifier = (uint16_t)(KPingIcmpIdBeginNum + index);
        UICMPPacket *packet = [PhoneNetDiagnosisHelper constructPacketWithSeq:index andIdentifier:identifier];
        ssize_t sent = sendto(socket_client, packet, sizeof(UICMPPacket), 0, (struct sockaddr *)&remote_addr, (socklen_t)sizeof(struct sockaddr));
        if (sent < 0) {
            log4cplus_warn("PhoneNetSDK-LanScanner", "ping %s , error code:%d, send icmp packet error..\n",[self.host UTF8String],(int)sent);
            [self stopPing];
            break;
        }
        
        BOOL res = NO;
        struct sockaddr_storage ret_addr;
        socklen_t addrLen = sizeof(ret_addr);
        void *buffer = malloc(65535);
        
        size_t bytesRead = recvfrom(socket_client, buffer, 65535, 0, (struct sockaddr *)&ret_addr, &addrLen);
        
        if ((int)bytesRead < 0) {
            [self.delegate simplePing:self didTimeOut:self.host];
            res = YES;
        }else if(bytesRead == 0){
            log4cplus_warn("PhoneNetSDK-LanScanner", "ping %s , receive icmp packet error , bytesRead=0",[self.host UTF8String]);
        }else{
            
            if ([PhoneNetDiagnosisHelper isValidPingResponseWithBuffer:(char *)buffer len:(int)bytesRead]) {
                [self.delegate simplePing:self receivedPacket:self.host];
                [self stopPing];
                break;
            }
        }
        
        if (res) {
            index++;
        }
        usleep(1000);
    } while (!self.isStopPingThread && index < _pingPacketCount);
    
    if (index == _pingPacketCount) {
        [self stopPing];
    }
    
}
@end
