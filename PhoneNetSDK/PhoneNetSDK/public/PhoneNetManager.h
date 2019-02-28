//
//  PhoneNetManager.h
//  PhoneNetSDK
//
//  Created by ethan on 2018/10/15.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNetModel.h"
#import "PhoneNetSDKHelper.h"


@interface PhoneNetManager : NSObject

+ (instancetype _Nonnull)shareInstance;

/**
 @brief setting sdk log level
 @discussion  If not set, the default log level is `PhoneNetSDKLogLevel_ERROR`
 @param logLevel Log level, type is an enumeration `PhoneNetSDKLogLevel`
 */
- (void)settingSDKLogLevel:(PhoneNetSDKLogLevel)logLevel;

- (void)registPhoneNetSDK;


/**
 @brief get SDK version
 @return sdk version
 */
- (NSString * _Nonnull)sdkVersion;

#pragma mark - about ping
/*！
 @description
 ping function
 
 @param host ip address or domain name
 @param count   send ping packet count
 @param handler ping detail information
 */
- (void)netStartPing:(NSString *_Nonnull)host packetCount:(int)count pingResultHandler:(NetPingResultHandler _Nonnull)handler;


/*!
 @description
 stop ping
 */
- (void)netStopPing;


/*！
 @description
 get the ping status

 @return YES: now is doing ping;  NO: not pinging at the moment
 */
- (BOOL)isDoingPing;


#pragma mark - About traceroute
/*!
 @description
 
 @param host ip address or domain name
 @param handler traceroute detail information
 */
- (void)netStartTraceroute:(NSString *_Nonnull)host tracerouteResultHandler:(NetTracerouteResultHandler _Nonnull)handler;


/*!
 @description
 stop traceroute
 */
- (void)netStopTraceroute;


/*!
 @description
 get the traceroute status
 
 @return YES: now is doing traceroute;  NO: not doing traceroute at the moment
 */
- (BOOL)isDoingTraceroute;

#pragma mark - nslookup
/**
 @description

 @param domain domain
 @param handler nslookup results
 */
- (void)netLookupDomain:(NSString * _Nonnull)domain completeHandler:(NetLookupResultHandler _Nonnull)handler;

#pragma mark -About network info
- (NetWorkInfo * _Nullable)netGetNetworkInfo;

@end
