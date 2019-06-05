//
//  PNetLog.h
//  PhoneNetSDK
//
//  Created by mediaios on 2019/2/27.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhoneNetSDKHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface PNetLog : NSObject
+ (void)setSDKLogLevel:(PhoneNetSDKLogLevel)logLevel;
@end

NS_ASSUME_NONNULL_END
