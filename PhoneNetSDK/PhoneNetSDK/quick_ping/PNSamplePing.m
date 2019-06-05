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
    [self.delegate simplePing:self finished:self.host];
}

- (BOOL)isPing
{
    return !self.isStopPingThread;
}

- (BOOL)settingUHostSocketAddressWithHost:(NSString *)host
{
    const char *hostaddr = [host UTF8String];
    memset(&remote_addr, 0, sizeof(remote_addr));
    remote_addr.sin_addr.s_addr = inet_addr(hostaddr);
    
    if (remote_addr.sin_addr.s_addr == INADDR_NONE) {
        struct hostent *remoteHost = gethostbyname(hostaddr);
        if (remoteHost == NULL || remoteHost->h_addr == NULL) {
            log4cplus_warn("PhoneNetPing", "access %s DNS error, remove this ip..\n",[host UTF8String]);
            return NO;
        }
        remote_addr.sin_addr = *(struct in_addr *)remoteHost->h_addr;
    }
    
    struct timeval timeout;
    timeout.tv_sec = 0;
    timeout.tv_usec = 1000*100;
    socket_client = socket(AF_INET,SOCK_DGRAM,IPPROTO_ICMP);
    int res = setsockopt(socket_client, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
    if (res < 0) {
        log4cplus_warn("PhoneNetPing", "ping %s , set timeout error..\n",[host UTF8String]);
    }
    remote_addr.sin_family = AF_INET;
    
    return YES;
}

- (NSString *)convertDomainToIp:(NSString *)host
{
    const char *hostaddr = [host UTF8String];
    memset(&remote_addr, 0, sizeof(remote_addr));
    remote_addr.sin_addr.s_addr = inet_addr(hostaddr);
    
    if (remote_addr.sin_addr.s_addr == INADDR_NONE) {
        struct hostent *remoteHost = gethostbyname(hostaddr);
        if (remoteHost == NULL || remoteHost->h_addr == NULL) {
            log4cplus_warn("PhoneNetPing", "access %s DNS error, remove this ip..\n",[host UTF8String]);
            return NULL;
        }
        remote_addr.sin_addr = *(struct in_addr *)remoteHost->h_addr;
        return [NSString stringWithFormat:@"%s",inet_ntoa(remote_addr.sin_addr)];
    }
    return host;
}

- (void)startPingHosts:(NSString *)host packetCount:(int)count
{
    if ([self settingUHostSocketAddressWithHost:host]) {
        self.host = [self convertDomainToIp:host];
    }
    
    if (self.host == NULL) {
        self.isStopPingThread = YES;
        log4cplus_warn("PhoneNetPing", "There is no valid domain...\n");
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
    [self settingUHostSocketAddressWithHost:self.host];
    int index = 0;
    BOOL isReceiverRemoteIpPingRes = NO;
    
    do {
        uint16_t identifier = (uint16_t)(KPingIcmpIdBeginNum + index);
        UICMPPacket *packet = [PhoneNetDiagnosisHelper constructPacketWithSeq:index andIdentifier:identifier];
        ssize_t sent = sendto(socket_client, packet, sizeof(UICMPPacket), 0, (struct sockaddr *)&remote_addr, (socklen_t)sizeof(struct sockaddr));
        if (sent < 0) {
            log4cplus_warn("PhoneNetPing", "ping %s , send icmp packet error..\n",[self.host UTF8String]);
        }
        
        isReceiverRemoteIpPingRes = [self receiverRemoteIpPingRes];
        
        if (isReceiverRemoteIpPingRes) {
            index++;
        }
        usleep(1000*20);
    } while (!self.isStopPingThread && index < _pingPacketCount && isReceiverRemoteIpPingRes);
    
    if (index == _pingPacketCount) {
        log4cplus_debug("PhoneNetPing", "ping complete..\n");
        /*
         int shutdown(int s, int how); // s is socket descriptor
         int how can be:
         SHUT_RD or 0 Further receives are disallowed
         SHUT_WR or 1 Further sends are disallowed
         SHUT_RDWR or 2 Further sends and receives are disallowed
         */
        shutdown(socket_client, SHUT_RDWR); //
        self.isStopPingThread = YES;
        [self.delegate simplePing:self finished:self.host];
    }
    
}

- (BOOL)receiverRemoteIpPingRes
{
    BOOL res = NO;
    struct sockaddr_storage ret_addr;
    socklen_t addrLen = sizeof(ret_addr);
    void *buffer = malloc(65535);
    
    size_t bytesRead = recvfrom(socket_client, buffer, 65535, 0, (struct sockaddr *)&ret_addr, &addrLen);
    
    if ((int)bytesRead < 0) {
        
        //            NSLog(@"PhoneNetPing , ping %@ , receive icmp packet timeout..\n",self.host );
        [self.delegate simplePing:self didTimeOut:self.host];
        res = YES;
    }else if(bytesRead == 0){
        log4cplus_warn("PhoneNetPing", "ping %s , receive icmp packet error , bytesRead=0",[self.host UTF8String]);
    }else{
        
        if ([PhoneNetDiagnosisHelper isValidPingResponseWithBuffer:(char *)buffer len:(int)bytesRead]) {
            [self.delegate simplePing:self receivedPacket:self.host];
            [self stopPing];
            res = YES;
        }
        
        usleep(1000*10);
    }
    return res;
}


@end
