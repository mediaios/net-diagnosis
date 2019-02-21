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
#import "log4cplus.h"
#import "PNetModel.h"
#import "PNetInfoTool.h"


/*   define log level  */
int PhoneNetSDK_IOS_FLAG_FATAL = 0x10;
int PhoneNetSDK_IOS_FLAG_ERROR = 0x08;
int PhoneNetSDK_IOS_FLAG_WARN = 0x04;
int PhoneNetSDK_IOS_FLAG_INFO = 0x02;
int PhoneNetSDK_IOS_FLAG_DEBUG = 0x01;
int PhoneNetSDK_IOS_LOG_LEVEL = PhoneNetSDK_IOS_LOG_LEVEL = PhoneNetSDK_IOS_FLAG_FATAL|PhoneNetSDK_IOS_FLAG_ERROR;

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
    switch (logLevel) {
        case PhoneNetSDKLogLevel_FATAL:
        {
            PhoneNetSDK_IOS_LOG_LEVEL = PhoneNetSDK_IOS_FLAG_FATAL;
            log4cplus_fatal("PhoneNetSDK", "setting UCSDK log level ,PhoneNetSDK_IOS_FLAG_FATAL...\n");
        }
            break;
        case PhoneNetSDKLogLevel_ERROR:
        {
            PhoneNetSDK_IOS_LOG_LEVEL = PhoneNetSDK_IOS_FLAG_FATAL|PhoneNetSDK_IOS_FLAG_ERROR;
            log4cplus_error("PhoneNetSDK", "setting UCSDK log level ,PhoneNetSDK_IOS_FLAG_ERROR...\n");
        }
            break;
        case PhoneNetSDKLogLevel_WARN:
        {
            PhoneNetSDK_IOS_LOG_LEVEL = PhoneNetSDK_IOS_FLAG_FATAL|PhoneNetSDK_IOS_FLAG_ERROR|PhoneNetSDK_IOS_FLAG_WARN;
            log4cplus_warn("PhoneNetSDK", "setting UCSDK log level ,PhoneNetSDK_IOS_FLAG_WARN...\n");
        }
            break;
        case PhoneNetSDKLogLevel_INFO:
        {
            PhoneNetSDK_IOS_LOG_LEVEL = PhoneNetSDK_IOS_FLAG_FATAL|PhoneNetSDK_IOS_FLAG_ERROR|PhoneNetSDK_IOS_FLAG_WARN|PhoneNetSDK_IOS_FLAG_INFO;
            log4cplus_info("PhoneNetSDK", "setting UCSDK log level ,PhoneNetSDK_IOS_FLAG_INFO...\n");
        }
            break;
        case PhoneNetSDKLogLevel_DEBUG:
        {
            PhoneNetSDK_IOS_LOG_LEVEL = PhoneNetSDK_IOS_FLAG_FATAL|PhoneNetSDK_IOS_FLAG_ERROR|PhoneNetSDK_IOS_FLAG_WARN|PhoneNetSDK_IOS_FLAG_INFO|PhoneNetSDK_IOS_FLAG_DEBUG;
            log4cplus_debug("PhoneNetSDK", "setting UCSDK log level ,UCNetAnalysisSDKLogLevel_DEBUG...\n");
        }
            break;
            
        default:
            break;
    }
}

- (void)registPhoneNetSDK
{
    [PhoneNotification addObserver:self selector:@selector(networkChange:) name:kPNetReachabilityChangedNotification object:nil];
    self.reachability = [PNetReachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    [self checkNetworkStatusWithReachability:self.reachability];
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
    [[PhonePingService shareInstance] startPingHost:host packetCount:count resultHandler:handler];
}


- (void)netStartTraceroute:(NSString *_Nonnull)host tracerouteResultHandler:(NetTracerouteResultHandler _Nonnull)handler
{
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
