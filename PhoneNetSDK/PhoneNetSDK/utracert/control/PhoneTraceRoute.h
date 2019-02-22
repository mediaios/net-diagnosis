//
//  PhoneTraceRoute.h
//  PingDemo
//
//  Created by ethan on 08/08/2018.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTracerRouteResModel.h"
#import "PhoneNetDiagnosisHelper.h"

const int kTracertRouteCount_noRes               = 5;     // 连续无响应的route个数
const int kTracertMaxTTL                         = 30;    // Max 30 hops（最多30跳）
const int kTracertSendIcmpPacketTimes            = 3;     // 对一个中间节点，发送2个icmp包
const int kIcmpPacketTimeoutTime                 = 300;   // ICMP包超时时间(ms)

@class PhoneTraceRoute;
@protocol PhoneTraceRouteDelegate<NSObject>
- (void)tracerouteWithUCTraceRoute:(PhoneTraceRoute *)ucTraceRoute tracertResult:(PTracerRouteResModel *)tracertRes;
- (void)tracerouteFinishedWithUCTraceRoute:(PhoneTraceRoute *)ucTraceRoute;
@optional


@end

@interface PhoneTraceRoute : NSObject
@property (nonatomic,strong) id<PhoneTraceRouteDelegate> delegate;

- (void)startTracerouteHost:(NSString *)host;

- (void)stopTracert;
- (BOOL)isTracert;
@end
