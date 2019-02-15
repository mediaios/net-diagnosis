//
//  PhoneNetDiagnosisHelper.m
//  PingDemo
//
//  Created by ethan on 08/08/2018.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import "PhoneNetDiagnosisHelper.h"
#import "NetAnalysisConst.h"

@implementation PhoneNetDiagnosisHelper


+ (uint16_t) in_cksumWithBuffer:(const void *)buffer andSize:(size_t)bufferLen
{
    /*
     将数据以字（16位）为单位累加到一个双字中
     如果数据长度为奇数，最后一个字节将被扩展到字，累加的结果是一个双字，
     最后将这个双字的高16位和低16位相加后取反
     */
    size_t              bytesLeft;
    int32_t             sum;
    const uint16_t *    cursor;
    union {
        uint16_t        us;
        uint8_t         uc[2];
    } last;
    uint16_t            answer;
    
    bytesLeft = bufferLen;
    sum = 0;
    cursor = (uint16_t*)buffer;
    
    while (bytesLeft > 1) {
        sum += *cursor;
        cursor += 1;
        bytesLeft -= 2;
    }
    
    /* mop up an odd byte, if necessary */
    if (bytesLeft == 1) {
        last.uc[0] = * (const uint8_t *) cursor;
        last.uc[1] = 0;
        sum += last.us;
    }
    
    /* add back carry outs from top 16 bits to low 16 bits */
    sum = (sum >> 16) + (sum & 0xffff);    /* add hi 16 to low 16 */
    sum += (sum >> 16);            /* add carry */
    answer = (uint16_t) ~sum;   /* truncate to 16 bits */
    
    return answer;
}

+ (BOOL)isValidPingResponseWithBuffer:(char *)buffer len:(int)len seq:(int)seq identifier:(int)identifier
{
    UICMPPacket *icmpPtr = (UICMPPacket *)[self icmpInpacket:buffer andLen:len];
    if (icmpPtr == NULL) {
        return NO;
    }
    uint16_t receivedChecksum = icmpPtr->checksum;
    icmpPtr->checksum = 0;
    uint16_t calculatedChecksum = [self in_cksumWithBuffer:icmpPtr andSize:len-((char*)icmpPtr - buffer)];
    
    return receivedChecksum == calculatedChecksum &&
    icmpPtr->type == ENU_U_ICMPType_EchoReplay &&
    icmpPtr->code == 0 &&
    OSSwapBigToHostInt16(icmpPtr->identifier) == identifier &&
    OSSwapBigToHostInt16(icmpPtr->seq) <= seq;
}

+ (BOOL)isValidPingResponseWithBuffer:(char *)buffer len:(int)len
{
    UICMPPacket *icmpPtr = (UICMPPacket *)[self icmpInpacket:buffer andLen:len];
    if (icmpPtr == NULL) {
        return NO;
    }
    
    //    NSLog(@"debug----name:%@,id:%d,packet->id:%d,seq:%d,packet->seq:%d",self.name ,identifier,OSSwapBigToHostInt16(icmpPtr->identifier),seq,OSSwapBigToHostInt16(icmpPtr->seq));
    
    uint16_t receivedChecksum = icmpPtr->checksum;
    icmpPtr->checksum = 0;
    uint16_t calculatedChecksum = [self in_cksumWithBuffer:icmpPtr andSize:len-((char*)icmpPtr - buffer)];
    
    return receivedChecksum == calculatedChecksum &&
    icmpPtr->type == ENU_U_ICMPType_EchoReplay &&
    icmpPtr->code == 0 &&
    OSSwapBigToHostInt16(icmpPtr->identifier)>=KPingIcmpIdBeginNum;;
}

/* 从 ipv4 数据包中解析出icmp */
+ (char *)icmpInpacket:(char *)packet andLen:(int)len
{
    if (len < (sizeof(PNetIPHeader) + sizeof(UICMPPacket))) {
        return NULL;
    }
    const struct PNetIPHeader *ipPtr = (const PNetIPHeader *)packet;
    if ((ipPtr->versionAndHeaderLength & 0xF0) != 0x40 // IPv4
        ||
        ipPtr->protocol != 1) { //ICMP
        return NULL;
    }
    size_t ipHeaderLength = (ipPtr->versionAndHeaderLength & 0x0F) * sizeof(uint32_t);
    
    if (len < ipHeaderLength + sizeof(UICMPPacket)) {
        return NULL;
    }
    
    return (char *)packet + ipHeaderLength;
}

+ (char *)tracertICMPInPacket:(char *)packet andLen:(int)len
{
    if (len < (sizeof(PNetIPHeader) + sizeof(PICMPPacket_Tracert))) {
        return NULL;
    }
    const struct PNetIPHeader *ipPtr = (const PNetIPHeader *)packet;
    if ((ipPtr->versionAndHeaderLength & 0xF0) != 0x40 // IPv4
        ||
        ipPtr->protocol != 1) { //ICMP
        return NULL;
    }
    size_t ipHeaderLength = (ipPtr->versionAndHeaderLength & 0x0F) * sizeof(uint32_t);
    
    if (len < ipHeaderLength + sizeof(PICMPPacket_Tracert)) {
        return NULL;
    }
    
    return (char *)packet + ipHeaderLength;
}

+ (UICMPPacket *)constructPacketWithSeq:(uint16_t)seq andIdentifier:(uint16_t)identifier
{
    UICMPPacket *packet = (UICMPPacket *)malloc(sizeof(UICMPPacket));
    packet->type  = ENU_U_ICMPType_EchoRequest;
    packet->code = 0;
    packet->checksum = 0;
    packet->identifier = OSSwapHostToBigInt16(identifier);
    packet->seq = OSSwapHostToBigInt16(seq);
    memset(packet->fills, 65, 56);
    packet->checksum = [self in_cksumWithBuffer:packet andSize:sizeof(UICMPPacket)];
    return packet;
}

+ (PICMPPacket_Tracert *)constructTracertICMPPacketWithSeq:(uint16_t)seq andIdentifier:(uint16_t)identifier
{
    PICMPPacket_Tracert *packet = (PICMPPacket_Tracert *)malloc(sizeof(PICMPPacket_Tracert));
    packet->type  = ENU_U_ICMPType_EchoRequest;
    packet->code = 0;
    packet->checksum = 0;
    packet->identifier = OSSwapHostToBigInt16(identifier);
    packet->seq = OSSwapHostToBigInt16(seq);
    packet->checksum = [self in_cksumWithBuffer:packet andSize:sizeof(PICMPPacket_Tracert)];
    return packet;
}


/*******        for traceroute        *********/
+ (NSArray<NSString *> *)resolveHost:(NSString *)hostname {
    NSMutableArray<NSString *> *resolve = [NSMutableArray array];
    CFHostRef hostRef = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)hostname);
    if (hostRef != NULL) {
        Boolean result = CFHostStartInfoResolution(hostRef, kCFHostAddresses, NULL); // 开始DNS解析
        if (result == true) {
            CFArrayRef addresses = CFHostGetAddressing(hostRef, &result);
            for(int i = 0; i < CFArrayGetCount(addresses); i++){
                CFDataRef saData = (CFDataRef)CFArrayGetValueAtIndex(addresses, i);
                struct sockaddr *addressGeneric = (struct sockaddr *)CFDataGetBytePtr(saData);
                
                if (addressGeneric != NULL) {
                    struct sockaddr_in *remoteAddr = (struct sockaddr_in *)CFDataGetBytePtr(saData);
                    [resolve addObject:[self formatIPv4Address:remoteAddr->sin_addr]];
                }
            }
        }
    }
    
    return [resolve copy];
}

+ (NSString *)formatIPv4Address:(struct in_addr)ipv4Addr {
    NSString *address = nil;
    
    char dstStr[INET_ADDRSTRLEN];
    char srcStr[INET_ADDRSTRLEN];
    memcpy(srcStr, &ipv4Addr, sizeof(struct in_addr));
    if(inet_ntop(AF_INET, srcStr, dstStr, INET_ADDRSTRLEN) != NULL) {
        address = [NSString stringWithUTF8String:dstStr];
    }
    
    return address;
}

+ (struct sockaddr *)createSockaddrWithAddress:(NSString *)address
{
    NSData *addrData = nil;
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_len = sizeof(addr);
    addr.sin_family = AF_INET;
    addr.sin_port = htons(20000);
    if (inet_pton(AF_INET, address.UTF8String, &addr.sin_addr.s_addr) < 0) {
        NSLog(@"create sockaddr failed");
        return NULL;
    }
    addrData = [NSData dataWithBytes:&addr length:sizeof(addr)];
    return (struct sockaddr *)[addrData bytes];
}

+ (BOOL)isTimeoutPacket:(char *)packet len:(int)len
{
    PICMPPacket_Tracert *icmpPacket = NULL;
    icmpPacket = (PICMPPacket_Tracert *)[self tracertICMPInPacket:packet andLen:len];
    if (icmpPacket != NULL && icmpPacket->type == ENU_U_ICMPType_TimeOut) {
        return YES;
    }
    return NO;
}

+ (BOOL)isEchoReplayPacket:(char *)packet len:(int)len
{
    PICMPPacket_Tracert *icmpPacket = NULL;
    icmpPacket = (PICMPPacket_Tracert *)[self tracertICMPInPacket:packet andLen:len];
    
    if (icmpPacket != NULL && icmpPacket->type == ENU_U_ICMPType_EchoReplay) {
        return YES;
    }
    return NO;
}

@end
