//
//  PhoneNetSDKHelper.h
//  PhoneNetSDK
//
//  Created by ethan on 2019/2/27.
//  Copyright © 2019 ucloud. All rights reserved.
//

#ifndef PhoneNetSDKHelper_h
#define PhoneNetSDKHelper_h
#import "PNetModel.h"


/**
 @brief This is an enumerated type that defines the log level
 
 @discussion When developing, it is recommended to set the log level of the SDK to `PhoneNetSDKLogLevel_DEBUG`, which is convenient for development and debugging. When you go online, change the level to a higher level of `PhoneNetSDKLogLevel_ERROR`.
 
 - PhoneNetSDKLogLevel_FATAL: FATAL level
 - PhoneNetSDKLogLevel_ERROR: ERROR level（If not set, the default is this level）
 - PhoneNetSDKLogLevel_WARN:  WARN level
 - PhoneNetSDKLogLevel_INFO:  INFO level
 - PhoneNetSDKLogLevel_DEBUG: DEBUG level
 */
typedef NS_ENUM(NSUInteger,PhoneNetSDKLogLevel)
{
    PhoneNetSDKLogLevel_FATAL,
    PhoneNetSDKLogLevel_ERROR,
    PhoneNetSDKLogLevel_WARN,
    PhoneNetSDKLogLevel_INFO,
    PhoneNetSDKLogLevel_DEBUG
};

#pragma mark -ping callback
typedef void(^NetPingResultHandler)(NSString *_Nullable pingres);

#pragma mark -tracert callback
typedef void(^NetTracerouteResultHandler)(NSString *_Nullable tracertRes ,NSString *_Nullable destIp);

#pragma mark -nslookup callback
typedef void (^NetLookupResultHandler)(NSMutableArray<DomainLookUpRes *>  *_Nullable lookupRes, PNError *_Nullable sdkError);

#pragma mark -portscan callback
typedef void (^NetPortScanHandler)(NSString * _Nullable port, BOOL isOpen, PNError * _Nullable sdkError);

#endif /* PhoneNetSDKHelper_h */
