//
//  PNDomainLook.h
//  PhoneNetSDK
//
//  Created by ethan on 2019/2/28.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhoneNetSDKHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface PNDomainLookup : NSObject
+ (instancetype)shareInstance;
- (void)lookupDomain:(NSString * _Nonnull)domain completeHandler:(NetLookupResultHandler _Nonnull)handler;
@end

NS_ASSUME_NONNULL_END
