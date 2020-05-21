//
//  PNetInfoTool.m
//  PhoneNetSDK
//
//  Created by mediaios on 2018/10/16.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import "PNetInfoTool.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreFoundation/CoreFoundation.h>

#import "PNetReachability.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <sys/utsname.h>

#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

static NSString * const U_NO_NETWORK   = @"NO NETWORK";
static NSString * const U_WIFI         = @"WIFI";
static NSString * const U_GPRS         = @"GPRS";
static NSString * const U_2G           = @"2G";
static NSString * const U_2_75G_EDGE   = @"2.75G EDGE";
static NSString * const U_3G           = @"3G";
static NSString * const U_3_5G_HSDPA   = @"3.5G HSDPA";
static NSString * const U_3_5G_HSUPA   = @"3.5G HSUPA";
static NSString * const U_HRPD         = @"HRPD";
static NSString * const U_4G           = @"4G";

@interface PNetInfoTool()
@property (nonatomic,copy) NSDictionary *ipInfoDict;
@property (nonatomic,copy) NSDictionary *wifiDict;
@end


@implementation PNetInfoTool


+ (instancetype)shareInstance {
    static PNetInfoTool *instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[PNetInfoTool alloc] init];
    });
    return instance;
}

- (void)refreshNetInfo
{
    // net info
    self.ipInfoDict = [PNetInfoTool getIPAddresses];
    
    // wifi info
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSString *ifsEle = (NSString *)ifs[0];
    self.wifiDict = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifsEle);
    
//    NSLog(@"%@",[self getLocalInfoForCurrentWiFi]);
}

#pragma mark - for wifi
- (NSString *)pGetSSID
{
    return [self.wifiDict objectForKey:@"SSID"];
}

- (NSString *)pGetBSSID
{
    return [self.wifiDict objectForKey:@"BSSID"];
}

- (NSString *)pGetWifiIpv4
{
    return [self.ipInfoDict objectForKey:@"en0/ipv4"];
}

- (NSString *)pGetSubNetMask
{
    return [self.ipInfoDict objectForKey:@"netmask"];
}

- (NSString *)pGetWifiIpv6
{
    return [self.ipInfoDict objectForKey:@"en0/ipv6"];
}

- (NSString *)pGetCellIpv4
{
    return [self.ipInfoDict objectForKey:@"pdp_ip0/ipv4"];
}

- (NSString*)pGetNetworkType
{
    NSString *netType = @"";
    PNetReachability *reachNet = [PNetReachability reachabilityWithHostName:@"www.apple.com"];
    PNetNetStatus net_status = [reachNet currentReachabilityStatus];
    switch (net_status) {
        case PNetReachable_None:
            netType = U_NO_NETWORK;
            break;
        case PNetReachable_WiFi:
            netType = U_WIFI;
            break;
        case PNetReachable_WWAN:
        {
            CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
            NSString *curreNetType = netInfo.currentRadioAccessTechnology;
            if ([curreNetType isEqualToString:CTRadioAccessTechnologyGPRS]) {
                netType = U_GPRS;
            }else if([curreNetType isEqualToString:CTRadioAccessTechnologyEdge]){
                netType = U_2_75G_EDGE;
            }else if([curreNetType isEqualToString:CTRadioAccessTechnologyWCDMA] ||
                     [curreNetType isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||
                     [curreNetType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||
                     [curreNetType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]){
                netType = U_3G;
            }else if([curreNetType isEqualToString:CTRadioAccessTechnologyHSDPA]){
                netType = U_3_5G_HSDPA;
            }else if([curreNetType isEqualToString:CTRadioAccessTechnologyHSUPA]){
                netType = U_3_5G_HSUPA;
            }else if([curreNetType isEqualToString:CTRadioAccessTechnologyeHRPD]){
                netType = U_HRPD;
            }else if([curreNetType isEqualToString:CTRadioAccessTechnologyLTE]){
                netType = U_4G;
            }
        }
            break;
            
        default:
            break;
    }
    
    return netType;
}


+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                    
                    if([[NSString stringWithUTF8String:interface->ifa_name] isEqualToString:@"en0"]) {
                        NSString *netmask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)interface->ifa_netmask)->sin_addr)];
                        if (netmask) {
                            [addresses setObject:netmask forKey:@"netmask"];
                        }
                    }
                
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

@end
