//
//  PNQuickPing.m
//  PhoneNetSDK
//
//  Created by mediaios on 2019/6/5.
//  Copyright © 2019年 mediaios. All rights reserved.
//

#import "PNQuickPing.h"
#import "PhoneNetSDKConst.h"
#import "PNetTools.h"
#include "log4cplus_pn.h"
#import "PNetQueue.h"

@interface PNQuickPing()
{
    int socket_client;
    struct sockaddr_in remote_addr;
}

@property (nonatomic,assign) BOOL isStopPingThread;
@property (nonatomic,strong) NSMutableDictionary *sendPacketDateDict;
@property (nonatomic,strong) NSMutableArray *hostList;
@property (atomic,assign)  int hostArrayIndex;
@end


@implementation PNQuickPing

- (instancetype)init
{
    if ([super init]) {
        self.hostArrayIndex = 0;
        
        _isStopPingThread = NO;
        _sendPacketDateDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addSendIcmpWithSeq:(int)seq
{
    NSString *key = [NSString stringWithFormat:@"SendIcmpPacketDate%d",seq];
    [_sendPacketDateDict setObject:[NSDate date] forKey:key];
}

- (NSDate *)getSendIcmpWithSeq:(int)seq
{
    NSString *key = [NSString stringWithFormat:@"SendIcmpPacketDate%d",seq];
    return [_sendPacketDateDict objectForKey:key];
}

- (BOOL)settingUHostSocketAddressWithHost:(NSString *)host
{
    try{
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
        timeout.tv_usec = 1000*200;
        socket_client = socket(AF_INET,SOCK_DGRAM,IPPROTO_ICMP);
        int res = setsockopt(socket_client, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
        if (res < 0) {
            log4cplus_warn("PhoneNetPing", "ping %s , set timeout error..\n",[host UTF8String]);
        }
        remote_addr.sin_family = AF_INET;
    } catch (NSException *exception) {
        log4cplus_error("PhoneNetPing", "func: %s, exception info: %s , line: %d",__func__,[exception.description UTF8String],__LINE__);
    }
    
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


- (void)startPingHost:(NSArray *)hostList
{
    _hostList = [NSMutableArray array];
    for (int i = 0; i < hostList.count; i++) {
        if ([self settingUHostSocketAddressWithHost:hostList[i]]) {
            [_hostList addObject:[self convertDomainToIp:hostList[i]]];
        }
    }
    
    if (_hostList.count == 0) {
        self.isStopPingThread = YES;
        log4cplus_info("PhoneNetPing", "There is no valid domain in the domain list, ping complete..\n");
        return;
    }
    self.hostArrayIndex = 0;
    [PNetQueue pnet_quick_ping_async:^{
        [self sendAndrecevPingPacket];
    }];
}

- (void)sendAndrecevPingPacket
{
    [self settingUHostSocketAddressWithHost:_hostList[self.hostArrayIndex]];
    [self startPing:socket_client andRemoteAddr:remote_addr];
    
    while (!self.isStopPingThread) {
        BOOL isReceiverRemoteIpPingRes = NO;
        
        try {
            isReceiverRemoteIpPingRes = [self receiverRemoteIpPingRes];
        } catch (NSException *exception) {
            log4cplus_error("PhoneNetPing", "func: %s, exception info: %s , line: %d",__func__,[exception.description UTF8String],__LINE__);
        }
        
        if (isReceiverRemoteIpPingRes) {
            self.hostArrayIndex++;
            if (self.hostArrayIndex == self.hostList.count) {
                log4cplus_info("PhoneNetPing", "ping complete..\n");
                /*
                 int shutdown(int s, int how); // s is socket descriptor
                 int how can be:
                 SHUT_RD or 0 Further receives are disallowed
                 SHUT_WR or 1 Further sends are disallowed
                 SHUT_RDWR or 2 Further sends and receives are disallowed
                 */
                shutdown(socket_client, SHUT_RDWR); //
                self.isStopPingThread = YES;
                [self.delegate oneIpPingFinishedWithQuickPing:self];
                break;
            }
            [self settingUHostSocketAddressWithHost:_hostList[self.hostArrayIndex]];
            [self startPing:socket_client andRemoteAddr:remote_addr];
        }
        usleep(500);
        
    }
}

- (void)startPing:(int)socketClient andRemoteAddr:(struct sockaddr_in)remoteAddr
{
    
    try {
        log4cplus_info("PhoneNetPing", "begin ping ip:%s",[self.hostList[self.hostArrayIndex] UTF8String]);
        int index = 0;
        uint16_t identifier = (uint16_t)(KPingIcmpIdBeginNum + self.hostArrayIndex);
        do {
            UICMPPacket *packet = [PhoneNetDiagnosisHelper constructPacketWithSeq:index andIdentifier:identifier];
            [self addSendIcmpWithSeq:index];
            ssize_t sent = sendto(socketClient, packet, sizeof(UICMPPacket), 0, (struct sockaddr *)&remoteAddr, (socklen_t)sizeof(struct sockaddr));
            if (sent < 0) {
                log4cplus_warn("PhoneNetPing", "ping %s , send icmp packet error..\n",[self.hostList[self.hostArrayIndex] UTF8String]);
            }
            
            free(packet);
            usleep(500);
            
        } while (++index < 5 && !self.isStopPingThread);
    } catch (NSException *exception) {
        log4cplus_error("PhoneNetPing", "func: %s, exception info: %s , line: %d",__func__,[exception.description UTF8String],__LINE__);
    }
}


- (BOOL)receiverRemoteIpPingRes
{
    BOOL res = NO;
    int ping_recev_index = 0;
    int ping_timeout_index = 0;
    struct sockaddr_storage ret_addr;
    socklen_t addrLen = sizeof(ret_addr);
    void *buffer = malloc(65535);
    while (true) {
        
        size_t bytesRead = recvfrom(socket_client, buffer, 65535, 0, (struct sockaddr *)&ret_addr, &addrLen);
        
        if ((int)bytesRead < 0) {
            
            log4cplus_warn("PhoneNetPing", "ping %s , receive icmp packet timeout..\n",[self.hostList[self.hostArrayIndex] UTF8String]);
            
            // 针对于一个新的ip，全部是timeout的情况，那么收到5个就开始ping下一个； 如果在ping一个ip的5个包中，其中第2个包以后开始timeout，那么针对于这个ip再timeout 3个包即开始下一个
            //            NSLog(@"ping ,rec ping error,bytesRead < 0，bytesRead:%d ,ping_recev_index:%d ,ping_timeout_index:%d",(int)bytesRead,ping_recev_index,ping_timeout_index);
            
            [self reporterPingResWithSorceIp:self.hostList[self.hostArrayIndex] ttl:0 timeMillSecond:0 seq:ping_timeout_index icmpId:0 dataSize:0 pingStatus:PhoneNetPingStatusDidTimeout];
            
            if (ping_recev_index != 0 && ping_timeout_index == 0 ) {
                ping_timeout_index = ping_recev_index;
            }
            ping_timeout_index++;
            if (ping_timeout_index == 5) {
                res = YES;
                log4cplus_info("PhoneNetPing", "done ping , ip:%s \n",[self.hostList[self.hostArrayIndex] UTF8String]);
                [self reporterPingResWithSorceIp:self.hostList[self.hostArrayIndex] ttl:0 timeMillSecond:0 seq:ping_timeout_index icmpId:0 dataSize:0 pingStatus:PhoneNetPingStatusFinished];
                break;
            }
            
            //            break;
        }else if(bytesRead == 0){
            log4cplus_warn("PhoneNetPing", "ping %s , receive icmp packet error , bytesRead=0",[self.hostList[self.hostArrayIndex] UTF8String]);
        }else if ([PhoneNetDiagnosisHelper isValidPingResponseWithBuffer:(char *)buffer len:(int)bytesRead]){
            UICMPPacket *icmpPtr = (UICMPPacket *)[PhoneNetDiagnosisHelper icmpInpacket:(char *)buffer andLen:(int)bytesRead];
            NSTimeInterval duration = 0.0;
            int seq = OSSwapBigToHostInt16(icmpPtr->seq);
            NSDate *date = [self getSendIcmpWithSeq:seq];
            duration = [[NSDate date] timeIntervalSinceDate:date];
            int ttl = ((PNetIPHeader *)buffer)->timeToLive;
            //                uint8_t *p_sorce = ((UCIPHeader *)buffer)->sourceAddress;
            //                uint8_t *p_dst = ((UCIPHeader *)buffer)->destinationAddress;
            //                NSString *sorceIp = [NSString stringWithFormat:@"%d.%d.%d.%d",*p_sorce, *(p_sorce+1), *(p_sorce+2), *(p_sorce+3)];
            //                NSString *destIp = [NSString stringWithFormat:@"%d.%d.%d.%d",*p_dst, *(p_dst+1),*(p_dst+2), *(p_dst+3)];
            int size = (int)(bytesRead-sizeof(PNetIPHeader));
            NSString *sorceIp = self.hostList[self.hostArrayIndex];
            
            //                NSLog(@"ping res: srcIP:%d.%d.%d.%d --> desIP:%d.%d.%d.%d ,size:%d , ttl:%d ,icmpID:%d, timeMillseconds:%f ,seq:%d",*p_sorce, *(p_sorce+1), *(p_sorce+2), *(p_sorce+3), *p_dst, *(p_dst+1),*(p_dst+2), *(p_dst+3),size,ttl,OSSwapBigToHostInt16(icmpPtr->identifier),duration * 1000,seq);
            
            //                log4cplus_warn("PhoneNetPing", "srcIP:%d.%d.%d.%d --> desIP:%d.%d.%d.%d ,size:%d , ttl:%d ,icmpID:%d, timeMillseconds:%f ,seq:%d",*p_sorce, *(p_sorce+1), *(p_sorce+2), *(p_sorce+3), *p_dst, *(p_dst+1),*(p_dst+2), *(p_dst+3),size,ttl,OSSwapBigToHostInt16(icmpPtr->identifier),duration * 1000,seq);
            
            
            //                log4cplus_info("PhoneNetPing", "ping %s , receive icmp packet..\n",[self.hostList[self.hostArrayIndex] UTF8String]);
            
            [self reporterPingResWithSorceIp:sorceIp ttl:ttl timeMillSecond:duration*1000 seq:seq icmpId:OSSwapBigToHostInt16(icmpPtr->identifier) dataSize:size pingStatus:PhoneNetPingStatusDidReceivePacket];
            ping_recev_index++;
            if (ping_recev_index == 5) {
                log4cplus_info("PhoneNetPing", "done ping , ip:%s \n",[self.hostList[self.hostArrayIndex] UTF8String]);
                [self reporterPingResWithSorceIp:sorceIp ttl:ttl timeMillSecond:duration*1000 seq:seq icmpId:OSSwapBigToHostInt16(icmpPtr->identifier) dataSize:size pingStatus:PhoneNetPingStatusFinished];
                
                close(socket_client);
                res = YES;
                break;
                
            }
        }
        usleep(500);
    }
    return res;
}


- (void)reporterPingResWithSorceIp:(NSString *)sorceIp ttl:(int)ttl timeMillSecond:(double)timeMillSec seq:(int)seq icmpId:(int)icmpId dataSize:(int)size pingStatus:(PhoneNetPingStatus)status
{
    PPingResModel *pingResModel = [[PPingResModel alloc] init];
    pingResModel.status = status;
    pingResModel.IPAddress = sorceIp;
    switch (status) {
        case PhoneNetPingStatusDidReceivePacket:
        {
            pingResModel.ICMPSequence = seq;
            pingResModel.timeToLive = ttl;
            pingResModel.timeMilliseconds = timeMillSec;
            pingResModel.dateBytesLength = size;
        }
            break;
        case PhoneNetPingStatusFinished:
        {
            pingResModel.ICMPSequence = 5;
        }
            break;
        case PhoneNetPingStatusDidTimeout:
        {
            pingResModel.ICMPSequence = seq;
        }
            break;
            
        default:
            break;
    }
    
    [self.delegate oneIpPingItemWithQuickPing:self pingResult:pingResModel pingStatus:status];
}

- (void)stop
{
    self.isStopPingThread = YES;
}

- (BOOL)isPing
{
    return !self.isStopPingThread;
}

@end
