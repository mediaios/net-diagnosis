//
//  PhoneNetManager.m
//  PhoneNetSDK
//
//  Created by ethan on 2018/10/15.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import "PhoneNetManager.h"
#import "PhonePingService.h"
#import "PhoneTraceRouteService.h"
#import "PNetReachability.h"
#import "UCNetworkService.h"
#import "PhoneNetSDKConst.h"
#import "PNetModel.h"
#import "PNetInfoTool.h"
#import "PNetLog.h"
#include "log4cplus_pn.h"
#import "PNDomainLookup.h"
#import "PNPortScan.h"


@interface PhoneNetManager()
@property (nonatomic,strong) PIpInfoModel *devicePublicIpInfo;
@property (nonatomic,strong) PNetReachability *reachability;
@end

@implementation PhoneNetManager

static PhoneNetManager *sdkManager_instance = nil;

+ (instancetype)shareInstance
{
    static dispatch_once_t pNetNetAnalysis_onceToken;
    dispatch_once(&pNetNetAnalysis_onceToken, ^{
        sdkManager_instance = [[super allocWithZone:NULL] init];
    });
    return sdkManager_instance;
}

- (void)settingSDKLogLevel:(PhoneNetSDKLogLevel)logLevel
{
    [PNetLog setSDKLogLevel:logLevel];
}

- (void)registPhoneNetSDK
{
    [PhoneNotification addObserver:self selector:@selector(networkChange:) name:kPNetReachabilityChangedNotification object:nil];
    self.reachability = [PNetReachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    [self checkNetworkStatusWithReachability:self.reachability];
}

- (NSString * _Nonnull)sdkVersion
{
    return PhoneNetSDKVersion;
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    return [PhoneNetManager shareInstance];
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [PhoneNetManager shareInstance];
}

- (void)netStopPing
{
    [[PhonePingService shareInstance] uStopPing];
}

- (BOOL)isDoingPing
{
    return [[PhonePingService shareInstance] uIsPing];
}

- (void)netStartPing:(NSString *_Nonnull)host packetCount:(int)count pingResultHandler:(NetPingResultHandler _Nonnull)handler
{
    if (!handler) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"no pingResultHandler" userInfo:nil];
        return;
    }
    [[PhonePingService shareInstance] startPingHost:host packetCount:count resultHandler:handler];
}


- (void)netStartTraceroute:(NSString *_Nonnull)host tracerouteResultHandler:(NetTracerouteResultHandler _Nonnull)handler
{
    if (!handler) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"no tracerouteResultHandler" userInfo:nil];
        return;
    }
    [[PhoneTraceRouteService shareInstance] startTracerouteHost:host resultHandler:handler];
}

- (void)netStopTraceroute
{
    [[PhoneTraceRouteService shareInstance] uStopTracert];
}

- (BOOL)isDoingTraceroute
{
    return [[PhoneTraceRouteService shareInstance] uIsTracert];
}

- (void)netLookupDomain:(NSString * _Nonnull)domain completeHandler:(NetLookupResultHandler _Nonnull)handler
{
    if (!handler) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"no lookup complete Handler" userInfo:nil];
        return;
    }
    [[PNDomainLookup shareInstance] lookupDomain:domain completeHandler:handler];
}

- (void)netPortScan:(NSString * _Nonnull)host
          beginPort:(NSUInteger)beginPort
            endPort:(NSUInteger)endPort
    completeHandler:(NetPortScanHandler)handler
{
    if (!handler) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"no port scan complete Handler" userInfo:nil];
        return;
    }
    [[PNPortScan shareInstance] portScan:host beginPort:beginPort endPort:endPort completeHandler:handler];
}

- (BOOL)isDoingPortScan
{
    return [[PNPortScan shareInstance] isDoingScanPort];
}

- (void)netStopPortScan
{
    [[PNPortScan shareInstance] stopPortScan];
}

- (void)networkChange:(NSNotification *)noti
{
    PNetReachability *reachability = [noti object];
    [self checkNetworkStatusWithReachability:reachability];
}

- (void)checkNetworkStatusWithReachability:(PNetReachability *)reachability
{
    PNetNetStatus status = [reachability currentReachabilityStatus];
    switch (status) {
        case PNetReachable_None:
        {
            log4cplus_debug("PhoneNetSDK", "none network...");
        }
            break;
        case PNetReachable_WiFi:
        {
            log4cplus_debug("PhoneNetSDK", "network type is WIFI...");
            [self netGetDevicePublicIpInfo];
        }
            break;
        case PNetReachable_WWAN:
        {
            log4cplus_debug("PhoneNetSDK", "network type is WWAN...");
            [self netGetDevicePublicIpInfo];
        }
            break;
            
            
        default:
            break;
    }
}

- (void)netGetDevicePublicIpInfo
{
    [UCNetworkService uHttpGetRequestWithUrl:PhoneNet_Get_Public_Ip_Url functionModule:@"GetDevicePublicIpInfo" timeout:10.0 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error || dict == nil) {
            log4cplus_warn("PhoneNetSDK", "get public ip error , content is nil..");
        }else{
            PIpInfoModel *ipModel = [PIpInfoModel uIpInfoModelWithDict:dict];
           
            self.devicePublicIpInfo = ipModel;
        }
    }];
}

#pragma mark -About network info
- (NetWorkInfo *)netGetNetworkInfo
{
    PNetInfoTool *phoneNetTool = [PNetInfoTool shareInstance];
    [phoneNetTool refreshNetInfo];
    NetWorkInfo *networkInfo = [[NetWorkInfo alloc] init];
    networkInfo.deviceNetInfo = [PDeviceNetInfo deviceNetInfo];
    networkInfo.ipInfoModel = self.devicePublicIpInfo;
    return networkInfo;
}

@end
