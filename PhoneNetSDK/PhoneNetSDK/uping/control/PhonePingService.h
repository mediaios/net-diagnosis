//
//  PhonePingService.h
//  PingDemo
//
//  Created by mediaios on 06/08/2018.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhonePing.h"
#import "PPingResModel.h"
#import "PReportPingModel.h"
#import "PhoneNetManager.h"

@interface PhonePingService : NSObject
+ (instancetype)shareInstance;
- (void)startPingHost:(NSString *)host packetCount:(int)count resultHandler:(NetPingResultHandler)handler;

- (void)uStopPing;
- (BOOL)uIsPing;

@end
