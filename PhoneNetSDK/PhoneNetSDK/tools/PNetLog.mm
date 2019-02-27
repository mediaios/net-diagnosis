//
//  PNetLog.m
//  PhoneNetSDK
//
//  Created by ethan on 2019/2/27.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import "PNetLog.h"
#import "PhoneNetSDKConst.h"
#include "log4cplus_pn.h"


/*   define log level  */
int PhoneNetSDK_IOS_FLAG_FATAL = 0x10;
int PhoneNetSDK_IOS_FLAG_ERROR = 0x08;
int PhoneNetSDK_IOS_FLAG_WARN = 0x04;
int PhoneNetSDK_IOS_FLAG_INFO = 0x02;
int PhoneNetSDK_IOS_FLAG_DEBUG = 0x01;
int PhoneNetSDK_IOS_LOG_LEVEL = PhoneNetSDK_IOS_LOG_LEVEL = PhoneNetSDK_IOS_FLAG_FATAL|PhoneNetSDK_IOS_FLAG_ERROR;

@implementation PNetLog

+ (void)setSDKLogLevel:(PhoneNetSDKLogLevel)logLevel
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
@end
