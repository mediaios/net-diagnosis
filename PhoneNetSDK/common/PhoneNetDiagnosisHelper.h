//
//  PhoneNetDiagnosisHelper.h
//  PingDemo
//
//  Created by ethan on 08/08/2018.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AssertMacros.h>
#import <arpa/inet.h>
#import <netdb.h>
#import <netinet/in.h>
#import <sys/socket.h>
#import <unistd.h>

#import <netinet/in.h>
#import <netinet/tcp.h>


#define kPhoneNetPingTimeout      500   // 500 millisecond
#define kPhoneNetPingPackets      5



typedef struct PNetIPHeader {
    uint8_t versionAndHeaderLength;
    uint8_t differentiatedServices;
    uint16_t totalLength;
    uint16_t identification;
    uint16_t flagsAndFragmentOffset;
    uint8_t timeToLive;
    uint8_t protocol;
    uint16_t headerChecksum;
    uint8_t sourceAddress[4];
    uint8_t destinationAddress[4];
    // options...
    // data...
}PNetIPHeader;

__Check_Compile_Time(sizeof(PNetIPHeader) == 20);
__Check_Compile_Time(offsetof(PNetIPHeader, versionAndHeaderLength) == 0);
__Check_Compile_Time(offsetof(PNetIPHeader, differentiatedServices) == 1);
__Check_Compile_Time(offsetof(PNetIPHeader, totalLength) == 2);
__Check_Compile_Time(offsetof(PNetIPHeader, identification) == 4);
__Check_Compile_Time(offsetof(PNetIPHeader, flagsAndFragmentOffset) == 6);
__Check_Compile_Time(offsetof(PNetIPHeader, timeToLive) == 8);
__Check_Compile_Time(offsetof(PNetIPHeader, protocol) == 9);
__Check_Compile_Time(offsetof(PNetIPHeader, headerChecksum) == 10);
__Check_Compile_Time(offsetof(PNetIPHeader, sourceAddress) == 12);
__Check_Compile_Time(offsetof(PNetIPHeader, destinationAddress) == 16);

/*
 use linux style . totals 64B
 */
typedef struct UICMPPacket
{
    uint8_t type;
    uint8_t code;
    uint16_t checksum;
    uint16_t identifier;
    uint16_t seq;
    char fills[56];  // data
}UICMPPacket;

typedef enum ENU_U_ICMPType
{
    ENU_U_ICMPType_EchoReplay = 0,
    ENU_U_ICMPType_EchoRequest = 8,
    ENU_U_ICMPType_TimeOut     = 11
}ENU_U_ICMPType;

__Check_Compile_Time(sizeof(UICMPPacket) == 64);
//__Check_Compile_Time(sizeof(UICMPPacket) == 8);
__Check_Compile_Time(offsetof(UICMPPacket, type) == 0);
__Check_Compile_Time(offsetof(UICMPPacket, code) == 1);
__Check_Compile_Time(offsetof(UICMPPacket, checksum) == 2);
__Check_Compile_Time(offsetof(UICMPPacket, identifier) == 4);
__Check_Compile_Time(offsetof(UICMPPacket, seq) == 6);



typedef struct PICMPPacket_Tracert
{
    uint8_t type;
    uint8_t code;
    uint16_t checksum;
    uint16_t identifier;
    uint16_t seq;
}PICMPPacket_Tracert;

__Check_Compile_Time(sizeof(PICMPPacket_Tracert) == 8);
__Check_Compile_Time(offsetof(PICMPPacket_Tracert, type) == 0);
__Check_Compile_Time(offsetof(PICMPPacket_Tracert, code) == 1);
__Check_Compile_Time(offsetof(PICMPPacket_Tracert, checksum) == 2);
__Check_Compile_Time(offsetof(PICMPPacket_Tracert, identifier) == 4);
__Check_Compile_Time(offsetof(PICMPPacket_Tracert, seq) == 6);

@interface PhoneNetDiagnosisHelper : NSObject

+ (uint16_t) in_cksumWithBuffer:(const void *)buffer andSize:(size_t)bufferLen;
+ (BOOL)isValidPingResponseWithBuffer:(char *)buffer len:(int)len seq:(int)seq identifier:(int)identifier;
+ (BOOL)isValidPingResponseWithBuffer:(char *)buffer len:(int)len;
+ (char *)icmpInpacket:(char *)packet andLen:(int)len;
+ (UICMPPacket *)constructPacketWithSeq:(uint16_t)seq andIdentifier:(uint16_t)identifier;


+ (NSArray<NSString *> *)resolveHost:(NSString *)hostname;
+ (struct sockaddr *)createSockaddrWithAddress:(NSString *)address;
+ (BOOL)isTimeoutPacket:(char *)packet len:(int)len;
+ (BOOL)isEchoReplayPacket:(char *)packet len:(int)len;
+ (PICMPPacket_Tracert *)constructTracertICMPPacketWithSeq:(uint16_t)seq andIdentifier:(uint16_t)identifier;
@end
